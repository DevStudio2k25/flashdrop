import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../features/connection/domain/entities/peer.dart';
import '../core/constants/app_constants.dart';

/// Network discovery service for finding peers on local network
class DiscoveryService {
  final _discoveredPeersController = StreamController<List<Peer>>.broadcast();
  Stream<List<Peer>> get onPeersDiscovered => _discoveredPeersController.stream;

  final List<Peer> _discoveredPeers = [];
  RawDatagramSocket? _socket;
  String? _localIp;
  String? _deviceName;
  String? _deviceType;
  bool _isRunning = false;

  static const int _broadcastPort = 37020;
  static const String _discoveryMessage = 'FLASHDROP_DISCOVERY';
  static const String _responsePrefix = 'FLASHDROP_RESPONSE';

  /// Initialize discovery service
  Future<void> initialize() async {
    debugPrint('🔧 [Discovery] Initializing...');
    _localIp = await _getLocalIp();
    _deviceName = await _getDeviceName();
    _deviceType = await _getDeviceType();
    debugPrint(
      '✅ [Discovery] My Device - IP: $_localIp, Name: "$_deviceName", Type: $_deviceType',
    );
  }

  /// Start broadcasting and listening for peers
  Future<void> startDiscovery() async {
    if (_isRunning) return;

    _isRunning = true;
    _discoveredPeers.clear();

    try {
      // Bind to broadcast port
      _socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        _broadcastPort,
      );
      _socket!.broadcastEnabled = true;

      debugPrint('📡 [Discovery] Socket bound to port $_broadcastPort');

      // Listen for responses
      _socket!.listen((event) {
        if (event == RawSocketEvent.read) {
          final datagram = _socket!.receive();
          if (datagram != null) {
            _handleIncomingMessage(datagram);
          }
        }
      });

      // Start broadcasting
      _startBroadcasting();
      debugPrint('📢 [Discovery] Broadcasting started');
    } catch (e) {
      debugPrint('❌ [Discovery] Failed to start: $e');
      _isRunning = false;
      rethrow;
    }
  }

  /// Start broadcasting discovery messages
  void _startBroadcasting() {
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isRunning) {
        timer.cancel();
        return;
      }

      try {
        // Send discovery message to broadcast address
        final message = utf8.encode(_discoveryMessage);

        // Calculate subnet broadcast based on local IP
        final localIpParts = _localIp?.split('.') ?? [];
        if (localIpParts.length == 4) {
          // Create subnet broadcast (e.g., 10.150.197.255)
          final subnetBroadcast =
              '${localIpParts[0]}.${localIpParts[1]}.${localIpParts[2]}.255';

          try {
            _socket?.send(
              message,
              InternetAddress(subnetBroadcast),
              _broadcastPort,
            );
          } catch (e) {
            // Ignore
          }
        }

        // Also try global broadcast
        final broadcastAddresses = [
          '255.255.255.255', // Global broadcast
        ];

        for (final broadcastAddr in broadcastAddresses) {
          try {
            _socket?.send(
              message,
              InternetAddress(broadcastAddr),
              _broadcastPort,
            );
          } catch (e) {
            // Ignore individual broadcast errors
          }
        }
      } catch (e) {
        debugPrint('❌ [Discovery] Broadcast error: $e');
      }
    });
  }

  /// Handle incoming discovery messages
  void _handleIncomingMessage(Datagram datagram) {
    try {
      final message = utf8.decode(datagram.data);
      final senderIp = datagram.address.address;

      // Ignore messages from self
      if (senderIp == _localIp || senderIp.startsWith('127.')) {
        return;
      }

      if (message == _discoveryMessage) {
        // Someone is looking for peers, respond
        debugPrint('📨 [Discovery] Discovery request from $senderIp');
        _sendResponse(datagram.address);
      } else if (message.startsWith(_responsePrefix)) {
        // Received a response, parse peer info
        debugPrint('📬 [Discovery] Response from $senderIp');
        _parsePeerResponse(message, senderIp);
      }
    } catch (e) {
      debugPrint('❌ [Discovery] Error: $e');
    }
  }

  /// Send response to discovery request
  void _sendResponse(InternetAddress address) {
    try {
      final response =
          '$_responsePrefix|$_deviceName|$_deviceType|${AppConstants.signalingServerPort}';
      final data = utf8.encode(response);
      _socket?.send(data, address, _broadcastPort);
      debugPrint('📤 [Discovery] Sent response to ${address.address}');
    } catch (e) {
      debugPrint('❌ [Discovery] Error sending response: $e');
    }
  }

  /// Parse peer response and add to discovered peers
  void _parsePeerResponse(String message, String ipAddress) {
    try {
      final parts = message.split('|');

      if (parts.length >= 4) {
        final deviceName = parts[1];
        final deviceType = parts[2];
        final port = int.parse(parts[3]);

        // Ignore if it's our own device (same name)
        if (deviceName == _deviceName) {
          debugPrint('⏭️ [Discovery] Ignoring self: $deviceName at $ipAddress');
          return;
        }

        final peer = Peer(
          id: 'peer-$ipAddress',
          name: deviceName,
          ipAddress: ipAddress,
          deviceType: deviceType,
          port: port,
        );

        // Check if peer already exists
        final existingIndex = _discoveredPeers.indexWhere(
          (p) => p.ipAddress == ipAddress,
        );

        if (existingIndex == -1) {
          _discoveredPeers.add(peer);
          debugPrint(
            '🎯 [Discovery] FOUND PEER: "$deviceName" ($deviceType) at $ipAddress:$port',
          );
          _discoveredPeersController.add(List.from(_discoveredPeers));
        }
      }
    } catch (e) {
      debugPrint('❌ [Discovery] Error parsing peer response: $e');
    }
  }

  /// Get local IP address
  Future<String> _getLocalIp() async {
    try {
      debugPrint('🔍 [Discovery] Getting local IP...');
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
      );

      debugPrint(
        '📋 [Discovery] Found ${interfaces.length} network interfaces',
      );

      // Try to find WiFi or mobile hotspot interface
      for (final interface in interfaces) {
        debugPrint('🔌 [Discovery] Interface: ${interface.name}');
        for (final addr in interface.addresses) {
          debugPrint('   IP: ${addr.address} (loopback: ${addr.isLoopback})');
          if (!addr.isLoopback) {
            // Check for common private network ranges
            if (addr.address.startsWith('192.168.') ||
                addr.address.startsWith('10.') ||
                addr.address.startsWith('172.')) {
              debugPrint('✅ [Discovery] Selected IP: ${addr.address}');
              return addr.address;
            }
          }
        }
      }

      // Fallback to any non-loopback address
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (!addr.isLoopback) {
            debugPrint('⚠️ [Discovery] Using fallback IP: ${addr.address}');
            return addr.address;
          }
        }
      }
    } catch (e) {
      debugPrint('❌ [Discovery] Error getting local IP: $e');
    }

    debugPrint('⚠️ [Discovery] Using localhost as fallback');
    return '127.0.0.1';
  }

  /// Get device name
  Future<String> _getDeviceName() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        debugPrint('📱 [Discovery] Android device: ${androidInfo.model}');
        return androidInfo.model;
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        debugPrint('💻 [Discovery] Windows PC: ${windowsInfo.computerName}');
        return windowsInfo.computerName;
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        debugPrint('🐧 [Discovery] Linux: ${linuxInfo.name}');
        return linuxInfo.name;
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        debugPrint('🍎 [Discovery] macOS: ${macInfo.computerName}');
        return macInfo.computerName;
      }
    } catch (e) {
      debugPrint('❌ [Discovery] Error getting device name: $e');
    }

    final fallback = Platform.isAndroid
        ? 'Android Device'
        : Platform.isWindows
        ? 'Windows PC'
        : Platform.isLinux
        ? 'Linux PC'
        : Platform.isMacOS
        ? 'Mac'
        : 'Unknown Device';
    debugPrint('⚠️ [Discovery] Using fallback name: $fallback');
    return fallback;
  }

  /// Get device type
  Future<String> _getDeviceType() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return 'mobile';
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return 'desktop';
    }
    return 'unknown';
  }

  /// Get discovered peers
  List<Peer> get discoveredPeers => List.from(_discoveredPeers);

  /// Get local IP
  String? get localIp => _localIp;

  /// Stop discovery
  void stopDiscovery() {
    debugPrint('⏹️ [Discovery] Stopping discovery...');
    _isRunning = false;
    _socket?.close();
    _socket = null;
    _discoveredPeers.clear();
    debugPrint('✅ [Discovery] Stopped');
  }

  /// Dispose resources
  void dispose() {
    stopDiscovery();
    _discoveredPeersController.close();
  }
}
