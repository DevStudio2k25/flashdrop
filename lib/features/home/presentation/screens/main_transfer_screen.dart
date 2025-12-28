import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../connection/presentation/providers/simple_connection_provider.dart';
import '../../../connection/presentation/providers/connection_state.dart'
    as conn;
import '../../../connection/domain/entities/peer.dart';

/// Main transfer screen - All-in-one: Connect + Send + Receive + History
class MainTransferScreen extends ConsumerStatefulWidget {
  const MainTransferScreen({super.key});

  @override
  ConsumerState<MainTransferScreen> createState() => _MainTransferScreenState();
}

class _MainTransferScreenState extends ConsumerState<MainTransferScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<FileTransferItem> _history = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _startService();
  }

  Future<void> _startService() async {
    // Auto-start receiver mode
    await ref.read(simpleConnectionProvider.notifier).startReceiving();

    // Listen for received files
    final httpService = ref.read(simpleConnectionProvider.notifier).httpService;

    // Listen for progress
    httpService?.onProgress.listen((progress) {
      if (progress.isReceiving) {
        _showProgressDialog(
          progress.fileName,
          progress.progress,
          isReceiving: true,
        );
      }
    });

    httpService?.onFileReceived.listen((file) {
      // Close progress dialog
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      setState(() {
        _history.insert(
          0,
          FileTransferItem(
            fileName: file.path.split('/').last,
            filePath: file.path,
            fileSize: file.lengthSync(),
            timestamp: DateTime.now(),
            isReceived: true,
          ),
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Received: ${file.path.split('/').last}')),
        );
      }
    });
  }

  void _showProgressDialog(
    String fileName,
    double progress, {
    required bool isReceiving,
  }) {
    // Check if dialog is already showing
    if (ModalRoute.of(context)?.isCurrent == false) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(isReceiving ? '📥 Receiving' : '📤 Sending'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(fileName),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 8),
            Text('${(progress * 100).toStringAsFixed(0)}%'),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndSendFiles() async {
    final connectionState = ref.read(simpleConnectionProvider);

    // Check if connected
    Peer? connectedPeer;
    connectionState.maybeWhen(
      connected: (peer, _) => connectedPeer = peer,
      orElse: () {},
    );

    if (connectedPeer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please connect to a device first')),
      );
      return;
    }

    // Pick files
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;

    // Listen for progress
    final httpService = ref.read(simpleConnectionProvider.notifier).httpService;
    final progressSubscription = httpService?.onProgress.listen((progress) {
      if (!progress.isReceiving) {
        _showProgressDialog(
          progress.fileName,
          progress.progress,
          isReceiving: false,
        );
      }
    });

    // Send files
    for (final file in result.files) {
      if (file.path != null) {
        try {
          final fileObj = File(file.path!);
          await ref.read(simpleConnectionProvider.notifier).sendFile(fileObj);

          // Close progress dialog
          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }

          // Add to history
          setState(() {
            _history.insert(
              0,
              FileTransferItem(
                fileName: file.name,
                filePath: file.path!,
                fileSize: file.size,
                timestamp: DateTime.now(),
                isReceived: false,
              ),
            );
          });

          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('✅ Sent: ${file.name}')));
          }
        } catch (e) {
          // Close progress dialog on error
          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }

          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('❌ Failed: ${file.name}')));
          }
        }
      }
    }

    progressSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(simpleConnectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FlashDrop'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.swap_horiz), text: 'Transfer'),
            Tab(icon: Icon(Icons.history), text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildTransferTab(connectionState), _buildHistoryTab()],
      ),
    );
  }

  Widget _buildTransferTab(conn.ConnectionState connectionState) {
    return Column(
      children: [
        // Connection Status Card
        _buildConnectionCard(connectionState),

        // Available Devices
        Expanded(
          child: connectionState.maybeWhen(
            discovering: (peers) => _buildPeersList(peers),
            connected: (peer, _) => _buildConnectedView(peer),
            orElse: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionCard(conn.ConnectionState connectionState) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            connectionState.maybeWhen(
              discovering: (peers) => Row(
                children: [
                  const Icon(Icons.wifi_tethering, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ready to Connect',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('${peers.length} device(s) found'),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      ref
                          .read(simpleConnectionProvider.notifier)
                          .startDiscovery();
                    },
                  ),
                ],
              ),
              connected: (peer, _) => Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Connected',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(peer.name),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      ref.read(simpleConnectionProvider.notifier).disconnect();
                    },
                  ),
                ],
              ),
              orElse: () => const Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 12),
                  Text('Initializing...'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeersList(List<Peer> peers) {
    if (peers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.devices, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No devices found'),
            SizedBox(height: 8),
            Text('Make sure both devices are on same network'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: peers.length,
      itemBuilder: (context, index) {
        final peer = peers[index];
        return ListTile(
          leading: CircleAvatar(
            child: Icon(
              peer.deviceType == 'desktop'
                  ? Icons.computer
                  : Icons.phone_android,
            ),
          ),
          title: Text(peer.name),
          subtitle: Text(peer.ipAddress),
          trailing: ElevatedButton(
            onPressed: () {
              ref.read(simpleConnectionProvider.notifier).connectToPeer(peer);
            },
            child: const Text('Connect'),
          ),
        );
      },
    );
  }

  Widget _buildConnectedView(Peer peer) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 80, color: Colors.green),
          const SizedBox(height: 24),
          Text(
            'Connected to ${peer.name}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: _pickAndSendFiles,
            icon: const Icon(Icons.send, size: 32),
            label: const Text('Send Files', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
            ),
          ),
          const SizedBox(height: 16),
          const Text('You can send and receive files'),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_history.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No transfer history'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: item.isReceived
                ? Colors.green.shade100
                : Colors.blue.shade100,
            child: Icon(
              item.isReceived ? Icons.download : Icons.upload,
              color: item.isReceived ? Colors.green : Colors.blue,
            ),
          ),
          title: Text(item.fileName),
          subtitle: Text(
            '${_formatBytes(item.fileSize)} • ${_formatTime(item.timestamp)}',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: () {
              // Open file location
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('File: ${item.filePath}')));
            },
          ),
        );
      },
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class FileTransferItem {
  final String fileName;
  final String filePath;
  final int fileSize;
  final DateTime timestamp;
  final bool isReceived;

  FileTransferItem({
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.timestamp,
    required this.isReceived,
  });
}
