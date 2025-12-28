# FlashDrop - Implementation Guide

**Quick Start Guide for Beginning Development**  
**Date:** December 28, 2025

---

## 🎯 OVERVIEW

This guide provides step-by-step instructions to begin implementing FlashDrop based on the complete planning documentation.

**Prerequisites:**
- ✅ Flutter project initialized (already done)
- ✅ All planning documents complete
- ✅ Development environment ready

---

## 📋 PHASE 1: WEEK 1 - PROJECT SETUP

### Day 1: Update Dependencies

**File to Edit:** `pubspec.yaml`

Replace the dependencies section with:

```yaml
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
  shelf: ^1.4.1

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
```

**Run:**
```bash
flutter pub get
```

---

### Day 2: Create Project Structure

**Create folders:**

```bash
# Core
mkdir lib\core
mkdir lib\core\constants
mkdir lib\core\errors
mkdir lib\core\utils
mkdir lib\core\platform

# Features
mkdir lib\features
mkdir lib\features\connection
mkdir lib\features\connection\data
mkdir lib\features\connection\data\datasources
mkdir lib\features\connection\data\models
mkdir lib\features\connection\data\repositories
mkdir lib\features\connection\domain
mkdir lib\features\connection\domain\entities
mkdir lib\features\connection\domain\repositories
mkdir lib\features\connection\domain\usecases
mkdir lib\features\connection\presentation
mkdir lib\features\connection\presentation\providers
mkdir lib\features\connection\presentation\screens
mkdir lib\features\connection\presentation\widgets

mkdir lib\features\transfer
mkdir lib\features\transfer\data
mkdir lib\features\transfer\data\datasources
mkdir lib\features\transfer\data\models
mkdir lib\features\transfer\data\repositories
mkdir lib\features\transfer\domain
mkdir lib\features\transfer\domain\entities
mkdir lib\features\transfer\domain\repositories
mkdir lib\features\transfer\domain\usecases
mkdir lib\features\transfer\presentation
mkdir lib\features\transfer\presentation\providers
mkdir lib\features\transfer\presentation\screens
mkdir lib\features\transfer\presentation\widgets

mkdir lib\features\home
mkdir lib\features\home\presentation
mkdir lib\features\home\presentation\screens
mkdir lib\features\home\presentation\widgets

# Shared
mkdir lib\shared
mkdir lib\shared\widgets
mkdir lib\shared\theme

# Services
mkdir lib\services
```

---

### Day 3: Create Core Constants

**File:** `lib/core/constants/app_constants.dart`

```dart
class AppConstants {
  static const String appName = 'FlashDrop';
  static const String appVersion = '1.0.0';
  static const int signalingPort = 8080;
  static const String mdnsServiceType = '_flashdrop._tcp';
}
```

**File:** `lib/core/constants/transfer_constants.dart`

```dart
class TransferConstants {
  static const int chunkSize = 65536; // 64KB
  static const int maxBufferSize = 16777216; // 16MB
  static const int windowSize = 256; // Chunks in flight
  static const int ackThreshold = 64; // Send ACK every N chunks
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  static const Duration connectionTimeout = Duration(seconds: 30);
}
```

---

### Day 4: Create Theme System

**File:** `lib/shared/theme/app_colors.dart`

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  
  // Secondary
  static const Color secondary = Color(0xFF10B981); // Green
  static const Color secondaryDark = Color(0xFF059669);
  static const Color secondaryLight = Color(0xFF34D399);
  
  // Neutral
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFEF4444);
  
  // Text
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF9CA3AF);
}
```

**File:** `lib/shared/theme/app_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        background: AppColors.background,
        surface: AppColors.surface,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
```

---

### Day 5: Update main.dart

**File:** `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared/theme/app_theme.dart';
import 'features/home/presentation/screens/home_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: FlashDropApp(),
    ),
  );
}

class FlashDropApp extends StatelessWidget {
  const FlashDropApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlashDrop',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
```

---

### Day 6-7: Create Home Screen

**File:** `lib/features/home/presentation/screens/home_screen.dart`

```dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              const Icon(
                Icons.flash_on,
                size: 100,
                color: Color(0xFF6366F1),
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
                onTap: () {
                  // TODO: Navigate to file selection
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Send Files - Coming Soon')),
                  );
                },
              ),
              const SizedBox(height: 24),
              
              // Receive Button
              _ActionButton(
                icon: Icons.download,
                label: 'Receive Files',
                onTap: () {
                  // TODO: Navigate to receive screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Receive Files - Coming Soon')),
                  );
                },
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
      color: const Color(0xFF6366F1),
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

---

## 📋 PHASE 2: WEEK 2 - WEBRTC INTEGRATION

### Day 1-2: Create WebRTC Service

**File:** `lib/services/webrtc_service.dart`

Copy the complete implementation from `TECHNICAL_DESIGN.md` section 4.1.

**Key Methods:**
- `initialize()`
- `createOffer()`
- `createAnswer()`
- `setRemoteDescription()`
- `addIceCandidate()`
- `sendData()`
- `closeConnection()`

---

### Day 3-4: Create Signaling Service

**File:** `lib/services/signaling_service.dart`

Copy the complete implementation from `TECHNICAL_DESIGN.md` section 4.2.

**Key Methods:**
- `startServer()`
- `stopServer()`
- `setAnswer()`
- HTTP endpoints: `/offer`, `/answer`, `/ice`

---

### Day 5-7: Test WebRTC Connection

**Create test screen:**

