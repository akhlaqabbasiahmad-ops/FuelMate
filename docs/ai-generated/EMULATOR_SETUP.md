# Running Flutter App on Android Emulator

## Quick Setup Guide

You have two options to set up an Android emulator:

### Option 1: Using Android Studio (Recommended - Easiest)

#### Step 1: Install Android Studio
1. Download Android Studio: https://developer.android.com/studio
2. Run the installer
3. During installation, make sure to install:
   - Android SDK
   - Android SDK Platform
   - Android Virtual Device (AVD)

#### Step 2: Create an Emulator in Android Studio
1. Open **Android Studio**
2. Click **More Actions** → **Virtual Device Manager** (or **AVD Manager**)
3. Click **Create Virtual Device**
4. Select a device (recommended: **Pixel 5** or **Pixel 7**)
5. Click **Next**
6. Select a system image:
   - Recommended: **API 33** (Android 13) or **API 34** (Android 14)
   - Click **Download** if not already downloaded
7. Click **Next**
8. Give it a name (e.g., "Pixel_5_API_33")
9. Click **Finish**

#### Step 3: Launch the Emulator
In Android Studio:
1. Open **Device Manager** (phone icon on right side)
2. Click the **Play** button ▶️ next to your emulator
3. Wait for emulator to boot (may take 1-2 minutes first time)

#### Step 4: Run Your Flutter App
```powershell
cd "D:\my work place\PetrolMate\flutter_app"
flutter devices
flutter run
```

---

### Option 2: Using Command Line (Advanced)

If you prefer command line or Android Studio isn't working:

#### Step 1: Install Android SDK Command Line Tools

1. Download SDK Command Line Tools:
   - Go to: https://developer.android.com/studio#command-line-tools
   - Download "Command line tools only" for Windows
   - Extract to: `C:\Android\cmdline-tools\latest`

2. Set Environment Variables:
   ```powershell
   # Run as Administrator
   [System.Environment]::SetEnvironmentVariable("ANDROID_HOME", "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk", "User")
   [System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Users\$env:USERNAME\AppData\Local\Android\Sdk\cmdline-tools\latest\bin;C:\Users\$env:USERNAME\AppData\Local\Android\Sdk\platform-tools", "User")
   ```

3. Restart PowerShell and verify:
   ```powershell
   sdkmanager --version
   ```

#### Step 2: Install Required SDK Components
```powershell
# Accept licenses
flutter doctor --android-licenses

# Install system image
sdkmanager "system-images;android-33;google_apis;x86_64"

# Install platform tools
sdkmanager "platform-tools" "platforms;android-33"
```

#### Step 3: Create Emulator via Command Line
```powershell
# Create AVD
avdmanager create avd -n Pixel_5_API_33 -k "system-images;android-33;google_apis;x86_64" -d pixel_5

# List emulators
flutter emulators
```

#### Step 4: Launch and Run
```powershell
# Launch emulator
flutter emulators --launch Pixel_5_API_33

# Wait for it to boot, then run
flutter run
```

---

## Quick Start (If You Already Have Android Studio)

```powershell
# 1. Open Android Studio → Device Manager → Create Virtual Device
# 2. Launch the emulator from Device Manager
# 3. Run these commands:

cd "D:\my work place\PetrolMate\flutter_app"
flutter devices
flutter run
```

---

## Important: API Configuration for Emulator

When using an Android emulator, you need to use a special IP address:

1. Open `lib/config/api_config.dart`
2. Update line 19:
   ```dart
   static const String apiHostIp = '10.0.2.2'; // Special IP for Android emulator
   ```

**Why `10.0.2.2`?**
- Android emulator uses `10.0.2.2` to access the host machine's `localhost`
- This is different from physical devices which need your actual IP

3. Make sure backend is running on your computer:
   ```powershell
   cd "D:\my work place\PetrolMate\backend"
   npm start
   ```

---

