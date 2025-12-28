# FlashDrop - System Architecture

**Version:** 1.0  
**Date:** December 28, 2025

---

## 1. ARCHITECTURE OVERVIEW

FlashDrop follows a **layered architecture** with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                       │
│  (UI Screens, Widgets, Platform-Specific Adaptations)       │
└─────────────────────────────────────────────────────────────┘
                            ↓↑
┌─────────────────────────────────────────────────────────────┐
│                    APPLICATION LAYER                         │
│     (State Management, Business Logic, Use Cases)            │
└─────────────────────────────────────────────────────────────┘
                            ↓↑
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                            │
│        (Entities, Repository Interfaces, Models)             │
└─────────────────────────────────────────────────────────────┘
                            ↓↑
┌─────────────────────────────────────────────────────────────┐
│                   INFRASTRUCTURE LAYER                       │
│   (WebRTC, File System, Network, Platform Channels)         │
└─────────────────────────────────────────────────────────────┘
```

### Design Principles
1. **Single Responsibility**: Each module has one clear purpose
2. **Dependency Inversion**: High-level modules don't depend on low-level details
3. **Platform Abstraction**: Platform-specific code isolated behind interfaces
4. **Testability**: All business logic is unit-testable
5. **Scalability**: Easy to add new platforms or features

---

## 2. COMPONENT DIAGRAM

```
┌──────────────────────────────────────────────────────────────────┐
│                         FlashDrop App                             │
│                                                                   │
│  ┌────────────────┐  ┌────────────────┐  ┌─────────────────┐   │
│  │  Home Screen   │  │ Connection UI  │  │  Transfer UI    │   │
│  └────────┬───────┘  └────────┬───────┘  └────────┬────────┘   │
│           │                   │                    │             │
│           └───────────────────┼────────────────────┘             │
│                               ↓                                  │
│                    ┌──────────────────────┐                      │
│                    │  Transfer Controller │                      │
│                    │  (State Management)  │                      │
│                    └──────────┬───────────┘                      │
│                               │                                  │
│           ┌───────────────────┼───────────────────┐             │
│           ↓                   ↓                   ↓             │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐   │
│  │   Connection   │  │  File Transfer │  │  File System   │   │
│  │    Manager     │  │     Engine     │  │    Manager     │   │
│  └────────┬───────┘  └────────┬───────┘  └────────┬───────┘   │
│           │                   │                    │             │
│           ↓                   ↓                    ↓             │
│  ┌────────────────────────────────────────────────────────┐    │
│  │              WebRTC Service Layer                       │    │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────────────────┐ │    │
│  │  │ Signaling│  │   Peer   │  │   Data Channel       │ │    │
│  │  │  Handler │  │Connection│  │   (File Streaming)   │ │    │
│  │  └──────────┘  └──────────┘  └──────────────────────┘ │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                   │
│  ┌────────────────────────────────────────────────────────┐    │
│  │           Platform Services                             │    │
│  │  ┌─────────────┐  ┌─────────────┐  ┌──────────────┐   │    │
│  │  │  Network    │  │   Storage   │  │ Permissions  │   │    │
│  │  │  Discovery  │  │   Access    │  │   Handler    │   │    │
│  │  └─────────────┘  └─────────────┘  └──────────────┘   │    │
│  └────────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────────┘
```

---

## 3. DATA FLOW DIAGRAMS

### 3.1 Connection Establishment Flow

```
┌─────────┐                                              ┌─────────┐
│ Sender  │                                              │Receiver │
│(Android)│                                              │(Windows)│
└────┬────┘                                              └────┬────┘
     │                                                        │
     │ 1. Click "Send Files"                                 │
     ├──────────────────────────────────────────────────────►│
     │                                                        │
     │                                    2. Click "Receive" │
     │                                                        │
     │ 3. Start mDNS broadcast                               │
     │    "FlashDrop-Device-ABC"                             │
     ├───────────────────────────────────────────────────────┤
     │                                                        │
     │                            4. Discover sender via mDNS│
     │◄───────────────────────────────────────────────────────┤
     │                                                        │
     │ 5. Create WebRTC Offer (SDP)                          │
     ├──────────────────────────────────────────────────────►│
     │                                                        │
     │                          6. Create WebRTC Answer (SDP)│
     │◄───────────────────────────────────────────────────────┤
     │                                                        │
     │ 7. Exchange ICE Candidates                            │
     │◄──────────────────────────────────────────────────────►│
     │                                                        │
     │ 8. WebRTC Connection Established (DTLS Encrypted)     │
     │◄══════════════════════════════════════════════════════►│
     │                                                        │
     │ 9. Open DataChannel "file-transfer"                   │
     │◄──────────────────────────────────────────────────────►│
     │                                                        │
     │ 10. Send file metadata (name, size, type)             │
     ├──────────────────────────────────────────────────────►│
     │                                                        │
     │                                   11. User confirms RX │
     │◄───────────────────────────────────────────────────────┤
     │                                                        │
     │ 12. Begin file transfer                               │
     │                                                        │
