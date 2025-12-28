import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PairingService {
  ServerSocket? _serverSocket;
  static const int pairingPort = 4040; // Changed to match app port hope
  static const int discoveryPort = 4041; // UDP Discovery Port

  /// PC: Starts listening for a Mobile device to perform a handshake.
  /// Returns the Mobile's IP address if successful.
  Future<String?> startPairingServer(String expectedToken) async {
    final completer = Completer<String?>();

    try {
      await stopPairingServer();

      _serverSocket = await ServerSocket.bind(
        InternetAddress.anyIPv4,
        pairingPort,
        shared: true,
      );
      debugPrint(
        '🤝 [Pairing] PC Listener ACTIVE on port $pairingPort. Token: $expectedToken',
      );
      debugPrint('   [Pairing] Listening on all interfaces: 0.0.0.0');

      _serverSocket!.listen((socket) {
        final remoteIp = socket.remoteAddress.address;
        debugPrint('🤝 [Pairing] HIT from $remoteIp');

        socket.listen((data) {
          try {
            final msg = String.fromCharCodes(data).trim();
            debugPrint('   [Pairing] Payload: $msg');

            final json = jsonDecode(msg);
            if (json['token'] == expectedToken) {
              // Prefer the actual connection IP (most reliable)
              final mobileIp = socket.remoteAddress.address;
              debugPrint('   [Pairing] Authenticated! IP: $mobileIp');

              // Ack
              socket.write('ACK');

              if (!completer.isCompleted) completer.complete(mobileIp);
            }
          } catch (e) {
            debugPrint('   [Pairing] Error: $e');
          } finally {
            socket.close();
          }
        });
      }, onError: (e) => debugPrint("   [Pairing] Socket Error: $e"));

      return completer.future;
    } catch (e) {
      debugPrint('🤝 [Pairing] Bind Failed: $e');
      return null;
    }
  }

  Future<void> stopPairingServer() async {
    try {
      if (_serverSocket != null) {
        await _serverSocket!.close();
        _serverSocket = null;
      }
    } catch (e) {
      debugPrint('Error stopping pairing server: $e');
    }
  }

  Future<bool> handshakeWithPC(
    List<String> pcIps,
    String myIp,
    String token,
  ) async {
    debugPrint('🤝 [Pairing] Handshake targets: $pcIps');

    // 1. Try UDP Punch/Direct Message first (Bypasses some TCP restrictions)
    try {
      final udpSocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        0,
      );
      for (final ip in pcIps) {
        final data = jsonEncode({
          "id": "pairing_knock",
          "name": "Pairing",
          "type": "mobile_handshake",
          "ipAddress": myIp,
          "port": 4040,
          "token": token, // Custom field
        }).codeUnits;
        udpSocket.send(data, InternetAddress(ip), discoveryPort);
        debugPrint('   [Pairing] UDP Knock sent to $ip:$discoveryPort');
      }
      udpSocket.close();
    } catch (e) {
      debugPrint('   [Pairing] UDP Knock failed: $e');
    }

    // 2. Try TCP Connect (Existing Logic)
    for (final pcIp in pcIps) {
      Socket? socket;
      try {
        debugPrint('🤝 [Pairing] Dialing $pcIp:$pairingPort...');
        socket = await Socket.connect(
          pcIp,
          pairingPort,
          timeout: const Duration(milliseconds: 1000),
        );

        final payload = jsonEncode({
          "token": token,
          "ip": myIp,
          "device": "Android",
        });
        socket.write(payload);
        await socket.flush();
        debugPrint('🤝 [Pairing] SUCCESS sending to $pcIp');
        socket.destroy();
        return true;
      } catch (e) {
        debugPrint('   [Pairing] Failed $pcIp: $e (Trying next...)');
      } finally {
        socket?.destroy();
      }
    }
    return false;
  }

  Future<List<String>> getPCCandidateIPs() async {
    final ips = <String>[];
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
      );
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (!addr.isLoopback) {
            ips.add(addr.address);
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetch IPs: $e');
    }
    return ips; // Return ALL IPs naturally
  }
}

final pairingServiceProvider = Provider((ref) => PairingService());
