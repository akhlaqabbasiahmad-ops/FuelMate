# Manual Version Increment Commands

## Current Status
- **Version Code**: 2 (updated)
- **Version Name**: 1.0.0

## Quick Fix: Increment Version Code

### Option 1: Using Your Build Script (Recommended)

```powershell
cd "D:\my work place\PetrolMate"
.\scripts\BUILD_AAB_RELEASE.ps1
```

Then upload:
```powershell
conda activate base
conda run -n base bundle exec fastlane android upload track:internal
```

### Option 2: Manual Build and Upload

**Step 1: Build AAB**
```powershell
cd "D:\my work place\PetrolMate\flutter_app"
flutter clean
flutter pub get
flutter build appbundle --release --split-debug-info=build/app/debug-info
```

**Step 2: Upload to Play Store**
```powershell
cd "D:\my work place\PetrolMate"
conda activate base
conda run -n base bundle exec fastlane android upload track:internal
```

## For Future Releases: Increment Version

### Manual Version Increment

**1. Update pubspec.yaml:**
```yaml
version: 1.0.0+3  # Increment the number after +
```

**2. Update build.gradle.kts:**
```kotlin
versionCode = 3  # Must match the number after + in pubspec.yaml
versionName = "1.0.0"  # Or increment to "1.0.1", "1.1.0", etc.
```

**3. Rebuild and upload:**
```powershell
cd "D:\my work place\PetrolMate\flutter_app"
flutter clean
flutter build appbundle --release --split-debug-info=build/app/debug-info

cd ..
conda run -n base bundle exec fastlane android upload track:internal
```

## Using Fastlane Version Bump (Automatic)

```powershell
conda activate base
conda run -n base bundle exec fastlane android version_bump
```

This automatically increments the version code in pubspec.yaml.

## Version Code Rules

- **Version Code**: Must be unique and incrementing (1, 2, 3, 4...)
- **Version Name**: User-visible version (1.0.0, 1.0.1, 1.1.0, 2.0.0)
- **Format**: `version: 1.0.0+2` means versionName=1.0.0, versionCode=2

## Complete Release Workflow

```powershell
# 1. Activate conda
conda activate base

# 2. Increment version (optional - fastlane can do this)
conda run -n base bundle exec fastlane android version_bump

# 3. Build AAB
cd "D:\my work place\PetrolMate\flutter_app"
flutter clean
flutter build appbundle --release --split-debug-info=build/app/debug-info

# 4. Upload to Play Store
cd ..
conda run -n base bundle exec fastlane android upload track:internal
```

## One-Command Release (Recommended)

```powershell
conda activate base
conda run -n base bundle exec fastlane android release track:internal
```

This does everything: bumps version, builds, and uploads!

