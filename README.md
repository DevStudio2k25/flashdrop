# FlashDrop v2.0 - Production-Grade Offline File Transfer

**Complete Rebuild** - Clean, Scalable, Production-Ready Architecture

---

## 🎯 Overview

FlashDrop v2.0 is a **completely rebuilt** offline file transfer application using **TCP sockets** for high-speed, reliable file transfers between Android and Windows devices without internet connectivity.

### Key Features

✅ **Offline-First** - No internet required  
✅ **TCP-Based** - Reliable, high-speed transfers  
✅ **Bidirectional** - Both devices can send and receive  
✅ **Unlimited File Size** - Supports files of any size  
✅ **Chunked Streaming** - Memory-safe transfers  
✅ **Transfer History** - Persistent database storage  
✅ **Clean Architecture** - Modular, maintainable codebase  
✅ **Production-Ready** - No experimental code or TODOs  

---

## 🏗️ Architecture

### Project Structure

```
lib/
├── main.dart                          # App entry point
│
├── core/                              # Core business logic
│   ├── constants/
│   │   └── network_constants.dart     # Protocol commands, ports, chunk size
│   │
│   ├── models/
│   │   ├── device_info.dart           # Device information model
│   │   ├── file_metadata.dart         # File metadata model
│   │   └── transfer_task.dart         # Transfer task with progress
│   │
│   ├── network/
│   │   ├── tcp_server.dart            # TCP server implementation
│   │   └── tcp_client.dart            # TCP client implementation
│   │
│   └── services/
│       ├── connection_manager.dart    # Connection lifecycle management
│       ├── device_service.dart        # Device info & IP detection
│       ├── file_transfer_engine.dart  # File transfer orchestration
│       └── database_service.dart      # SQLite history storage
│
├── state/                             # Riverpod state management
│   ├── connection_provider.dart       # Connection state providers
│   ├── transfer_provider.dart         # Transfer state providers
│   └── database_provider.dart         # Database providers
│
└── ui/                                # User interface
    ├── screens/
    │   └── home_screen.dart           # Main app screen
    │
    ├── theme/
    │   ├── app_colors.dart            # Color palette
    │   └── app_theme.dart             # Material 3 theme
    │
    └── widgets/
        ├── status_badge.dart          # Connection status badge
        └── transfer_progress_card.dart # Transfer progress UI
```

---

## 🔧 Technical Stack

### Core Technologies
- **Flutter 3.x** - Cross-platform framework
- **Dart SDK ^3.10.4** - Programming language
- **TCP Sockets** - Direct peer-to-peer communication
- **SQLite** - Persistent transfer history

### Key Dependencies
```yaml
flutter_riverpod: ^2.4.9      # State management
file_picker: ^8.1.4            # File selection
path_provider: ^2.1.1          # Directory paths
permission_handler: ^11.1.0    # Android permissions
network_info_plus: ^5.0.1      # Network detection
sqflite: ^2.3.0                # Database (Android)
sqflite_common_ffi: ^2.3.0+4   # Database (Windows)
device_info_plus: ^9.1.2       # Device information
google_fonts: ^6.1.0           # Typography
uuid: ^4.2.2                   # Unique IDs
crypto: ^3.0.3                 # Checksums
```

---

## 🌐 Network Architecture

### Connection Model

**Android (Hotspot Mode)**
- Acts as **TCP Server**
- Listens on port `8888`
- Broadcasts device info
- Accepts incoming connections

**Windows (Client Mode)**
- Acts as **TCP Client**
- Connects to Android's IP
- Sends handshake
- Establishes bidirectional channel

### Protocol Flow

```
1. HANDSHAKE
   Client → Server: { command: "HANDSHAKE", device: {...} }
   Server → Client: { command: "HANDSHAKE_ACK", device: {...} }

2. FILE_OFFER
   Sender → Receiver: { command: "FILE_OFFER", metadata: {...} }
   
3. FILE_ACCEPT/REJECT
   Receiver → Sender: { command: "FILE_ACCEPT", fileId: "..." }

4. FILE_DATA
   Sender → Receiver: [Binary chunks of 128KB]

5. FILE_COMPLETE
   Sender → Receiver: { command: "FILE_COMPLETE", fileId: "..." }
```

### Transfer Mechanism

