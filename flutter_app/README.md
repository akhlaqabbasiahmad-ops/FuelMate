# FuelMate Flutter App

A Flutter mobile application for petrol delivery service, converted from React Native Expo.

## Features

- **Role Selection**: Users can register as either "Needy" (requesting petrol) or "Provider" (delivering petrol)
- **Location Services**: Real-time location tracking for finding nearby users
- **Request Management**: Create, view, and manage petrol delivery requests
- **Quote System**: Providers can send quotes, needers can accept them
- **Chat System**: Real-time messaging between needers and providers
- **Request History**: View completed and accepted requests

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / Xcode (for running on emulators/simulators)
- A physical device or emulator for testing

## Installation

### 1. Install Flutter

Follow the official Flutter installation guide for your operating system:
- [Windows](https://docs.flutter.dev/get-started/install/windows)
- [macOS](https://docs.flutter.dev/get-started/install/macos)
- [Linux](https://docs.flutter.dev/get-started/install/linux)

Verify installation:
```bash
flutter doctor
```

### 2. Clone and Setup

```bash
cd flutter_app
flutter pub get
```

### 3. Configure API Endpoint

Edit `lib/config/api_config.dart` and update the IP address:

```dart
static const String apiHostIp = '192.168.1.6'; // Your computer's local IP
```

**To find your IP:**
- **Windows**: Run `ipconfig` in Command Prompt
- **macOS/Linux**: Run `ifconfig` or `ip addr` in Terminal

### 4. Setup Backend

Make sure your backend server is running on port 3000 or 4000 (production).

From the project root:
```bash
cd backend
npm install
npm run start
```

## Running the App

### Android

#### Using Emulator
```bash
# List available emulators
flutter emulators

# Launch an emulator
flutter emulators --launch <emulator_id>

# Run the app
flutter run
```

#### Using Physical Device
1. Enable Developer Options on your Android device
2. Enable USB Debugging
3. Connect device via USB
4. Run:
```bash
flutter devices
flutter run
```

### iOS (macOS only)

#### Using Simulator
```bash
# Open iOS Simulator
open -a Simulator

# Run the app
flutter run
```

#### Using Physical Device
1. Connect your iPhone via USB
2. Trust the computer on your device
3. Run:
```bash
flutter run
```

## Project Structure

```
flutter_app/
├── lib/
│   ├── config/           # API configuration
│   │   ├── api_config.dart
│   │   └── api_endpoints.dart
│   ├── models/           # Data models
│   │   ├── user.dart
│   │   ├── petrol_request.dart
│   │   ├── quote.dart
│   │   └── chat_message.dart
│   ├── services/         # API services
│   │   ├── api_service.dart
│   │   ├── user_service.dart
│   │   ├── request_service.dart
│   │   ├── chat_service.dart
│   │   └── storage_service.dart
│   ├── providers/        # State management
│   │   ├── user_provider.dart
│   │   └── request_provider.dart
│   ├── screens/          # UI screens
│   │   ├── role_selection_screen.dart
│   │   ├── name_input_screen.dart
│   │   ├── requests_screen.dart
│   │   └── history_screen.dart
│   └── main.dart         # App entry point
├── pubspec.yaml          # Dependencies
└── README.md
```

## Key Dependencies

- **provider**: State management
- **http** & **dio**: HTTP client for API calls
- **shared_preferences**: Local storage
- **geolocator**: Location services
- **permission_handler**: Permission management
- **go_router**: Navigation
- **intl**: Date formatting

## Permissions

### Android
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to find nearby petrol providers/needers</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>We need your location to find nearby petrol providers/needers</string>
```

## Building for Production

### Android APK
```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

### iOS (macOS only)
```bash
flutter build ios --release
```

## Troubleshooting

### Location Permission Issues
- Make sure location services are enabled on your device
- Check that the app has location permissions in device settings
- For iOS simulator, use Features > Location > Custom Location

### API Connection Issues
- Verify backend is running: `http://YOUR_IP:3000/health`
- Check firewall settings
- For Android emulator, use `10.0.2.2` instead of `localhost`
- For physical devices, ensure device and computer are on same WiFi network

### Build Issues
```bash
# Clean build
flutter clean
flutter pub get
flutter run
```

## Development Tips

1. **Hot Reload**: Press `r` in terminal while app is running
2. **Hot Restart**: Press `R` in terminal
3. **Debug Mode**: Use VS Code or Android Studio debugger
4. **Logs**: Use `print()` statements or `debugPrint()`

## Differences from React Native Version

- Uses **Provider** instead of Context API for state management
- Uses **SharedPreferences** instead of AsyncStorage
- Uses **Geolocator** instead of expo-location
- Material Design UI instead of React Native components
- Native Flutter navigation instead of React Navigation

## API Endpoints

The app connects to the following backend endpoints:
- `/api/users/*` - User management
- `/api/requests/*` - Request management
- `/api/location/*` - Location updates
- `/api/chat/*` - Chat messaging
- `/health` - Health check

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is part of the PetrolMate application.

## Support

For issues or questions, please check the backend README or create an issue in the repository.