```

### 3.2 File Transfer Flow

```
┌──────────────┐                                    ┌──────────────┐
│   Sender     │                                    │   Receiver   │
└──────┬───────┘                                    └──────┬───────┘
       │                                                   │
       │ 1. Read file from storage                        │
       │    (FileSystemManager)                           │
       │                                                   │
       │ 2. Split into chunks (64KB each)                 │
       │    Chunk 1: [0-65535]                            │
       │    Chunk 2: [65536-131071]                       │
       │    ...                                            │
       │                                                   │
       │ 3. Send metadata packet                          │
       │    {type: "start", name: "video.mp4",            │
       │     size: 104857600, chunks: 1600}               │
       ├─────────────────────────────────────────────────►│
       │                                                   │
       │                                4. Prepare buffer  │
       │                                   Create temp file│
       │                                                   │
       │ 5. Send chunk 1 + checksum                       │
       │    {chunk: 1, data: <binary>, hash: "abc123"}    │
       ├─────────────────────────────────────────────────►│
       │                                                   │
       │                                   6. Verify hash  │
       │                                      Write to file│
       │                                                   │
       │                                      7. Send ACK  │
       │◄──────────────────────────────────────────────────┤
       │                                                   │
       │ 8. Send chunk 2 + checksum                       │
       ├─────────────────────────────────────────────────►│
       │                                                   │
       │ ... (repeat for all chunks) ...                  │
       │                                                   │
       │ 9. Send completion packet                        │
       │    {type: "complete", totalChunks: 1600}         │
       ├─────────────────────────────────────────────────►│
       │                                                   │
       │                              10. Finalize file    │
       │                                  Move to Downloads│
       │                                                   │
       │                              11. Send final ACK   │
       │◄──────────────────────────────────────────────────┤
       │                                                   │
       │ 12. Show "Transfer Complete"                     │
       │                                                   │
```

### 3.3 Pause/Resume Flow

```
┌──────────────┐                                    ┌──────────────┐
│   Sender     │                                    │   Receiver   │
└──────┬───────┘                                    └──────┬───────┘
       │                                                   │
       │ Transfer in progress (chunk 500/1600)            │
       │                                                   │
       │ USER CLICKS "PAUSE"                              │
       │                                                   │
       │ 1. Send pause signal                             │
       │    {type: "pause", lastChunk: 500}               │
       ├─────────────────────────────────────────────────►│
       │                                                   │
       │                                   2. Flush buffer │
       │                                      Save state   │
       │                                                   │
       │                                      3. Send ACK  │
       │◄──────────────────────────────────────────────────┤
       │                                                   │
       │ 4. Stop sending chunks                           │
       │    Save state: {lastChunk: 500, offset: 32768000}│
       │                                                   │
       │ ... (pause duration: 5 minutes) ...              │
       │                                                   │
       │ USER CLICKS "RESUME"                             │
       │                                                   │
       │ 5. Send resume signal                            │
       │    {type: "resume", fromChunk: 501}              │
       ├─────────────────────────────────────────────────►│
       │                                                   │
       │                                6. Verify state    │
       │                                   Ready to receive│
       │                                                   │
       │                                      7. Send ACK  │
       │◄──────────────────────────────────────────────────┤
       │                                                   │
       │ 8. Resume sending from chunk 501                 │
       ├─────────────────────────────────────────────────►│
       │                                                   │
       │ Transfer continues...                            │
       │                                                   │
