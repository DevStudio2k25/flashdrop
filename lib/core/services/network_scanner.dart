import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../constants/network_constants.dart';

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
    if (_isScanning) return;

    _isScanning = true;
    _discoveredIPs.clear();

    try {
      debugPrint(
        '🔍 [NetworkScanner] Starting full subnet scan (192.168.x.x)...',
      );

      final localIP = await _getLocalIP();
      if (localIP == null) {
        debugPrint('❌ [NetworkScanner] No valid 192.168.x.x IP found');
        _isScanning = false;
        return;
      }

      final parts = localIP.split('.');
      final subnet = '${parts[0]}.${parts[1]}.${parts[2]}';

      // Prioritize Gateway (likely .1)
      final gatewayIP = '$subnet.1';
      if (await _pingIP(gatewayIP, NetworkConstants.defaultPort)) {
        debugPrint('✅ [NetworkScanner] Found Gateway: $gatewayIP');
        _discoveredIPs.add(gatewayIP);
        _scanController.add(_discoveredIPs);
        _isScanning = false;
        return; // Stop if we found the gateway (most likely target)
      }

      // Scan the rest efficiently (Batch of 50)
      final allIPs = List.generate(254, (i) => '$subnet.${i + 1}')
          .where(
            (ip) => ip != localIP && ip != gatewayIP,
          ) // Skip self and gateway (already checked)
          .toList();

      const int batchSize = 50;
      for (var i = 0; i < allIPs.length; i += batchSize) {
        if (!_isScanning) break; // Allow cancellation

        final end = (i + batchSize < allIPs.length)
            ? i + batchSize
            : allIPs.length;
        final batch = allIPs.sublist(i, end);

        final futures = batch.map(
          (ip) => _pingIP(ip, NetworkConstants.defaultPort),
        );
        final results = await Future.wait(futures);

        for (int k = 0; k < results.length; k++) {
          if (results[k]) {
            final ip = batch[k];
            if (!_discoveredIPs.contains(ip)) {
              _discoveredIPs.add(ip);
              debugPrint('✅ [NetworkScanner] Found: $ip');
              _scanController.add(_discoveredIPs);
            }
          }
        }
      }

      debugPrint('🎯 [NetworkScanner] Scan complete.');
    } catch (e) {
      debugPrint('❌ [NetworkScanner] Scan failed: $e');
    } finally {
      _isScanning = false;
    }
  }

  /// Get local IP address (Strict 192.168.x.x)
  Future<String?> _getLocalIP() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.address.startsWith('192.168.')) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      // Ignore
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

  /// Add a discovered IP manually (e.g. from UDP Discovery)
  void addDiscoveredIp(String ip) {
    if (!_discoveredIPs.contains(ip)) {
      _discoveredIPs.add(ip);
      _scanController.add(_discoveredIPs);
      debugPrint('➕ [NetworkScanner] Added UDP Discovered IP: $ip');
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
