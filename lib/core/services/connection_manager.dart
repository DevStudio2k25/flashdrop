import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/device_info.dart';
import '../network/tcp_server.dart';
import '../network/tcp_client.dart';
import '../services/device_service.dart';
import '../services/network_scanner.dart';
import '../constants/network_constants.dart';

/// Connection state
enum ConnectionState { disconnected, connecting, connected, error }

/// Connection manager - handles TCP connections
class ConnectionManager {
  static final ConnectionManager _instance = ConnectionManager._internal();
  factory ConnectionManager() => _instance;
  ConnectionManager._internal();

  final DeviceService _deviceService = DeviceService();
  final NetworkScanner _networkScanner = NetworkScanner();

  TcpServer? _server;
  TcpClient? _client;

  ConnectionState _state = ConnectionState.disconnected;
  DeviceInfo? _localDevice;
  DeviceInfo? _remoteDevice;
  String? _errorMessage;

  final _stateController = StreamController<ConnectionState>.broadcast();
  final _remoteDeviceController = StreamController<DeviceInfo?>.broadcast();

  /// Stream of connection state changes
  Stream<ConnectionState> get onStateChanged => _stateController.stream;

  /// Stream of remote device changes
  Stream<DeviceInfo?> get onRemoteDeviceChanged =>
      _remoteDeviceController.stream;

  /// Current connection state
  ConnectionState get state => _state;

  /// Local device info
  DeviceInfo? get localDevice => _localDevice;

  /// Remote device info
  DeviceInfo? get remoteDevice => _remoteDevice;

  /// Error message
  String? get errorMessage => _errorMessage;

  /// Get TCP server instance
  TcpServer? get server => _server;

  /// Get TCP client instance
  TcpClient? get client => _client;

  /// Stream of discovered IPs
  Stream<List<String>> get onIPsDiscovered => _networkScanner.onIPsFound;

  /// Initialize connection manager
  Future<void> initialize() async {
    try {
      _localDevice = await _deviceService.getLocalDeviceInfo();
      debugPrint(
        '✅ [ConnectionManager] Initialized with device: $_localDevice',
      );
    } catch (e) {
      debugPrint('❌ [ConnectionManager] Initialization failed: $e');
      _updateState(ConnectionState.error);
      _errorMessage = 'Failed to initialize: $e';
      rethrow;
    }
  }

  /// Start as server (Android hotspot mode)
  Future<void> startServer() async {
    if (_localDevice == null) {
      throw Exception('Connection manager not initialized');
    }

    if (_server != null && _server!.isRunning) {
      debugPrint('⚠️ [ConnectionManager] Server already running');
      return;
    }

    try {
      debugPrint('🚀 [ConnectionManager] Starting server...');

      _server = TcpServer(
        port: NetworkConstants.defaultPort,
        localDevice: _localDevice!,
      );

      await _server!.start();

      // Listen for incoming connections
      _server!.onConnection.listen((socket) {
        debugPrint('🤝 [ConnectionManager] Client connected');
        _updateState(ConnectionState.connected);
      });

      // Listen for handshake messages
      _server!.onMessage.listen((message) {
        _handleServerMessage(message);
      });

      // No broadcasting needed for network scanner

      debugPrint('✅ [ConnectionManager] Server started successfully');
    } catch (e) {
      debugPrint('❌ [ConnectionManager] Failed to start server: $e');
      _updateState(ConnectionState.error);
      _errorMessage = 'Failed to start server: $e';
      rethrow;
    }
  }

  /// Start network scan (for client/Windows)
  Future<void> startDiscovery() async {
    if (_localDevice == null) {
      throw Exception('Connection manager not initialized');
    }

    try {
      debugPrint('🔍 [ConnectionManager] Starting network scan...');
      await _networkScanner.scanNetwork();
      debugPrint('✅ [ConnectionManager] Network scan started');
    } catch (e) {
      debugPrint('❌ [ConnectionManager] Network scan failed: $e');
      rethrow;
    }
  }

