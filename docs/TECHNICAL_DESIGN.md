# FlashDrop - Technical Design (Flutter Implementation)

**Version:** 1.0  
**Date:** December 28, 2025

---

## 1. FLUTTER PROJECT STRUCTURE

```
flashdrop/
├── android/                      # Android-specific configuration
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── AndroidManifest.xml
│   │   │   └── kotlin/
│   │   │       └── com/flashdrop/
│   │   │           └── ForegroundService.kt
│   │   └── build.gradle
│   └── build.gradle
│
├── windows/                      # Windows-specific configuration
│   ├── runner/
│   │   ├── main.cpp
│   │   └── Runner.rc
│   └── CMakeLists.txt
│
├── lib/
│   ├── main.dart                # App entry point
│   │
│   ├── core/                    # Core utilities
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   └── transfer_constants.dart
│   │   ├── errors/
│   │   │   ├── failures.dart
│   │   │   └── exceptions.dart
│   │   ├── utils/
│   │   │   ├── file_utils.dart
│   │   │   ├── network_utils.dart
│   │   │   └── checksum_utils.dart
│   │   └── platform/
│   │       ├── platform_info.dart
│   │       └── platform_channels.dart
│   │
│   ├── features/                # Feature modules
│   │   ├── connection/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── webrtc_datasource.dart
│   │   │   │   │   └── signaling_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   ├── peer_model.dart
│   │   │   │   │   └── sdp_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── connection_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── peer.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── connection_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── establish_connection.dart
│   │   │   │       ├── discover_peers.dart
│   │   │   │       └── disconnect.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── connection_provider.dart
│   │   │       ├── screens/
│   │   │       │   ├── connection_screen.dart
│   │   │       │   └── qr_scan_screen.dart
│   │   │       └── widgets/
│   │   │           ├── peer_list_item.dart
│   │   │           └── connection_status_indicator.dart
│   │   │
│   │   ├── transfer/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── file_datasource.dart
│   │   │   │   │   └── datachannel_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   ├── file_metadata_model.dart
│   │   │   │   │   ├── chunk_model.dart
│   │   │   │   │   └── transfer_progress_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── transfer_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── file_metadata.dart
│   │   │   │   │   ├── chunk.dart
│   │   │   │   │   └── transfer_progress.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── transfer_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── send_files.dart
│   │   │   │       ├── receive_files.dart
│   │   │   │       ├── pause_transfer.dart
│   │   │   │       ├── resume_transfer.dart
│   │   │   │       └── cancel_transfer.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── transfer_provider.dart
│   │   │       ├── screens/
│   │   │       │   ├── file_selection_screen.dart
│   │   │       │   ├── transfer_screen.dart
│   │   │       │   └── receive_confirmation_screen.dart
│   │   │       └── widgets/
│   │   │           ├── file_list_item.dart
│   │   │           ├── transfer_progress_card.dart
│   │   │           └── speed_indicator.dart
│   │   │
│   │   └── home/
│   │       └── presentation/
│   │           ├── screens/
│   │           │   └── home_screen.dart
│   │           └── widgets/
│   │               ├── send_button.dart
│   │               └── receive_button.dart
│   │
│   ├── shared/                  # Shared widgets & themes
│   │   ├── widgets/
│   │   │   ├── custom_button.dart
│   │   │   ├── loading_indicator.dart
│   │   │   └── error_dialog.dart
│   │   └── theme/
│   │       ├── app_theme.dart
│   │       ├── colors.dart
│   │       └── text_styles.dart
│   │
│   └── services/                # Global services
│       ├── webrtc_service.dart
│       ├── signaling_service.dart
│       ├── file_service.dart
│       ├── permission_service.dart
│       └── notification_service.dart
│
├── test/                        # Unit & widget tests
│   ├── features/
│   │   ├── connection/
│   │   └── transfer/
│   └── core/
│
├── integration_test/            # Integration tests
│   └── app_test.dart
│
├── pubspec.yaml
└── README.md
```

---

## 2. KEY DEPENDENCIES (pubspec.yaml)

