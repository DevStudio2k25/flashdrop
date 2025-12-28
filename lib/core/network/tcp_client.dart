import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/device_info.dart';
import '../constants/network_constants.dart';

/// TCP Client for connecting to server and sending files
class TcpClient {
  Socket? _socket;
  final DeviceInfo remoteDevice;

  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _dataController = StreamController<List<int>>.broadcast();

  bool _isConnected = false;
  String messageBuffer = '';

  TcpClient({required this.remoteDevice});

  /// Stream of incoming messages
  Stream<Map<String, dynamic>> get onMessage => _messageController.stream;

  /// Stream of incoming raw data
  Stream<List<int>> get onData => _dataController.stream;

  /// Check if connected
  bool get isConnected => _isConnected;

  /// Connect to remote server
  Future<void> connect() async {
    if (_isConnected) {
      debugPrint('⚠️ [TcpClient] Already connected');
      return;
    }

    try {
      debugPrint(
        '🔗 [TcpClient] Connecting to ${remoteDevice.ipAddress}:${remoteDevice.port}...',
      );

      _socket = await Socket.connect(
        remoteDevice.ipAddress,
        remoteDevice.port,
        timeout: NetworkConstants.socketTimeout,
      );

      _isConnected = true;
      debugPrint('✅ [TcpClient] Connected to ${remoteDevice.name}');

      // Configure socket for optimal performance
      try {
        _socket!.setOption(SocketOption.tcpNoDelay, true);
      } catch (e) {
        debugPrint('⚠️ [TcpClient] Could not set socket options: $e');
      }

      _socket!.listen(
        (List<int> data) {
          // Check if this looks like JSON (starts with '{' or contains newline)
          if (data.isNotEmpty && (data[0] == 123 || data.contains(10))) {
            // Likely JSON message
            try {
              final String chunk = utf8.decode(data);
              messageBuffer += chunk;

              // Process complete messages
              while (messageBuffer.contains(
                NetworkConstants.messageDelimiter,
              )) {
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
          debugPrint('❌ [TcpClient] Socket error: $error');
          _handleDisconnection();
        },
        onDone: () {
          debugPrint('🔴 [TcpClient] Disconnected from server');
          _handleDisconnection();
        },
      );
    } catch (e) {
      debugPrint('❌ [TcpClient] Connection failed: $e');
      _isConnected = false;
      rethrow;
    }
  }

  /// Handle disconnection
  void _handleDisconnection() {
    _isConnected = false;
    _socket?.destroy();
    _socket = null;
  }

  /// Send JSON message to server
  Future<void> sendMessage(Map<String, dynamic> message) async {
    if (!_isConnected || _socket == null) {
      throw Exception('Not connected to server');
    }

    try {
      final json = jsonEncode(message);
      final data = utf8.encode(json + NetworkConstants.messageDelimiter);
      _socket!.add(data);
      await _socket!.flush().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('⚠️ [TcpClient] Flush timeout for message');
        },
      );
    } catch (e) {
      debugPrint('❌ [TcpClient] Failed to send message: $e');
      rethrow;
    }
  }

  /// Send raw data to server
  Future<void> sendData(List<int> data) async {
    if (!_isConnected || _socket == null) {
      throw Exception('Not connected to server');
    }

    try {
      _socket!.add(data);
      await _socket!.flush().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('⚠️ [TcpClient] Flush timeout for data');
        },
      );
    } catch (e) {
      debugPrint('❌ [TcpClient] Failed to send data: $e');
      rethrow;
    }
  }

  /// Disconnect from server
  Future<void> disconnect() async {
    if (!_isConnected) return;

    try {
      await _socket?.close();
      _isConnected = false;
      debugPrint('🔴 [TcpClient] Disconnected');
    } catch (e) {
      debugPrint('❌ [TcpClient] Error disconnecting: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _messageController.close();
    _dataController.close();
  }
}
