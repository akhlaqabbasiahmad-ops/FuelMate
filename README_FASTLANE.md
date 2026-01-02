# 🚀 Fastlane Setup - Quick Start Guide

Automate your Play Store uploads with fastlane! This guide will get you set up in minutes.

## 📋 Simple 3-Step Setup

### Step 1: Install Ruby (Windows)

1. Download **Ruby+Devkit** from: https://rubyinstaller.org/downloads/
2. Install it (check "Add Ruby to PATH" during installation)
3. Verify installation:
   ```powershell
   ruby --version
   ```
   Should show Ruby 2.7+ or 3.x

### Step 2: Run Setup Script

```powershell
cd "D:\my work place\PetrolMate"
.\scripts\SETUP_FASTLANE.ps1
```

This installs fastlane and all dependencies automatically.

### Step 3: Get Google Play API Key

1. Go to [Google Play Console](https://play.google.com/console)
2. Select your app: **com.asentyx.fuelmate**
3. Go to **Setup > API access**
4. Click **Create new service account**
5. In Google Cloud Console:
   - Create service account
   - Download JSON key file
6. Back in Play Console:
   - Grant access to the service account
   - Give it **Manage production releases** permission
7. Save the JSON file as: `fastlane/api-key.json`

## ✅ You're Ready!

### Upload to Play Store (One Command)

**Internal Testing:**
```powershell
bundle exec fastlane android internal
```

**Alpha:**
```powershell
bundle exec fastlane android alpha
```

**Beta:**
```powershell
bundle exec fastlane android beta
```

**Production:**
```powershell
bundle exec fastlane android production
```

### Upload Existing AAB File

If you already built an AAB with `BUILD_AAB_RELEASE.ps1`:

```powershell
bundle exec fastlane android upload track:internal
```

### Complete Release (Recommended)

Automatically bumps version, builds, and uploads:

```powershell
bundle exec fastlane android release track:internal
```

## 📚 More Information

See detailed guide: `docs/ai-generated/FASTLANE_SETUP.md`

## 🔗 References

- Fastlane Docs: https://docs.fastlane.tools/
- Android Setup: https://docs.fastlane.tools/getting-started/android/setup/

