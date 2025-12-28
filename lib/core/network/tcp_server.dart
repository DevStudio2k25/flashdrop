import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/device_info.dart';
import '../constants/network_constants.dart';

/// TCP Server for receiving connections and files
class TcpServer {
  ServerSocket? _serverSocket;
  Socket? _clientSocket;
  final int port;
  final DeviceInfo localDevice;

  final _connectionController = StreamController<Socket>.broadcast();
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _dataController = StreamController<List<int>>.broadcast();

  bool _isRunning = false;
  String? _connectedClientIp;

  TcpServer({required this.port, required this.localDevice});

  /// Stream of incoming connections
  Stream<Socket> get onConnection => _connectionController.stream;

  /// Stream of incoming messages
  Stream<Map<String, dynamic>> get onMessage => _messageController.stream;

  /// Stream of incoming raw data
  Stream<List<int>> get onData => _dataController.stream;

  /// Check if server is running
  bool get isRunning => _isRunning;

  /// Get connected client IP
  String? get connectedClientIp => _connectedClientIp;

  /// Start TCP server
  Future<void> start() async {
    if (_isRunning) {
      debugPrint('⚠️ [TcpServer] Server already running');
      return;
    }

    try {
      _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);

      _isRunning = true;
      debugPrint(
        '✅ [TcpServer] Server started on ${localDevice.ipAddress}:$port',
      );

      _serverSocket!.listen(
        _handleConnection,
        onError: (error) {
          debugPrint('❌ [TcpServer] Server error: $error');
        },
        onDone: () {
          debugPrint('🔴 [TcpServer] Server closed');
          _isRunning = false;
        },
      );
    } catch (e) {
      debugPrint('❌ [TcpServer] Failed to start server: $e');
      _isRunning = false;
      rethrow;
    }
  }

  /// Handle incoming connection
  void _handleConnection(Socket socket) {
    debugPrint(
      '🔗 [TcpServer] New connection from ${socket.remoteAddress.address}:${socket.remotePort}',
    );

    _clientSocket = socket;
    _connectedClientIp = socket.remoteAddress.address;
    _connectionController.add(socket);

    // Configure socket for optimal performance
    try {
      socket.setOption(SocketOption.tcpNoDelay, true);
    } catch (e) {
      debugPrint('⚠️ [TcpServer] Could not set socket options: $e');
    }

    // Buffer for incomplete messages
    String messageBuffer = '';

    socket.listen(
      (List<int> data) {
        // Check if this looks like JSON (starts with '{' or contains newline)
        if (data.isNotEmpty && (data[0] == 123 || data.contains(10))) {
          // Likely JSON message
          try {
            final String chunk = utf8.decode(data);
            messageBuffer += chunk;

            // Process complete messages (delimited by newline)
            while (messageBuffer.contains(NetworkConstants.messageDelimiter)) {
              final delimiterIndex = messageBuffer.indexOf(
                NetworkConstants.messageDelimiter,
              );
              final message = messageBuffer.substring(0, delimiterIndex);
              messageBuffer = messageBuffer.substring(delimiterIndex + 1);

              if (message.isNotEmpty) {
                try {
                  final json = jsonDecode(message) as Map<String, dynamic>;
                  _messageController.add(json);
                } catch (e) {
                  // Not JSON, treat as binary
                  _dataController.add(utf8.encode(message));
                }
              }
            }
          } catch (e) {
            // Failed to decode, treat as binary
            _dataController.add(data);
          }
        } else {
          // Binary data
          _dataController.add(data);
        }
      },
      onError: (error) {
        debugPrint('❌ [TcpServer] Socket error: $error');
        _handleDisconnection();
      },
      onDone: () {
        debugPrint('🔴 [TcpServer] Client disconnected');
        _handleDisconnection();
      },
    );
  }

  /// Handle client disconnection
  void _handleDisconnection() {
    _clientSocket?.destroy();
    _clientSocket = null;
    _connectedClientIp = null;
  }

  /// Send JSON message to connected client
  Future<void> sendMessage(Map<String, dynamic> message) async {
    if (_clientSocket == null) {
      throw Exception('No client connected');
    }

    try {
      final json = jsonEncode(message);
      final data = utf8.encode(json + NetworkConstants.messageDelimiter);
      _clientSocket!.add(data);
      await _clientSocket!.flush();
    } catch (e) {
      debugPrint('❌ [TcpServer] Failed to send message: $e');
      rethrow;
    }
  }

  /// Send raw data to connected client
  Future<void> sendData(List<int> data) async {
    if (_clientSocket == null) {
      throw Exception('No client connected');
    }

    try {
      _clientSocket!.add(data);
      await _clientSocket!.flush();
    } catch (e) {
      debugPrint('❌ [TcpServer] Failed to send data: $e');
      rethrow;
    }
  }

  /// Stop server
  Future<void> stop() async {
    if (!_isRunning) return;

    try {
      _clientSocket?.destroy();
      await _serverSocket?.close();
      _isRunning = false;
      _connectedClientIp = null;
      debugPrint('🔴 [TcpServer] Server stopped');
    } catch (e) {
      debugPrint('❌ [TcpServer] Error stopping server: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    stop();
    _connectionController.close();
    _messageController.close();
    _dataController.close();
  }
}
