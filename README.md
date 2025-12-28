# FlashDrop 🚀

**Fast, Private, Peer-to-Peer File Transfer**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Windows-lightgrey.svg)]()

---

## 📖 Overview

**FlashDrop** is a high-performance, privacy-first file transfer application that enables you to send files directly between Android devices and Windows desktops **without internet, cloud storage, or servers**.

### ✨ Key Features

- 🚄 **Blazing Fast** - Near Wi-Fi speed transfers (200+ Mbps on 5GHz)
- 🔒 **100% Private** - No cloud, no servers, no tracking
- 🌐 **Works Offline** - Local network or hotspot only
- 📱 **Cross-Platform** - Android ↔ Windows seamlessly
- 💰 **Completely Free** - No ads, no subscriptions, no limits
- 🔐 **Encrypted by Default** - WebRTC DTLS encryption
- ⏸️ **Pause & Resume** - Never lose progress
- 📦 **Unlimited Size** - Transfer files of any size

---

## 🎯 Use Cases

- **Photographers**: Transfer RAW photos from phone to PC instantly
- **Developers**: Move large project files between devices
- **Content Creators**: Send videos without cloud upload waits
- **Privacy-Conscious**: Keep sensitive files off third-party servers
- **Offline Work**: Transfer files without internet access

---

## 🏗️ Project Status

**Current Phase:** 📋 Planning & Design Complete  
**Next Phase:** 🛠️ Development (Week 1-2: Foundation)

### Documentation Complete ✅

- [x] **[PRD.md](PRD.md)** - Product Requirements Document
- [x] **[ARCHITECTURE.md](ARCHITECTURE.md)** - System Architecture
- [x] **[TECHNICAL_DESIGN.md](TECHNICAL_DESIGN.md)** - Flutter Implementation Details
- [x] **[DEVELOPMENT_PLAN.md](DEVELOPMENT_PLAN.md)** - 10-Week Development Roadmap
- [x] **[RISKS.md](RISKS.md)** - Risk Analysis & Mitigation

---

## 🚀 Quick Start (Post-Development)

### Android
```bash
# Download APK from Releases
# Install on Android 8+ device
# Grant storage permissions
# Start transferring!
```

### Windows
```bash
# Download .exe from Releases
# Run installer
# Allow firewall access
# Start receiving files!
```

---

## 🛠️ Technology Stack

### Core
- **Framework**: Flutter 3.x (single codebase)
- **Platforms**: Android, Windows Desktop
- **Transfer Protocol**: WebRTC DataChannel
- **State Management**: Riverpod
- **Architecture**: Clean Architecture (Feature-First)

### Key Dependencies
- `flutter_webrtc` - WebRTC implementation
- `file_picker` - File selection
- `permission_handler` - Android permissions
- `qr_flutter` / `mobile_scanner` - QR code signaling
- `network_info_plus` - Network detection

---

## 📐 Architecture Highlights

### How It Works

```
┌─────────────┐                                ┌─────────────┐
│   Android   │                                │   Windows   │
│   (Sender)  │                                │ (Receiver)  │
└──────┬──────┘                                └──────┬──────┘
       │                                              │
       │  1. Discover via mDNS or QR Code            │
       │◄────────────────────────────────────────────┤
       │                                              │
       │  2. Establish WebRTC Connection (DTLS)      │
       │◄────────────────────────────────────────────►│
       │                                              │
       │  3. Send File Metadata                      │
       ├─────────────────────────────────────────────►│
       │                                              │
       │  4. Stream File Chunks (64KB each)          │
       ├═════════════════════════════════════════════►│
       │                                              │
       │  5. Verify Checksums & Reconstruct File     │
       │                                              │
       └──────────────────────────────────────────────┘
```

### Key Design Decisions

- **WebRTC DataChannel**: Peer-to-peer with built-in encryption
- **64KB Chunks**: Optimal balance of speed and reliability
- **Local Signaling**: HTTP server + mDNS (no external dependencies)
- **Isolates**: Offload heavy operations from UI thread
- **Foreground Service**: Reliable background transfers on Android

---

## 📊 Performance Targets

| Network Type | Target Speed | File Size | Expected Time |
|--------------|--------------|-----------|---------------|
| Wi-Fi 5GHz (802.11ac) | 200+ Mbps | 1GB | ~40 seconds |
| Wi-Fi 2.4GHz (802.11n) | 40+ Mbps | 1GB | ~3 minutes |
| Mobile Hotspot | 80+ Mbps | 1GB | ~1.5 minutes |

---

## 🗺️ Development Roadmap

### MVP (v1.0) - 10 Weeks
- ✅ Week 1-2: Foundation & WebRTC Integration
- ✅ Week 3-4: File Transfer Engine
- ✅ Week 5-6: UI Development
- ✅ Week 7-8: Advanced Features (Pause/Resume)
- ✅ Week 9-10: Testing & Release

### Post-MVP (v1.1+)
- 📁 Folder transfer
- 📜 Transfer history
- 🌙 Dark mode
- 🔐 Session PIN
- 🌐 Web receiver (browser)

### Future (v2.0+)
- 🍎 iOS support
- 🐧 Linux desktop
- 🍏 macOS support
- 📡 Multi-device broadcast

---

## 🤝 Contributing

This project is currently in **active development**. Contributions will be welcome after v1.0 release.

### Development Setup (Coming Soon)
```bash
# Clone repository
git clone https://github.com/yourusername/flashdrop.git

# Install dependencies
flutter pub get

# Run on Android
flutter run -d android

# Run on Windows
flutter run -d windows
```

---

## 🔒 Privacy & Security

### What We DON'T Do
- ❌ No cloud storage
- ❌ No external servers
- ❌ No data collection
- ❌ No analytics
- ❌ No tracking
- ❌ No ads

### What We DO
- ✅ End-to-end encryption (WebRTC DTLS)
- ✅ Local-only transfers
- ✅ No file data leaves your devices
- ✅ Open-source code (auditable)
- ✅ Receive confirmation required

---

## 📄 License

This project is licensed under the **MIT License** - see [LICENSE](LICENSE) file for details.

```
Copyright (c) 2025 FlashDrop Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

[Full MIT License text]
```

---

## 🙏 Acknowledgments

- **WebRTC** - For enabling peer-to-peer communication
- **Flutter Team** - For amazing cross-platform framework
- **Open Source Community** - For inspiration and support

---

## 📞 Support

- 📧 **Email**: support@flashdrop.dev (coming soon)
- 🐛 **Issues**: [GitHub Issues](https://github.com/yourusername/flashdrop/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/yourusername/flashdrop/discussions)

---

## 🌟 Star History

If you find FlashDrop useful, please consider giving it a star! ⭐

---

## 📈 Project Stats (Post-Launch)

- **Downloads**: TBD
- **Active Users**: TBD
- **Average Rating**: TBD
- **GitHub Stars**: TBD

---

**Built with ❤️ by developers who value privacy and performance**

---

## 📚 Additional Documentation

- **[App_Idea.md](App_Idea.md)** - Original product vision
- **[PRD.md](PRD.md)** - Detailed product requirements
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System design
- **[TECHNICAL_DESIGN.md](TECHNICAL_DESIGN.md)** - Implementation details
- **[DEVELOPMENT_PLAN.md](DEVELOPMENT_PLAN.md)** - Development timeline
- **[RISKS.md](RISKS.md)** - Risk analysis

---

**Status**: 🟢 Active Development  
**Version**: 0.1.0 (Pre-release)  
**Last Updated**: December 28, 2025