```yaml
name: flashdrop
description: Fast, private, peer-to-peer file transfer app
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

  # WebRTC
  flutter_webrtc: ^0.9.48

  # File System
  file_picker: ^6.1.1
  path_provider: ^2.1.1
  permission_handler: ^11.1.0

  # Network
  network_info_plus: ^5.0.1
  http: ^1.1.2

  # QR Code
  qr_flutter: ^4.1.0
  mobile_scanner: ^3.5.5

  # UI
  flutter_svg: ^2.0.9
  google_fonts: ^6.1.0
  animations: ^2.0.11

  # Utilities
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  uuid: ^4.2.2
  crypto: ^3.0.3
  crc32: ^1.0.0

  # Platform
  device_info_plus: ^9.1.1
  package_info_plus: ^5.0.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  flutter_lints: ^3.0.1
  
  # Code Generation
  build_runner: ^2.4.7
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  riverpod_generator: ^2.3.9

  # Testing
  mockito: ^5.4.4
  integration_test:
    sdk: flutter

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
```

---

## 3. STATE MANAGEMENT (RIVERPOD)

### 3.1 Connection Provider

```dart
// lib/features/connection/presentation/providers/connection_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flashdrop/features/connection/domain/entities/peer.dart';
import 'package:flashdrop/features/connection/domain/usecases/establish_connection.dart';
import 'package:flashdrop/features/connection/domain/usecases/discover_peers.dart';

part 'connection_provider.g.dart';

@freezed
class ConnectionState with _$ConnectionState {
  const factory ConnectionState.disconnected() = _Disconnected;
  const factory ConnectionState.discovering({
    required List<Peer> discoveredPeers,
  }) = _Discovering;
  const factory ConnectionState.connecting({
    required Peer peer,
  }) = _Connecting;
  const factory ConnectionState.connected({
    required Peer peer,
    required String dataChannelId,
  }) = _Connected;
  const factory ConnectionState.error({
    required String message,
  }) = _ConnectionError;
}

@riverpod
class ConnectionNotifier extends _$ConnectionNotifier {
  @override
  ConnectionState build() {
    return const ConnectionState.disconnected();
  }

  Future<void> startDiscovery() async {
    state = ConnectionState.discovering(discoveredPeers: []);
    
    final discoverPeers = ref.read(discoverPeersUsecaseProvider);
    
    await for (final peer in discoverPeers.execute()) {
      if (state is _Discovering) {
        final currentPeers = (state as _Discovering).discoveredPeers;
        state = ConnectionState.discovering(
          discoveredPeers: [...currentPeers, peer],
        );
      }
    }
  }

  Future<void> connectToPeer(Peer peer) async {
    state = ConnectionState.connecting(peer: peer);
    
    final establishConnection = ref.read(establishConnectionUsecaseProvider);
    
    final result = await establishConnection.execute(peer);
    
    result.fold(
      (failure) => state = ConnectionState.error(message: failure.message),
      (dataChannelId) => state = ConnectionState.connected(
        peer: peer,
        dataChannelId: dataChannelId,
      ),
    );
  }

  void disconnect() {
    // Close WebRTC connection
    ref.read(webrtcServiceProvider).closeConnection();
    state = const ConnectionState.disconnected();
  }
}
```

### 3.2 Transfer Provider

```dart
// lib/features/transfer/presentation/providers/transfer_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flashdrop/features/transfer/domain/entities/file_metadata.dart';
import 'package:flashdrop/features/transfer/domain/entities/transfer_progress.dart';
import 'package:flashdrop/features/transfer/domain/usecases/send_files.dart';

part 'transfer_provider.g.dart';

@freezed
class TransferState with _$TransferState {
  const factory TransferState.idle() = _Idle;
  const factory TransferState.preparing({
    required List<FileMetadata> files,
  }) = _Preparing;
  const factory TransferState.transferring({
    required TransferProgress progress,
  }) = _Transferring;
  const factory TransferState.paused({
    required TransferProgress progress,
  }) = _Paused;
  const factory TransferState.completed({
    required List<String> savedPaths,
  }) = _Completed;
  const factory TransferState.failed({
    required String error,
  }) = _Failed;
}

@riverpod
class TransferNotifier extends _$TransferNotifier {
  @override
  TransferState build() {
    return const TransferState.idle();
  }

  Future<void> sendFiles(List<FileMetadata> files) async {
    state = TransferState.preparing(files: files);
    
    final sendFilesUsecase = ref.read(sendFilesUsecaseProvider);
    
    await for (final progress in sendFilesUsecase.execute(files)) {
      state = TransferState.transferring(progress: progress);
    }
    
    // Transfer complete
    state = TransferState.completed(savedPaths: []);
  }

  void pauseTransfer() {
    if (state is _Transferring) {
      final progress = (state as _Transferring).progress;
      state = TransferState.paused(progress: progress);
      ref.read(transferRepositoryProvider).pauseTransfer();
    }
  }

  Future<void> resumeTransfer() async {
    if (state is _Paused) {
      final progress = (state as _Paused).progress;
      state = TransferState.transferring(progress: progress);
      
      await ref.read(transferRepositoryProvider).resumeTransfer();
    }
  }

  void cancelTransfer() {
    ref.read(transferRepositoryProvider).cancelTransfer();
    state = const TransferState.idle();
  }
}
```