## Troubleshooting

### ❌ "No emulators available"

**Solution:** Create one using Android Studio (easiest) or command line

### ❌ "HAXM installation failed" or "Intel HAXM is required"

**Solution:** Enable virtualization in BIOS
1. Restart computer
2. Enter BIOS (usually F2, F10, or Del during boot)
3. Find "Virtualization Technology" or "Intel VT-x"
4. Enable it
5. Save and exit

**Alternative:** Use ARM-based emulator (slower but works without HAXM)
```powershell
sdkmanager "system-images;android-33;google_apis;arm64-v8a"
avdmanager create avd -n Pixel_5_ARM -k "system-images;android-33;google_apis;arm64-v8a" -d pixel_5
```

### ❌ Emulator is very slow

**Solutions:**
1. Allocate more RAM in AVD settings (4GB recommended)
2. Enable hardware acceleration (HAXM or Hyper-V)
3. Use a lower API level (API 30 instead of 34)
4. Close other applications

### ❌ "cmdline-tools component is missing"

**Solution:** Install via Android Studio:
1. Open Android Studio
2. Go to **Settings** → **Appearance & Behavior** → **System Settings** → **Android SDK**
3. Click **SDK Tools** tab
4. Check **Android SDK Command-line Tools**
5. Click **Apply**

### ❌ Can't connect to backend

**Solution:**
1. Verify backend is running: `http://localhost:3000/health`
2. Use `10.0.2.2` in `api_config.dart` (not `localhost`)
3. Check firewall isn't blocking port 3000

---

## Recommended Emulator Specs

For best performance:

- **Device:** Pixel 5 or Pixel 7
- **API Level:** 33 (Android 13) or 34 (Android 14)
- **RAM:** 4GB
- **Storage:** 8GB
- **Graphics:** Hardware (if available)

---

## Quick Commands Reference

```powershell
# List available emulators
flutter emulators

# Launch specific emulator
flutter emulators --launch <emulator_name>

# Check connected devices
flutter devices

# Run on emulator
flutter run

# Run on specific device
flutter run -d emulator-5554

# Cold boot emulator (fresh start)
emulator -avd Pixel_5_API_33 -no-snapshot-load
```

---

## Alternative: Use Physical Device

If emulator setup is too complex, you can use a physical Android device instead!

See: [PHYSICAL_DEVICE_SETUP.md](PHYSICAL_DEVICE_SETUP.md)

**Physical device is:**
- ✅ Faster than emulator
- ✅ More accurate testing
- ✅ Easier to set up
- ✅ Better performance

---

## Step-by-Step: Fastest Method

**Using Android Studio (5 minutes):**

1. **Download & Install Android Studio**
   - https://developer.android.com/studio
   - Follow installer prompts

2. **Open Android Studio**
   - Skip creating a project
   - Click **More Actions** → **Virtual Device Manager**

3. **Create Emulator**
   - Click **Create Virtual Device**
   - Select **Pixel 5**
   - Download **API 33** (Android 13)
   - Click **Finish**

4. **Launch Emulator**
   - Click Play ▶️ button
   - Wait for boot

5. **Run Flutter App**
   ```powershell
   cd "D:\my work place\PetrolMate\flutter_app"
   flutter run
   ```

Done! 🎉

---

## Checking Your Setup

Run this to see what's missing:

```powershell
flutter doctor -v
```

Look for:
- ✅ Flutter
- ✅ Android toolchain
- ✅ Android Studio (optional but helpful)

---

## Need Help?

1. **Easiest:** Use Android Studio's Device Manager
2. **Alternative:** Use a physical device (see PHYSICAL_DEVICE_SETUP.md)
3. **Issues?** Run `flutter doctor -v` and check what's missing

---

## Ready to Run!

Once your emulator is running:

```powershell
cd "D:\my work place\PetrolMate\flutter_app"
flutter run
```

Your app will install and launch automatically! 🚀

