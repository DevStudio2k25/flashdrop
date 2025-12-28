import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';

class NetworkDiagnosticScreen extends StatefulWidget {
  const NetworkDiagnosticScreen({super.key});

  @override
  State<NetworkDiagnosticScreen> createState() =>
      _NetworkDiagnosticScreenState();
}

class _NetworkDiagnosticScreenState extends State<NetworkDiagnosticScreen> {
  String _localIp = 'Checking...';
  String _deviceName = 'Checking...';
  List<NetworkInterface> _interfaces = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkNetwork();
  }

  Future<void> _checkNetwork() async {
    setState(() => _isLoading = true);

    try {
      // Get all network interfaces
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: true,
      );

      // Get local IP
      String? localIp;
      for (final interface in interfaces) {
        debugPrint('🔌 Interface: ${interface.name}');
        for (final addr in interface.addresses) {
          debugPrint('   IP: ${addr.address} (loopback: ${addr.isLoopback})');
          if (!addr.isLoopback) {
            if (addr.address.startsWith('192.168.') ||
                addr.address.startsWith('10.') ||
                addr.address.startsWith('172.')) {
              localIp = addr.address;
              break;
            }
          }
        }
        if (localIp != null) break;
      }

      // Get device name
      final deviceInfo = DeviceInfoPlugin();
      String deviceName = 'Unknown';

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceName = '${androidInfo.brand} ${androidInfo.model}';
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        deviceName = windowsInfo.computerName;
      }

      setState(() {
        _localIp = localIp ?? 'Not found';
        _deviceName = deviceName;
        _interfaces = interfaces;
        _isLoading = false;
      });

      debugPrint('✅ Network check complete');
      debugPrint('   IP: $_localIp');
      debugPrint('   Device: $_deviceName');
    } catch (e) {
      debugPrint('❌ Network check failed: $e');
      setState(() {
        _localIp = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Diagnostic'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _checkNetwork),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(),
                  const SizedBox(height: 16),
                  _buildDeviceInfo(),
                  const SizedBox(height: 16),
                  _buildNetworkInterfaces(),
                  const SizedBox(height: 16),
                  _buildInstructions(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    final isConnected = _localIp != 'Not found' && _localIp != 'Checking...';

    return Card(
      color: isConnected ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              isConnected ? Icons.check_circle : Icons.error,
              size: 64,
              color: isConnected ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 12),
            Text(
              isConnected ? 'Network Connected' : 'Network Not Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isConnected
                    ? Colors.green.shade900
                    : Colors.red.shade900,
              ),
            ),
            const SizedBox(height: 8),
            if (isConnected)
              Text(
                'Your device is ready for file transfer',
                style: TextStyle(color: Colors.green.shade700),
              )
            else
              Text(
                'Please connect to WiFi or Hotspot',
                style: TextStyle(color: Colors.red.shade700),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Device Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoRow('Device Name', _deviceName),
            _buildInfoRow('Local IP', _localIp, copyable: true),
            _buildInfoRow(
              'Platform',
              Platform.isAndroid ? 'Android' : 'Windows',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
                if (copyable)
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('IP copied to clipboard')),
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

  Widget _buildNetworkInterfaces() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Network Interfaces',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            if (_interfaces.isEmpty)
              const Text('No network interfaces found')
            else
              ..._interfaces.map((interface) {
                return ExpansionTile(
                  title: Text(interface.name),
                  children: interface.addresses.map((addr) {
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        addr.isLoopback ? Icons.loop : Icons.wifi,
                        size: 20,
                      ),
                      title: Text(addr.address),
                      subtitle: Text(
                        addr.isLoopback ? 'Loopback' : 'Network',
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Connection Instructions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildInstruction(
              '1',
              'Mobile Hotspot Method',
              'Turn on hotspot on Android, connect Windows to it',
            ),
            const SizedBox(height: 12),
            _buildInstruction(
              '2',
              'Same WiFi Method',
              'Connect both devices to the same WiFi network',
            ),
            const SizedBox(height: 12),
            _buildInstruction(
              '3',
              'Check IP Address',
              'Both devices should have IP starting with 192.168.x.x or 10.x.x.x',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'If IP shows "Not found", you are not connected to any network',
                      style: TextStyle(color: Colors.blue.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstruction(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(radius: 16, child: Text(number)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                description,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
