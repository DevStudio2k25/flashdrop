import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/connection_provider.dart';
import '../../state/transfer_provider.dart';
import '../../state/database_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/status_badge.dart';
import '../widgets/transfer_progress_card.dart';
import '../widgets/qr_code_dialog.dart';
import '../../core/services/connection_manager.dart' as conn_mgr;
import '../../core/models/device_info.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:async';
import 'qr_scanner_screen.dart';
import 'custom_file_picker.dart';
import '../../core/services/pairing_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:io';

/// Main home screen
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _ipController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _checkPermissions(); // Request Permissions First

    final connectionManager = ref.read(connectionManagerProvider);
    final transferEngine = ref.read(fileTransferEngineProvider);
    final database = ref.read(databaseServiceProvider);

    await connectionManager.initialize();
    await transferEngine.initialize();
    await database.initialize();
  }

  Future<void> _checkPermissions() async {
    if (Platform.isAndroid) {
      // Basic Storage
      await Permission.storage.request();
      // For Android 11+
      if (await Permission.manageExternalStorage.isDenied) {
        await Permission.manageExternalStorage.request();
      }

      // For Android 13+ Photo Picker / Media (Instead of raw storage sometimes)
      await Permission.photos.request();
      await Permission.videos.request();
      await Permission.audio.request();

      // For Network/Discovery
      await Permission.location.request();
      await Permission.nearbyWifiDevices.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // Light gray background
      appBar: AppBar(
        title: const Text(
          'FlashDrop',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.folder_open, color: AppColors.textPrimary),
              tooltip: 'Set Download Location',
              onPressed: _pickDownloadFolder,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildConnectionStatus(),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildConnectionTab(),
          _buildTransfersTab(),
          _buildHistoryTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        elevation: 2,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.wifi_outlined),
            selectedIcon: Icon(Icons.wifi),
            label: 'Connect',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz),
            label: 'Transfers',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    final connectionState = ref.watch(connectionStateProvider);

    return connectionState.when(
      data: (state) {
        switch (state) {
          case conn_mgr.ConnectionState.connected:
            return const StatusBadge(
              text: 'Connected',
              color: AppColors.success,
              icon: Icons.check_circle,
            );
          case conn_mgr.ConnectionState.connecting:
            return const StatusBadge(
              text: 'Connecting',
              color: AppColors.warning,
              icon: Icons.sync,
            );
          case conn_mgr.ConnectionState.error:
            return const StatusBadge(
              text: 'Error',
              color: AppColors.error,
              icon: Icons.error,
            );
          default:
            return const StatusBadge(
              text: 'Disconnected',
              color: AppColors.textTertiary,
              icon: Icons.wifi_off,
            );
        }
      },
      loading: () =>
          const StatusBadge(text: '...', color: AppColors.textTertiary),
      error: (_, __) =>
          const StatusBadge(text: 'Error', color: AppColors.error),
    );
  }

  Future<void> _pickDownloadFolder() async {
    String? path = await FilePicker.platform.getDirectoryPath();
    if (path != null) {
      ref.read(fileTransferEngineProvider).setCustomDownloadPath(path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download location set to: $path'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Widget _buildConnectionTab() {
    final localDevice = ref.watch(localDeviceProvider);
    final remoteDevice = ref.watch(remoteDeviceProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. My Device Card (Always visible)
          _buildDeviceCard(localDevice),
          const SizedBox(height: 24),

          // 2. Server Control (Always visible to allow hosting)
          _buildServerCard(),
          const SizedBox(height: 24),

          // 3. Client Control (Always visible to allow connecting)
          _buildClientCard(),

          const SizedBox(height: 24),

          // 3. Connected Device Info (if any)
          if (remoteDevice.value != null) ...[
            _buildConnectedDeviceCard(remoteDevice.value!),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildDeviceCard(AsyncValue<DeviceInfo?> localDevice) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: AppColors.border.withOpacity(0.5)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.smartphone,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'This Device',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // Refresh Button
                          IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            onPressed: () {
                              ref.read(deviceServiceProvider).clearCache();
                              // ignore: unused_result
                              ref.refresh(localDeviceProvider);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Refreshing network info...'),
                                ),
                              );
                            },
                            tooltip: 'Refresh IP',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      localDevice.when(
                        data: (device) => Text(
                          device?.name ?? 'Unknown Device',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        loading: () => const Text('Loading...'),
                        error: (_, __) => const Text('Error loading info'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) {
                      final ip = localDevice.value?.ipAddress ?? '-';
                      // Just show whatever IP we have. If it's 10.x, so be it.
                      // We remove the strict visual error.
                      return Row(
                        children: [
                          const Icon(
                            Icons.wifi,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Network IP',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textTertiary,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                ip,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  Container(width: 1, height: 24, color: AppColors.border),
                  _buildMiniInfo(
                    'Port',
                    localDevice.value?.port.toString() ?? '-',
                    Icons.numbers,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniInfo(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServerCard() {
    return Consumer(
      builder: (context, ref, child) {
        final connectionState = ref.watch(connectionStateProvider);
        return connectionState.when(
          data: (state) {
            final isRunning =
                state == conn_mgr.ConnectionState.connected ||
                state == conn_mgr.ConnectionState.listening;

            return Card(
              elevation: 4,
              shadowColor: AppColors.primary.withOpacity(0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Host Session (Server)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isRunning)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Running',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Start server to let others connect to you.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!isRunning)
                      _buildPrimaryButton(
                        label: 'Start Server',
                        icon: Icons.wifi_tethering,
                        onPressed: _startServer,
                        color: AppColors.primary,
                      )
                    else ...[
                      _buildPrimaryButton(
                        label: 'Show QR Code (My IP)',
                        icon: Icons.qr_code,
                        onPressed:
                            _showPCQR, // Reuse this method (renamed ideally but logic fits)
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      _buildSecondaryButton(
                        label: 'Stop Server',
                        icon: Icons.stop_circle_outlined,
                        onPressed: _disconnect,
                        color: AppColors.error,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildClientCard() {
    final connectionState = ref.watch(connectionStateProvider).value;
    if (connectionState == conn_mgr.ConnectionState.connected) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: AppColors.border.withOpacity(0.5)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Join Session (Client)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connect to a device by IP or QR.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _ipController,
              decoration: InputDecoration(
                hintText: 'Enter Server IP (e.g. 192.168.x.x)',
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(
                  Icons.dialpad,
                  color: AppColors.textTertiary,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildPrimaryButton(
                    label: 'Connect',
                    icon: Icons.link,
                    onPressed: _connectToServerManually,
                    color: AppColors.primary,
                  ),
                ),
                if (Platform.isAndroid || Platform.isIOS) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSecondaryButton(
                      label: 'Scan QR',
                      icon: Icons.qr_code_scanner,
                      onPressed: _scanQRCode,
                      color: AppColors.secondary, // Green for scan
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element

  Widget _buildConnectedDeviceCard(DeviceInfo device) {
    return Card(
      color: AppColors.success,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.link, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Connected To',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    device.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    device.ipAddress,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _disconnect,
              icon: const Icon(Icons.close, color: Colors.white),
              tooltip: 'Disconnect',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.3), width: 1.5),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildTransfersTab() {
    final connectionState = ref.watch(connectionStateProvider);

    return connectionState.when(
      data: (state) {
        if (state != conn_mgr.ConnectionState.connected) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.link_off_rounded,
                    size: 48,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'No Connection',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connect to a device to start sharing files.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            Column(
              children: [
                // Transfers list
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      24,
                      16,
                      100,
                    ), // Bottom padding for FAB
                    children: [
                      // Sending section
                      _buildSendingSection(),
                      const SizedBox(height: 24),

                      // Receiving section
                      _buildReceivingSection(),
                    ],
                  ),
                ),
              ],
            ),

            // Floating File Picker Button
            Positioned(
              bottom: 24,
              right: 24,
              left: 24,
              child: ElevatedButton.icon(
                onPressed: _pickAndSendFile,
                icon: const Icon(Icons.add_rounded, size: 28),
                label: const Text(
                  'Send Files',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                  minimumSize: const Size(double.infinity, 64),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Error')),
    );
  }

  Widget _buildSendingSection() {
    final sendingTasks = ref.watch(sendingTasksProvider);

    return sendingTasks.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 12),
              child: Text(
                'SENDING (${tasks.length})',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textTertiary,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            ...tasks.map(
              (task) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TransferProgressCard(task: task),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildReceivingSection() {
    final receivingTasks = ref.watch(receivingTasksProvider);

    return receivingTasks.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 12),
              child: Text(
                'RECEIVING (${tasks.length})',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textTertiary,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            ...tasks.map(
              (task) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TransferProgressCard(task: task),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildHistoryTab() {
    final history = ref.watch(transferHistoryProvider);

    return history.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: AppColors.textTertiary),
                SizedBox(height: 16),
                Text(
                  'No transfer history',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return TransferProgressCard(task: tasks[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  Future<void> _startServer() async {
    try {
      final connectionManager = ref.read(connectionManagerProvider);

      // REFRESH DEVICE INFO NOW (to get latest IP)
      final deviceService = ref.read(deviceServiceProvider);
      deviceService.clearCache();
      await deviceService.getLocalDeviceInfo();

      await connectionManager.startServer();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Server started. Waiting for connection...'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to start server: $e')));
      }
    }
  }

  Future<void> _connectToServerManually() async {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter server IP address')),
      );
      return;
    }

    try {
      debugPrint('🔗 [UI] Connecting manually to $ip...');
      final connectionManager = ref.read(connectionManagerProvider);
      await connectionManager.connectToServer(ip);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connected to $ip successfully!')),
        );
      }
    } catch (e) {
      debugPrint('❌ [UI] Manual connection failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _scanQRCode() async {
    // 1. Scan QR
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );

    if (result != null && mounted) {
      debugPrint("📷 QR Result: $result");

      try {
        String? targetIp;

        // Try parsing JSON first (New Style)
        try {
          final Map<String, dynamic> data = jsonDecode(result);
          if (data.containsKey('ips')) {
            final ips = List<String>.from(data['ips']);
            // Pick first 192.168 if available, else first one
            targetIp = ips.firstWhere(
              (ip) => ip.startsWith('192.168'),
              orElse: () => ips.first,
            );
          } else if (data.containsKey('ip')) {
            targetIp = data['ip'];
          }
        } catch (_) {
          // Not JSON, assume raw IP string (Old Style)
          targetIp = result.trim();
        }

        if (targetIp != null) {
          setState(() {
            _ipController.text = targetIp!; // JUST FILL
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('IP Scanned: $targetIp')));
        } else {
          throw Exception("No IP found in QR");
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Invalid QR Data')));
        }
      }
    }
  }

  Future<void> _showPCQR() async {
    // Just show a QR with local IPs. No server/handshake logic.
    final pairingService = ref.read(pairingServiceProvider);
    final ips = await pairingService.getPCCandidateIPs();
    final qrPayload = jsonEncode({"ips": ips});

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => QRCodeDialog(
        deviceName: 'This Device IPs',
        ipAddress: ips.join('\n'), // Show all IPs visibily
        qrData: qrPayload,
      ),
    );
  }

  Future<void> _disconnect() async {
    final connectionManager = ref.read(connectionManagerProvider);
    await connectionManager.disconnect();

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Disconnected')));
    }
  }

  Future<void> _pickAndSendFile() async {
    List<File> files = [];

    if (Platform.isAndroid) {
      // Use Custom Picker to avoid 'unknown_path' crashes
      final paths = await Navigator.push<List<String>>(
        context,
        MaterialPageRoute(builder: (_) => const CustomFilePicker()),
      );
      if (paths == null || paths.isEmpty) return;
      files = paths.map((p) => File(p)).toList();
    } else {
      // Logic for Windows/Desktop
      try {
        final result = await FilePicker.platform.pickFiles(allowMultiple: true);
        if (result == null || result.files.isEmpty) return;
        files = result.files
            .where((f) => f.path != null)
            .map((f) => File(f.path!))
            .toList();
      } catch (e) {
        debugPrint("Windows FilePicker Error: $e");
        return;
      }
    }

    if (files.isEmpty) return;

    final transferEngine = ref.read(fileTransferEngineProvider);

    // Add files to queue
    await transferEngine.addFilesToQueue(files);

    // Start sending queue
    await transferEngine.startSendingQueue();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${files.length} file(s) added to queue'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }
}