```

---

## 4. WEBRTC SIGNALING ARCHITECTURE

### 4.1 Signaling Strategy: Hybrid Approach

FlashDrop uses **multiple signaling methods** with automatic fallback:

#### Method 1: Local HTTP Signaling Server (Primary)
```
┌─────────────────────────────────────────────────────────────┐
│  Receiver (Windows) starts embedded HTTP server             │
│  http://192.168.1.100:8080                                  │
│                                                              │
│  Endpoints:                                                  │
│  POST /offer  → Receive SDP offer from sender               │
│  GET  /answer → Return SDP answer to sender                 │
│  POST /ice    → Exchange ICE candidates                     │
└─────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────┐
│  Sender (Android) discovers server via mDNS                 │
│  Sends HTTP POST with SDP offer                             │
│  Polls for answer and ICE candidates                        │
└─────────────────────────────────────────────────────────────┘
```

**Pros:**
- Fast (local network only)
- No external dependencies
- Works offline
- Automatic discovery via mDNS

**Cons:**
- Requires both devices on same network
- Firewall may block (mitigated by user prompt)

---

#### Method 2: QR Code Exchange (Fallback)
```
┌─────────────────────────────────────────────────────────────┐
│  Receiver (Windows) generates QR code containing:           │
│  {                                                           │
│    "offer": "<SDP_OFFER_BASE64>",                           │
│    "ip": "192.168.1.100",                                   │
│    "port": 8080                                             │
│  }                                                           │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  Sender (Android) scans QR code                             │
│  Extracts SDP offer and connection info                     │
│  Generates SDP answer                                       │
│  Sends answer via HTTP to receiver's IP:port                │
└─────────────────────────────────────────────────────────────┘
```

**Pros:**
- Works when mDNS fails
- User-initiated (clear action)
- No network discovery required

**Cons:**
- Extra user step (scan QR)
- Requires camera permission

---

### 4.2 ICE Configuration

```dart
final iceServers = [
  {
    'urls': [
      'stun:stun.l.google.com:19302',
      'stun:stun1.l.google.com:19302',
    ]
  }
];

final pcConstraints = {
  'iceServers': iceServers,
  'sdpSemantics': 'unified-plan',
};
```

**Note:** TURN servers are **NOT** required for local network transfers. STUN is used only for ICE candidate gathering.

---

## 5. FILE TRANSFER ENGINE ARCHITECTURE

### 5.1 Chunking Strategy

```dart
class FileChunker {
  static const int CHUNK_SIZE = 65536; // 64KB
  static const int MAX_BUFFER_SIZE = 16777216; // 16MB
  
  Stream<Chunk> chunkFile(File file) async* {
    final fileSize = await file.length();
    final totalChunks = (fileSize / CHUNK_SIZE).ceil();
    
    int chunkIndex = 0;
    int offset = 0;
    
    final randomAccessFile = await file.open(mode: FileMode.read);
    
    while (offset < fileSize) {
      final remainingBytes = fileSize - offset;
      final currentChunkSize = min(CHUNK_SIZE, remainingBytes);
      
      final bytes = await randomAccessFile.read(currentChunkSize);
      final checksum = _calculateChecksum(bytes);
      
      yield Chunk(
        index: chunkIndex,
        data: bytes,
        checksum: checksum,
        totalChunks: totalChunks,
      );
      
      offset += currentChunkSize;
      chunkIndex++;
    }
    
    await randomAccessFile.close();
  }
  
  String _calculateChecksum(Uint8List bytes) {
    // Use CRC32 for speed (not cryptographic security)
    return crc32(bytes).toString();
  }
}
```

### 5.2 Flow Control & Buffering

```dart
class TransferFlowController {
  static const int WINDOW_SIZE = 256; // Chunks in flight
  static const int ACK_THRESHOLD = 64; // Send ACK every N chunks
  
  final Queue<Chunk> sendBuffer = Queue();
  final Set<int> pendingAcks = {};
  
  bool canSendChunk() {
    return pendingAcks.length < WINDOW_SIZE;
  }
  
  void onChunkSent(int chunkIndex) {
    pendingAcks.add(chunkIndex);
  }
  