```dart
// lib/features/connection/presentation/screens/connection_test_screen.dart

class ConnectionTestScreen extends StatefulWidget {
  @override
  State<ConnectionTestScreen> createState() => _ConnectionTestScreenState();
}

class _ConnectionTestScreenState extends State<ConnectionTestScreen> {
  final webrtcService = WebRTCService();
  final signalingService = SignalingService();
  
  String status = 'Not connected';
  
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }
  
  Future<void> _initializeServices() async {
    await webrtcService.initialize();
    setState(() => status = 'Initialized');
  }
  
  Future<void> _startAsReceiver() async {
    await signalingService.startServer();
    setState(() => status = 'Server running at ${signalingService.serverUrl}');
  }
  
  Future<void> _createOffer() async {
    final offer = await webrtcService.createOffer();
    setState(() => status = 'Offer created: ${offer.sdp?.substring(0, 50)}...');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('WebRTC Test')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Status: $status'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startAsReceiver,
              child: Text('Start as Receiver'),
            ),
            ElevatedButton(
              onPressed: _createOffer,
              child: Text('Create Offer (Sender)'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Test on real devices:**
1. Run on Windows: `flutter run -d windows`
2. Run on Android: `flutter run -d <device-id>`
3. Verify connection establishment

---

## 📋 PHASE 3: WEEKS 3-4 - FILE TRANSFER

### Implementation Order:

1. **File Chunker** (`lib/features/transfer/data/datasources/file_datasource.dart`)
2. **Domain Entities** (`lib/features/transfer/domain/entities/`)
3. **Transfer Repository** (`lib/features/transfer/data/repositories/transfer_repository_impl.dart`)
4. **Transfer Provider** (`lib/features/transfer/presentation/providers/transfer_provider.dart`)
5. **Transfer UI** (`lib/features/transfer/presentation/screens/transfer_screen.dart`)

**Reference:** See `TECHNICAL_DESIGN.md` sections 5 and 6 for complete implementations.

---

## 📋 TESTING CHECKLIST

### Week 1 Tests
- [ ] App builds on Android
- [ ] App builds on Windows
- [ ] Home screen renders correctly
- [ ] Theme applies correctly
- [ ] Navigation works

### Week 2 Tests
- [ ] WebRTC service initializes
- [ ] Signaling server starts
- [ ] Offer/Answer exchange works
- [ ] ICE candidates exchange
- [ ] DataChannel opens
- [ ] Can send text message via DataChannel

### Week 3-4 Tests
- [ ] File chunks correctly
- [ ] Checksums calculate accurately
- [ ] Single file transfers successfully
- [ ] Multiple files transfer
- [ ] Large file (1GB+) transfers
- [ ] Progress updates correctly
- [ ] Transfer completes without errors

---

## 🐛 COMMON ISSUES & SOLUTIONS

### Issue: WebRTC not working on Windows
**Solution:** Ensure Windows Firewall allows the app. Add firewall rule manually if needed.

### Issue: Android permissions denied
**Solution:** Request permissions at runtime using `permission_handler` package.

### Issue: Build errors with code generation
**Solution:** Run `flutter pub run build_runner build --delete-conflicting-outputs`

### Issue: Hot reload not working
**Solution:** Restart app completely. Some WebRTC changes require full restart.

### Issue: Memory usage high
**Solution:** Profile with Dart DevTools, check for unclosed streams and file handles.

---

## 📊 PROGRESS TRACKING

### Week 1 Checklist
- [ ] Dependencies installed
- [ ] Project structure created
- [ ] Constants defined
- [ ] Theme implemented
- [ ] Home screen complete
- [ ] App runs on both platforms

### Week 2 Checklist
- [ ] WebRTC service implemented
- [ ] Signaling service implemented
- [ ] Connection test successful
- [ ] DataChannel opens
- [ ] Can send/receive messages

### Week 3 Checklist
- [ ] File chunking works
- [ ] Checksum validation works
- [ ] Transfer protocol defined
- [ ] Single file transfer works

### Week 4 Checklist
- [ ] Multiple file transfer works
- [ ] Large file transfer works
- [ ] Progress tracking accurate
- [ ] Flow control implemented

---

## 🚀 QUICK COMMANDS REFERENCE

```bash
# Get dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build

# Run on Android
flutter run -d android

# Run on Windows
flutter run -d windows

# Build release APK
flutter build apk --release

# Build release Windows
flutter build windows --release

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format lib/

# Clean build
flutter clean
```

---

## 📚 DOCUMENTATION REFERENCES

- **PRD:** Product requirements and features
- **ARCHITECTURE:** System design and data flows
- **TECHNICAL_DESIGN:** Detailed code implementations
- **DEVELOPMENT_PLAN:** Week-by-week tasks
- **RISKS:** Known issues and mitigations

---

## 💡 DEVELOPMENT TIPS

1. **Start Simple:** Get basic connection working before adding features
2. **Test Early:** Test on real devices from Day 1
3. **Profile Often:** Use Dart DevTools to catch performance issues early
4. **Commit Frequently:** Small, focused commits with clear messages
5. **Document As You Go:** Update docs when you deviate from plan
6. **Ask for Help:** Flutter community is helpful (Discord, Reddit, Stack Overflow)

---

## 🎯 DEFINITION OF DONE (Week 1)

Week 1 is complete when:
- ✅ App builds on Android and Windows
- ✅ Home screen displays correctly
- ✅ Theme is applied
- ✅ All dependencies installed
- ✅ Project structure created
- ✅ Code is committed to Git

---

## 🎯 DEFINITION OF DONE (Week 2)

Week 2 is complete when:
- ✅ WebRTC connection established between two devices
- ✅ DataChannel opens successfully
- ✅ Can send text messages via DataChannel
- ✅ Connection state managed with Riverpod
- ✅ Basic error handling implemented

---

**Ready to start coding!** 🚀

Follow this guide step-by-step, referring to the detailed technical documentation as needed.

**Good luck building FlashDrop!**
