# Running Flutter App WITHOUT Android Studio

You don't need Android Studio! Here are multiple ways to run your Flutter app.

## 🌐 Option 1: Run on Web (Easiest & Fastest!)

**Perfect for quick testing and development.**

### Step 1: Make sure backend is running
```powershell
cd "D:\my work place\PetrolMate\backend"
npm start
```

### Step 2: Run on Chrome
```powershell
cd "D:\my work place\PetrolMate\flutter_app"
flutter run -d chrome
```

**That's it!** The app will open in Chrome browser automatically! 🎉

### Features on Web:
- ✅ Hot reload (press 'r')
- ✅ Fast development
- ✅ No device needed
- ✅ Works with localhost
- ⚠️ Location services limited (can simulate)

---

## 📱 Option 2: Physical Android Device (No Android Studio Needed!)

**Best for real testing.**

### Quick Setup:
1. **Enable Developer Mode** on phone:
   - Settings → About Phone → Tap "Build Number" 7 times

2. **Enable USB Debugging**:
   - Settings → Developer Options → USB Debugging ON

3. **Connect phone via USB**

4. **Update API config** for physical device:
   - Open `lib/config/api_config.dart`
   - Find your IP: Run `ipconfig` in Command Prompt
   - Change line 42 to:
   ```dart
   return 'http://YOUR_IP:$apiPort'; // e.g., 'http://192.168.1.6:3000'
   ```

5. **Run:**
   ```powershell
   flutter devices
   flutter run
   ```

**No Android Studio required!** Just USB cable and Flutter SDK.

---

## 🖥️ Option 3: Command Line Emulator (Advanced)

If you really want an emulator without Android Studio:

### Prerequisites:
You need Android SDK command-line tools. Check if you have them:
```powershell
sdkmanager --version
```

If not found, download from: https://developer.android.com/studio#command-line-tools

### Create Emulator via Command Line:

```powershell
# 1. Accept licenses
flutter doctor --android-licenses

# 2. Install system image
sdkmanager "system-images;android-33;google_apis;x86_64"

# 3. Create emulator
avdmanager create avd -n MyEmulator -k "system-images;android-33;google_apis;x86_64" -d pixel_5

# 4. Launch emulator
emulator -avd MyEmulator

# 5. In another terminal, run app
flutter run
```

**Note:** This is more complex. Web or physical device is easier!

---

## 🎯 Recommended Approach

**For Development:** Use **Web** (Chrome)
- Fastest
- No setup
- Hot reload
- Perfect for UI development

**For Testing:** Use **Physical Device**
- Real device testing
- Better performance
- Accurate sensors
- Just needs USB cable

**Avoid:** Command-line emulator (complex setup)

---

## Quick Start Commands

### Web (Recommended for Quick Testing):
```powershell
# Make sure backend is running first!
cd "D:\my work place\PetrolMate\flutter_app"
flutter run -d chrome
```

### Physical Device:
```powershell
# 1. Connect phone via USB
# 2. Enable USB debugging on phone
# 3. Update api_config.dart with your IP
# 4. Run:
flutter devices
flutter run
```

---

## API Configuration for Each Platform

Edit `lib/config/api_config.dart` line 42:

**For Web:**
```dart
return 'http://localhost:$apiPort';
```

**For Android Emulator:**
```dart
return 'http://10.0.2.2:$apiPort';
```

**For Physical Device:**
```dart
return 'http://192.168.1.6:$apiPort'; // Your computer's IP
```

---

## Troubleshooting

### Web: "Failed to fetch"
**Solution:**
1. Check backend is running: `http://localhost:3000/health`
2. Verify `api_config.dart` uses `localhost`
3. Check CORS is enabled in backend

### Physical Device: "No devices found"
**Solution:**
1. Check USB cable is connected
2. Enable USB debugging on phone
3. Accept "Allow USB debugging" popup on phone
4. Run: `flutter devices`

### "Android SDK not found"
**Solution:**
You need Android SDK for Android development. Either:
- Install Android Studio (easiest)
- Download command-line tools manually
- Or just use **Web** for development!

---

## What You Need

### For Web Development:
- ✅ Flutter SDK
- ✅ Chrome browser
- ✅ Backend running
- ❌ No Android Studio needed!
- ❌ No emulator needed!
- ❌ No physical device needed!

### For Physical Device:
- ✅ Flutter SDK
- ✅ USB cable
- ✅ Android phone
- ✅ Backend running
- ❌ No Android Studio needed!
- ❌ No emulator needed!

---

## Current Status

✅ **You can run on web RIGHT NOW!**

Just execute:
```powershell
cd "D:\my work place\PetrolMate\flutter_app"
flutter run -d chrome
```

The app is already configured and ready to run in Chrome!

---

## Performance Comparison

| Platform | Speed | Setup | Best For |
|----------|-------|-------|----------|
| **Web** | ⚡⚡⚡ Fast | ✅ None | Quick development |
| **Physical Device** | ⚡⚡⚡ Fast | ⚡ 5 min | Real testing |
| **Emulator (CLI)** | ⚡ Slow | ⚡⚡⚡ 30 min | When no device |
| **Android Studio** | ⚡⚡ Medium | ⚡⚡ 15 min | Full IDE features |

---

## My Recommendation

1. **Start with Web** for development:
   ```powershell
   flutter run -d chrome
   ```

2. **Test on Physical Device** when ready:
   - Connect phone via USB
   - Update IP in `api_config.dart`
   - Run `flutter run`

3. **Skip Android Studio** unless you need:
   - Visual emulator manager
   - Android-specific debugging
   - Full IDE features

---

## Ready to Run!

**Quickest way (30 seconds):**

```powershell
# Terminal 1: Start backend
cd "D:\my work place\PetrolMate\backend"
npm start

# Terminal 2: Run Flutter on web
cd "D:\my work place\PetrolMate\flutter_app"
flutter run -d chrome
```

**Done!** Your app is now running in Chrome! 🚀

---

## Hot Reload

While app is running:
- Press **`r`** - Hot reload (instant updates)
- Press **`R`** - Hot restart
- Press **`q`** - Quit

Make changes to your code and press `r` to see them instantly!

---

## Need More Help?

- **Web issues:** Check backend is running on port 3000
- **Device issues:** See [PHYSICAL_DEVICE_SETUP.md](PHYSICAL_DEVICE_SETUP.md)
- **Emulator issues:** See [EMULATOR_SETUP.md](EMULATOR_SETUP.md)

**Bottom line:** You don't need Android Studio! Use web or physical device. 🎉

