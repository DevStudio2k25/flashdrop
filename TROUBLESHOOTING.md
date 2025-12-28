# 🔧 Discovery Not Working - Troubleshooting Guide

## ❌ Problem: PC pe scan nahi ho raha

### **Quick Checks:**

#### 1. **Android Side (Server)**
```
✅ Hotspot ON hai?
✅ FlashDrop app running hai?
✅ "Start Server" button dabaya?
✅ Console mein "Broadcasting started" dikha?
```

#### 2. **Windows Side (Client)**
```
✅ Hotspot se connected hai?
✅ FlashDrop app running hai?
✅ "Scan for Nearby Devices" button dabaya?
✅ Console mein kya error hai?
```

---

## 🔥 **Most Common Issue: Windows Firewall**

### **Problem:**
Windows Firewall UDP port 8889 ko block kar raha hai!

### **Solution:**

#### **Option 1: Firewall Rule Add Karo (Recommended)**

1. **Windows Firewall Settings kholo:**
   ```
   Control Panel → System and Security → Windows Defender Firewall
   → Advanced Settings
   ```

2. **Inbound Rule banao:**
   ```
   - Click "Inbound Rules"
   - Click "New Rule..."
   - Rule Type: Port
   - Protocol: UDP
   - Port: 8889
   - Action: Allow the connection
   - Profile: All (Domain, Private, Public)
   - Name: FlashDrop Discovery
   - Finish
   ```

3. **Outbound Rule banao:**
   ```
   Same steps, but for "Outbound Rules"
   ```

#### **Option 2: Temporarily Disable Firewall (Testing Only)**

```
⚠️ WARNING: Only for testing!

Settings → Update & Security → Windows Security
→ Firewall & network protection
→ Turn off for Private network
```

---

## 🐛 **Debug Steps**

### **Step 1: Check Console Logs**

**Android Console:**
```
Expected logs:
🔊 [Discovery] Starting broadcast for Samsung Galaxy
✅ [Discovery] Broadcasting started
📡 [Discovery] Broadcast sent: Samsung Galaxy
📡 [Discovery] Broadcast sent: Samsung Galaxy
... (every 2 seconds)
```

**Windows Console:**
```
Expected logs:
🔍 [UI] Starting discovery...
🔍 [ConnectionManager] Starting device discovery...
👂 [Discovery] Starting to listen for devices...
✅ [Discovery] Listening for broadcasts
✅ [UI] Discovery started successfully
📱 [Discovery] Found device: Samsung Galaxy (192.168.43.1)
```

### **Step 2: Check Network**

**Same network pe hain?**
```
Android Hotspot IP: 192.168.43.1
Windows IP: 192.168.43.x (same subnet!)

Check karo:
Windows → CMD → ipconfig
```

### **Step 3: Test UDP Manually**

**Android pe test:**
```dart
// Already broadcasting on port 8889
// Check logs for "Broadcast sent"
```

**Windows pe test:**
```dart
// Already listening on port 8889
// Check logs for "Listening for broadcasts"
```

---

## 🔍 **Common Errors & Solutions**

### **Error 1: "SocketException: Bind failed"**
```
Problem: Port already in use
Solution: 
- Close other apps using port 8889
- Restart FlashDrop
```

### **Error 2: "No devices found"**
```
Problem: Firewall blocking OR not on same network
Solution:
1. Check firewall (see above)
2. Verify same network:
   - Android: 192.168.43.1
   - Windows: 192.168.43.x
```

### **Error 3: "Discovery failed: ..."**
```
Problem: Permission or network issue
Solution:
- Check Windows firewall
- Restart both apps
- Reconnect to hotspot
```

---

## ✅ **Working Setup Checklist**

```
Android:
☐ Hotspot enabled
☐ FlashDrop running
☐ Server started
☐ Console shows "Broadcasting started"
☐ Console shows "Broadcast sent" every 2 seconds

Windows:
☐ Connected to Android hotspot
☐ IP is 192.168.43.x
☐ FlashDrop running
☐ Clicked "Scan for Nearby Devices"
☐ Console shows "Listening for broadcasts"
☐ Firewall allows UDP 8889

Result:
☐ Windows console shows "Found device: ..."
☐ Device appears in list
☐ Can tap to connect
```

---

## 🚀 **Quick Test**

### **Test 1: Manual IP (Bypass Discovery)**
```
Agar discovery nahi chal raha:
1. Android ka IP note karo (192.168.43.1)
2. Windows pe manually connect karo
3. Agar ye kaam kare, toh discovery ka issue hai
4. Agar ye bhi nahi kare, toh network ka issue hai
```

### **Test 2: Ping Test**
```
Windows CMD:
ping 192.168.43.1

Agar reply aaye:
✅ Network connection theek hai
❌ Discovery/Firewall issue hai

Agar reply na aaye:
❌ Network connection problem hai
```

---

## 💡 **Pro Tips**

### **Tip 1: Console Dekho**
```
Hamesha console logs dekho:
- Android: flutter run output
- Windows: flutter run -d windows output

Logs batayenge kya ho raha hai!
```

### **Tip 2: Firewall Exception**
```
Production app ke liye:
- Installer mein firewall rule add karo
- Ya app first run pe permission maango
```

### **Tip 3: Fallback to Manual**
```
Agar discovery fail ho:
- Manual IP entry option rakho
- User ko choice do: Auto ya Manual
```

---

## 🔧 **Advanced Debugging**

### **Check UDP Broadcast:**

**Windows PowerShell (Admin):**
```powershell
# Check if port 8889 is listening
netstat -an | findstr "8889"

# Should show:
UDP    0.0.0.0:8889    *:*
```

**Wireshark (Optional):**
```
1. Install Wireshark
2. Capture on Wi-Fi adapter
3. Filter: udp.port == 8889
4. Should see broadcasts from 192.168.43.1
```

---

## 📝 **Summary**

### **Most Likely Issue:**
```
🔥 Windows Firewall blocking UDP port 8889
```

### **Quick Fix:**
```
1. Add firewall rule for UDP 8889 (Inbound + Outbound)
2. Restart FlashDrop
3. Scan again
```

### **If Still Not Working:**
```
1. Check console logs (both sides)
2. Verify same network (ping test)
3. Try manual IP connection
4. Check antivirus/security software
```

---

**Sabse pehle Windows Firewall check karo - 99% yehi issue hota hai! 🔥**