  void onAckReceived(int chunkIndex) {
    pendingAcks.remove(chunkIndex);
  }
}
```

**Rationale:**
- **64KB chunks**: Balance between overhead and throughput
- **256 chunk window**: ~16MB in flight (prevents memory overflow)
- **Selective ACKs**: Reduce protocol overhead

---

### 5.3 Threading Model (Isolates)

```
┌──────────────────────────────────────────────────────────────┐
│                      Main Isolate (UI)                        │
│  - Render UI                                                  │
│  - Handle user input                                          │
│  - Update progress indicators                                │
└───────────────────────┬──────────────────────────────────────┘
                        │
                        │ (SendPort / ReceivePort)
                        │
┌───────────────────────▼──────────────────────────────────────┐
│                  Transfer Isolate                             │
│  - Read file chunks                                           │
│  - Calculate checksums                                        │
│  - Send via DataChannel                                       │
│  - Handle ACKs                                                │
│  - Report progress to main isolate                           │
└───────────────────────┬──────────────────────────────────────┘
                        │
                        │ (Platform Channel)
                        │
┌───────────────────────▼──────────────────────────────────────┐
│                  Native WebRTC Layer                          │
│  - Manage peer connection                                     │
│  - Handle ICE negotiation                                     │
│  - DataChannel I/O                                            │
└──────────────────────────────────────────────────────────────┘
```

**Benefits:**
- UI remains responsive during large transfers
- File I/O doesn't block rendering
- Checksum calculation offloaded

---

## 6. STATE MANAGEMENT ARCHITECTURE

### 6.1 State Management Choice: **Riverpod**

**Rationale:**
- Compile-time safety
- Easy testing
- No BuildContext dependency
- Excellent for async operations
- Provider composition

### 6.2 State Structure

```dart
// Connection State
@freezed
class ConnectionState with _$ConnectionState {
  const factory ConnectionState.disconnected() = _Disconnected;
  const factory ConnectionState.discovering() = _Discovering;
  const factory ConnectionState.connecting() = _Connecting;
  const factory ConnectionState.connected({
    required String peerId,
    required String peerName,
  }) = _Connected;
  const factory ConnectionState.error(String message) = _ConnectionError;
}

// Transfer State
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
    required List<String> filePaths,
  }) = _Completed;
  const factory TransferState.failed(String error) = _TransferFailed;
}

// Transfer Progress Model
class TransferProgress {
  final int currentFileIndex;
  final int totalFiles;
  final int currentFileBytes;
  final int currentFileTotalBytes;
  final int totalBytesTransferred;
  final int totalBytes;
  final double speedBytesPerSecond;
  final Duration estimatedTimeRemaining;
  
  double get overallProgress => totalBytesTransferred / totalBytes;
  double get currentFileProgress => currentFileBytes / currentFileTotalBytes;
  String get speedMbps => (speedBytesPerSecond * 8 / 1000000).toStringAsFixed(2);
}
```

---

## 7. PLATFORM-SPECIFIC ARCHITECTURE

### 7.1 Android-Specific Components

```dart
// Android Foreground Service (for background transfers)
class TransferForegroundService {
  static const CHANNEL = 'com.flashdrop/foreground_service';
  
  Future<void> startForegroundService() async {
    await platform.invokeMethod('startForeground', {
      'title': 'FlashDrop Transfer',
      'message': 'Transferring files...',
    });
  }
  
  Future<void> updateNotification(TransferProgress progress) async {
    await platform.invokeMethod('updateNotification', {
      'progress': progress.overallProgress,
      'speed': progress.speedMbps,
    });
  }
}

// Android: AndroidManifest.xml additions
// - INTERNET permission (WebRTC)
// - ACCESS_WIFI_STATE (network detection)
// - READ_EXTERNAL_STORAGE / READ_MEDIA_* (file access)
// - FOREGROUND_SERVICE (background transfers)
// - WAKE_LOCK (prevent sleep during transfer)
```

### 7.2 Windows-Specific Components

```dart
// Windows: Drag-and-drop support
class WindowsDropTarget {
  void registerDropTarget(int windowHandle) {
    // Use FFI to register Windows drop target
    // Receive file paths from drag-and-drop
  }
}

// Windows: System tray integration
class WindowsSystemTray {
  void showTrayIcon() {
    // Minimize to tray
    // Show transfer progress in tray
  }
}

