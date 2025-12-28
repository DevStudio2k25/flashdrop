# FlashDrop v2.0 - Architecture Documentation

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        FlashDrop v2.0                            │
│                  Offline File Transfer System                    │
└─────────────────────────────────────────────────────────────────┘

┌──────────────┐                                  ┌──────────────┐
│   Android    │                                  │   Windows    │
│  (Hotspot)   │                                  │     (PC)     │
│              │                                  │              │
│  TCP Server  │◄────────TCP Connection──────────►│  TCP Client  │
│  Port: 8888  │                                  │              │
└──────────────┘                                  └──────────────┘
```

## Layer Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                          UI Layer                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Connect    │  │  Transfers   │  │   History    │          │
│  │     Tab      │  │     Tab      │  │     Tab      │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                              ▲
                              │ Riverpod Providers
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      State Management                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ Connection   │  │  Transfer    │  │  Database    │          │
│  │  Providers   │  │  Providers   │  │  Providers   │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                              ▲
                              │ Service Calls
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Business Logic                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ Connection   │  │ File Transfer│  │  Database    │          │
│  │   Manager    │  │    Engine    │  │   Service    │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                              ▲
                              │ Network/Storage I/O
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Infrastructure                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  TCP Server  │  │  TCP Client  │  │    SQLite    │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
```

## Connection Flow

```
┌─────────────┐                                ┌─────────────┐
│   Android   │                                │   Windows   │
│  (Server)   │                                │  (Client)   │
└──────┬──────┘                                └──────┬──────┘
       │                                              │
       │  1. Start Server (Port 8888)                │
       │◄─────────────────────────────────────────────┤
       │                                              │
       │  2. Connect to Server IP                    │
       │◄─────────────────────────────────────────────┤
       │                                              │
       │  3. HANDSHAKE                               │
       │◄─────────────────────────────────────────────┤
       │                                              │
       │  4. HANDSHAKE_ACK                           │
       ├─────────────────────────────────────────────►│
       │                                              │
       │  ✅ CONNECTION ESTABLISHED                   │
       │                                              │
       │  5. Bidirectional Communication             │
       │◄────────────────────────────────────────────►│
       │                                              │
       └──────────────────────────────────────────────┘
```

## File Transfer Flow

```
┌─────────────┐                                ┌─────────────┐
│   Sender    │                                │  Receiver   │
└──────┬──────┘                                └──────┬──────┘
       │                                              │
       │  1. FILE_OFFER (metadata)                   │
       ├─────────────────────────────────────────────►│
       │                                              │
       │  2. FILE_ACCEPT (fileId)                    │
       │◄─────────────────────────────────────────────┤
       │                                              │
       │  3. FILE_DATA (chunk 1 - 128KB)             │
       ├═════════════════════════════════════════════►│
       │                                              │
       │  4. FILE_DATA (chunk 2 - 128KB)             │
       ├═════════════════════════════════════════════►│
       │                                              │
       │  5. FILE_DATA (chunk N - remaining)         │
       ├═════════════════════════════════════════════►│
       │                                              │
       │  6. FILE_COMPLETE (fileId)                  │
       ├─────────────────────────────────────────────►│
       │                                              │
       │  ✅ TRANSFER COMPLETE                        │
       │                                              │
       └──────────────────────────────────────────────┘
```

## Data Models

### DeviceInfo
```dart
{
  id: String,           // Unique device ID
  name: String,         // Device name
  ipAddress: String,    // Local IP (e.g., 192.168.43.1)
  platform: String,     // 'android' or 'windows'
  port: int             // Server port (8888)
}
```

### FileMetadata
```dart
{
  id: String,           // Unique file ID
  name: String,         // File name
  size: int,            // File size in bytes
  mimeType: String,     // MIME type
  relativePath: String? // Optional path
}
```

### TransferTask
```dart
{
  id: String,                    // Task ID
  fileMetadata: FileMetadata,    // File info
  direction: TransferDirection,  // send/receive
  status: TransferStatus,        // pending/inProgress/completed/failed
  bytesTransferred: int,         // Progress
  speed: double,                 // Bytes per second
  startTime: DateTime,           // Start timestamp
  endTime: DateTime?,            // End timestamp
  errorMessage: String?,         // Error if failed
  savePath: String?              // Save location
}
```

## Service Responsibilities

### ConnectionManager
- Initialize local device info
- Start TCP server (Android)
- Connect to TCP server (Windows)
- Handle handshake protocol
- Manage connection lifecycle
- Emit connection state changes

### FileTransferEngine
- Orchestrate file transfers
- Handle FILE_OFFER/ACCEPT/REJECT
- Stream file chunks (128KB)
- Track transfer progress
- Update transfer tasks
- Save to database

### DatabaseService
- Initialize SQLite database
- Save transfer history
- Query transfer records
- Filter by direction (send/receive)
- Clear history

### DeviceService
- Get local device name
- Detect local IP address
- Identify platform (Android/Windows)
- Check network connectivity

## State Flow

```
User Action
    ↓
UI Component
    ↓
Riverpod Provider (read/watch)
    ↓
Service Method Call
    ↓
Business Logic Execution
    ↓
State Update (StreamController/StateNotifier)
    ↓
Riverpod Provider (emit)
    ↓
UI Component (rebuild)
    ↓
User Sees Update
```

## Error Handling

### Connection Errors
- **Timeout**: Retry with exponential backoff
- **Refused**: Check IP address and port
- **Disconnected**: Notify user, allow reconnect

### Transfer Errors
- **File Not Found**: Cancel transfer, show error
- **Disk Full**: Pause transfer, notify user
- **Network Lost**: Pause transfer, attempt resume

### Database Errors
- **Failed to Save**: Log error, continue operation
- **Failed to Query**: Return empty list, log error

## Performance Considerations

### Memory Management
- Stream files in 128KB chunks
- Never load entire file into memory
- Close file handles immediately after use
- Dispose controllers and streams

### Network Optimization
- Use TCP for reliability
- 128KB chunks balance speed/overhead
- Async I/O prevents blocking
- Flush socket buffer after each chunk

### UI Responsiveness
- All network I/O is async
- Heavy operations off main thread
- Progress updates throttled (every 100ms)
- Smooth animations (60fps)

---

**Document Version**: 1.0  
**Last Updated**: December 28, 2025
