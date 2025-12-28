import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

/// Simple HTTP-based file transfer service
class HttpFileTransferService {
  HttpServer? _server;
  String? _localIp;
  static const int _port = 8080;

  final _onFileReceivedController = StreamController<File>.broadcast();
  Stream<File> get onFileReceived => _onFileReceivedController.stream;

  final _onProgressController = StreamController<TransferProgress>.broadcast();
  Stream<TransferProgress> get onProgress => _onProgressController.stream;

  final _onConnectionReceivedController = StreamController<String>.broadcast();
  Stream<String> get onConnectionReceived =>
      _onConnectionReceivedController.stream;

  /// Get local IP
  String? get localIp => _localIp;

  /// Start HTTP server (for receiver)
  Future<void> startServer(String localIp) async {
    _localIp = localIp;
    debugPrint('🚀 [HTTP] Starting server on $_localIp:$_port');

    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(_corsMiddleware())
        .addHandler(_router);

    _server = await shelf_io.serve(handler, _localIp!, _port);
    debugPrint('✅ [HTTP] Server running at http://$_localIp:$_port');
  }

  /// CORS middleware
  Middleware _corsMiddleware() {
    return (Handler handler) {
      return (Request request) async {
        if (request.method == 'OPTIONS') {
          return Response.ok('', headers: _corsHeaders);
        }
        final response = await handler(request);
        return response.change(headers: _corsHeaders);
      };
    };
  }

  Map<String, String> get _corsHeaders => {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Content-Length, File-Name',
  };

  /// Route handler
  Future<Response> _router(Request request) async {
    if (request.url.path == 'upload' && request.method == 'POST') {
      return await _handleFileUpload(request);
    } else if (request.url.path == 'ping' && request.method == 'GET') {
      return Response.ok(jsonEncode({'status': 'ready'}));
    } else if (request.url.path == 'connect' && request.method == 'POST') {
      return await _handleConnect(request);
    }
    return Response.notFound('Not found');
  }