---

## 4. WEBRTC INTEGRATION

### 4.1 WebRTC Service

```dart
// lib/services/webrtc_service.dart

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flashdrop/core/constants/transfer_constants.dart';

class WebRTCService {
  RTCPeerConnection? _peerConnection;
  RTCDataChannel? _dataChannel;
  
  final _onDataChannelMessageController = StreamController<RTCDataChannelMessage>.broadcast();
  Stream<RTCDataChannelMessage> get onDataChannelMessage => _onDataChannelMessageController.stream;
  
  final _onConnectionStateChangeController = StreamController<RTCPeerConnectionState>.broadcast();
  Stream<RTCPeerConnectionState> get onConnectionStateChange => _onConnectionStateChangeController.stream;

  static const Map<String, dynamic> _configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ],
    'sdpSemantics': 'unified-plan',
  };

  static const Map<String, dynamic> _dataChannelConfig = {
    'ordered': true,
    'maxRetransmits': 3,
  };

  Future<void> initialize() async {
    _peerConnection = await createPeerConnection(_configuration);
    
    _peerConnection!.onConnectionState = (state) {
      _onConnectionStateChangeController.add(state);
    };
    
    _peerConnection!.onDataChannel = (channel) {
      _setupDataChannel(channel);
    };
  }

  Future<RTCSessionDescription> createOffer() async {
    // Create data channel before offer (for offerer)
    _dataChannel = await _peerConnection!.createDataChannel(
      'file-transfer',
      RTCDataChannelInit()..ordered = true..maxRetransmits = 3,
    );
    _setupDataChannel(_dataChannel!);
    
    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    return offer;
  }

  Future<RTCSessionDescription> createAnswer(RTCSessionDescription offer) async {
    await _peerConnection!.setRemoteDescription(offer);
    
    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    return answer;
  }

  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    await _peerConnection!.setRemoteDescription(description);
  }

  Future<void> addIceCandidate(RTCIceCandidate candidate) async {
    await _peerConnection!.addCandidate(candidate);
  }

  void _setupDataChannel(RTCDataChannel channel) {
    _dataChannel = channel;
    
    _dataChannel!.onMessage = (message) {
      _onDataChannelMessageController.add(message);
    };
    
    _dataChannel!.onDataChannelState = (state) {
      print('DataChannel state: $state');
    };
  }

  Future<void> sendData(Uint8List data) async {
    if (_dataChannel?.state == RTCDataChannelState.RTCDataChannelOpen) {
      await _dataChannel!.send(RTCDataChannelMessage.fromBinary(data));
    } else {
      throw Exception('DataChannel not open');
    }
  }

  Future<void> sendText(String text) async {
    if (_dataChannel?.state == RTCDataChannelState.RTCDataChannelOpen) {
      await _dataChannel!.send(RTCDataChannelMessage(text));
    } else {
      throw Exception('DataChannel not open');
    }
  }

  bool get isDataChannelOpen => 
    _dataChannel?.state == RTCDataChannelState.RTCDataChannelOpen;

  Future<void> closeConnection() async {
    await _dataChannel?.close();
    await _peerConnection?.close();
    
    _dataChannel = null;
    _peerConnection = null;
  }

  void dispose() {
    _onDataChannelMessageController.close();
    _onConnectionStateChangeController.close();
  }
}
```

### 4.2 Signaling Service (Local HTTP Server)

