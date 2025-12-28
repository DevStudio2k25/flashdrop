import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/peer.dart';
import 'connection_state.dart';
import '../../../../services/http_file_transfer_service.dart';
import '../../../../services/discovery_service.dart';

part 'simple_connection_provider.g.dart';

/// Simple HTTP-based connection provider (no WebRTC!)
@riverpod
class SimpleConnection extends _$SimpleConnection {
  HttpFileTransferService? _httpService;
  DiscoveryService? _discoveryService;
  Peer? _connectedPeer;

  @override
  ConnectionState build() {
    debugPrint('🔧 [Connection] Initializing Simple HTTP Connection');
    return const ConnectionState.disconnected();
  }

  /// Start discovery
  Future<void> startDiscovery() async {
    debugPrint('🔍 [Connection] Starting discovery...');
    state = const ConnectionState.discovering(discoveredPeers: []);

    try {
      _discoveryService = DiscoveryService();
      await _discoveryService!.initialize();

      _discoveryService!.onPeersDiscovered.listen((peers) {
        debugPrint('📱 [Connection] ${peers.length} peer(s) found');
        state = ConnectionState.discovering(discoveredPeers: peers);
      });

      await _discoveryService!.startDiscovery();
      debugPrint('✅ [Connection] Discovery started');
    } catch (e) {
      debugPrint('❌ [Connection] Discovery failed: $e');
      state = ConnectionState.error(message: 'Failed to discover peers: $e');
    }
  }

  /// Connect to peer
  Future<void> connectToPeer(Peer peer) async {
    state = ConnectionState.connecting(peer: peer);

    try {
      debugPrint('🔗 [Connection] Connecting to ${peer.name}...');

      // Initialize discovery if not already done
      if (_discoveryService == null) {
        _discoveryService = DiscoveryService();
        await _discoveryService!.initialize();
      }

      _httpService ??= HttpFileTransferService();

      // Start server if not already started (needed for local IP)
      if (_httpService!.localIp == null) {
        await _httpService!.startServer(_discoveryService!.localIp!);
      }

      // Check if peer is reachable
      final isReachable = await _httpService!.checkConnection(peer.ipAddress);

      if (!isReachable) {
        throw Exception('Peer not reachable');
      }

      // Notify peer about connection
      await _httpService!.notifyConnection(peer.ipAddress);

      _connectedPeer = peer;
      state = ConnectionState.connected(peer: peer, dataChannelId: 'http');
      debugPrint('🎉 [Connection] CONNECTED to ${peer.name}!');
    } catch (e) {
      debugPrint('❌ [Connection] Failed: $e');
      state = ConnectionState.error(message: 'Connection failed: $e');
    }
  }

  /// Start receiver
  Future<void> startReceiving() async {
    try {
      debugPrint('📱 [Connection] Starting receiver...');

      _httpService = HttpFileTransferService();
      _discoveryService = DiscoveryService();

      await _discoveryService!.initialize();
      await _httpService!.startServer(_discoveryService!.localIp!);
      await _discoveryService!.startDiscovery();

      debugPrint('✅ [Connection] Receiver ready!');

      // Listen for received files
      _httpService!.onFileReceived.listen((file) {
        debugPrint('📥 [Connection] File received: ${file.path}');
      });

      // Listen for incoming connections
      _httpService!.onConnectionReceived.listen((senderIp) {
        debugPrint('🤝 [Connection] Incoming connection from $senderIp');

        // Find peer in discovered list
        final currentState = state;
        currentState.maybeWhen(
          discovering: (peers) {
            final peer = peers.firstWhere(
              (p) => p.ipAddress == senderIp,
              orElse: () => Peer(
                id: 'peer-$senderIp',
                name: 'Device',
                ipAddress: senderIp,
                deviceType: 'unknown',
              ),
            );

            _connectedPeer = peer;
            state = ConnectionState.connected(
              peer: peer,
              dataChannelId: 'http',
            );
            debugPrint('🎉 [Connection] AUTO-CONNECTED to ${peer.name}!');
          },
          orElse: () {},
        );
      });

      // Listen for discovered peers
      _discoveryService!.onPeersDiscovered.listen((peers) {
        debugPrint('📱 [Connection] ${peers.length} peer(s) found');

        // Only update if not connected
        state.maybeWhen(
          discovering: (_) {
            state = ConnectionState.discovering(discoveredPeers: peers);
          },
          disconnected: () {
            state = ConnectionState.discovering(discoveredPeers: peers);
          },
          orElse: () {},
        );
      });

      // Set initial state to discovering
      state = const ConnectionState.discovering(discoveredPeers: []);
      debugPrint('🎉 [Connection] Receiver READY - Discovering peers!');
    } catch (e) {
      debugPrint('❌ [Connection] Failed: $e');
      state = ConnectionState.error(message: 'Failed to start: $e');
    }
  }

  /// Send file
  Future<void> sendFile(File file) async {
    if (_connectedPeer == null) throw Exception('No peer connected');

    try {
      debugPrint('📤 [Connection] Sending file...');
      await _httpService!.sendFile(_connectedPeer!.ipAddress, file);
      debugPrint('✅ [Connection] File sent!');
    } catch (e) {
      debugPrint('❌ [Connection] Send failed: $e');
      rethrow;
    }
  }

  /// Disconnect
  Future<void> disconnect() async {
    await _httpService?.stopServer();
    _discoveryService?.stopDiscovery();
    _httpService = null;
    _discoveryService = null;
    _connectedPeer = null;
    state = const ConnectionState.disconnected();
  }

  /// Get HTTP service
  HttpFileTransferService? get httpService => _httpService;
}
