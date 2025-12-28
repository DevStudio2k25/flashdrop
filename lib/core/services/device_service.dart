import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import '../models/device_info.dart';
import '../constants/network_constants.dart';

/// Device information service
class DeviceService {
  static final DeviceService _instance = DeviceService._internal();
  factory DeviceService() => _instance;
  DeviceService._internal();

  DeviceInfo? _localDevice;

  /// Get local device information
  Future<DeviceInfo> getLocalDeviceInfo() async {
    // Always refresh IP on Android to handle network changes (Hotspot on/off)
    if (Platform.isAndroid) _localDevice = null;

    if (_localDevice != null) return _localDevice!;

    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      String deviceName = 'Unknown Device';
      String platform = 'unknown';

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceName = androidInfo.model;
        platform = 'android';
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfoPlugin.windowsInfo;
        deviceName = windowsInfo.computerName;
        platform = 'windows';
      }

      String? primaryIp;
      String? secondaryIp;

      // START NEW IP SCAN LOGIC
      try {
        final interfaces = await NetworkInterface.list(
          includeLoopback: false,
          type: InternetAddressType.IPv4,
        );

        debugPrint(
          '🔍 [DeviceService] Scanning Interfaces: ${interfaces.length} found',
        );

        for (final iface in interfaces) {
          debugPrint('   👉 Interface: ${iface.name}');
          for (final addr in iface.addresses) {
            final ip = addr.address;
            debugPrint('      🔹 IP: $ip');

            if (ip.startsWith('192.168.')) {
              debugPrint('      ✅ FOUND LAN IP: $ip');
              primaryIp = ip; // Start of 192.168 is GOLD
            } else if (ip.startsWith('10.')) {
              secondaryIp ??= ip; // Keep as backup/info
            } else if (primaryIp == null && secondaryIp == null) {
              secondaryIp = ip; // Any other non-local
            }
          }
        }
      } catch (e) {
        debugPrint('IP Scan Error: $e');
      }

      // If we found a 192.168 address, USE IT.
      // Otherwise, fallback to whatever else we found (so UI doesn't crash),
      // but UI will likely warn "Hotspot not active".
      String finalIp = primaryIp ?? secondaryIp ?? '127.0.0.1';

      _localDevice = DeviceInfo(
        id: const Uuid().v4(),
        name: deviceName,
        ipAddress: finalIp,
        platform: platform,
        port: NetworkConstants.defaultPort,
        otherIp: secondaryIp != finalIp
            ? secondaryIp
            : null, // Store secondary if different
      );

      debugPrint('📱 [DeviceService] Local device: $_localDevice');
      return _localDevice!;
    } catch (e) {
      debugPrint('❌ [DeviceService] Failed to get device info: $e');
      rethrow;
    }
  }

  /// Check if device is on same network as target IP
  bool isSameNetwork(String targetIp) {
    if (_localDevice == null) return false;

    final localParts = _localDevice!.ipAddress.split('.');
    final targetParts = targetIp.split('.');

    if (localParts.length != 4 || targetParts.length != 4) return false;

    // Check if first 3 octets match (same subnet)
    return localParts[0] == targetParts[0] &&
        localParts[1] == targetParts[1] &&
        localParts[2] == targetParts[2];
  }

  /// Clear cached device info
  void clearCache() {
    _localDevice = null;
  }
}