  /// Handle connection request
  Future<Response> _handleConnect(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      final senderIp = data['ip'] as String;

      debugPrint('🤝 [HTTP] Connection request from $senderIp');

      // Notify listeners about incoming connection
      _onConnectionReceivedController.add(senderIp);

      return Response.ok(jsonEncode({'status': 'connected'}));
    } catch (e) {
      debugPrint('❌ [HTTP] Connection error: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }

  /// Handle file upload
  Future<Response> _handleFileUpload(Request request) async {
    try {
      debugPrint('📥 [HTTP] Receiving file...');

      // Get filename from header
      final fileName = request.headers['file-name'] ?? 'received_file';
      final contentLength =
          int.tryParse(request.headers['content-length'] ?? '0') ?? 0;

      debugPrint('📄 [HTTP] File name: $fileName');
      debugPrint(
        '📦 [HTTP] Size: ${(contentLength / 1024 / 1024).toStringAsFixed(2)} MB',
      );

      // Read file data with progress
      final chunks = <List<int>>[];
      int bytesReceived = 0;

      await for (final chunk in request.read()) {
        chunks.add(chunk);
        bytesReceived += chunk.length;

        // Emit progress
        _onProgressController.add(
          TransferProgress(
            fileName: fileName,
            bytesTransferred: bytesReceived,
            totalBytes: contentLength,
            isReceiving: true,
          ),
        );
      }

      final fileData = chunks.expand((x) => x).toList();
      debugPrint('✅ [HTTP] File received: ${fileData.length} bytes');

      // Determine file type and create organized folder structure
      final fileExtension = fileName.split('.').last.toLowerCase();
      final category = _getCategoryForFile(fileExtension);

      // Create organized directory based on platform
      Directory baseDir;
      if (Platform.isAndroid) {
        baseDir = Directory('/storage/emulated/0/Download/FlashDrop');
      } else if (Platform.isWindows) {
        final userProfile = Platform.environment['USERPROFILE'] ?? '';
        baseDir = Directory('$userProfile\\Downloads\\FlashDrop');
      } else {
        // macOS, Linux, etc.
        final home = Platform.environment['HOME'] ?? '';
        baseDir = Directory('$home/Downloads/FlashDrop');
      }

      final categoryDir = Directory(path.join(baseDir.path, category));

      if (!await categoryDir.exists()) {
        await categoryDir.create(recursive: true);
      }

      final filePath = path.join(categoryDir.path, fileName);
      final file = File(filePath);
      await file.writeAsBytes(fileData);

      debugPrint('💾 [HTTP] File saved: $filePath');

      // Notify listeners
      _onFileReceivedController.add(file);

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'File received successfully',
          'path': filePath,
          'category': category,
        }),
      );
    } catch (e) {
      debugPrint('❌ [HTTP] Error receiving file: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }

  /// Get category folder for file type
  String _getCategoryForFile(String extension) {
    // Images
    if ([
      'jpg',
      'jpeg',
      'png',
      'gif',
      'bmp',
      'webp',
      'svg',
    ].contains(extension)) {
      return 'Images';
    }
    // Videos
    if (['mp4', 'avi', 'mkv', 'mov', 'wmv', 'flv', '3gp'].contains(extension)) {
      return 'Videos';
    }
    // Audio
    if ([
      'mp3',
      'wav',
      'flac',
      'aac',
      'm4a',
      'ogg',
      'wma',
    ].contains(extension)) {
      return 'Audio';
    }
    // Documents
    if (['pdf', 'doc', 'docx', 'txt', 'rtf', 'odt'].contains(extension)) {
      return 'Documents';
    }
    // Spreadsheets
    if (['xls', 'xlsx', 'csv', 'ods'].contains(extension)) {
      return 'Spreadsheets';
    }
    // Presentations
    if (['ppt', 'pptx', 'odp'].contains(extension)) {
      return 'Presentations';
    }
    // Archives
    if (['zip', 'rar', '7z', 'tar', 'gz'].contains(extension)) {
      return 'Archives';
    }
    // APK/Apps
    if (['apk', 'aar', 'jar'].contains(extension)) {
      return 'Apps';
    }
    // Code
    if ([
      'dart',
      'java',
      'py',
      'js',
      'ts',
      'cpp',
      'c',
      'h',
    ].contains(extension)) {
      return 'Code';
    }
    // Others
    return 'Others';
  }

  /// Send file to receiver (for sender)
  Future<void> sendFile(String receiverIp, File file) async {
    try {
      final url = 'http://$receiverIp:$_port/upload';
      debugPrint('📤 [HTTP] Sending file to $url');

      final fileName = path.basename(file.path);
      final fileSize = await file.length();

      debugPrint('📄 [HTTP] File: $fileName');
      debugPrint(
        '📦 [HTTP] Size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB',
      );

      // Read file bytes
      final bytes = await file.readAsBytes();

      // Emit initial progress
      _onProgressController.add(
        TransferProgress(
          fileName: fileName,
          bytesTransferred: 0,
          totalBytes: fileSize,
          isReceiving: false,
        ),
      );

      // Send file via simple POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/octet-stream',
          'file-name': fileName,
          'Content-Length': fileSize.toString(),
        },
        body: bytes,
      );

      if (response.statusCode == 200) {
        debugPrint('✅ [HTTP] File sent successfully!');

        // Emit completion progress
        _onProgressController.add(
          TransferProgress(
            fileName: fileName,
            bytesTransferred: fileSize,
            totalBytes: fileSize,
            isReceiving: false,
          ),
        );
      } else {
        debugPrint('❌ [HTTP] Upload failed: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        throw Exception(
          'Upload failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('❌ [HTTP] Error sending file: $e');
      rethrow;
    }
  }

  /// Check if receiver is ready
  Future<bool> checkConnection(String receiverIp) async {
    try {
      final url = 'http://$receiverIp:$_port/ping';
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Stop server
  Future<void> stopServer() async {
    debugPrint('⏹️ [HTTP] Stopping server...');
    await _server?.close();
    _server = null;
    debugPrint('✅ [HTTP] Server stopped');
  }

  /// Notify peer about connection
  Future<void> notifyConnection(String receiverIp) async {
    try {
      final url = 'http://$receiverIp:$_port/connect';
      debugPrint('🤝 [HTTP] Notifying peer at $url');

      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'ip': _localIp}),
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        debugPrint('✅ [HTTP] Peer notified successfully');
      }
    } catch (e) {
      debugPrint('⚠️ [HTTP] Failed to notify peer: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _onFileReceivedController.close();
    _onProgressController.close();
    _onConnectionReceivedController.close();
  }
}

/// Transfer progress data
class TransferProgress {
  final String fileName;
  final int bytesTransferred;
  final int totalBytes;
  final bool isReceiving;

  TransferProgress({
    required this.fileName,
    required this.bytesTransferred,
    required this.totalBytes,
    required this.isReceiving,
  });

  double get progress => totalBytes > 0 ? bytesTransferred / totalBytes : 0.0;
}