  /// Connect to server as client (Windows connecting to Android)
  Future<void> connectToServer(String serverIp) async {
    if (_localDevice == null) {
      throw Exception('Connection manager not initialized');
    }

    try {
      debugPrint('🔗 [ConnectionManager] Connecting to $serverIp...');
      _updateState(ConnectionState.connecting);

      final remoteDevice = DeviceInfo(
        id: 'remote-device',
        name: 'Remote Device',
        ipAddress: serverIp,
        platform: 'unknown',
        port: NetworkConstants.defaultPort,
      );

      _client = TcpClient(remoteDevice: remoteDevice);
      await _client!.connect();

      // Send handshake
      await _client!.sendMessage({
        'command': NetworkConstants.cmdHandshake,
        'device': _localDevice!.toJson(),
      });

      // Listen for messages
      _client!.onMessage.listen((message) {
        _handleClientMessage(message);
      });

      _remoteDevice = remoteDevice;
      _remoteDeviceController.add(_remoteDevice);
      _updateState(ConnectionState.connected);

      debugPrint('✅ [ConnectionManager] Connected to server');
    } catch (e) {
      debugPrint('❌ [ConnectionManager] Connection failed: $e');
      _updateState(ConnectionState.error);
      _errorMessage = 'Connection failed: $e';
      rethrow;
    }
  }

  /// Handle server-side messages
  void _handleServerMessage(Map<String, dynamic> message) {
    final command = message['command'] as String?;

    switch (command) {
      case NetworkConstants.cmdHandshake:
        _handleHandshake(message);
        break;
      default:
        debugPrint('⚠️ [ConnectionManager] Unknown command: $command');
    }
  }

  /// Handle client-side messages
  void _handleClientMessage(Map<String, dynamic> message) {
    final command = message['command'] as String?;

    switch (command) {
      case NetworkConstants.cmdHandshakeAck:
        _handleHandshakeAck(message);
        break;
      default:
        debugPrint('⚠️ [ConnectionManager] Unknown command: $command');
    }
  }

  /// Handle handshake from client
  void _handleHandshake(Map<String, dynamic> message) {
    try {
      final deviceJson = message['device'] as Map<String, dynamic>;
      _remoteDevice = DeviceInfo.fromJson(deviceJson);
      _remoteDeviceController.add(_remoteDevice);

      debugPrint(
        '🤝 [ConnectionManager] Handshake from ${_remoteDevice!.name}',
      );

      // Send acknowledgment
      _server?.sendMessage({
        'command': NetworkConstants.cmdHandshakeAck,
        'device': _localDevice!.toJson(),
      });
    } catch (e) {
      debugPrint('❌ [ConnectionManager] Handshake failed: $e');
    }
  }

  /// Handle handshake acknowledgment
  void _handleHandshakeAck(Map<String, dynamic> message) {
    try {
      final deviceJson = message['device'] as Map<String, dynamic>;
      _remoteDevice = DeviceInfo.fromJson(deviceJson);
      _remoteDeviceController.add(_remoteDevice);

      debugPrint(
        '✅ [ConnectionManager] Handshake complete with ${_remoteDevice!.name}',
      );
    } catch (e) {
      debugPrint('❌ [ConnectionManager] Handshake ack failed: $e');
    }
  }

  /// Disconnect from remote device
  Future<void> disconnect() async {
    try {
      await _client?.disconnect();
      await _server?.stop();
      _networkScanner.stop();

      _client = null;
      _server = null;
      _remoteDevice = null;
      _remoteDeviceController.add(null);

      _updateState(ConnectionState.disconnected);
      debugPrint('🔴 [ConnectionManager] Disconnected');
    } catch (e) {
      debugPrint('❌ [ConnectionManager] Error disconnecting: $e');
    }
  }

  /// Update connection state
  void _updateState(ConnectionState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _stateController.close();
    _remoteDeviceController.close();
  }
}
