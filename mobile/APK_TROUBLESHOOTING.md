# APK Crash Troubleshooting Guide

## Issue: App crashes after installation

The APK has been rebuilt with the JavaScript bundle properly embedded. If it still crashes, here are common causes and solutions:

## Common Causes

### 1. **API Connection Failure**
The app tries to connect to the backend API on startup. If the backend is not running or unreachable, it may crash.

**Solution:**
- Make sure the backend server is running on port 3000
- Check that your device and computer are on the same network
- Update `mobile/src/config/api.config.ts` with your computer's IP address
- For testing without backend, temporarily disable API calls

### 2. **Network Security Configuration**
Android may block HTTP connections (non-HTTPS) by default.

**Solution:**
- Add network security config (already included in AndroidManifest.xml)
- Or use HTTPS in production

### 3. **Missing Permissions**
The app requires location permissions.

**Solution:**
- Grant location permissions when prompted
- Check Android Settings > Apps > FuelMate > Permissions

## Debugging Steps

### 1. Check Logcat Logs
```bash
# Connect device via USB
adb logcat | grep -i "fuelmate\|react\|error"
```

### 2. Test with ADB
```bash
# Install APK
adb install -r "android/app/build/outputs/apk/debug/app-debug.apk"

# View logs
adb logcat
```

### 3. Check if Bundle is Included
The bundle should be at:
```
android/app/build/generated/assets/createBundleDebugJsAndAssets/index.android.bundle
```

## Quick Fix: Disable API Check Temporarily

If you want to test the app without backend:

1. Edit `mobile/src/services/user-validation.ts`
2. Make `isUserRegistered()` always return `true` temporarily
3. Rebuild APK

## Rebuild APK

After making changes:
```bash
cd mobile/android
./gradlew.bat clean
./gradlew.bat assembleDebug
```

The new APK will be at:
```
mobile/android/app/build/outputs/apk/debug/app-debug.apk
```