```dart
// lib/services/signaling_service.dart

import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

class SignalingService {
  HttpServer? _server;
  String? _localIp;
  int _port = 8080;
  
  RTCSessionDescription? _pendingOffer;
  RTCSessionDescription? _pendingAnswer;
  final List<RTCIceCandidate> _iceCandidates = [];
  
  final _onOfferReceivedController = StreamController<RTCSessionDescription>.broadcast();
  Stream<RTCSessionDescription> get onOfferReceived => _onOfferReceivedController.stream;

  Future<void> startServer() async {
    _localIp = await _getLocalIp();
    
    final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_corsMiddleware())
      .addHandler(_router);
    
    _server = await shelf_io.serve(handler, _localIp!, _port);
    print('Signaling server running at http://$_localIp:$_port');
  }

  Middleware _corsMiddleware() {
    return (Handler handler) {
      return (Request request) async {
        if (request.method == 'OPTIONS') {
          return Response.ok('', headers: _corsHeaders);
        }
        
        final response = await handler(request);
        return response.change(headers: _corsHeaders);
      };
    };
  }

  Map<String, String> get _corsHeaders => {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  };

  Future<Response> _router(Request request) async {
    if (request.url.path == 'offer' && request.method == 'POST') {
      return await _handleOffer(request);
    } else if (request.url.path == 'answer' && request.method == 'GET') {
      return _handleGetAnswer(request);
    } else if (request.url.path == 'ice' && request.method == 'POST') {
      return await _handleIceCandidate(request);
    }
    
    return Response.notFound('Not found');
  }

  Future<Response> _handleOffer(Request request) async {
    final body = await request.readAsString();
    final json = jsonDecode(body);
    
    _pendingOffer = RTCSessionDescription(
      json['sdp'],
      json['type'],
    );
    
    _onOfferReceivedController.add(_pendingOffer!);
    
    return Response.ok(jsonEncode({'status': 'offer received'}));
  }

  Response _handleGetAnswer(Request request) {
    if (_pendingAnswer != null) {
      return Response.ok(jsonEncode({
        'sdp': _pendingAnswer!.sdp,
        'type': _pendingAnswer!.type,
      }));
    }
    
    return Response(202, body: jsonEncode({'status': 'waiting for answer'}));
  }

  Future<Response> _handleIceCandidate(Request request) async {
    final body = await request.readAsString();
    final json = jsonDecode(body);
    
    final candidate = RTCIceCandidate(
      json['candidate'],
      json['sdpMid'],
      json['sdpMLineIndex'],
    );
    
    _iceCandidates.add(candidate);
    
    return Response.ok(jsonEncode({'status': 'ice candidate received'}));
  }

  void setAnswer(RTCSessionDescription answer) {
    _pendingAnswer = answer;
  }

  List<RTCIceCandidate> getIceCandidates() {
    return List.from(_iceCandidates);
  }

  Future<String> _getLocalIp() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
    );
    
    for (final interface in interfaces) {
      for (final addr in interface.addresses) {
        if (!addr.isLoopback && addr.address.startsWith('192.168.')) {
          return addr.address;
        }
      }
    }
    
    return '127.0.0.1';
  }

  String get serverUrl => 'http://$_localIp:$_port';

  Future<void> stopServer() async {
    await _server?.close();
    _server = null;
  }

  void dispose() {
    _onOfferReceivedController.close();
  }
}
```

---

## 5. FILE TRANSFER ENGINE

### 5.1 File Chunker

```dart
// lib/features/transfer/data/datasources/file_datasource.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flashdrop/features/transfer/domain/entities/chunk.dart';
import 'package:flashdrop/core/constants/transfer_constants.dart';

class FileDataSource {
  static const int CHUNK_SIZE = TransferConstants.chunkSize; // 64KB

  Stream<Chunk> chunkFile(File file) async* {
    final fileSize = await file.length();
    final totalChunks = (fileSize / CHUNK_SIZE).ceil();
    
    final randomAccessFile = await file.open(mode: FileMode.read);
    
    try {
      int chunkIndex = 0;
      int offset = 0;
      
      while (offset < fileSize) {
        final remainingBytes = fileSize - offset;
        final currentChunkSize = remainingBytes < CHUNK_SIZE 
          ? remainingBytes 
          : CHUNK_SIZE;
        
        final bytes = await randomAccessFile.read(currentChunkSize);
        final checksum = _calculateChecksum(bytes);
        
        yield Chunk(
          index: chunkIndex,
          data: Uint8List.fromList(bytes),
          checksum: checksum,
          totalChunks: totalChunks,
        );
        
        offset += currentChunkSize;
        chunkIndex++;
      }
    } finally {
      await randomAccessFile.close();
    }
  }

  String _calculateChecksum(List<int> bytes) {
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> writeChunk(File file, Chunk chunk) async {
    final randomAccessFile = await file.open(mode: FileMode.append);
    
    try {
      // Verify checksum
      final calculatedChecksum = _calculateChecksum(chunk.data);
      if (calculatedChecksum != chunk.checksum) {
        throw Exception('Checksum mismatch for chunk ${chunk.index}');
      }
      
      await randomAccessFile.writeFrom(chunk.data);
    } finally {
      await randomAccessFile.close();
    }
  }

  Future<FileMetadata> getFileMetadata(File file) async {
    final stat = await file.stat();
    final name = file.path.split('/').last;
    
    return FileMetadata(
      name: name,
      size: stat.size,
      mimeType: _getMimeType(name),
      path: file.path,
    );
  }

  String _getMimeType(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    
    const mimeTypes = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'pdf': 'application/pdf',
      'mp4': 'video/mp4',
      'mp3': 'audio/mpeg',
      'zip': 'application/zip',
    };
    
    return mimeTypes[extension] ?? 'application/octet-stream';
  }
}
```

