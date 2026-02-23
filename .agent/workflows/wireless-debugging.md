---
description: connect mobile using wireless debugging
---

### Wireless Debugging Setup (Android 11+)

Follow these steps to connect your device wirelessly for Flutter development.

#### 1. Prerequisites
- Ensure your phone and computer are on the **same Wi-Fi network**.
- Enable **Developer Options** on your phone (Settings > About Phone > Tap 'Build Number' 7 times).
- Enable **USB Debugging** and **Wireless Debugging** in Developer Options.

#### 2. Find Pairing Information
- On your phone, go to **Wireless Debugging** > **Pair device with pairing code**.
- Take note of the **IP address & Port** (e.g., `192.168.1.5:4321`) and the **Pairing Code**.

#### 3. Pair the Device
In your computer's terminal, run the following command (replace with your values):
```powershell
adb pair [IP_ADDRESS]:[PORT] [PAIRING_CODE]
```
Example: `adb pair 192.168.1.5:4321 123456`

#### 4. Connect to the Device
- Back on the phone, look at the main "Wireless Debugging" screen for the **IP address & Port** listed under **IP address & Port** (this port is usually different from the pairing port).
- Run the connect command:
```powershell
adb connect [IP_ADDRESS]:[PORT]
```

#### 5. Verify the Connection
```powershell
flutter devices
```
If successful, your device should appear in the list.

### Troubleshooting
- **ADB Command Not Found**: Ensure Android SDK platform-tools is in your PATH.
- **Connection Failed**: Toggle Wi-Fi off and on on both devices.
- **Restart ADB Server**:
  ```powershell
  adb kill-server
  adb start-server
  ```
