# FlashDrop - Risks & Mitigations

**Version:** 1.0  
**Date:** December 28, 2025

---

## 1. TECHNICAL RISKS

### RISK-T01: WebRTC Connection Failures
**Severity:** 🔴 HIGH  
**Probability:** MEDIUM  
**Impact:** Critical - Core functionality broken

**Description:**
WebRTC peer connections may fail to establish due to:
- NAT traversal issues
- Firewall blocking
- ICE candidate gathering failures
- STUN server unavailability
- Platform-specific WebRTC bugs

**Mitigation Strategies:**
1. **Primary:** Focus on local network transfers (same Wi-Fi)
   - Eliminates most NAT issues
   - Direct peer-to-peer connection

2. **Fallback Signaling:**
   - Implement multiple signaling methods (mDNS + QR code)
   - Allow manual IP entry as last resort

3. **Robust ICE Configuration:**
   ```dart
   final iceServers = [
     {'urls': 'stun:stun.l.google.com:19302'},
     {'urls': 'stun:stun1.l.google.com:19302'},
     {'urls': 'stun:stun2.l.google.com:19302'}, // Backup
   ];
   ```

4. **Connection Diagnostics:**
   - Implement debug panel showing ICE state
   - Log connection failures with details
   - Provide user-friendly error messages

5. **Testing:**
   - Test on various network configurations
   - Test with different routers
   - Test with mobile hotspots

**Contingency Plan:**
If WebRTC proves unreliable, fall back to HTTP-based transfer:
- Sender runs HTTP server
- Receiver connects via HTTP
- Less elegant but more reliable

---

### RISK-T02: File Transfer Performance Below Target
**Severity:** 🟡 MEDIUM  
**Probability:** MEDIUM  
**Impact:** High - User experience degraded

**Description:**
Transfer speeds may not reach target (80% of Wi-Fi bandwidth) due to:
- Inefficient chunking
- DataChannel buffer bloat
- CPU bottleneck (checksum calculation)
- Memory allocation overhead
- Flutter/Dart performance limitations

**Mitigation Strategies:**
1. **Optimize Chunk Size:**
   - Test various sizes (16KB, 32KB, 64KB, 128KB)
   - Benchmark on real devices
   - Choose optimal size based on data

2. **Use Isolates for Heavy Operations:**
   ```dart
   // Offload checksum calculation to isolate
   final checksum = await compute(_calculateChecksum, chunkData);
   ```

3. **Implement Flow Control:**
   - Sliding window protocol (256 chunks in flight)
   - Backpressure handling
   - Adaptive buffering

4. **Profile Early and Often:**
   - Use Dart DevTools
   - Identify bottlenecks in Week 4
   - Optimize hot paths

5. **Platform-Specific Optimizations:**
   - Use native code for checksums if needed (FFI)
   - Optimize DataChannel buffer sizes

**Performance Targets:**
- 802.11n (2.4GHz): >40 Mbps
- 802.11ac (5GHz): >200 Mbps
- Hotspot: >80 Mbps

**Contingency Plan:**
If targets not met:
- Reduce checksum frequency (every 10th chunk)
- Use faster hash (CRC32 instead of SHA-256)
- Disable checksums (user option)

---

### RISK-T03: Memory Leaks with Large Files
**Severity:** 🔴 HIGH  
**Probability:** MEDIUM  
**Impact:** Critical - App crashes, poor UX

**Description:**
Transferring large files (5GB+) may cause memory leaks due to:
- Chunks not being garbage collected
- DataChannel buffer accumulation
- File handles not closed
- Stream subscriptions not cancelled

**Mitigation Strategies:**
1. **Streaming Architecture:**
   - Never load entire file into memory
   - Process chunks one at a time
   - Release memory immediately after sending

2. **Explicit Resource Management:**
   ```dart
   try {
     final file = await File(path).open();
     // ... transfer logic
   } finally {
     await file.close(); // Always close
   }
   ```

3. **Memory Monitoring:**
   - Use Dart DevTools memory profiler
   - Test with 10GB files in Week 4
   - Set memory usage alerts

4. **Chunk Lifecycle Management:**
   ```dart
   class ChunkManager {
     final _activeChunks = <int, Chunk>{};
     
     void onChunkSent(int index) {
       _activeChunks.remove(index); // Explicit cleanup
     }
   }
   ```

