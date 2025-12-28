import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../models/file_metadata.dart';
import '../models/transfer_task.dart';
import '../constants/network_constants.dart';
import '../services/connection_manager.dart';

/// Enhanced file transfer engine with queue and real progress
class FileTransferEngine {
  static final FileTransferEngine _instance = FileTransferEngine._internal();
  factory FileTransferEngine() => _instance;
  FileTransferEngine._internal();

  final ConnectionManager _connectionManager = ConnectionManager();

  // Active transfers
  final Map<String, TransferTask> _activeTasks = {};
  final Map<String, File> _pendingFiles = {}; // Store file references
  final Map<String, RandomAccessFile> _openFiles = {};
  final Map<String, int> _receivedBytes = {};
  final Map<String, DateTime> _lastProgressUpdate = {};

  // Transfer queue
  final List<String> _sendQueue = [];
  bool _isSending = false;

  final _taskUpdateController = StreamController<TransferTask>.broadcast();
  final _fileReceivedController = StreamController<TransferTask>.broadcast();

  /// Stream of transfer task updates
  Stream<TransferTask> get onTaskUpdate => _taskUpdateController.stream;

  /// Stream of completed file receptions
  Stream<TransferTask> get onFileReceived => _fileReceivedController.stream;

  /// Get all active tasks
  List<TransferTask> get activeTasks => _activeTasks.values.toList();

  /// Get sending tasks
  List<TransferTask> get sendingTasks => _activeTasks.values
      .where((t) => t.direction == TransferDirection.send)
      .toList();

  /// Get receiving tasks
  List<TransferTask> get receivingTasks => _activeTasks.values
      .where((t) => t.direction == TransferDirection.receive)
      .toList();

  /// Initialize transfer engine
  Future<void> initialize() async {
    debugPrint('🔧 [FileTransferEngine] Initializing...');

    // Listen for incoming messages from connection manager (Unified Stream)
    _connectionManager.messageStream.listen((message) {
      _handleIncomingMessage(message);
    });

    debugPrint('✅ [FileTransferEngine] Initialized');
  }

  /// Add files to send queue
  Future<void> addFilesToQueue(List<File> files) async {
    for (final file in files) {
      final fileStats = await file.stat();
      final fileName = path.basename(file.path);

      final metadata = FileMetadata(
        id: const Uuid().v4(),
        name: fileName,
        size: fileStats.size,
        mimeType: _getMimeType(fileName),
      );

      final task = TransferTask(
        id: metadata.id,
        fileMetadata: metadata,
        direction: TransferDirection.send,
        status: TransferStatus.pending,
        startTime: DateTime.now(),
      );

      _activeTasks[task.id] = task;
      _pendingFiles[task.id] = file;
      _sendQueue.add(task.id);
      _taskUpdateController.add(task);

      debugPrint('📋 [FileTransferEngine] Added to queue: ${metadata.name}');
    }
  }

  /// Start sending files from queue
  Future<void> startSendingQueue() async {
    if (_isSending) {
      debugPrint('⚠️ [FileTransferEngine] Already sending');
      return;
    }

    if (_sendQueue.isEmpty) {
      debugPrint('⚠️ [FileTransferEngine] Queue is empty');
      return;
    }

    _isSending = true;
    debugPrint('🚀 [FileTransferEngine] Starting queue processing...');

    while (_sendQueue.isNotEmpty) {
      final taskId = _sendQueue.first;
      await _sendSingleFile(taskId);
      _sendQueue.removeAt(0);
    }

    _isSending = false;
    debugPrint('✅ [FileTransferEngine] Queue processing complete');
  }

