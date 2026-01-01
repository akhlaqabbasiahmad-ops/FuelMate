# Running Flutter App on Physical Android Device

## Quick Setup (5 Steps)

### Step 1: Enable Developer Options on Your Phone

1. Open **Settings** on your Android phone
2. Go to **About Phone** (or **About Device**)
3. Find **Build Number** (may be under Software Information)
4. **Tap Build Number 7 times** rapidly
5. You'll see a message: "You are now a developer!"

### Step 2: Enable USB Debugging

1. Go back to main **Settings**
2. Find **Developer Options** (usually in System or Additional Settings)
3. Enable **USB Debugging**
4. Enable **Install via USB** (if available)
5. Keep Developer Options ON

### Step 3: Connect Your Phone

1. Connect your phone to computer via **USB cable**
2. On your phone, you'll see a popup: **"Allow USB debugging?"**
3. Check **"Always allow from this computer"**
4. Tap **OK**

### Step 4: Verify Connection

Run this command to check if Flutter detects your device:

```powershell
cd "D:\my work place\PetrolMate\flutter_app"
flutter devices
```

You should see your device listed (e.g., "SM-G991B" or similar).

### Step 5: Run the App

```powershell
flutter run
```

The app will install and launch on your phone automatically!

## Troubleshooting

### ❌ Device Not Detected?

**Solution 1: Check USB Connection**
- Try a different USB cable
- Try a different USB port
- Make sure cable supports data transfer (not just charging)

**Solution 2: Install USB Drivers (Windows)**
- Download USB drivers for your phone manufacturer:
  - Samsung: https://developer.samsung.com/android-usb-driver
  - Google Pixel: Included with Android SDK
  - Other brands: Search "[Brand] USB drivers"

**Solution 3: Restart ADB**
```powershell
adb kill-server
adb start-server
flutter devices
```

**Solution 4: Change USB Mode**
- On your phone, swipe down notification panel
- Tap USB notification
- Change from "Charging only" to "File Transfer" or "MTP"

### ❌ "Unauthorized" Error?

**Solution:**
- Disconnect and reconnect USB cable
- Check for USB debugging popup on phone
- Tap "Always allow" and OK

### ❌ App Installs but Crashes?

**Solution:**
1. Check backend is running
2. Update API IP in `lib/config/api_config.dart`
3. Make sure phone and computer are on **same WiFi network**

## Important: API Configuration for Physical Device

When using a physical device, you **MUST** update the API configuration:

1. Open `lib/config/api_config.dart`
2. Find your computer's IP address:
   ```powershell
   ipconfig
   ```
   Look for "IPv4 Address" (e.g., 192.168.1.6)

3. Update the file:
   ```dart
   static const String apiHostIp = '192.168.1.6'; // Your IP here
   ```

4. **Important:** Do NOT use `localhost` or `127.0.0.1` - these won't work on physical devices!

5. Ensure your phone and computer are on the **same WiFi network**

## Testing the Setup

After running `flutter run`, you should see:

```
✓ Built build\app\outputs\flutter-apk\app-debug.apk.
Installing build\app\outputs\flutter-apk\app.apk...
Waiting for SM-G991B to report its views...
Flutter run key commands.
r Hot reload. 🔥🔥🔥
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).

Running with sound null safety

An Observatory debugger and profiler on SM-G991B is available at: http://127.0.0.1:xxxxx/
The Flutter DevTools debugger and profiler on SM-G991B is available at: http://127.0.0.1:xxxxx/
```

## Hot Reload (Development Feature)

While the app is running:
- Press **`r`** - Hot reload (instant updates)
- Press **`R`** - Hot restart (full restart)
- Press **`q`** - Quit

This lets you make code changes and see them instantly on your phone!

## Network Requirements

For the app to work on your physical device:

✅ **Required:**
- Phone and computer on **same WiFi network**
- Backend server running on computer
- Correct IP address in `api_config.dart`
- Firewall allows connections on port 3000/4000

❌ **Won't Work:**
- Using `localhost` or `127.0.0.1`
- Phone on mobile data, computer on WiFi
- Different WiFi networks
- VPN enabled (may cause issues)

## Quick Commands Reference

```powershell
# Check connected devices
flutter devices

# Run on specific device (if multiple connected)
flutter run -d <device-id>

# Run in release mode (faster, no debugging)
flutter run --release

# Clear and rebuild
flutter clean
flutter pub get
flutter run

# View logs
flutter logs

# Install only (don't run)
flutter install
```

## Building APK for Distribution

To create an APK file you can share:

```powershell
# Debug APK (for testing)
flutter build apk --debug

# Release APK (optimized)
flutter build apk --release
```

APK location: `build\app\outputs\flutter-apk\app-release.apk`

## Common Phone Brands Setup

### Samsung
- Developer Options: Settings → About Phone → Software Information → Build Number (tap 7x)
- USB Debugging: Settings → Developer Options → USB Debugging

### Google Pixel
- Developer Options: Settings → About Phone → Build Number (tap 7x)
- USB Debugging: Settings → System → Developer Options → USB Debugging

### Xiaomi/Redmi
- Developer Options: Settings → About Phone → MIUI Version (tap 7x)
- USB Debugging: Settings → Additional Settings → Developer Options → USB Debugging
- Also enable: "Install via USB" and "USB Debugging (Security settings)"

### OnePlus
- Developer Options: Settings → About Phone → Build Number (tap 7x)
- USB Debugging: Settings → System → Developer Options → USB Debugging

### Oppo/Realme
- Developer Options: Settings → About Phone → Version (tap 7x)
- USB Debugging: Settings → Additional Settings → Developer Options → USB Debugging

## Success Checklist

Before running `flutter run`, verify:

- ✅ Developer Options enabled on phone
- ✅ USB Debugging enabled
- ✅ Phone connected via USB
- ✅ USB debugging authorized on phone
- ✅ `flutter devices` shows your device
- ✅ Backend server is running
- ✅ API IP updated in `api_config.dart`
- ✅ Phone and computer on same WiFi

## Ready to Run!

Now execute:

```powershell
cd "D:\my work place\PetrolMate\flutter_app"
flutter run
```

Your app will install and launch on your phone! 🚀

---

**Need help?** Check if your device appears in `flutter devices`. If not, review the troubleshooting section above.