5. **Testing:**
   - Automated memory leak tests
   - Long-running transfer tests (hours)
   - Multiple consecutive transfers

**Memory Budget:**
- Target: <200MB during 5GB transfer
- Maximum: <500MB
- Baseline (idle): <50MB

**Contingency Plan:**
If memory issues persist:
- Reduce window size (fewer chunks in flight)
- Force garbage collection periodically
- Implement memory pressure detection

---

### RISK-T04: Flutter Desktop Instability
**Severity:** 🟡 MEDIUM  
**Probability:** LOW  
**Impact:** High - Windows app unusable

**Description:**
Flutter desktop (Windows) is relatively new and may have:
- Rendering bugs
- Platform channel issues
- File system access problems
- Crash-prone behavior

**Mitigation Strategies:**
1. **Early Testing:**
   - Build Windows app in Week 1
   - Identify issues immediately
   - Report bugs to Flutter team

2. **Use Stable Flutter Channel:**
   ```bash
   flutter channel stable
   flutter upgrade
   ```

3. **Minimal Native Code:**
   - Rely on Flutter packages
   - Avoid complex platform channels
   - Use well-tested packages only

4. **Fallback UI:**
   - Keep UI simple and standard
   - Avoid experimental widgets
   - Use Material widgets (cross-platform)

5. **Community Support:**
   - Monitor Flutter GitHub issues
   - Join Flutter Discord/Reddit
   - Seek help early

**Contingency Plan:**
If Flutter desktop is too unstable:
- Build Windows app with Electron + WebRTC
- Separate codebase but proven technology
- More maintenance but higher reliability

---

### RISK-T05: Android Background Execution Limits
**Severity:** 🟡 MEDIUM  
**Probability:** HIGH  
**Impact:** Medium - Transfers interrupted when app backgrounded

**Description:**
Android 8+ aggressively kills background processes:
- App may be killed mid-transfer
- Foreground service may not prevent killing
- Battery optimization may interfere

**Mitigation Strategies:**
1. **Foreground Service (Required):**
   ```kotlin
   class TransferForegroundService : Service() {
     override fun onStartCommand(...): Int {
       startForeground(NOTIFICATION_ID, notification)
       return START_STICKY
     }
   }
   ```

2. **Persistent Notification:**
   - Show ongoing notification during transfer
   - Update with progress
   - Prevents app from being killed

3. **Wake Lock:**
   ```xml
   <uses-permission android:name="android.permission.WAKE_LOCK" />
   ```
   - Prevent device from sleeping
   - Release immediately after transfer

4. **User Education:**
   - Prompt to disable battery optimization
   - Warn before backgrounding during transfer
   - Show "Keep screen on" option

5. **State Persistence:**
   - Save transfer state periodically
   - Resume from last checkpoint if killed

**Testing:**
- Test on various Android versions (8, 10, 12, 13)
- Test with aggressive battery saver modes
- Test with screen off

**Contingency Plan:**
If background transfers unreliable:
- Require app to stay in foreground
- Show warning when user tries to background
- Implement "screen dimming" mode

---

### RISK-T06: Pause/Resume Data Corruption
**Severity:** 🔴 HIGH  
**Probability:** LOW  
**Impact:** Critical - File corruption, data loss

**Description:**
Pausing and resuming transfers may cause:
- Chunk index misalignment
- Duplicate chunks
- Missing chunks
- Checksum failures

**Mitigation Strategies:**
1. **Robust State Management:**
   ```dart
   class TransferState {
     final int lastChunkSent;
     final int lastChunkAcknowledged;
     final Set<int> pendingChunks;
     
     // Resume from lastChunkAcknowledged + 1
   }
   ```

2. **Checksum Validation:**
   - Verify every chunk
   - Reject duplicates
   - Request retransmission on mismatch

3. **Atomic State Persistence:**
   - Save state after each ACK
   - Use transactions for state updates
   - Verify state integrity on resume

4. **Extensive Testing:**
   - Pause/resume at random points
   - Pause for extended periods
   - Multiple pause/resume cycles
   - Compare file hashes (sender vs receiver)

