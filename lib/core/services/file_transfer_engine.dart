import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../models/file_metadata.dart';
import '../models/transfer_task.dart';
import '../constants/network_constants.dart';
import '../services/connection_manager.dart';
import 'transfer_foreground_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

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

  // Write queues to prevent "async operation pending" on RandomAccessFile
  final Map<String, List<List<int>>> _writeQueues = {};
  final Map<String, bool> _isWriting = {};

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

    // Initialize foreground service (Android only)
    if (Platform.isAndroid) {
      await TransferForegroundService.initialize();
    }

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

    // Start foreground service and wake lock (Android only)
    if (Platform.isAndroid) {
      await WakelockPlus.enable();
      final firstTask = _activeTasks[_sendQueue.first];
      if (firstTask != null) {
        await TransferForegroundService.startService(
          fileName: firstTask.fileMetadata.name,
          totalFiles: _sendQueue.length,
        );
      }
    }

    while (_sendQueue.isNotEmpty) {
      final taskId = _sendQueue.first;
      await _sendSingleFile(taskId);
      _sendQueue.removeAt(0);
    }

    _isSending = false;
    debugPrint(
      '✅ [FileTransferEngine] All files sent, waiting for confirmations...',
    );

    // Wait for all tasks to be actually completed (ACK received)
    final sentTasks = _activeTasks.values
        .where((t) => t.direction == TransferDirection.send)
        .toList();

    if (sentTasks.isNotEmpty) {
      // Calculate dynamic timeout based on actual transfer speed
      // Use CONSERVATIVE approach: minimum speed + 50% buffer
      // This handles fluctuating network speeds
      final totalBytes = sentTasks.fold<int>(
        0,
        (sum, task) => sum + task.fileMetadata.size,
      );

      // Find MINIMUM speed (worst case) instead of average
      double minSpeed = double.infinity;
      for (final task in sentTasks) {
        if (task.speed > 0 && task.speed < minSpeed) {
          minSpeed = task.speed;
        }
      }

      // Use minimum speed if available, otherwise assume 2 MB/s (very conservative)
      final effectiveSpeed = minSpeed != double.infinity
          ? minSpeed
          : 2 * 1024 * 1024; // 2 MB/s default (very conservative)

      // Calculate timeout with 50% buffer for verification + ACK + speed fluctuation
      final estimatedSeconds = (totalBytes / effectiveSpeed * 1.5).ceil();
      final timeoutSeconds = 60 + estimatedSeconds; // Base 60s + estimated time

      debugPrint(
        '⏱️ [FileTransferEngine] ACK timeout: $timeoutSeconds sec for ${_formatBytes(totalBytes)} @ ${_formatSpeed(effectiveSpeed.toDouble())} (min speed)',
      );

      // Store task IDs to wait for (ONLY current batch)
      final waitingTaskIds = sentTasks.map((t) => t.id).toSet();

      final startWait = DateTime.now();
      while (waitingTaskIds.any((id) {
        final task = _activeTasks[id];
        return task != null && task.status == TransferStatus.verifying;
      })) {
        await Future.delayed(const Duration(milliseconds: 100));

        // Dynamic timeout
        if (DateTime.now().difference(startWait).inSeconds > timeoutSeconds) {
          debugPrint(
            '⚠️ [FileTransferEngine] ACK timeout after $timeoutSeconds seconds, marking as complete',
          );
          for (final taskId in waitingTaskIds) {
            final task = _activeTasks[taskId];
            if (task != null && task.status == TransferStatus.verifying) {
              _updateTaskStatus(taskId, TransferStatus.completed);
            }
          }
          break;
        }
      }
    }

    debugPrint('✅ [FileTransferEngine] Queue processing complete');

    // Stop foreground service and wake lock (Android only)
    if (Platform.isAndroid) {
      await TransferForegroundService.stopService();
      await WakelockPlus.disable();
    }
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
        // Check cancellation
        if (_activeTasks[taskId]?.status == TransferStatus.cancelled) {
          break;
        }

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

        // Update progress (throttle using constant)
        final now = DateTime.now();
        final lastUpdate = _lastProgressUpdate[taskId];
        if (lastUpdate == null ||
            now.difference(lastUpdate).inMilliseconds >
                NetworkConstants.progressUpdateThrottle) {
          _updateTaskProgress(taskId, bytesSent, speed);
          _lastProgressUpdate[taskId] = now;
        }
      }

      await randomAccessFile.close();
      debugPrint(
        '📤 [FileTransferEngine] All bytes sent. Waiting for receiver confirmation...',
      );

      // Met golden rule: Bytes sent != Complete.
      // Transition to VERIFYING state (UI shows "Waiting for confirmation...")
      _updateTaskStatus(taskId, TransferStatus.verifying);

      // We do NOT mark complete here. We wait for ACK.
    } catch (e) {
      await randomAccessFile.close();
      rethrow;
    }
  }

  // --- Receiver Logic ---

  /// Listen for incoming file data
  void _listenForFileData(String taskId) {
    if (_writeQueues.containsKey(taskId)) return;

    _writeQueues[taskId] = [];
    _isWriting[taskId] = false;

    void onData(List<int> data) {
      if (!_activeTasks.containsKey(taskId)) return;
      _writeQueues[taskId]?.add(data);
      _processWriteQueue(taskId);
    }

    _connectionManager.server?.onData.listen(onData);
    _connectionManager.client?.onData.listen(onData);
  }

  /// Process write queue sequentially to prevent concurrent write errors
  Future<void> _processWriteQueue(String taskId) async {
    if (_isWriting[taskId] == true) return;
    _isWriting[taskId] = true;

    try {
      final queue = _writeQueues[taskId];
      final file = _openFiles[taskId];
      final task = _activeTasks[taskId];

      if (queue == null || file == null || task == null) {
        _isWriting[taskId] = false;
        return;
      }

      while (queue.isNotEmpty) {
        final data = queue.removeAt(0); // FIFO

        await file.writeFrom(data);

        _receivedBytes[taskId] = (_receivedBytes[taskId] ?? 0) + data.length;

        // Progress Update
        final bytesReceived = _receivedBytes[taskId]!;

        // Calculate Speed (Average from start)
        final elapsed = DateTime.now()
            .difference(task.startTime)
            .inMilliseconds;
        final speed = elapsed > 0 ? (bytesReceived / elapsed) * 1000.0 : 0.0;

        final now = DateTime.now();
        final lastUpdate = _lastProgressUpdate[taskId];
        if (lastUpdate == null ||
            now.difference(lastUpdate).inMilliseconds >
                NetworkConstants.progressUpdateThrottle) {
          _updateTaskProgress(taskId, bytesReceived, speed);
          _lastProgressUpdate[taskId] = now;
        }

        // STRICT BYTE CHECK: Only mark complete if bytes exactly match
        // Overflow protection: If we get MORE than expected, something is wrong.
        if (bytesReceived > task.fileMetadata.size) {
          debugPrint(
            '❌ [FileTransferEngine] ERROR: Received more bytes than expected!',
          );
          await _handleTransferFailure(taskId, 'Size Mismatch (Overflow)');
          return;
        }

        // Completion Check
        if (bytesReceived == task.fileMetadata.size) {
          await _completeFileReception(taskId);
          return; // Stop processing this task
        }
      }
    } catch (e) {
      debugPrint('❌ [FileTransferEngine] Write/Queue error: $e');
    } finally {
      _isWriting[taskId] = false;
      // Check if more items arrived while processing (recursively process rest)
      if (_writeQueues[taskId] != null && _writeQueues[taskId]!.isNotEmpty) {
        _processWriteQueue(taskId);
      }
    }
  }

  /// Complete file reception
  Future<void> _completeFileReception(String taskId) async {
    debugPrint('🏁 [FileTransferEngine] Bytes Downloaded. Verifying...');

    // Update status to VERIFYING (UI shows "Verifying...")
    _updateTaskStatus(taskId, TransferStatus.verifying);

    // CRITICAL: Flush and close file to ensure all data is written to disk
    final fileRef = _openFiles[taskId];
    if (fileRef != null) {
      await fileRef.flush(); // Ensure all buffered data is written
      await fileRef.close();
      debugPrint('💾 [FileTransferEngine] File flushed and closed: $taskId');
    }
    _openFiles.remove(taskId);
    _writeQueues.remove(taskId);

    final task = _activeTasks[taskId];
    if (task == null) return;

    // 🔒 SAFETY CHECK: OPTION A - SIZE VERIFY
    // Verify exact file size on disk matches metadata
    final savedFile = File(task.savePath!);
    if (!savedFile.existsSync()) {
      _updateTaskStatus(
        taskId,
        TransferStatus.failed,
        errorMessage: 'File missing after download',
      );
      return;
    }

    final savedSize = await savedFile.length();
    final expectedSize = task.fileMetadata.size;

    if (savedSize != expectedSize) {
      debugPrint(
        '❌ [FileTransferEngine] INTEGRITY CHECK FAILED: Expected $expectedSize, Got $savedSize',
      );
      _updateTaskStatus(
        taskId,
        TransferStatus.failed,
        errorMessage: 'Integrity Check Failed (Size Mismatch)',
      );
      return;
    }

    debugPrint(
      '🔐 [FileTransferEngine] Integrity Check Passed. Marking Complete.',
    );

    _updateTaskStatus(taskId, TransferStatus.completed);
    _fileReceivedController.add(task);
    debugPrint(
      '✅ [FileTransferEngine] File written to disk: ${task.fileMetadata.name}',
    );

    // Send ACK
    final ackMsg = {'command': 'FILE_TRANSFER_ACK', 'fileId': taskId};

    debugPrint('📤 [FileTransferEngine] Sending ACK for: $taskId');
    try {
      if (_connectionManager.server != null) {
        await _connectionManager.server!.sendMessage(ackMsg);
        debugPrint('✅ [FileTransferEngine] ACK sent via server');
      } else if (_connectionManager.client != null) {
        await _connectionManager.client!.sendMessage(ackMsg);
        debugPrint('✅ [FileTransferEngine] ACK sent via client');
      } else {
        debugPrint('❌ [FileTransferEngine] No connection to send ACK!');
      }
    } catch (e) {
      debugPrint('❌ [FileTransferEngine] Failed to send ACK: $e');
    }
  }

  /// Handle failures helper
  Future<void> _handleTransferFailure(String taskId, String error) async {
    final file = _openFiles[taskId];
    await file?.close();
    _openFiles.remove(taskId);
    _writeQueues.remove(taskId);
    _updateTaskStatus(taskId, TransferStatus.failed, errorMessage: error);
  }

  /// Handle incoming messages
  void _handleIncomingMessage(Map<String, dynamic> message) {
    final command = message['command'] as String?;

    debugPrint('📥 [FileTransferEngine] Received message: $command');

    if (command == 'FILE_TRANSFER_ACK') {
      debugPrint('🔔 [FileTransferEngine] ACK message detected!');
      _handleTransferAck(message);
      return;
    }

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

      // Auto-accept
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

      // Init Progress tracking
      _updateTaskStatus(task.id, TransferStatus.inProgress, savePath: filePath);

      debugPrint('📁 [FileTransferEngine] Ready to receive: $filePath');

      // Start listening for data
      _listenForFileData(task.id);
    } catch (e) {
      debugPrint('❌ [FileTransferEngine] Accept failed: $e');
    }
  }

  /// Handle file acceptance (Sender side)
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

  /// Handle file completion (Old logic fallback)
  void _handleFileComplete(Map<String, dynamic> message) {
    // We prefer TransferAck now, but this is backup
    // final fileId = message['fileId'] as String;
    // _updateTaskStatus(fileId, TransferStatus.completed); // Disabled to enforce ACK check
  }

  // Handle ACK from receiver (Sender side confirmation)
  void _handleTransferAck(Map<String, dynamic> message) {
    final fileId = message['fileId'] as String;
    debugPrint('✅ [FileTransferEngine] Receiver confirmed: $fileId');
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

    // Prevent overwriting completion unless explicit
    if ((task.isComplete) && status != TransferStatus.completed) return;

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

  void _updateTaskProgress(String taskId, int bytesTransferred, double speed) {
    final task = _activeTasks[taskId];
    if (task == null) return;

    final updatedTask = task.copyWith(
      bytesTransferred: bytesTransferred,
      speed: speed,
    );

    _activeTasks[taskId] = updatedTask;
    _taskUpdateController.add(updatedTask);

    // Update foreground service notification (Android only)
    if (Platform.isAndroid && TransferForegroundService.isRunning) {
      final progress = (updatedTask.progress * 100).toInt();
      final speedStr = _formatSpeed(speed);
      TransferForegroundService.updateProgress(
        fileName: updatedTask.fileMetadata.name,
        progress: progress,
        speed: speedStr,
      );
    }
  }

  /// Format speed for display
  String _formatSpeed(double bytesPerSecond) {
    if (bytesPerSecond < 1024) {
      return '${bytesPerSecond.toStringAsFixed(0)} B/s';
    }
    if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
    }
    return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }

  /// Format bytes for display
  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
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
        // Fallback
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
