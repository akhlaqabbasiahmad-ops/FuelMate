# Flutter App Quick Start Guide

## Prerequisites Check

Before running the app, make sure you have:

1. **Flutter SDK installed**
   ```bash
   flutter --version
   ```
   Should show Flutter 3.0.0 or higher

2. **Backend server running**
   - The backend should be running on port 3000 or 4000
   - Test: Open browser to `http://localhost:3000/health`

## Quick Setup (5 minutes)

### Step 1: Install Dependencies
```bash
cd flutter_app
flutter pub get
```

### Step 2: Configure API (Important!)
Edit `lib/config/api_config.dart`:
```dart
static const String apiHostIp = 'YOUR_IP_HERE'; // e.g., '192.168.1.6'
```

**Find your IP:**
- Windows: `ipconfig` → Look for IPv4 Address
- Mac/Linux: `ifconfig` → Look for inet address

### Step 3: Check Flutter Setup
```bash
flutter doctor
```
Fix any issues shown (especially Android/iOS setup)

### Step 4: Connect Device or Start Emulator

#### Option A: Physical Device (Recommended)
**Android:**
1. Enable Developer Options on phone
2. Enable USB Debugging
3. Connect via USB
4. Accept USB debugging prompt on phone

**iOS (Mac only):**
1. Connect iPhone via USB
2. Trust computer on device

#### Option B: Emulator/Simulator
**Android:**
```bash
flutter emulators
flutter emulators --launch <emulator_name>
```

**iOS (Mac only):**
```bash
open -a Simulator
```

### Step 5: Run the App
```bash
flutter run
```

That's it! The app should launch on your device.

## Common Issues & Solutions

### ❌ "No devices found"
**Solution:**
```bash
flutter devices
```
If empty, check USB connection or start emulator

### ❌ "Failed to connect to backend"
**Solution:**
- Check backend is running: `http://YOUR_IP:3000/health`
- Verify IP address in `api_config.dart`
- For Android emulator, use `10.0.2.2` instead of `localhost`
- Ensure phone and computer are on same WiFi

### ❌ "Location permission denied"
**Solution:**
- Go to device Settings → Apps → FuelMate → Permissions
- Enable Location permission

### ❌ Build errors
**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

## Development Commands

```bash
# Hot reload (while app is running)
Press 'r' in terminal

# Hot restart (while app is running)
Press 'R' in terminal

# Stop app
Press 'q' in terminal

# Run with verbose logging
flutter run -v

# Build release APK
flutter build apk --release
```

## Testing the App

1. **Select Role**: Choose "I Need Petrol" or "I Provide Petrol"
2. **Enter Name**: Type your name (e.g., "John")
3. **Grant Location**: Allow location permission when prompted
4. **View Requests**: You should see nearby users/requests

## Network Configuration

### For Physical Device Testing:
- Device and computer must be on **same WiFi network**
- Update `apiHostIp` with your computer's local IP
- Disable VPN if connection fails

### For Emulator Testing:
- Android Emulator: Use `10.0.2.2` as IP
- iOS Simulator: Use `localhost` or actual IP

## Next Steps

- Read full [README.md](README.md) for detailed documentation
- Check backend logs for API calls
- Use Flutter DevTools for debugging

## Support

If you encounter issues:
1. Check `flutter doctor` output
2. Verify backend is accessible
3. Check device/emulator logs
4. Review Flutter console output

Happy coding! 🚀