- **Chunk Size**: 128KB (optimized for speed)
- **Streaming**: Files are read and sent in chunks
- **Memory Safe**: No full-file loading
- **Progress Tracking**: Real-time bytes transferred
- **Error Handling**: Automatic reconnection logic

---

## 📱 Usage Guide

### Setup

#### Android Device (Server)
1. Enable mobile hotspot
2. Open FlashDrop
3. Tap "Start Server (Hotspot Mode)"
4. Note your IP address (displayed on screen)

#### Windows PC (Client)
1. Connect to Android's hotspot
2. Open FlashDrop
3. Enter Android's IP address
4. Tap "Connect to Server"

### Transferring Files

**After Connection:**
- Both devices can send files
- Go to "Transfers" tab
- Tap "Send File"
- Select file(s)
- Transfer starts automatically

**Receiving Files:**
- Files are auto-accepted (configurable)
- Saved to `/Download` folder
- Progress shown in real-time

### Transfer History

- View all past transfers in "History" tab
- Shows: File name, size, direction, status, timestamp
- Persists across app restarts

---

## 🔐 Security & Privacy

### What FlashDrop Does
✅ Local network only (no internet)  
✅ Direct device-to-device transfer  
✅ No cloud storage  
✅ No external servers  
✅ No data collection  
✅ No analytics or tracking  

### Network Security
- TCP connections are local-only
- No data leaves your devices
- Hotspot provides network isolation
- Optional: Add encryption layer (future)

---

## 🚀 Performance

### Optimizations
- **128KB chunks** - Balanced speed/memory
- **Streaming I/O** - No file buffering
- **Async operations** - Non-blocking UI
- **Isolates** - Heavy work off main thread (future)

### Expected Speeds
| Network | Speed | 1GB File |
|---------|-------|----------|
| Wi-Fi 5GHz | 200+ Mbps | ~40 sec |
| Wi-Fi 2.4GHz | 40+ Mbps | ~3 min |
| Hotspot | 80+ Mbps | ~1.5 min |

---

## 🛠️ Development

### Build & Run

```bash
# Get dependencies
flutter pub get

# Run on Android
flutter run -d android

# Run on Windows
flutter run -d windows

# Build APK
flutter build apk --release

# Build Windows executable
flutter build windows --release
```

### Code Quality

```bash
# Analyze code
flutter analyze

# Format code
flutter format lib/

# Run tests
flutter test
```

---

## 📊 State Management

### Riverpod Providers

**Connection State**
```dart
connectionManagerProvider    // Connection manager instance
connectionStateProvider       // Stream of connection states
remoteDeviceProvider         // Stream of remote device info
localDeviceProvider          // Future of local device info
```

**Transfer State**
```dart
fileTransferEngineProvider   // Transfer engine instance
activeTransfersProvider      // Stream of active transfers
receivedFilesProvider        // Stream of received files
```

**Database State**
```dart
databaseServiceProvider      // Database service instance
transferHistoryProvider      // Future of all history
sentFilesHistoryProvider     // Future of sent files
receivedFilesHistoryProvider // Future of received files
```

---

## 🎨 UI/UX

### Design System
- **Material 3** - Modern design language
- **Google Fonts (Inter)** - Clean typography
- **Color Palette** - Blue primary, consistent accents
- **Responsive** - Adapts to screen sizes

### Screens
1. **Connect Tab** - Device info, connection controls
2. **Transfers Tab** - Active file transfers
3. **History Tab** - Past transfer records

---

## 🔮 Future Enhancements

### Planned Features
- [ ] Pause/Resume transfers
- [ ] Multiple file queue
- [ ] Folder transfers
- [ ] Transfer speed throttling
- [ ] Dark mode
- [ ] End-to-end encryption
- [ ] QR code pairing
- [ ] Auto-discovery (mDNS)
- [ ] iOS support
- [ ] Linux support

---

## 📝 License

MIT License - See LICENSE file

---

## 🙏 Credits

Built with ❤️ using Flutter

**Technologies:**
- Flutter Team - Cross-platform framework
- Dart Team - Programming language
- Riverpod - State management
- SQLite - Database

---

## 📞 Support

For issues, feature requests, or contributions:
- GitHub Issues: [Link]
- Email: support@flashdrop.dev

---

**Status**: ✅ Production Ready  
**Version**: 2.0.0  
**Last Updated**: December 28, 2025
