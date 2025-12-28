import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/connection_provider.dart';
import '../../state/transfer_provider.dart';
import '../../state/database_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/status_badge.dart';
import '../widgets/transfer_progress_card.dart';
import '../../core/services/connection_manager.dart' as conn_mgr;
import '../../core/models/device_info.dart';
import 'package:file_picker/file_picker.dart';
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
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final connectionManager = ref.read(connectionManagerProvider);
    final transferEngine = ref.read(fileTransferEngineProvider);
    final database = ref.read(databaseServiceProvider);

    await connectionManager.initialize();
    await transferEngine.initialize();
    await database.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlashDrop'),
        actions: [_buildConnectionStatus(), const SizedBox(width: 16)],
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
        destinations: const [
          NavigationDestination(icon: Icon(Icons.wifi), label: 'Connect'),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz),
            label: 'Transfers',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
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
            );
          case conn_mgr.ConnectionState.connecting:
            return const StatusBadge(
              text: 'Connecting...',
              color: AppColors.warning,
            );
          case conn_mgr.ConnectionState.error:
            return const StatusBadge(text: 'Error', color: AppColors.error);
          default:
            return const StatusBadge(
              text: 'Disconnected',
              color: AppColors.textTertiary,
            );
        }
      },
      loading: () =>
          const StatusBadge(text: 'Loading...', color: AppColors.textTertiary),
      error: (_, __) =>
          const StatusBadge(text: 'Error', color: AppColors.error),
    );
  }

  Widget _buildConnectionTab() {
    final localDevice = ref.watch(localDeviceProvider);
    final remoteDevice = ref.watch(remoteDeviceProvider);
    final connectionState = ref.watch(connectionStateProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Local device info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Device',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  localDevice.when(
                    data: (device) {
                      if (device == null) {
                        return const Text('No device info');
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('Name', device.name),
                          _buildInfoRow('IP Address', device.ipAddress),
                          _buildInfoRow(
                            'Platform',
                            device.platform.toUpperCase(),
                          ),
                          _buildInfoRow('Port', device.port.toString()),
                        ],
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (error, _) => Text('Error: $error'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Connection controls
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Connection',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),

                  // Server OR Client mode (both Android and Windows)
                  if (Platform.isAndroid || Platform.isWindows) ...[
                    // Server status indicator
                    Consumer(
                      builder: (context, ref, child) {
                        final connectionState = ref.watch(
                          connectionStateProvider,
                        );
                        return connectionState.when(
                          data: (state) {
                            if (state == conn_mgr.ConnectionState.connected) {
                              return Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.success,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppColors.success,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            '✅ Server Running',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: AppColors.success,
                                            ),
                                          ),
                                          Consumer(
                                            builder: (context, ref, child) {
                                              final localDevice = ref.watch(
                                                localDeviceProvider,
                                              );
                                              return localDevice.when(
                                                data: (device) => Text(
                                                  'IP: ${device?.ipAddress ?? "Unknown"}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                                loading: () =>
                                                    const Text('Loading...'),
                                                error: (_, __) =>
                                                    const SizedBox.shrink(),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        );
                      },
                    ),

                    // Server button (always visible, changes based on state)
                    Consumer(
                      builder: (context, ref, child) {
                        final connectionState = ref.watch(
                          connectionStateProvider,
                        );
                        return connectionState.when(
                          data: (state) {
                            final isRunning =
                                state == conn_mgr.ConnectionState.connected;

                            return Column(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: isRunning
                                      ? _disconnect
                                      : _startServer,
                                  icon: Icon(
                                    isRunning
                                        ? Icons.stop
                                        : Icons.wifi_tethering,
                                  ),
                                  label: Text(
                                    isRunning
                                        ? 'Stop Server'
                                        : 'Start as Server (Hotspot Mode)',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(
                                      double.infinity,
                                      50,
                                    ),
                                    backgroundColor: isRunning
                                        ? AppColors.error
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isRunning
                                      ? '🟢 Server is running'
                                      : '📱 Enable hotspot, then start server',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isRunning
                                        ? AppColors.success
                                        : AppColors.textSecondary,
                                    fontWeight: isRunning
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Divider (only if not running)
                                if (!isRunning) ...[
                                  const Row(
                                    children: [
                                      Expanded(child: Divider()),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Text(
                                          'OR',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Expanded(child: Divider()),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ],
                            );
                          },
                          loading: () => ElevatedButton.icon(
                            onPressed: _startServer,
                            icon: const Icon(Icons.wifi_tethering),
                            label: const Text('Start as Server (Hotspot Mode)'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                            ),
                          ),
                          error: (_, __) => ElevatedButton.icon(
                            onPressed: _startServer,
                            icon: const Icon(Icons.wifi_tethering),
                            label: const Text('Start as Server (Hotspot Mode)'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                            ),
                          ),
                        );
                      },
                    ),

                    // Client mode (scan for other Android servers)
                    const Text(
                      '🔍 Connect to Another Device:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Scan button (for both Android and Windows)
                  if (Platform.isAndroid || Platform.isWindows) ...[
                    ElevatedButton.icon(
                      onPressed: _startDiscovery,
                      icon: _isScanning
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.search),
                      label: Text(
                        _isScanning
                            ? 'Scanning...'
                            : '🔍 Auto Scan for Devices',
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),

                    // Show scanning message
                    if (_isScanning)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Looking for nearby devices...',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Show discovered IPs
                    Consumer(
                      builder: (context, ref, child) {
                        final discoveredIPs = ref.watch(discoveredIPsProvider);

                        return discoveredIPs.when(
                          data: (ips) {
                            if (ips.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.devices,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Found ${ips.length} device(s):',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ...ips.map(
                                  (ip) => Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: const Icon(
                                        Icons.phone_android,
                                        color: AppColors.primary,
                                      ),
                                      title: Text(
                                        ip,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: const Text('FlashDrop Server'),
                                      trailing: ElevatedButton(
                                        onPressed: () => _connectToIP(ip),
                                        child: const Text('Connect'),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                          loading: () =>
                              const SizedBox.shrink(), // Don't show loading by default
                          error: (_, __) => const SizedBox.shrink(),
                        );
                      },
                    ),

                    // Divider
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Manual IP Entry
                    const Text(
                      '📝 Manual Connection:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Show Android IP if available
                    Consumer(
                      builder: (context, ref, child) {
                        final localDevice = ref.watch(localDeviceProvider);
                        return localDevice.when(
                          data: (device) {
                            if (device != null && Platform.isAndroid) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.primary.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.info_outline,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Your Android IP:',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            Text(
                                              device.ipAddress,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.copy),
                                        onPressed: () {
                                          // Copy to clipboard
                                          _ipController.text = device.ipAddress;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'IP copied to field!',
                                              ),
                                              duration: Duration(seconds: 1),
                                            ),
                                          );
                                        },
                                        tooltip: 'Copy to field',
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        );
                      },
                    ),

                    TextField(
                      controller: _ipController,
                      decoration: const InputDecoration(
                        labelText: 'Server IP Address',
                        hintText: '192.168.43.1',
                        prefixIcon: Icon(Icons.computer),
                        helperText:
                            'Enter Android hotspot IP (shown above if Android)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _connectToServerManually,
                      icon: const Icon(Icons.link),
                      label: const Text('Connect Manually'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: AppColors.secondary,
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Disconnect button
                  ...connectionState.when(
                    data: (state) {
                      if (state == conn_mgr.ConnectionState.connected) {
                        return [
                          OutlinedButton.icon(
                            onPressed: _disconnect,
                            icon: const Icon(Icons.link_off),
                            label: const Text('Disconnect'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              foregroundColor: AppColors.error,
                            ),
                          ),
                        ];
                      }
                      return <Widget>[];
                    },
                    loading: () => <Widget>[],
                    error: (_, __) => <Widget>[],
                  ),
                ],
              ),
            ),
          ),

          // Remote device info
          remoteDevice.when(
            data: (device) {
              if (device == null) return const SizedBox.shrink();
              return Column(
                children: [
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Connected Device',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow('Name', device.name),
                          _buildInfoRow('IP Address', device.ipAddress),
                          _buildInfoRow(
                            'Platform',
                            device.platform.toUpperCase(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.link_off, size: 64, color: AppColors.textTertiary),
                SizedBox(height: 16),
                Text(
                  'Not connected to any device',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Send file button
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _pickAndSendFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Select Files to Send'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),

            // Transfers list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
            Row(
              children: [
                const Icon(Icons.upload, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'SENDING (${tasks.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
            Row(
              children: [
                const Icon(Icons.download, color: AppColors.secondary),
                const SizedBox(width: 8),
                Text(
                  'RECEIVING (${tasks.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
      await connectionManager.startServer();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server started successfully')),
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

  Future<void> _startDiscovery() async {
    try {
      setState(() {
        _isScanning = true;
      });

      debugPrint('🔍 [UI] Starting discovery...');
      final connectionManager = ref.read(connectionManagerProvider);
      await connectionManager.startDiscovery();

      debugPrint('✅ [UI] Discovery started successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Scanning... Devices will appear below'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Auto-stop scanning after 30 seconds
      Future.delayed(const Duration(seconds: 30), () {
        if (mounted) {
          setState(() {
            _isScanning = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
      });

      debugPrint('❌ [UI] Discovery failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Discovery failed: $e\n\nCheck Windows Firewall!'),
            duration: Duration(seconds: 5),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _connectToDevice(DeviceInfo device) async {
    try {
      final connectionManager = ref.read(connectionManagerProvider);
      await connectionManager.connectToServer(device.ipAddress);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Connected to ${device.name}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Connection failed: $e')));
      }
    }
  }

  Future<void> _connectToIP(String ip) async {
    try {
      debugPrint('🔗 [UI] Connecting to $ip...');
      final connectionManager = ref.read(connectionManagerProvider);
      await connectionManager.connectToServer(ip);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Connected to $ip!')));
      }
    } catch (e) {
      debugPrint('❌ [UI] Connection failed: $e');
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
    try {
      // Allow multiple file selection
      final result = await FilePicker.platform.pickFiles(allowMultiple: true);
      if (result == null || result.files.isEmpty) return;

      // Convert to File objects
      final files = result.files
          .where((f) => f.path != null)
          .map((f) => File(f.path!))
          .toList();

      if (files.isEmpty) return;

      final transferEngine = ref.read(fileTransferEngineProvider);

      // Add files to queue
      await transferEngine.addFilesToQueue(files);

      // Start sending queue
      await transferEngine.startSendingQueue();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${files.length} file(s) added to queue')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send files: $e')));
      }
    }
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }
}
