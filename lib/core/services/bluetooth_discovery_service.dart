import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/device_info.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

final bluetoothDiscoveryProvider = Provider<BluetoothDiscoveryService>((ref) {
  return BluetoothDiscoveryService();
});

class BluetoothDiscoveryService {
  final bool _isSupported = Platform.isAndroid;
  String? _originalName;
  bool _isBroadcasting = false;

  /// Check if Bluetooth is supported and enabled
  Future<bool> isEnabled() async {
    if (!_isSupported) return false;
    try {
      return (await FlutterBluetoothSerial.instance.isEnabled) ?? false;
    } catch (e) {
      debugPrint('Error checking Bluetooth status: $e');
      return false;
    }
  }

  /// Enable Bluetooth
  Future<bool> enableBluetooth() async {
    if (!_isSupported) return false;
    try {
      return (await FlutterBluetoothSerial.instance.requestEnable()) ?? false;
    } catch (e) {
      debugPrint('Error enabling Bluetooth: $e');
      return false;
    }
  }

  /// Start broadcasting IP by changing Bluetooth name
  /// Format: FD_IP_Name (e.g., FD_192.168.1.5_MyPhone)
  Future<void> startBroadcasting(String ipAddress, String deviceName) async {
    if (!_isSupported) return;
    if (_isBroadcasting) return;

    try {
      // 1. Get current name
      _originalName = await FlutterBluetoothSerial.instance.name;

      // 2. Construct new name
      // Replace dots in IP with hyphens if needed, or simple keep dots?
      // Some adapters might have issues with specific chars.
      // Let's use standard chars. IP 192.168.1.5 -> 192-168-1-5
      final safeIp = ipAddress.replaceAll('.', '-');
      final newName = 'FD_${safeIp}_$deviceName';

      // 3. Set new name
      await FlutterBluetoothSerial.instance.changeName(newName);

      // 4. Ensure discoverable
      // Request discoverable duration (e.g., 300 seconds)
      await FlutterBluetoothSerial.instance.requestDiscoverable(300);

      _isBroadcasting = true;
      debugPrint('🔵 [Bluetooth] Broadcasting as $newName');
    } catch (e) {
      debugPrint('❌ [Bluetooth] Failed to broadcast: $e');
    }
  }

  /// Stop broadcasting and restore original name
  Future<void> stopBroadcasting() async {
    if (!_isSupported || !_isBroadcasting) return;

    try {
      if (_originalName != null) {
        await FlutterBluetoothSerial.instance.changeName(_originalName!);
        debugPrint('🔵 [Bluetooth] Restored name to $_originalName');
      }
      _isBroadcasting = false;
    } catch (e) {
      debugPrint('❌ [Bluetooth] Failed to stop broadcast: $e');
    }
  }

  /// Scan for other FlashDrop devices
  Stream<List<DeviceInfo>> scanForDevices() {
    if (!_isSupported) return const Stream.empty();

    return FlutterBluetoothSerial.instance.startDiscovery().map((result) {
      // Logic to accumulate? The API returns events one by one usually.
      // This maps one result to a list? No, we need a transformer or state.
      // For simplicity, we will let the UI accumulate or just return the latest found.
      // But startDiscovery returns a stream of BluetoothDiscoveryResult.
      return []; // Placeholder: Requires state management handling.
    });
  }

  // A simpler scan method that collects results for a duration
  Future<List<DeviceInfo>> quickScan({
    Duration duration = const Duration(seconds: 4),
  }) async {
    if (!_isSupported) return [];

    final devices = <DeviceInfo>[];

    try {
      debugPrint('🔵 [Bluetooth] Starting scan...');
      // Clear cache if possible or just start discovery
      final stream = FlutterBluetoothSerial.instance.startDiscovery();

      final subscription = stream.listen((result) {
        final name = result.device.name ?? '';
        if (name.startsWith('FD_')) {
          final info = _parseDeviceFromBluetoothName(name);
          if (info != null &&
              !devices.any((d) => d.ipAddress == info.ipAddress)) {
            debugPrint('✅ [Bluetooth] Found: ${info.name} (${info.ipAddress})');
            devices.add(info);
          }
        }
      });

      await Future.delayed(duration);
      await subscription.cancel();
      // await FlutterBluetoothSerial.instance.cancelDiscovery(); // Ensure stop
    } catch (e) {
      debugPrint('❌ [Bluetooth] Scan failed: $e');
    }

    return devices;
  }

  DeviceInfo? _parseDeviceFromBluetoothName(String btName) {
    try {
      // Format: FD_192-168-1-5_DeviceName
      final parts = btName.split('_');
      if (parts.length < 3) return null;

      final ipPart = parts[1].replaceAll('-', '.');
      final namePart = parts
          .sublist(2)
          .join('_'); // Rejoin remaining parts if name had underscores

      return DeviceInfo(
        id: 'bt_${ipPart.replaceAll('.', '')}',
        ipAddress: ipPart,
        name: namePart,
        port: 8080,
        platform: 'android',
      );
    } catch (e) {
      return null;
    }
  }
}
