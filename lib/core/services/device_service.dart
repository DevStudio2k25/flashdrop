import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
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
    if (_localDevice != null) return _localDevice!;

    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final networkInfo = NetworkInfo();

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

      // Get local IP address
      String? ipAddress = await networkInfo.getWifiIP();
      ipAddress ??= await _getLocalIpAddress();

      if (ipAddress == null) {
        throw Exception('Unable to get local IP address');
      }

      _localDevice = DeviceInfo(
        id: const Uuid().v4(),
        name: deviceName,
        ipAddress: ipAddress,
        platform: platform,
        port: NetworkConstants.defaultPort,
      );

      debugPrint('📱 [DeviceService] Local device: $_localDevice');
      return _localDevice!;
    } catch (e) {
      debugPrint('❌ [DeviceService] Failed to get device info: $e');
      rethrow;
    }
  }

  /// Get local IP address (fallback method)
  Future<String?> _getLocalIpAddress() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
      );

      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          // Skip loopback
          if (addr.address.startsWith('127.')) continue;
          // Prefer 192.168.x.x or 10.x.x.x
          if (addr.address.startsWith('192.168.') ||
              addr.address.startsWith('10.')) {
            return addr.address;
          }
        }
      }

      // Return any non-loopback address
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (!addr.address.startsWith('127.')) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      debugPrint('❌ [DeviceService] Error getting IP: $e');
    }
    return null;
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
