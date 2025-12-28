You are a senior product architect and lead Flutter multiplatform engineer.

Your task is to independently create a COMPLETE, IMPLEMENTABLE PRODUCT REQUIREMENTS DOCUMENT (PRD)
and immediately begin development planning for a high-performance, personal, peer-to-peer file transfer application.

Do NOT ask follow-up questions.
Make reasonable technical assumptions where required.
Act as if this product will be built and shipped.

====================================================
PRODUCT OVERVIEW
====================================================

Product Name (working): FlashDrop (you may rename if better)

Goal:
Build a FAST, PRIVATE, SERVERLESS file transfer app that works:
- Android → Android
- Android → Windows (desktop .exe)
- Optional: Android → PC browser

Key Principles:
- 100% free
- No cloud storage
- No permanent backend server
- Works offline / local network
- Extremely fast (near Wi-Fi speed)
- Secure by default
- Personal use focused

Core Technology:
- WebRTC DataChannel for file transfer
- Flutter (single codebase)
- Platforms: Android + Windows desktop
- Optional Web receiver support

====================================================
CORE FUNCTIONAL REQUIREMENTS
====================================================

1. DEVICE DISCOVERY & CONNECTION
- App must support peer-to-peer connection using WebRTC
- Signaling must NOT require a public server
- Use one or more of the following:
  - Local Wi-Fi signaling
  - Temporary local HTTP signaling server
  - QR-code based SDP exchange
- Internet must NOT be required after connection is established

2. FILE TRANSFER
- Support sending:
  - Single file
  - Multiple files
  - Large files (GB size)
- Transfer must use:
  - WebRTC DataChannel
  - Chunked binary transfer (recommended ~64KB chunks)
- Support:
  - Pause / resume
  - Cancel
  - Retry on failure
- Show real-time:
  - Progress
  - Speed
  - ETA

3. PERFORMANCE
- Optimize for:
  - Same Wi-Fi network
  - Hotspot mode
- Target throughput:
  - As close to raw Wi-Fi speed as possible
- No UI blocking
- Use isolates / background execution where required

4. SECURITY & PRIVACY
- Use WebRTC default encryption (DTLS)
- No file data stored on any server
- No analytics, no tracking
- Optional session PIN or receive confirmation

5. ANDROID → WINDOWS SUPPORT
- Windows build must produce a native .exe using Flutter desktop
- Same codebase for Android and Windows
- Desktop UX optimized for:
  - Mouse
  - Keyboard
  - Large screens
- App should display:
  - Connection instructions
  - QR code or pairing info if required

====================================================
NON-FUNCTIONAL REQUIREMENTS
====================================================

- Flutter best practices
- Clean architecture (feature-first or layered)
- Modular, scalable codebase
- Easy to extend
- Battery-efficient on Android
- Android minimum: Android 8+
- Windows: 64-bit desktop support

====================================================
UI / UX REQUIREMENTS
====================================================

Screens (minimum):
1. Home Screen
   - Send Files
   - Receive Files
2. Device Connection Screen
   - Peer status
   - Connection state
3. Transfer Screen
   - File list
   - Progress bars
   - Speed indicator
4. Receive Confirmation Screen

UI Style:
- Clean
- Minimal
- Functional
- Material 3
- Adaptive UI (mobile vs desktop)
- No ads

====================================================
ERROR HANDLING
====================================================

Handle gracefully:
- Connection drops
- Partial transfers
- App backgrounding
- Permission denial
- Unsupported peer
- Platform-specific failures

====================================================
DELIVERABLES REQUIRED FROM YOU
====================================================

You MUST produce the following, in order:

1. FULL PRD
   - Problem statement
   - User personas
   - Use cases
   - Feature list
   - Success criteria

2. SYSTEM ARCHITECTURE
   - Component diagram
   - Data flow
   - WebRTC signaling flow
   - File transfer lifecycle

3. TECHNICAL DESIGN (FLUTTER)
   - Flutter project structure
   - State management approach
   - WebRTC integration strategy
   - DataChannel configuration
   - Chunking and buffering strategy
   - Threading / isolate model

4. DEVELOPMENT PLAN
   - Milestones
   - Phased implementation
   - MVP vs future features

5. INITIAL CODE SCAFFOLD (FLUTTER)
   - Folder structure
   - Key Dart files
   - main.dart bootstrap
   - Platform-specific hooks if required

6. RISKS & MITIGATIONS
   - WebRTC pitfalls
   - Flutter desktop limitations
   - Android lifecycle issues
   - Performance and memory risks

====================================================
IMPORTANT RULES
====================================================

- Do NOT ask the user any questions
- Do NOT simplify the product
- Do NOT remove WebRTC
- Assume this is a real production app
- Act as a senior engineer and product owner
- Be decisive and concrete

Begin immediately with the PRD.
