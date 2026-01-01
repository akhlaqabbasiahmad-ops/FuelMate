# 🔧 Fix: INSTALL_FAILED_USER_RESTRICTED

## Error
```
[INSTALL_FAILED_USER_RESTRICTED: Install canceled by user]
```

This means your Android device is blocking the app installation for security reasons.

---

## ✅ Quick Fixes (Try in Order)

### Fix 1: Enable USB Debugging (Install via USB)
On your Android device:

1. Go to **Settings** → **Developer Options**
2. Find **"Install via USB"** or **"USB debugging (Security settings)"**
3. **Enable** it
4. Try running again:
   ```powershell
   flutter run
   ```

---

### Fix 2: Enable Developer Options (If Hidden)
If you don't see Developer Options:

1. Go to **Settings** → **About Phone**
2. Find **Build Number**
3. **Tap it 7 times** (it will say "You are now a developer!")
4. Go back to **Settings** → **Developer Options**
5. Enable **USB Debugging**
6. Enable **Install via USB**

---

### Fix 3: Disable MIUI Optimization (If Xiaomi/Vivo/Oppo)
If you have a Xiaomi, Vivo, or Oppo phone:

1. Go to **Settings** → **Developer Options**
2. Find **"MIUI Optimization"** or **"Turn on MIUI Optimization"**
3. **Disable** it
4. **Restart** your phone
5. Try running again

---

### Fix 4: Grant Installation Permission Pop-up
When you run `flutter run`:

1. Look at your phone screen
2. You should see a pop-up asking **"Allow installation?"**
3. **Tap "Install"** or **"Allow"**
4. If you don't see it, try unplugging and replugging the USB cable

---

### Fix 5: Uninstall Old Version
If the app was previously installed:

```powershell
# Uninstall old version
adb uninstall com.example.fuelmate_flutter

# Then run again
flutter run
```

---

### Fix 6: Use Wireless Debugging (Alternative)
If USB installation keeps failing:

1. On device: **Settings** → **Developer Options** → **Wireless Debugging**
2. **Enable** it
3. Tap **Pair device with pairing code**
4. Note the IP address and port
5. On computer:
   ```powershell
   adb pair <IP>:<PORT>
   # Enter pairing code from device
   
   adb connect <IP>:<PORT>
   flutter run
   ```

---

## 🔍 Device Info
Your device: **23129RAA4G**

Based on the device ID, this might be a Xiaomi or similar device with extra security restrictions.

---

## 🚀 Recommended Solution

**For Xiaomi/Vivo/Oppo devices:**

1. **Settings** → **Developer Options**
2. Enable **USB Debugging**
3. Enable **Install via USB** (or **USB debugging (Security settings)**)
4. Disable **MIUI Optimization** (important!)
5. **Restart phone**
6. Run:
   ```powershell
   flutter run
   ```

---

## ⚠️ Watch Your Phone Screen!

When you run `flutter run`, a permission dialog might appear on your phone. You must **tap "Allow" or "Install"** within a few seconds, or it will fail.

---

## 📱 Alternative: Build APK and Install Manually

If all else fails, build and install manually:

```powershell
# Build APK
flutter build apk

# The APK will be at:
# build\app\outputs\flutter-apk\app-debug.apk

# Copy it to your phone and install manually
```

---

## ✅ Quick Checklist

- [ ] Developer Options enabled
- [ ] USB Debugging enabled
- [ ] Install via USB enabled
- [ ] MIUI Optimization disabled (if Xiaomi/Vivo/Oppo)
- [ ] USB cable connected properly
- [ ] Phone screen unlocked
- [ ] Watching for permission pop-up

---

**Most Common Solution:** Enable "Install via USB" in Developer Options! 🎯

Try that first, then run `flutter run` again!