### 5.2 Transfer Repository Implementation

```dart
// lib/features/transfer/data/repositories/transfer_repository_impl.dart

import 'dart:async';
import 'dart:convert';
import 'package:flashdrop/features/transfer/domain/entities/file_metadata.dart';
import 'package:flashdrop/features/transfer/domain/entities/transfer_progress.dart';
import 'package:flashdrop/features/transfer/domain/repositories/transfer_repository.dart';
import 'package:flashdrop/services/webrtc_service.dart';
import 'package:flashdrop/features/transfer/data/datasources/file_datasource.dart';

class TransferRepositoryImpl implements TransferRepository {
  final WebRTCService webrtcService;
  final FileDataSource fileDataSource;
  
  bool _isPaused = false;
  bool _isCancelled = false;
  
  TransferRepositoryImpl({
    required this.webrtcService,
    required this.fileDataSource,
  });

  @override
  Stream<TransferProgress> sendFiles(List<FileMetadata> files) async* {
    _isPaused = false;
    _isCancelled = false;
    
    int totalBytes = files.fold(0, (sum, file) => sum + file.size);
    int transferredBytes = 0;
    
    final startTime = DateTime.now();
    
    for (int fileIndex = 0; fileIndex < files.length; fileIndex++) {
      if (_isCancelled) break;
      
      final file = files[fileIndex];
      final fileObj = File(file.path);
      
      // Send file metadata
      await _sendMetadata(file, fileIndex, files.length);
      
      int fileTransferredBytes = 0;
      
      // Send file chunks
      await for (final chunk in fileDataSource.chunkFile(fileObj)) {
        // Handle pause
        while (_isPaused && !_isCancelled) {
          await Future.delayed(Duration(milliseconds: 100));
        }
        
        if (_isCancelled) break;
        
        await _sendChunk(chunk);
        
        fileTransferredBytes += chunk.data.length;
        transferredBytes += chunk.data.length;
        
        final elapsed = DateTime.now().difference(startTime);
        final speed = transferredBytes / elapsed.inSeconds;
        final remaining = (totalBytes - transferredBytes) / speed;
        
        yield TransferProgress(
          currentFileIndex: fileIndex,
          totalFiles: files.length,
          currentFileBytes: fileTransferredBytes,
          currentFileTotalBytes: file.size,
          totalBytesTransferred: transferredBytes,
          totalBytes: totalBytes,
          speedBytesPerSecond: speed,
          estimatedTimeRemaining: Duration(seconds: remaining.toInt()),
        );
      }
      
      // Send completion signal for this file
      await _sendFileComplete(fileIndex);
    }
    
    // Send overall completion signal
    await _sendTransferComplete();
  }

  Future<void> _sendMetadata(FileMetadata file, int fileIndex, int totalFiles) async {
    final metadata = {
      'type': 'metadata',
      'fileIndex': fileIndex,
      'totalFiles': totalFiles,
      'name': file.name,
      'size': file.size,
      'mimeType': file.mimeType,
    };
    
    await webrtcService.sendText(jsonEncode(metadata));
  }

  Future<void> _sendChunk(Chunk chunk) async {
    // Send chunk header (JSON)
    final header = {
      'type': 'chunk',
      'index': chunk.index,
      'totalChunks': chunk.totalChunks,
      'checksum': chunk.checksum,
      'size': chunk.data.length,
    };
    
    await webrtcService.sendText(jsonEncode(header));
    
    // Wait for small delay to ensure header is processed
    await Future.delayed(Duration(milliseconds: 10));
    
    // Send chunk data (binary)
    await webrtcService.sendData(chunk.data);
    
    // Wait for ACK (simplified - in production, implement proper ACK handling)
    await Future.delayed(Duration(milliseconds: 5));
  }

  Future<void> _sendFileComplete(int fileIndex) async {
    final message = {
      'type': 'file_complete',
      'fileIndex': fileIndex,
    };
    
    await webrtcService.sendText(jsonEncode(message));
  }

  Future<void> _sendTransferComplete() async {
    final message = {'type': 'transfer_complete'};
    await webrtcService.sendText(jsonEncode(message));
  }

  @override
  void pauseTransfer() {
    _isPaused = true;
  }

  @override
  Future<void> resumeTransfer() async {
    _isPaused = false;
  }

  @override
  void cancelTransfer() {
    _isCancelled = true;
  }

  @override
  Stream<TransferProgress> receiveFiles(String savePath) async* {
    // Implementation for receiving files
    // Listen to WebRTC data channel messages
    // Reconstruct files from chunks
    // Yield progress updates
    
    // This is a simplified version - full implementation would be more complex
    await for (final message in webrtcService.onDataChannelMessage) {
      if (message.isBinary) {
        // Handle binary chunk data
      } else {
        // Handle JSON control messages
        final json = jsonDecode(message.text);
        
        if (json['type'] == 'metadata') {
          // Prepare to receive file
        } else if (json['type'] == 'chunk') {
          // Prepare to receive chunk data
        }
      }
    }
  }
}
```

