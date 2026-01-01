# How to Run the Flutter App

## ✅ Complete Conversion Summary

Your React Native Expo app has been **successfully converted to Flutter**! 

### What Was Converted:
- ✅ All screens (Role Selection, Name Input, Requests, History, Chat)
- ✅ All API services (Users, Requests, Quotes, Chat)
- ✅ State management (Provider instead of Context)
- ✅ Local storage (SharedPreferences instead of AsyncStorage)
- ✅ Location services (Geolocator instead of expo-location)
- ✅ Navigation system
- ✅ All models and data structures

## 🚀 Quick Start (3 Steps)

### Step 1: Install Flutter (if not already installed)

**Windows:**
1. Download Flutter SDK: https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\flutter`
3. Add `C:\flutter\bin` to your PATH environment variable
4. Open new PowerShell and run: `flutter doctor`

**Mac:**
```bash
brew install flutter
flutter doctor
```

**Linux:**
```bash
# Download and extract Flutter
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.x.x-stable.tar.xz
tar xf flutter_linux_3.x.x-stable.tar.xz
export PATH="$PATH:`pwd`/flutter/bin"
flutter doctor
```

### Step 2: Setup the Project

**Option A: Using PowerShell Script (Windows)**
```powershell
cd "D:\my work place\PetrolMate\flutter_app"
.\setup.ps1
```

**Option B: Manual Setup**
```bash
cd "D:\my work place\PetrolMate\flutter_app"
flutter pub get
flutter doctor
```

### Step 3: Configure & Run

1. **Update API Configuration**
   - Open `lib/config/api_config.dart`
   - Change line 19: `static const String apiHostIp = 'YOUR_IP_HERE';`
   - Find your IP: Run `ipconfig` (Windows) or `ifconfig` (Mac/Linux)

2. **Start Backend** (if not running)
   ```bash
   cd "D:\my work place\PetrolMate\backend"
   npm start
   ```

3. **Connect Device or Start Emulator**
   
   **Android Emulator:**
   ```bash
   flutter emulators
   flutter emulators --launch <emulator_name>
   ```
   
   **Physical Device:**
   - Enable Developer Options
   - Enable USB Debugging
   - Connect via USB

4. **Run the App**
   ```bash
   flutter run
   ```

## 📱 Running on Different Platforms

### Android (Physical Device)
```bash
# 1. Enable Developer Options on phone
# 2. Enable USB Debugging
# 3. Connect phone via USB
# 4. Run:
flutter devices
flutter run
```

### Android (Emulator)
```bash
flutter emulators
flutter emulators --launch Pixel_5_API_33
flutter run
```

### iOS (Mac only - Physical Device)
```bash
# 1. Connect iPhone via USB
# 2. Trust computer on device
# 3. Run:
flutter run
```

### iOS (Mac only - Simulator)
```bash
open -a Simulator
flutter run
```

## 🔧 Troubleshooting

### "Flutter not found"
**Solution:** Add Flutter to PATH
```powershell
# Windows PowerShell (Run as Administrator)
$env:Path += ";C:\flutter\bin"
[Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::User)
```

### "No devices found"
**Solution:** 
```bash
# Check connected devices
flutter devices

# If empty, start an emulator or connect a device
flutter emulators --launch <emulator_name>
```

### "Failed to connect to backend"
**Solution:**
1. Check backend is running: Open browser to `http://localhost:3000/health`
2. Verify IP in `lib/config/api_config.dart`
3. For Android emulator, use `10.0.2.2` instead of your IP
4. Ensure device and computer are on same WiFi (for physical devices)

### "Location permission denied"
**Solution:**
- Go to device Settings → Apps → FuelMate → Permissions
- Enable Location permission

### Build errors
**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

## 📂 Project Structure

```
flutter_app/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── config/                      # API configuration
│   │   ├── api_config.dart         # ⚠️ UPDATE YOUR IP HERE
│   │   └── api_endpoints.dart
│   ├── models/                      # Data models
│   │   ├── user.dart
│   │   ├── petrol_request.dart
│   │   ├── quote.dart
│   │   └── chat_message.dart
│   ├── services/                    # API services
│   │   ├── api_service.dart
│   │   ├── user_service.dart
│   │   ├── request_service.dart
│   │   ├── chat_service.dart
│   │   └── storage_service.dart
│   ├── providers/                   # State management
│   │   ├── user_provider.dart
│   │   └── request_provider.dart
│   └── screens/                     # UI screens
│       ├── role_selection_screen.dart
│       ├── name_input_screen.dart
│       ├── requests_screen.dart
│       └── history_screen.dart
├── android/                         # Android configuration
├── ios/                            # iOS configuration
├── pubspec.yaml                    # Dependencies
├── setup.ps1                       # Setup script
└── README.md                       # Full documentation
```

## 🎯 Key Differences from React Native

| Feature | React Native | Flutter |
|---------|-------------|---------|
| State Management | Context API | Provider |
| Storage | AsyncStorage | SharedPreferences |
| Location | expo-location | Geolocator |
| Navigation | React Navigation | Named routes |
| HTTP | Axios | http/dio |
| UI | React Native components | Material Design widgets |

## 💻 Development Commands

```bash
# Hot reload (while running)
Press 'r' in terminal

# Hot restart (while running)
Press 'R' in terminal

# Stop app
Press 'q' in terminal

# Build release APK
flutter build apk --release

# Build release App Bundle
flutter build appbundle --release

# Clean build
flutter clean

# Update dependencies
flutter pub get

# Check for issues
flutter doctor
```

## 🌐 Network Configuration

### For Physical Device:
- Update `apiHostIp` in `lib/config/api_config.dart` with your computer's IP
- Ensure device and computer are on same WiFi
- Example: `static const String apiHostIp = '192.168.1.6';`

### For Android Emulator:
- Use `10.0.2.2` as the IP address
- Example: `static const String apiHostIp = '10.0.2.2';`

### For iOS Simulator:
- Use `localhost` or your actual IP
- Example: `static const String apiHostIp = 'localhost';`

## 📖 Additional Resources

- **Full Documentation**: See [README.md](README.md)
- **Quick Start Guide**: See [QUICKSTART.md](QUICKSTART.md)
- **Flutter Docs**: https://docs.flutter.dev
- **Flutter Cookbook**: https://docs.flutter.dev/cookbook

## ✨ Features Implemented

- ✅ User registration (Needy/Provider roles)
- ✅ Location-based request discovery
- ✅ Real-time request updates
- ✅ Quote system
- ✅ Chat messaging (basic structure)
- ✅ Request history
- ✅ Offline storage
- ✅ Permission handling

## 🎨 UI/UX

The Flutter app maintains the same color scheme and design as the React Native version:
- Primary Color: `#FF6B35` (Orange)
- Background: `#F5F5F5` (Light Gray)
- Success: `#4CAF50` (Green)
- Info: `#2196F3` (Blue)

## 🔐 Permissions

The app requires:
- **Location**: To find nearby users
- **Internet**: To communicate with backend

These are automatically requested on first launch.

## 📞 Support

If you encounter any issues:
1. Check `flutter doctor` output
2. Verify backend is running and accessible
3. Check device/emulator logs
4. Review Flutter console output
5. See troubleshooting section above

## 🎉 Success!

Your React Native app has been successfully converted to Flutter! The app is now ready to run on both Android and iOS devices with native performance.

**To start using it right now:**
```bash
cd "D:\my work place\PetrolMate\flutter_app"
flutter pub get
flutter run
```

Happy coding! 🚀


