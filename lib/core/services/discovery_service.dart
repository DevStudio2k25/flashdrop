import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/device_info.dart';
import '../constants/network_constants.dart';

/// UDP Discovery Service
/// Broadcasts presence on the network and listens for other devices.
class DiscoveryService {
  static final DiscoveryService _instance = DiscoveryService._internal();
  factory DiscoveryService() => _instance;
  DiscoveryService._internal();

  RawDatagramSocket? _broadcastSocket;
  RawDatagramSocket? _listenSocket;
  Timer? _broadcastTimer;

  final _discoveredDeviceController = StreamController<DeviceInfo>.broadcast();
  Stream<DeviceInfo> get onDeviceFound => _discoveredDeviceController.stream;

  bool _isBroadcasting = false;
  bool _isListening = false;

  /// Start Broadcasting (Server uses this)
  /// Sends "I am here" packets every 2 seconds
  Future<void> startBroadcasting(DeviceInfo localDevice) async {
    if (_isBroadcasting) return;

    try {
      debugPrint('📡 [Discovery] Starting UDP Broadcast...');
      _broadcastSocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        0, // Random available port for sending
      );
      _broadcastSocket!.broadcastEnabled = true;
      _isBroadcasting = true;

      // Create discovery packet
      final packet = jsonEncode({
        'cmd': 'flashdrop_announce',
        'id': localDevice.id,
        'name': localDevice.name,
        'platform': localDevice.platform,
        'port': localDevice.port, // TCP Port
        // We do NOT send IP, because receiver will get it from packet header
      });
      final data = utf8.encode(packet);

      // Send every 2 seconds
      _broadcastTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
        if (!_isBroadcasting || _broadcastSocket == null) {
          timer.cancel();
          return;
        }

        try {
          // Send to Broadcast Address
          _broadcastSocket!.send(
            data,
            InternetAddress('255.255.255.255'),
            NetworkConstants.discoveryPort,
          );
          // Also try standard subnet broadcast (fallback)
          // _broadcastSocket!.send(data, InternetAddress('192.168.43.255'), NetworkConstants.discoveryPort);
        } catch (e) {
          debugPrint('⚠️ [Discovery] Broadcast error: $e');
        }
      });

      debugPrint('✅ [Discovery] Broadcasting as ${localDevice.name}');
    } catch (e) {
      debugPrint('❌ [Discovery] Failed to start broadcast: $e');
      _isBroadcasting = false;
    }
  }

  /// Start Listening (Client uses this)
  /// Listens for "I am here" packets
  Future<void> startListening() async {
    if (_isListening) return;

    try {
      debugPrint(
        '👂 [Discovery] Listening for devices on port ${NetworkConstants.discoveryPort}...',
      );
      _listenSocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        NetworkConstants.discoveryPort,
        reuseAddress: true, // Allow multiple apps/instances to bind
      );

      _isListening = true;

      _listenSocket!.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = _listenSocket!.receive();
          if (datagram != null) {
            _handlePacket(datagram);
          }
        }
      });
    } catch (e) {
      debugPrint('❌ [Discovery] Failed to start listening: $e');
      _isListening = false;
    }
  }

  void _handlePacket(Datagram datagram) {
    try {
      final message = utf8.decode(datagram.data);
      final json = jsonDecode(message) as Map<String, dynamic>;

      if (json['cmd'] == 'flashdrop_announce') {
        final senderIp = datagram.address.address;
        debugPrint('🎯 [Discovery] Packet from $senderIp: $message');

        // Construct Device Info
        final device = DeviceInfo(
          id: json['id'] ?? 'unknown',
          name: json['name'] ?? 'Unknown',
          ipAddress: senderIp, // CRITICAL: Use the actual IP from the packet
          platform: json['platform'] ?? 'unknown',
          port: json['port'] ?? NetworkConstants.defaultPort,
        );

        _discoveredDeviceController.add(device);
      }
    } catch (e) {
      // Ignore junk packets
    }
  }

  /// Stop everything
  void stop() {
    _isBroadcasting = false;
    _isListening = false;
    _broadcastTimer?.cancel();
    _broadcastSocket?.close();
    _listenSocket?.close();
    _broadcastSocket = null;
    _listenSocket = null;
    debugPrint('🛑 [Discovery] Service stopped');
  }
}