5. **Final Verification:**
   ```dart
   final senderHash = await calculateFileHash(originalFile);
   final receiverHash = await calculateFileHash(receivedFile);
   
   if (senderHash != receiverHash) {
     throw TransferCorruptionError();
   }
   ```

**Testing Scenarios:**
- Pause at 10%, 50%, 90%
- Pause for 1 second, 1 minute, 1 hour
- Pause/resume 10 times in single transfer
- Network drop during pause

**Contingency Plan:**
If pause/resume unreliable:
- Remove pause feature from MVP
- Add to v1.1 after more testing
- Implement "restart transfer" instead

---

## 2. PLATFORM-SPECIFIC RISKS

### RISK-P01: Windows Firewall Blocking
**Severity:** 🟡 MEDIUM  
**Probability:** HIGH  
**Impact:** Medium - Connection fails, user confusion

**Description:**
Windows Firewall will prompt user when app tries to open HTTP server:
- User may deny access
- Firewall may block silently
- Antivirus may interfere

**Mitigation Strategies:**
1. **Clear User Messaging:**
   - Show dialog before starting server
   - Explain why firewall access needed
   - Provide troubleshooting steps

2. **Firewall Rule Detection:**
   ```dart
   Future<bool> isFirewallBlocking() async {
     // Try to bind to port
     // If fails, likely firewall issue
   }
   ```

3. **Alternative Ports:**
   - Try multiple ports (8080, 8081, 8082)
   - Use dynamic port selection
   - Display port to user

4. **Documentation:**
   - Include firewall setup guide
   - Screenshots of Windows Firewall dialog
   - Common antivirus configurations

**Contingency Plan:**
- Provide manual firewall configuration guide
- Use QR code signaling (no server needed)
- Implement UPnP port forwarding (future)

---

### RISK-P02: Android Storage Permissions
**Severity:** 🟡 MEDIUM  
**Probability:** MEDIUM  
**Impact:** Medium - Cannot access files

**Description:**
Android 11+ scoped storage restrictions:
- Cannot access arbitrary files
- Must use Storage Access Framework
- Permission prompts may confuse users

**Mitigation Strategies:**
1. **Use Storage Access Framework:**
   ```dart
   final result = await FilePicker.platform.pickFiles(
     allowMultiple: true,
     type: FileType.any,
   );
   ```

2. **Request Minimal Permissions:**
   - Only request when needed
   - Explain why permission needed
   - Graceful degradation if denied

3. **Target Android 13:**
   - Use granular media permissions
   - `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`, etc.

4. **Testing:**
   - Test on Android 11, 12, 13
   - Test permission denial scenarios
   - Test revoked permissions

**Contingency Plan:**
- Use SAF exclusively (no direct file access)
- Limit to Downloads folder only
- Provide clear permission instructions

---

### RISK-P03: Windows SmartScreen Warnings
**Severity:** 🟡 MEDIUM  
**Probability:** HIGH  
**Impact:** Medium - Users scared to install

**Description:**
Unsigned Windows .exe will trigger SmartScreen:
- "Windows protected your PC" warning
- Users may not know how to bypass
- Damages trust and credibility

**Mitigation Strategies:**
1. **Code Signing Certificate:**
   - Purchase EV code signing certificate (~$300/year)
   - Sign .exe with certificate
   - Builds reputation over time

2. **Clear Installation Guide:**
   - Document SmartScreen bypass steps
   - Explain why warning appears
   - Provide SHA-256 checksum for verification

3. **Alternative Distribution:**
   - Microsoft Store (no SmartScreen)
   - Portable ZIP version (no installer)
   - Chocolatey package manager

4. **Build Reputation:**
   - Distribute widely
   - Get downloads (SmartScreen learns)
   - Submit to Microsoft for review

**Contingency Plan (MVP):**
- Accept SmartScreen warnings for v1.0
- Provide detailed bypass instructions
- Purchase certificate for v1.1

---

## 3. USER EXPERIENCE RISKS

### RISK-U01: Complex Setup Process
**Severity:** 🟡 MEDIUM  
**Probability:** MEDIUM  
**Impact:** Medium - Users abandon app

**Description:**
Users may struggle with:
- Connecting devices to same network
- Understanding QR code scanning
- Granting permissions
- Firewall prompts

