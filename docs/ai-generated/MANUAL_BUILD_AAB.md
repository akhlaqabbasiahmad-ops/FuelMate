# Manual AAB Build Commands

## Build Release AAB with Version Code 2

### Step-by-Step Commands

**1. Navigate to Flutter app directory:**
```powershell
cd "D:\my work place\PetrolMate\flutter_app"
```

**2. Clean previous builds:**
```powershell
flutter clean
```

**3. Get dependencies:**
```powershell
flutter pub get
```

**4. Build release AAB:**
```powershell
flutter build appbundle --release --split-debug-info=build/app/debug-info
```

### Complete Command Sequence (Copy & Paste)

```powershell
cd "D:\my work place\PetrolMate\flutter_app"
flutter clean
flutter pub get
flutter build appbundle --release --split-debug-info=build/app/debug-info
```

### Output Location

After build completes, your AAB file will be at:
```
D:\my work place\PetrolMate\flutter_app\build\app\outputs\bundle\release\app-release.aab
```

### Verify Build

Check if AAB was created:
```powershell
Test-Path "build\app\outputs\bundle\release\app-release.aab"
```

Get file size:
```powershell
Get-Item "build\app\outputs\bundle\release\app-release.aab" | Select-Object Name, Length, LastWriteTime
```

### Current Version Info

- **Version Code**: 2 (updated in build.gradle.kts)
- **Version Name**: 1.0.0 (from pubspec.yaml)
- **Package Name**: com.asentyx.fuelmate

### Troubleshooting

**If build fails:**
1. Make sure Flutter is in PATH: `flutter --version`
2. Check Android SDK is configured: `flutter doctor`
3. Verify keystore exists: `Test-Path "..\fuelmate-release.jks"`

**If version code error persists:**
- Make sure `build.gradle.kts` has `versionCode = 2`
- Make sure `pubspec.yaml` has `version: 1.0.0+2`
- Run `flutter clean` before rebuilding