  /// Send single file
  Future<void> _sendSingleFile(String taskId) async {
    final task = _activeTasks[taskId];
    final file = _pendingFiles[taskId];

    if (task == null || file == null) return;

    try {
      debugPrint('📤 [FileTransferEngine] Sending: ${task.fileMetadata.name}');

      // Send file offer
      final message = {
        'command': NetworkConstants.cmdFileOffer,
        'metadata': task.fileMetadata.toJson(),
      };

      if (_connectionManager.server != null) {
        await _connectionManager.server!.sendMessage(message);
      } else if (_connectionManager.client != null) {
        await _connectionManager.client!.sendMessage(message);
      }

      // Wait for acceptance (will be handled in message listener)
      await _waitForAcceptance(taskId);

      // Start actual file transfer
      await _transferFileChunks(taskId, file);

      debugPrint('✅ [FileTransferEngine] File sent: ${task.fileMetadata.name}');
    } catch (e) {
      debugPrint('❌ [FileTransferEngine] Send failed: $e');
      _updateTaskStatus(
        taskId,
        TransferStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  /// Wait for file acceptance
  Future<void> _waitForAcceptance(String taskId) async {
    final completer = Completer<void>();
    Timer? timeout;

    // Listen for acceptance
    final subscription = _taskUpdateController.stream.listen((task) {
      if (task.id == taskId && task.status == TransferStatus.inProgress) {
        timeout?.cancel();
        completer.complete();
      }
    });

    // Timeout after 30 seconds
    timeout = Timer(const Duration(seconds: 30), () {
      if (!completer.isCompleted) {
        completer.completeError('File acceptance timeout');
      }
    });

    try {
      await completer.future;
    } finally {
      subscription.cancel();
      timeout.cancel();
    }
  }

  /// Transfer file in chunks with real progress
  Future<void> _transferFileChunks(String taskId, File file) async {
    final task = _activeTasks[taskId];
    if (task == null) return;

    final randomAccessFile = await file.open(mode: FileMode.read);
    final fileSize = task.fileMetadata.size;
    int bytesSent = 0;
    final startTime = DateTime.now();

    try {
      while (bytesSent < fileSize) {
        final chunkSize = (fileSize - bytesSent) < NetworkConstants.chunkSize
            ? fileSize - bytesSent
            : NetworkConstants.chunkSize;

        final chunk = await randomAccessFile.read(chunkSize);

        // Send chunk
        if (_connectionManager.server != null) {
          await _connectionManager.server!.sendData(chunk);
        } else if (_connectionManager.client != null) {
          await _connectionManager.client!.sendData(chunk);
        }

        bytesSent += chunk.length;

        // Calculate speed
        final elapsed = DateTime.now().difference(startTime).inMilliseconds;
        final speed = elapsed > 0 ? (bytesSent / elapsed) * 1000.0 : 0.0;

        // Update progress (throttle to every 100ms)
        final now = DateTime.now();
        final lastUpdate = _lastProgressUpdate[taskId];
        if (lastUpdate == null ||
            now.difference(lastUpdate).inMilliseconds > 100) {
          _updateTaskProgress(taskId, bytesSent, speed);
          _lastProgressUpdate[taskId] = now;
        }

        debugPrint(
          '📊 [FileTransferEngine] Progress: ${(bytesSent / fileSize * 100).toStringAsFixed(1)}%',
        );
      }

      await randomAccessFile.close();

      // Send completion message
      final completeMsg = {
        'command': NetworkConstants.cmdFileComplete,
        'fileId': taskId,
      };

      if (_connectionManager.server != null) {
        await _connectionManager.server!.sendMessage(completeMsg);
      } else if (_connectionManager.client != null) {
        await _connectionManager.client!.sendMessage(completeMsg);
      }

      _updateTaskStatus(taskId, TransferStatus.completed);
    } catch (e) {
      await randomAccessFile.close();
      rethrow;
    }
  }

  /// Handle incoming messages
  void _handleIncomingMessage(Map<String, dynamic> message) {
    final command = message['command'] as String?;

    switch (command) {
      case NetworkConstants.cmdFileOffer:
        _handleFileOffer(message);
        break;
      case NetworkConstants.cmdFileAccept:
        _handleFileAccept(message);
        break;
      case NetworkConstants.cmdFileReject:
        _handleFileReject(message);
        break;
      case NetworkConstants.cmdFileComplete:
        _handleFileComplete(message);
        break;
      default:
        break;
    }
  }

  /// Handle file offer
  void _handleFileOffer(Map<String, dynamic> message) async {
    try {
      final metadataJson = message['metadata'] as Map<String, dynamic>;
      final metadata = FileMetadata.fromJson(metadataJson);

      debugPrint('📥 [FileTransferEngine] File offer: ${metadata.name}');

      final task = TransferTask(
        id: metadata.id,
        fileMetadata: metadata,
        direction: TransferDirection.receive,
        status: TransferStatus.pending,
        startTime: DateTime.now(),
      );

      _activeTasks[task.id] = task;
      _taskUpdateController.add(task);

      // Auto-accept and prepare to receive
      await _acceptAndPrepareReceive(task);
    } catch (e) {
      debugPrint('❌ [FileTransferEngine] File offer failed: $e');
    }
  }

  /// Accept file and prepare to receive
  Future<void> _acceptAndPrepareReceive(TransferTask task) async {
    try {
      // Send acceptance
      final message = {
        'command': NetworkConstants.cmdFileAccept,
        'fileId': task.id,
      };

      if (_connectionManager.server != null) {
        await _connectionManager.server!.sendMessage(message);
      } else if (_connectionManager.client != null) {
        await _connectionManager.client!.sendMessage(message);
      }

      // Prepare file for writing
      final downloadsDir = await _getDownloadsDirectory();
      final filePath = path.join(downloadsDir.path, task.fileMetadata.name);
      final file = File(filePath);

      final randomAccessFile = await file.open(mode: FileMode.write);
      _openFiles[task.id] = randomAccessFile;
      _receivedBytes[task.id] = 0;

      _updateTaskStatus(task.id, TransferStatus.inProgress, savePath: filePath);

      debugPrint('📁 [FileTransferEngine] Ready to receive: $filePath');

      // Start listening for data
      _listenForFileData(task.id);
    } catch (e) {
      debugPrint('❌ [FileTransferEngine] Accept failed: $e');
    }
  }

  /// Listen for incoming file data
  void _listenForFileData(String taskId) {
    // Listen for raw data from server
    _connectionManager.server?.onData.listen((data) {
      _writeFileChunk(taskId, data);
    });

    // Listen for raw data from client
    _connectionManager.client?.onData.listen((data) {
      _writeFileChunk(taskId, data);
    });
  }

  /// Write file chunk
  Future<void> _writeFileChunk(String taskId, List<int> data) async {
    final file = _openFiles[taskId];
    final task = _activeTasks[taskId];

    if (file == null || task == null) return;

    try {
      await file.writeFrom(data);
      _receivedBytes[taskId] = (_receivedBytes[taskId] ?? 0) + data.length;

      final bytesReceived = _receivedBytes[taskId]!;
      final speed = 0.0; // Calculate from timing

      _updateTaskProgress(taskId, bytesReceived, speed);

      // Check if complete
      if (bytesReceived >= task.fileMetadata.size) {
        await _completeFileReception(taskId);
      }
    } catch (e) {
      debugPrint('❌ [FileTransferEngine] Write chunk failed: $e');
    }
  }

  /// Complete file reception
  Future<void> _completeFileReception(String taskId) async {
    final file = _openFiles[taskId];
    await file?.close();
    _openFiles.remove(taskId);

    final task = _activeTasks[taskId];
    if (task != null) {
      _updateTaskStatus(taskId, TransferStatus.completed);
      _fileReceivedController.add(task);
      debugPrint(
        '✅ [FileTransferEngine] File received: ${task.fileMetadata.name}',
      );
    }
  }

  /// Handle file acceptance
  void _handleFileAccept(Map<String, dynamic> message) {
    final fileId = message['fileId'] as String;
    _updateTaskStatus(fileId, TransferStatus.inProgress);
    debugPrint('✅ [FileTransferEngine] File accepted: $fileId');
  }

  /// Handle file rejection
  void _handleFileReject(Map<String, dynamic> message) {
    final fileId = message['fileId'] as String;
    _updateTaskStatus(fileId, TransferStatus.cancelled);
  }

  /// Handle file completion
  void _handleFileComplete(Map<String, dynamic> message) {
    final fileId = message['fileId'] as String;
    _updateTaskStatus(fileId, TransferStatus.completed);
  }

  /// Update task status
  void _updateTaskStatus(
    String taskId,
    TransferStatus status, {
    String? errorMessage,
    String? savePath,
  }) {
    final task = _activeTasks[taskId];
    if (task == null) return;

    final updatedTask = task.copyWith(
      status: status,
      endTime:
          status == TransferStatus.completed ||
              status == TransferStatus.failed ||
              status == TransferStatus.cancelled
          ? DateTime.now()
          : null,
      errorMessage: errorMessage,
      savePath: savePath,
    );

    _activeTasks[taskId] = updatedTask;
    _taskUpdateController.add(updatedTask);
  }

  /// Update task progress
  void _updateTaskProgress(String taskId, int bytesTransferred, double speed) {
    final task = _activeTasks[taskId];
    if (task == null) return;

    final updatedTask = task.copyWith(
      bytesTransferred: bytesTransferred,
      speed: speed,
    );

    _activeTasks[taskId] = updatedTask;
    _taskUpdateController.add(updatedTask);
  }

  String? _customSavePath;

  void setCustomDownloadPath(String path) {
    _customSavePath = path;
    debugPrint('📂 [FileTransferEngine] Custom save path set to: $path');
  }

  /// Get downloads directory
  Future<Directory> _getDownloadsDirectory() async {
    // 1. Use Custom Path if set
    if (_customSavePath != null) {
      final dir = Directory(_customSavePath!);
      if (await dir.exists()) return dir;
      try {
        await dir.create(recursive: true);
        return dir;
      } catch (e) {
        debugPrint('⚠️ [FileTransferEngine] Failed to create custom dir: $e');
      }
    }

    // 2. Default Fallback
    Directory? dir;
    if (Platform.isAndroid) {
      dir = Directory('/storage/emulated/0/Download/FlashDrop');
    } else {
      // Windows
      final home = Platform.environment['USERPROFILE'] ?? '';
      dir = Directory('$home\\Downloads\\FlashDrop');
    }

    if (!await dir.exists()) {
      try {
        await dir.create(recursive: true);
      } catch (e) {
        debugPrint(
          '⚠️ [FileTransferEngine] Failed to create FlashDrop folder: $e',
        );
        // Fallback to root Downloads if creation fails
        if (Platform.isAndroid) {
          return Directory('/storage/emulated/0/Download');
        } else {
          final home = Platform.environment['USERPROFILE'] ?? '';
          return Directory('$home\\Downloads');
        }
      }
    }
    return dir;
  }

  /// Get MIME type
  String _getMimeType(String fileName) {
    final ext = path.extension(fileName).toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.pdf':
        return 'application/pdf';
      case '.mp4':
        return 'video/mp4';
      case '.mp3':
        return 'audio/mp3';
      default:
        return 'application/octet-stream';
    }
  }

  /// Clear completed tasks
  void clearCompletedTasks() {
    _activeTasks.removeWhere((_, task) => task.isComplete || task.hasFailed);
  }

  /// Dispose resources
  void dispose() {
    for (var file in _openFiles.values) {
      file.close();
    }
    _openFiles.clear();
    _activeTasks.clear();
    _pendingFiles.clear();
    _sendQueue.clear();
    _receivedBytes.clear();
    _lastProgressUpdate.clear();
    _taskUpdateController.close();
    _fileReceivedController.close();
  }
}