---

## 6. DOMAIN ENTITIES

### 6.1 Core Entities

```dart
// lib/features/transfer/domain/entities/file_metadata.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_metadata.freezed.dart';

@freezed
class FileMetadata with _$FileMetadata {
  const factory FileMetadata({
    required String name,
    required int size,
    required String mimeType,
    required String path,
  }) = _FileMetadata;
}
```

```dart
// lib/features/transfer/domain/entities/chunk.dart

import 'dart:typed_data';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chunk.freezed.dart';

@freezed
class Chunk with _$Chunk {
  const factory Chunk({
    required int index,
    required Uint8List data,
    required String checksum,
    required int totalChunks,
  }) = _Chunk;
}
```

```dart
// lib/features/transfer/domain/entities/transfer_progress.dart

class TransferProgress {
  final int currentFileIndex;
  final int totalFiles;
  final int currentFileBytes;
  final int currentFileTotalBytes;
  final int totalBytesTransferred;
  final int totalBytes;
  final double speedBytesPerSecond;
  final Duration estimatedTimeRemaining;

  TransferProgress({
    required this.currentFileIndex,
    required this.totalFiles,
    required this.currentFileBytes,
    required this.currentFileTotalBytes,
    required this.totalBytesTransferred,
    required this.totalBytes,
    required this.speedBytesPerSecond,
    required this.estimatedTimeRemaining,
  });

  double get overallProgress => totalBytesTransferred / totalBytes;
  
  double get currentFileProgress => currentFileBytes / currentFileTotalBytes;
  
  String get speedMbps => (speedBytesPerSecond * 8 / 1000000).toStringAsFixed(2);
  
  String get formattedETA {
    final hours = estimatedTimeRemaining.inHours;
    final minutes = estimatedTimeRemaining.inMinutes % 60;
    final seconds = estimatedTimeRemaining.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
```

---

## 7. PLATFORM-SPECIFIC IMPLEMENTATION

### 7.1 Android Foreground Service

```kotlin
// android/app/src/main/kotlin/com/flashdrop/ForegroundService.kt

package com.flashdrop

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

class TransferForegroundService : Service() {
    companion object {
        const val CHANNEL_ID = "flashdrop_transfer"
        const val NOTIFICATION_ID = 1
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notification = createNotification("Preparing transfer...")
        startForeground(NOTIFICATION_ID, notification)
        return START_STICKY
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "File Transfer",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "FlashDrop file transfer notifications"
            }
            
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(message: String): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("FlashDrop")
            .setContentText(message)
            .setSmallIcon(R.drawable.ic_notification)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    fun updateNotification(progress: Int, speed: String) {
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Transferring files")
            .setContentText("$progress% • $speed Mbps")
            .setSmallIcon(R.drawable.ic_notification)
            .setProgress(100, progress, false)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
        
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(NOTIFICATION_ID, notification)
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
```