**Mitigation Strategies:**
1. **Onboarding Tutorial:**
   - First-run walkthrough
   - Animated guides
   - Step-by-step instructions

2. **Automatic Discovery:**
   - mDNS "just works" on same network
   - No manual configuration needed
   - Clear status indicators

3. **Helpful Error Messages:**
   ```dart
   if (connectionFailed) {
     showDialog(
       title: "Connection Failed",
       message: "Make sure both devices are on the same Wi-Fi network.",
       actions: [
         "Check Wi-Fi Settings",
         "Try QR Code Instead",
         "Help",
       ],
     );
   }
   ```

4. **In-App Help:**
   - FAQ section
   - Troubleshooting guide
   - Video tutorials (future)

**Success Metric:**
- Time to first transfer: <60 seconds
- Setup completion rate: >90%

---

### RISK-U02: Poor Transfer Speed Perception
**Severity:** 🟡 MEDIUM  
**Probability:** LOW  
**Impact:** Medium - Users think app is slow

**Description:**
Even if transfer is fast, users may perceive it as slow due to:
- Inaccurate progress indicators
- Misleading ETA
- No visual feedback

**Mitigation Strategies:**
1. **Accurate Progress:**
   - Update every 500ms
   - Show bytes transferred, not just percentage
   - Display current file name

2. **Real-Time Speed:**
   - Calculate over 5-second window (smooth)
   - Show in Mbps (familiar to users)
   - Highlight when speed is high

3. **Visual Feedback:**
   - Animated progress bar
   - Speed graph (optional)
   - Completion animations

4. **Comparison Context:**
   ```
   "Transferring at 150 Mbps"
   "3x faster than Bluetooth"
   "Estimated time: 2 minutes"
   ```

---

## 4. SECURITY & PRIVACY RISKS

### RISK-S01: Man-in-the-Middle Attacks
**Severity:** 🟡 MEDIUM  
**Probability:** LOW  
**Impact:** High - File interception

**Description:**
On untrusted networks, attacker could:
- Intercept signaling
- Perform MITM on WebRTC connection
- Access transferred files

**Mitigation Strategies:**
1. **WebRTC DTLS Encryption (Default):**
   - All data encrypted by default
   - No plaintext transmission
   - Perfect Forward Secrecy

2. **Signaling Security:**
   - Use HTTPS for signaling (if using external server)
   - Implement SDP fingerprint verification
   - Show connection fingerprint to user

3. **User Education:**
   - Warn about public Wi-Fi
   - Recommend using hotspot for sensitive files
   - Display encryption status

4. **Optional Session PIN (Post-MVP):**
   ```dart
   final pin = generateRandomPin(6);
   // User must enter PIN on receiver to accept
   ```

**Risk Acceptance:**
For MVP, rely on WebRTC default encryption. Add additional layers in v1.1.

---

### RISK-S02: Malicious File Transfers
**Severity:** 🟡 MEDIUM  
**Probability:** LOW  
**Impact:** Medium - Malware infection

**Description:**
Receiver may unknowingly accept malicious files:
- Executable malware
- Phishing documents
- Exploits

**Mitigation Strategies:**
1. **Receive Confirmation:**
   - Always show file details before accepting
   - Display file name, size, type
   - Require explicit user confirmation

2. **File Type Warnings:**
   ```dart
   if (file.extension == '.exe' || file.extension == '.bat') {
     showWarning(
       "This is an executable file. Only accept if you trust the sender.",
     );
   }
   ```

3. **Sandboxed Save Location:**
   - Save to Downloads folder (not system directories)
   - Never auto-execute files
   - Let OS handle file scanning

4. **User Responsibility:**
   - Clear disclaimer in app
   - Recommend antivirus scanning
   - No automatic file opening

**Risk Acceptance:**
FlashDrop is a file transfer tool, not a security tool. Users responsible for file safety.

---

## 5. BUSINESS & LEGAL RISKS

### RISK-B01: Liability for Misuse
**Severity:** 🟡 MEDIUM  
**Probability:** LOW  
**Impact:** Medium - Legal issues

**Description:**
Users may misuse app for:
- Piracy (sharing copyrighted content)
- Illegal content distribution
- Corporate espionage

