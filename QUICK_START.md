# 🚀 FlashDrop v2.0 - Quick Start Guide

## Prerequisites

### Development Environment
- Flutter SDK 3.x or higher
- Dart SDK ^3.10.4
- Android Studio (for Android builds)
- Visual Studio 2022 (for Windows builds)

### Devices
- **Android**: Version 8.0+ with hotspot capability
- **Windows**: Windows 10/11

---

## Installation

### 1. Clone & Setup
```bash
cd flashdrop
flutter pub get
```

### 2. Verify Installation
```bash
flutter doctor
flutter analyze
```

---

## Building

### Android APK
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Windows Executable
```bash
# Debug build
flutter build windows --debug

# Release build
flutter build windows --release

# Output: build/windows/runner/Release/flashdrop.exe
```

---

## Running

### On Android Device
```bash
# Connect device via USB
flutter devices

# Run app
flutter run -d <device-id>
```

### On Windows
```bash
flutter run -d windows
```

---

## Usage

### Step 1: Setup Android (Server)

1. **Enable Hotspot**
   - Go to Settings → Network & Internet → Hotspot & Tethering
   - Enable "Portable Hotspot"
   - Note the hotspot name and password

2. **Start FlashDrop**
   - Open FlashDrop app
   - Go to "Connect" tab
   - Tap "Start Server (Hotspot Mode)"
   - Note your IP address (e.g., 192.168.43.1)

### Step 2: Setup Windows (Client)

1. **Connect to Hotspot**
   - Open Wi-Fi settings
   - Connect to Android's hotspot
   - Enter password

2. **Connect to Server**
   - Open FlashDrop app
   - Go to "Connect" tab
   - Enter Android's IP address (e.g., 192.168.43.1)
   - Tap "Connect to Server"
   - Wait for "Connected" status

### Step 3: Transfer Files

**From Either Device:**
1. Go to "Transfers" tab
2. Tap "Send File" button
3. Select file from picker
4. Transfer starts automatically
5. Monitor progress in real-time

**Receiving:**
- Files are auto-accepted
- Saved to `/Download` folder
- Progress shown on screen
- Notification on completion

### Step 4: View History

1. Go to "History" tab
2. See all past transfers
3. View file details
4. Check transfer status

---

## Troubleshooting

### Connection Issues

**Problem**: "Connection failed"
- ✅ Check Android hotspot is enabled
- ✅ Verify Windows is connected to hotspot
- ✅ Confirm IP address is correct
- ✅ Check firewall settings on Windows

**Problem**: "Server not reachable"
- ✅ Restart Android hotspot
- ✅ Reconnect Windows to hotspot
- ✅ Restart both apps
- ✅ Check port 8888 is not blocked

### Transfer Issues

**Problem**: "Transfer failed"
- ✅ Check network connection
- ✅ Verify sufficient storage space
- ✅ Ensure file permissions
- ✅ Try smaller file first

**Problem**: "Slow transfer speed"
- ✅ Move devices closer together
- ✅ Reduce network interference
- ✅ Close other apps using network
- ✅ Use 5GHz hotspot if available

### App Issues

**Problem**: "App crashes on startup"
- ✅ Clear app data
- ✅ Reinstall app
- ✅ Check device compatibility
- ✅ Review error logs

**Problem**: "File picker not working"
- ✅ Grant storage permissions
- ✅ Check Android version (8.0+)
- ✅ Restart app
- ✅ Try different file location

---

## Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Manual Testing Checklist

**Connection**
- [ ] Android can start server
- [ ] Windows can connect to server
- [ ] Connection status updates correctly
- [ ] Disconnect works properly

**File Transfer**
- [ ] Can send file from Android to Windows
- [ ] Can send file from Windows to Android
- [ ] Progress updates in real-time
- [ ] Large files (>1GB) transfer successfully
- [ ] Multiple files can be queued

**History**
- [ ] Transfers are logged
- [ ] History persists after app restart
- [ ] Can view sent files
- [ ] Can view received files

**UI/UX**
- [ ] All screens load correctly
- [ ] Navigation works smoothly
- [ ] Buttons respond to taps
- [ ] No UI freezing during transfers

---

## Performance Tips

### For Best Transfer Speeds

1. **Use 5GHz Hotspot**
   - Enable 5GHz band in hotspot settings
   - Provides 2-3x faster speeds than 2.4GHz

2. **Minimize Distance**
   - Keep devices within 3-5 meters
   - Avoid walls and obstacles

3. **Close Background Apps**
   - Stop other network-using apps
   - Disable auto-sync services

4. **Use Quality USB Cable**
   - For Android device charging during transfer
   - Prevents battery drain

---

## Debugging

### Enable Debug Logging

**Android**
```bash
flutter run -d android --verbose
```

**Windows**
```bash
flutter run -d windows --verbose
```

### View Logs

**Android (via ADB)**
```bash
adb logcat | grep -i flashdrop
```

**Windows (Console)**
- Logs appear in terminal where app was launched

### Common Debug Points

1. **Connection Handshake**
   - Look for "HANDSHAKE" and "HANDSHAKE_ACK" messages
   - Verify device info is exchanged

2. **File Transfer**
   - Check "FILE_OFFER" and "FILE_ACCEPT" messages
   - Monitor chunk transfer progress
   - Verify "FILE_COMPLETE" message

3. **Database**
   - Check SQLite database creation
   - Verify history records are saved
   - Confirm query operations

---

## Configuration

### Network Settings

**Default Port**: 8888  
**Chunk Size**: 128KB  
**Socket Timeout**: 30 seconds  

To modify, edit:
```dart
lib/core/constants/network_constants.dart
```

### File Storage

**Android**: `/storage/emulated/0/Download`  
**Windows**: `C:\Users\<username>\Downloads`

To modify, edit:
```dart
lib/core/services/file_transfer_engine.dart
```

---

## Permissions

### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### Windows
- No special permissions required
- Firewall prompt on first run

---

## Support

### Getting Help

1. **Check Documentation**
   - README.md
   - ARCHITECTURE.md
   - This guide

2. **Review Code**
   - All code is well-commented
   - Check service implementations

3. **Report Issues**
   - Provide device info
   - Include error logs
   - Describe steps to reproduce

---

## Next Steps

After successful setup:

1. **Test with Real Files**
   - Try various file types
   - Test different file sizes
   - Verify transfer integrity

2. **Measure Performance**
   - Record transfer speeds
   - Note any bottlenecks
   - Optimize as needed

3. **Customize**
   - Adjust UI theme
   - Modify transfer settings
   - Add custom features

---

**Happy Transferring! 🚀**

For more information, see:
- [README.md](README.md) - Project overview
- [ARCHITECTURE.md](ARCHITECTURE.md) - Technical details
- [REBUILD_SUMMARY.md](REBUILD_SUMMARY.md) - What's new

---

**Last Updated**: December 28, 2025  
**Version**: 2.0.0
