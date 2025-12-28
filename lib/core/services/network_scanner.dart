import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Simple network scanner to find devices on same subnet
class NetworkScanner {
  static final NetworkScanner _instance = NetworkScanner._internal();
  factory NetworkScanner() => _instance;
  NetworkScanner._internal();

  final _discoveredIPs = <String>[];
  final _scanController = StreamController<List<String>>.broadcast();

  Stream<List<String>> get onIPsFound => _scanController.stream;
  List<String> get discoveredIPs => _discoveredIPs;

  bool _isScanning = false;

  /// Scan local network for devices
  Future<void> scanNetwork() async {
    if (_isScanning) {
      debugPrint('⚠️ [NetworkScanner] Already scanning');
      return;
    }

    _isScanning = true;
    _discoveredIPs.clear();

    try {
      debugPrint('🔍 [NetworkScanner] Starting network scan...');

      // Get local IP
      final localIP = await _getLocalIP();
      if (localIP == null) {
        debugPrint('❌ [NetworkScanner] Could not get local IP');
        _isScanning = false;
        return;
      }

      debugPrint('📱 [NetworkScanner] Local IP: $localIP');

      // Extract subnet (e.g., 192.168.43.x)
      final parts = localIP.split('.');
      if (parts.length != 4) {
        debugPrint('❌ [NetworkScanner] Invalid IP format');
        _isScanning = false;
        return;
      }

      final subnet = '${parts[0]}.${parts[1]}.${parts[2]}';
      debugPrint('🌐 [NetworkScanner] Scanning subnet: $subnet.x');

      // Scan common IPs (1, 2, 100-110 for hotspot range)
      final ipsToScan = [
        '$subnet.1', // Common hotspot IP
        '$subnet.2',
        ...List.generate(11, (i) => '$subnet.${100 + i}'), // 100-110
      ];

      // Scan in parallel (faster)
      final futures = ipsToScan.map((ip) => _pingIP(ip, 8888));
      final results = await Future.wait(futures);

      for (int i = 0; i < results.length; i++) {
        if (results[i]) {
          final ip = ipsToScan[i];
          if (!_discoveredIPs.contains(ip)) {
            _discoveredIPs.add(ip);
            debugPrint('✅ [NetworkScanner] Found device: $ip');
            _scanController.add(_discoveredIPs);
          }
        }
      }

      debugPrint(
        '🎯 [NetworkScanner] Scan complete. Found ${_discoveredIPs.length} devices',
      );
    } catch (e) {
      debugPrint('❌ [NetworkScanner] Scan failed: $e');
    } finally {
      _isScanning = false;
    }
  }

  /// Get local IP address
  Future<String?> _getLocalIP() async {
    try {
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            // Skip if it's not a local network IP
            final ip = addr.address;
            if (ip.startsWith('192.168.') ||
                ip.startsWith('10.') ||
                ip.startsWith('172.')) {
              return ip;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('❌ [NetworkScanner] Failed to get local IP: $e');
    }
    return null;
  }

  /// Ping IP to check if FlashDrop server is running
  Future<bool> _pingIP(String ip, int port) async {
    try {
      final socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(milliseconds: 500),
      );
      await socket.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Stop scanning
  void stop() {
    _isScanning = false;
    _discoveredIPs.clear();
  }

  /// Dispose
  void dispose() {
    stop();
    _scanController.close();
  }
}