// Windows: Firewall prompt handling
// - App must be signed to avoid SmartScreen warnings
// - Prompt user to allow HTTP server through firewall
```

---

## 8. SECURITY ARCHITECTURE

### 8.1 Encryption Layers

```
┌──────────────────────────────────────────────────────────────┐
│  Application Layer: File Data                                 │
└───────────────────────┬──────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────────────┐
│  WebRTC DataChannel: Binary Chunks                            │
└───────────────────────┬──────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────────────┐
│  DTLS Encryption (AES-128-GCM or AES-256-GCM)                 │
│  - Automatic key exchange via DTLS handshake                  │
│  - Perfect Forward Secrecy                                    │
└───────────────────────┬──────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────────────┐
│  SRTP (Secure Real-Time Protocol)                             │
└───────────────────────┬──────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────────────┐
│  UDP/TCP Transport                                            │
└──────────────────────────────────────────────────────────────┘
```

**Key Points:**
- Encryption is **mandatory** (WebRTC default)
- No plaintext file data ever transmitted
- Keys never leave devices
- No man-in-the-middle possible on local network

### 8.2 Receive Confirmation Flow

```dart
class ReceiveConfirmationDialog {
  Future<bool> showConfirmation({
    required String senderName,
    required List<FileMetadata> files,
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Incoming Files'),
        content: Column(
          children: [
            Text('From: $senderName'),
            Text('Files: ${files.length}'),
            Text('Total size: ${_formatBytes(totalSize)}'),
            ...files.map((f) => ListTile(
              title: Text(f.name),
              subtitle: Text(_formatBytes(f.size)),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Reject'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Accept'),
          ),
        ],
      ),
    );
  }
}
```

---

## 9. ERROR HANDLING ARCHITECTURE

### 9.1 Error Categories

```dart
sealed class TransferError {
  const TransferError();
}

class NetworkError extends TransferError {
  final String message;
  const NetworkError(this.message);
}

class FileSystemError extends TransferError {
  final String path;
  final String reason;
  const FileSystemError(this.path, this.reason);
}

class PermissionError extends TransferError {
  final String permission;
  const PermissionError(this.permission);
}

class ProtocolError extends TransferError {
  final String details;
  const ProtocolError(this.details);
}

class ChecksumMismatchError extends TransferError {
  final int chunkIndex;
  const ChecksumMismatchError(this.chunkIndex);
}
```

### 9.2 Retry Strategy

```dart
class RetryPolicy {
  static const MAX_RETRIES = 3;
  static const INITIAL_DELAY = Duration(seconds: 1);
  static const MAX_DELAY = Duration(seconds: 10);
  
  Future<T> executeWithRetry<T>(Future<T> Function() operation) async {
    int attempt = 0;
    Duration delay = INITIAL_DELAY;
    
    while (attempt < MAX_RETRIES) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        if (attempt >= MAX_RETRIES) rethrow;
        
        await Future.delayed(delay);
        delay = Duration(seconds: min(delay.inSeconds * 2, MAX_DELAY.inSeconds));
      }
    }
    
    throw Exception('Max retries exceeded');
  }
}
```

---

## 10. PERFORMANCE OPTIMIZATIONS

### 10.1 Memory Management

```dart
class MemoryAwareChunkSender {
  static const MAX_MEMORY_USAGE = 50 * 1024 * 1024; // 50MB
  
  int _currentMemoryUsage = 0;
  
  Future<void> sendChunk(Chunk chunk) async {
    // Wait if memory usage too high
    while (_currentMemoryUsage > MAX_MEMORY_USAGE) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    
    _currentMemoryUsage += chunk.data.length;
    
    try {
      await _dataChannel.send(chunk.data);
    } finally {
      _currentMemoryUsage -= chunk.data.length;
    }
  }
}
```

### 10.2 DataChannel Configuration

```dart
final dataChannelConfig = {
  'ordered': true,           // Maintain chunk order
  'maxRetransmits': 3,       // Retry failed packets
  'protocol': 'flashdrop-v1',
};