### 7.2 Platform Channel (Flutter ↔ Native)

```dart
// lib/core/platform/platform_channels.dart

import 'package:flutter/services.dart';

class PlatformChannels {
  static const _foregroundServiceChannel = MethodChannel('com.flashdrop/foreground_service');

  static Future<void> startForegroundService() async {
    try {
      await _foregroundServiceChannel.invokeMethod('startForeground');
    } on PlatformException catch (e) {
      print('Failed to start foreground service: ${e.message}');
    }
  }

  static Future<void> updateNotification({
    required int progress,
    required String speed,
  }) async {
    try {
      await _foregroundServiceChannel.invokeMethod('updateNotification', {
        'progress': progress,
        'speed': speed,
      });
    } on PlatformException catch (e) {
      print('Failed to update notification: ${e.message}');
    }
  }

  static Future<void> stopForegroundService() async {
    try {
      await _foregroundServiceChannel.invokeMethod('stopForeground');
    } on PlatformException catch (e) {
      print('Failed to stop foreground service: ${e.message}');
    }
  }
}
```

---

## 8. UI IMPLEMENTATION

### 8.1 Home Screen

```dart
// lib/features/home/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashdrop/shared/theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Icon(
                Icons.flash_on,
                size: 100,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 16),
              
              // App Name
              Text(
                'FlashDrop',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Tagline
              Text(
                'Fast, Private File Transfer',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 64),
              
              // Send Button
              _ActionButton(
                icon: Icons.send,
                label: 'Send Files',
                onTap: () => Navigator.pushNamed(context, '/file-selection'),
              ),
              const SizedBox(height: 24),
              
              // Receive Button
              _ActionButton(
                icon: Icons.download,
                label: 'Receive Files',
                onTap: () => Navigator.pushNamed(context, '/receive'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.primaryColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 8.2 Transfer Progress Screen

```dart
// lib/features/transfer/presentation/screens/transfer_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashdrop/features/transfer/presentation/providers/transfer_provider.dart';

class TransferScreen extends ConsumerWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transferState = ref.watch(transferNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer'),
      ),
      body: transferState.when(
        idle: () => const Center(child: Text('No transfer in progress')),
        preparing: (files) => _PreparingView(files: files),
        transferring: (progress) => _TransferringView(progress: progress),
        paused: (progress) => _PausedView(progress: progress),
        completed: (paths) => _CompletedView(paths: paths),
        failed: (error) => _ErrorView(error: error),
      ),
    );
  }
}

class _TransferringView extends ConsumerWidget {
  final TransferProgress progress;

  const _TransferringView({required this.progress});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Overall Progress
          Text(
            '${(progress.overallProgress * 100).toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Progress Bar
          LinearProgressIndicator(
            value: progress.overallProgress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 32),
          
          // Transfer Stats
          _StatRow(
            label: 'Speed',
            value: '${progress.speedMbps} Mbps',
          ),
          const SizedBox(height: 16),
          _StatRow(
            label: 'Time Remaining',
            value: progress.formattedETA,
          ),
          const SizedBox(height: 16),
          _StatRow(
            label: 'Files',
            value: '${progress.currentFileIndex + 1} / ${progress.totalFiles}',
          ),
          const SizedBox(height: 48),
          
          // Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => ref.read(transferNotifierProvider.notifier).pauseTransfer(),
                icon: const Icon(Icons.pause),
                label: const Text('Pause'),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () => ref.read(transferNotifierProvider.notifier).cancelTransfer(),
                icon: const Icon(Icons.close),
                label: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
```

---

## 9. CONSTANTS & CONFIGURATION

```dart
// lib/core/constants/transfer_constants.dart

class TransferConstants {
  static const int chunkSize = 65536; // 64KB
  static const int maxBufferSize = 16777216; // 16MB
  static const int windowSize = 256; // Chunks in flight
  static const int ackThreshold = 64; // Send ACK every N chunks
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  static const Duration connectionTimeout = Duration(seconds: 30);
}

// lib/core/constants/app_constants.dart

class AppConstants {
  static const String appName = 'FlashDrop';
  static const String appVersion = '1.0.0';
  static const int signalingPort = 8080;
  static const String mdnsServiceType = '_flashdrop._tcp';
}
```

---

**Document Status:** ✅ COMPLETE  
**Next Steps:** Create Development Plan and Initial Code Scaffold