**Mitigation Strategies:**
1. **Clear Terms of Service:**
   ```
   FlashDrop is a tool for personal file transfer.
   Users are solely responsible for content transferred.
   Do not use for illegal purposes.
   ```

2. **No Content Monitoring:**
   - App is end-to-end encrypted
   - No server-side storage
   - Cannot monitor or control usage

3. **Open Source License:**
   - MIT or Apache 2.0
   - Disclaimer of warranties
   - Limitation of liability

4. **Privacy Policy:**
   - No data collection
   - No analytics
   - No user tracking

**Legal Disclaimer:**
```
THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES,
OR OTHER LIABILITY ARISING FROM USE OF THE SOFTWARE.
```

---

### RISK-B02: Trademark Issues
**Severity:** 🟢 LOW  
**Probability:** LOW  
**Impact:** Low - Name change required

**Description:**
"FlashDrop" name may conflict with existing trademarks.

**Mitigation Strategies:**
1. **Trademark Search:**
   - Search USPTO database
   - Search app stores
   - Google search for conflicts

2. **Alternative Names:**
   - FlashShare
   - QuickDrop
   - ZapTransfer
   - BoltSend

3. **No Trademark Registration (MVP):**
   - Don't register trademark initially
   - Easy to rename if needed
   - Low risk for open-source project

**Contingency Plan:**
If trademark conflict discovered, rename app before v1.0 release.

---

## 6. RISK MATRIX

| Risk ID | Risk | Severity | Probability | Priority |
|---------|------|----------|-------------|----------|
| RISK-T01 | WebRTC Connection Failures | 🔴 HIGH | MEDIUM | 🔴 P1 |
| RISK-T03 | Memory Leaks | 🔴 HIGH | MEDIUM | 🔴 P1 |
| RISK-T06 | Pause/Resume Corruption | 🔴 HIGH | LOW | 🟡 P2 |
| RISK-T02 | Poor Performance | 🟡 MEDIUM | MEDIUM | 🟡 P2 |
| RISK-T04 | Flutter Desktop Issues | 🟡 MEDIUM | LOW | 🟡 P2 |
| RISK-T05 | Android Background Limits | 🟡 MEDIUM | HIGH | 🟡 P2 |
| RISK-P01 | Windows Firewall | 🟡 MEDIUM | HIGH | 🟡 P2 |
| RISK-P02 | Android Permissions | 🟡 MEDIUM | MEDIUM | 🟢 P3 |
| RISK-P03 | SmartScreen Warnings | 🟡 MEDIUM | HIGH | 🟢 P3 |
| RISK-U01 | Complex Setup | 🟡 MEDIUM | MEDIUM | 🟢 P3 |
| RISK-S01 | MITM Attacks | 🟡 MEDIUM | LOW | 🟢 P3 |
| RISK-S02 | Malicious Files | 🟡 MEDIUM | LOW | 🟢 P3 |

**Priority Levels:**
- 🔴 **P1 (Critical):** Address immediately, may block release
- 🟡 **P2 (High):** Address during development, test thoroughly
- 🟢 **P3 (Medium):** Monitor, mitigate if occurs

---

## 7. RISK MONITORING PLAN

### Weekly Risk Review
**Every Friday:**
1. Review risk matrix
2. Update probabilities based on progress
3. Identify new risks
4. Adjust mitigation strategies

### Risk Triggers
**Immediate escalation if:**
- WebRTC connection success rate <80%
- Transfer speed <50% of target
- Memory usage >500MB
- Crash rate >1%
- Critical bug discovered

### Risk Reporting
**Format:**
```
RISK ALERT: [RISK-ID]
Status: [OCCURRED / LIKELY / MITIGATED]
Impact: [description]
Action Taken: [mitigation steps]
Next Steps: [plan]
```

---

## 8. LESSONS LEARNED (Post-Launch)

### To Be Completed After v1.0 Release

**Questions to Answer:**
1. Which risks materialized?
2. Which mitigations were effective?
3. What unexpected risks emerged?
4. How can we improve risk management for v1.1?

**Template:**
```
Risk: [ID]
Occurred: [YES/NO]
Severity: [ACTUAL]
Mitigation Effectiveness: [1-10]
Lessons: [what we learned]
```

---

**Document Status:** ✅ COMPLETE  
**Next Steps:** Begin development with risk awareness
