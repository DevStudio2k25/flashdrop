import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/connection_manager.dart';
import '../core/models/device_info.dart';

/// Connection manager provider
final connectionManagerProvider = Provider<ConnectionManager>((ref) {
  return ConnectionManager();
});

/// Connection state provider
final connectionStateProvider = StreamProvider<ConnectionState>((ref) {
  final manager = ref.watch(connectionManagerProvider);
  return manager.onStateChanged;
});

/// Remote device provider
final remoteDeviceProvider = StreamProvider<DeviceInfo?>((ref) {
  final manager = ref.watch(connectionManagerProvider);
  return manager.onRemoteDeviceChanged;
});

/// Local device provider
final localDeviceProvider = FutureProvider<DeviceInfo?>((ref) async {
  final manager = ref.watch(connectionManagerProvider);
  await manager.initialize();
  return manager.localDevice;
});

/// Discovered IPs provider (simple list of IP addresses)
final discoveredIPsProvider = StreamProvider<List<String>>((ref) {
  final manager = ref.watch(connectionManagerProvider);
  return manager.onIPsDiscovered;
});
