import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/device_info.dart';
import '../constants/network_constants.dart';

/// Automatic device discovery using UDP broadcast
class DeviceDiscoveryService {
  static final DeviceDiscoveryService _instance =
      DeviceDiscoveryService._internal();
  factory DeviceDiscoveryService() => _instance;
  DeviceDiscoveryService._internal();

  RawDatagramSocket? _socket;
  Timer? _broadcastTimer;

  final _discoveredDevicesController =
      StreamController<List<DeviceInfo>>.broadcast();
  final Map<String, DeviceInfo> _discoveredDevices = {};
  final Map<String, DateTime> _lastSeen = {};

  /// Stream of discovered devices
  Stream<List<DeviceInfo>> get onDevicesDiscovered =>
      _discoveredDevicesController.stream;

  /// Get list of currently discovered devices
  List<DeviceInfo> get discoveredDevices => _discoveredDevices.values.toList();

  /// Start broadcasting (for server/Android)
  Future<void> startBroadcasting(DeviceInfo localDevice) async {
    try {
      debugPrint('🔊 [Discovery] Starting broadcast for ${localDevice.name}');

      // Bind to any address for sending broadcasts
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      _socket!.broadcastEnabled = true;

      // Broadcast every 2 seconds
      _broadcastTimer = Timer.periodic(const Duration(seconds: 2), (_) {
        _sendBroadcast(localDevice);
      });

      debugPrint('✅ [Discovery] Broadcasting started');
    } catch (e) {
      debugPrint('❌ [Discovery] Failed to start broadcasting: $e');
      rethrow;
    }
  }

  /// Start listening for broadcasts (for client/Windows)
  Future<void> startListening() async {
    try {
      debugPrint('👂 [Discovery] Starting to listen for devices...');

      // Bind to broadcast port
      _socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        NetworkConstants.discoveryPort,
      );
      _socket!.broadcastEnabled = true;

      // Listen for incoming broadcasts
      _socket!.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = _socket!.receive();
          if (datagram != null) {
            _handleIncomingBroadcast(datagram);
          }
        }
      });

      // Clean up stale devices every 5 seconds
      Timer.periodic(const Duration(seconds: 5), (_) {
        _cleanupStaleDevices();
      });

      debugPrint('✅ [Discovery] Listening for broadcasts');
    } catch (e) {
      debugPrint('❌ [Discovery] Failed to start listening: $e');
      rethrow;
    }
  }

  /// Send broadcast message
  void _sendBroadcast(DeviceInfo device) {
    try {
      final message = {
        'type': 'FLASHDROP_DEVICE',
        'device': device.toJson(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final data = utf8.encode(jsonEncode(message));

      // Send to broadcast address
      _socket!.send(
        data,
        InternetAddress('255.255.255.255'),
        NetworkConstants.discoveryPort,
      );

      debugPrint('📡 [Discovery] Broadcast sent: ${device.name}');
    } catch (e) {
      debugPrint('⚠️ [Discovery] Broadcast failed: $e');
    }
  }

  /// Handle incoming broadcast
  void _handleIncomingBroadcast(Datagram datagram) {
    try {
      final message = utf8.decode(datagram.data);
      final json = jsonDecode(message) as Map<String, dynamic>;

      // Verify it's a FlashDrop device
      if (json['type'] != 'FLASHDROP_DEVICE') return;

      final deviceJson = json['device'] as Map<String, dynamic>;
      final device = DeviceInfo.fromJson(deviceJson);

      // Don't add ourselves
      if (_isLocalDevice(device)) return;

      // Add or update device
      _discoveredDevices[device.id] = device;
      _lastSeen[device.id] = DateTime.now();

      debugPrint(
        '📱 [Discovery] Found device: ${device.name} (${device.ipAddress})',
      );

      // Emit updated list
      _discoveredDevicesController.add(discoveredDevices);
    } catch (e) {
      debugPrint('⚠️ [Discovery] Failed to parse broadcast: $e');
    }
  }

  /// Check if device is local (don't discover ourselves)
  bool _isLocalDevice(DeviceInfo device) {
    // Simple check - can be improved
    return false; // For now, allow all devices
  }

  /// Remove devices that haven't been seen in 10 seconds
  void _cleanupStaleDevices() {
    final now = DateTime.now();
    final staleDevices = <String>[];

    _lastSeen.forEach((deviceId, lastSeenTime) {
      if (now.difference(lastSeenTime).inSeconds > 10) {
        staleDevices.add(deviceId);
      }
    });

    for (final deviceId in staleDevices) {
      debugPrint('🗑️ [Discovery] Removing stale device: $deviceId');
      _discoveredDevices.remove(deviceId);
      _lastSeen.remove(deviceId);
    }

    if (staleDevices.isNotEmpty) {
      _discoveredDevicesController.add(discoveredDevices);
    }
  }

  /// Stop discovery
  Future<void> stop() async {
    _broadcastTimer?.cancel();
    _socket?.close();
    _discoveredDevices.clear();
    _lastSeen.clear();
    debugPrint('🔴 [Discovery] Stopped');
  }

  /// Dispose resources
  void dispose() {
    stop();
    _discoveredDevicesController.close();
  }
}
