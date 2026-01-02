# Fastlane Setup Guide for Play Store Automation

This guide will help you set up fastlane to automate uploading your AAB files to Google Play Store.

## What is Fastlane?

Fastlane is a tool that automates beta deployments and releases for Android apps. It handles:
- Building your app
- Uploading to Play Store
- Managing different release tracks (Internal, Alpha, Beta, Production)
- Version management

**Documentation**: https://docs.fastlane.tools/

## Prerequisites

1. **Ruby 2.5+** installed on your system
   - Windows: Download from https://rubyinstaller.org/
   - Recommended: Ruby+Devkit version
   
2. **Google Play Console API Access**
   - Service Account with JSON key file

## Quick Setup (3 Steps)

### Step 1: Install Ruby (if not installed)

**Windows:**
1. Download RubyInstaller: https://rubyinstaller.org/
2. Install Ruby+Devkit (recommended)
3. Verify installation:
   ```powershell
   ruby --version
   ```

### Step 2: Run Setup Script

```powershell
cd "D:\my work place\PetrolMate"
.\scripts\SETUP_FASTLANE.ps1
```

This will:
- Install Bundler
- Install fastlane and dependencies
- Guide you through API key setup

### Step 3: Set Up Google Play Console API

1. Go to [Google Play Console](https://play.google.com/console)
2. Select your app: **com.asentyx.fuelmate**
3. Navigate to **Setup > API access**
4. Click **Create new service account**
5. Follow the link to Google Cloud Console
6. Create a service account:
   - Name: `fastlane-service-account`
   - Role: `Service Account User`
7. Create and download JSON key
8. Return to Play Console and grant access:
   - Click **Grant access** next to your service account
   - Grant permissions: **View app information** and **Manage production releases**
9. Save the JSON file as:
   ```
   fastlane/api-key.json
   ```

## Usage

### Basic Commands

**Build AAB only:**
```powershell
bundle exec fastlane android build
```

**Upload to Internal Testing:**
```powershell
bundle exec fastlane android internal
```

**Upload to Alpha:**
```powershell
bundle exec fastlane android alpha
```

**Upload to Beta:**
```powershell
bundle exec fastlane android beta
```

**Upload to Production:**
```powershell
bundle exec fastlane android production
```

### Upload Existing AAB File

If you already have an AAB file built:

```powershell
# Upload to Internal Testing
bundle exec fastlane android upload track:internal

# Upload to Alpha
bundle exec fastlane android upload track:alpha

# Upload to Beta
bundle exec fastlane android upload track:beta

# Upload to Production
bundle exec fastlane android upload track:production
```

### Complete Release (Recommended)

This will:
1. Bump version code
2. Build AAB
3. Upload to Play Store

```powershell
# Internal Testing
bundle exec fastlane android release track:internal

# Alpha
bundle exec fastlane android release track:alpha

# Beta
bundle exec fastlane android release track:beta

# Production
bundle exec fastlane android release track:production
```

## File Structure

```
PetrolMate/
├── Gemfile                 # Ruby dependencies
├── Gemfile.lock            # Locked versions (auto-generated)
├── fastlane/
│   ├── Appfile             # App configuration
│   ├── Fastfile             # Build and upload lanes
│   └── api-key.json         # Google Play API key (you need to add this)
└── scripts/
    └── SETUP_FASTLANE.ps1   # Setup script
```

## Available Lanes

| Lane | Description |
|------|-------------|
| `build` | Build release AAB only |
| `internal` | Build and upload to Internal Testing |
| `alpha` | Build and upload to Alpha track |
| `beta` | Build and upload to Beta track |
| `production` | Build and upload to Production |
| `upload` | Upload existing AAB file |
| `version_bump` | Increment version code |
| `release` | Complete release (bump + build + upload) |

## Environment Variables (Optional)

You can set these environment variables instead of using `api-key.json`:

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS = "fastlane\api-key.json"
```

Or set the path directly in Fastfile (not recommended for security).

## Troubleshooting

### Ruby Not Found
- Install Ruby from https://rubyinstaller.org/
- Make sure Ruby is in your PATH

### Bundle Install Fails
- Make sure you have internet connection
- Try: `gem install bundler` manually
- Then: `bundle install`

### API Key Issues
- Verify JSON file is at `fastlane/api-key.json`
- Check service account has correct permissions in Play Console
- Ensure JSON file is valid (not corrupted)

### Upload Fails
- Check your internet connection
- Verify API key has correct permissions
- Check Play Console for any app issues
- Ensure AAB file exists and is valid

## Integration with Existing Build Script

You can also use fastlane with your existing build script:

```powershell
# Build AAB using your script
.\scripts\BUILD_AAB_RELEASE.ps1

# Then upload using fastlane
bundle exec fastlane android upload track:internal
```

## Next Steps

1. Complete the setup using `SETUP_FASTLANE.ps1`
2. Set up Google Play Console API access
3. Test with Internal Testing track first
4. Once verified, use for regular releases

## References

- Fastlane Documentation: https://docs.fastlane.tools/
- Android Setup Guide: https://docs.fastlane.tools/getting-started/android/setup/
- Play Store Actions: https://docs.fastlane.tools/actions/#google-play