// Increase buffer sizes for high throughput
final pcConfig = {
  'iceServers': iceServers,
  'sdpSemantics': 'unified-plan',
  'bundlePolicy': 'max-bundle',
  'rtcpMuxPolicy': 'require',
};
```

---

## 11. TESTING ARCHITECTURE

### 11.1 Test Pyramid

```
                    ┌──────────┐
                    │   E2E    │  (5%)
                    │  Tests   │
                    └──────────┘
                ┌────────────────────┐
                │  Integration Tests │  (15%)
                └────────────────────┘
        ┌──────────────────────────────────┐
        │         Unit Tests                │  (80%)
        └──────────────────────────────────┘
```

### 11.2 Key Test Scenarios

```dart
// Unit Tests
- FileChunker splits files correctly
- Checksum calculation is accurate
- State transitions are valid
- Retry logic works as expected

// Integration Tests
- WebRTC connection establishment
- File transfer end-to-end (mocked network)
- Pause/resume functionality
- Error recovery

// E2E Tests (Manual + Automated)
- Android → Windows transfer (real devices)
- Large file transfer (10GB)
- Network interruption recovery
- Multi-file batch transfer
```

---

## 12. DEPLOYMENT ARCHITECTURE

### 12.1 Build Pipeline

```
┌─────────────────────────────────────────────────────────────┐
│  Source Code (GitHub)                                        │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  CI/CD (GitHub Actions)                                      │
│  - Run tests                                                 │
│  - Lint code                                                 │
│  - Build Android APK (release)                               │
│  - Build Windows .exe (release)                              │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  Artifacts                                                   │
│  - flashdrop-v1.0.0-android.apk                              │
│  - flashdrop-v1.0.0-windows-x64.exe                          │
│  - flashdrop-v1.0.0-windows-x64.zip (portable)               │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  Distribution                                                │
│  - GitHub Releases                                           │
│  - (Future: Google Play, Microsoft Store)                   │
└─────────────────────────────────────────────────────────────┘
```

---

## 13. MONITORING & DIAGNOSTICS

### 13.1 Telemetry (Privacy-Preserving)

```dart
class LocalTelemetry {
  // NO external analytics
  // Local-only diagnostics for debugging
  
  void logTransferMetrics({
    required int fileSize,
    required Duration duration,
    required double avgSpeed,
    required int retries,
  }) {
    // Store locally for user to view in "Diagnostics" screen
    // Never sent to external servers
  }
}
```

### 13.2 Debug Mode

```dart
class DebugPanel {
  // Accessible via hidden gesture (e.g., 5 taps on logo)
  
  void showDebugInfo() {
    // - WebRTC connection state
    // - ICE candidate types
    // - DataChannel buffer levels
    // - Transfer statistics
    // - Network interface info
  }
}
```

---

## 14. SCALABILITY CONSIDERATIONS

### Future Architecture Enhancements (Post-MVP)

1. **Multi-Peer Support**
   - 1-to-many transfers (broadcast)
   - Mesh network topology

2. **Protocol Versioning**
   - Backward compatibility
   - Feature negotiation

3. **Plugin Architecture**
   - Custom transfer protocols
   - Third-party integrations

4. **Cloud Relay (Optional)**
   - TURN server for NAT traversal (different networks)
   - User-controlled (opt-in only)

---

## 15. ARCHITECTURE DECISION RECORDS (ADRs)

### ADR-001: Why WebRTC over Custom Socket Protocol?
**Decision:** Use WebRTC DataChannel  
**Rationale:**
- Built-in encryption (DTLS)
- NAT traversal (ICE)
- Mature, battle-tested
- Cross-platform support
- No need to reinvent the wheel

**Alternatives Considered:**
- Raw TCP sockets (no encryption, NAT issues)
- HTTP file upload (requires server)
- Bluetooth (too slow, limited range)

---

### ADR-002: Why Riverpod over Bloc/GetX?
**Decision:** Use Riverpod for state management  
**Rationale:**
- Compile-time safety
- No BuildContext needed
- Easy testing
- Excellent async support
- Active maintenance

---

### ADR-003: Why 64KB Chunk Size?
**Decision:** 64KB chunks for file transfer  
**Rationale:**
- Balance between overhead and throughput
- Fits well within DataChannel buffer (16MB default)
- Fast checksum calculation
- Easy to resume from any chunk

**Tested Alternatives:**
- 16KB: Too much overhead
- 256KB: Buffer bloat, slower error recovery

---

**Document Status:** ✅ APPROVED  
**Next Steps:** Proceed to Technical Design document
