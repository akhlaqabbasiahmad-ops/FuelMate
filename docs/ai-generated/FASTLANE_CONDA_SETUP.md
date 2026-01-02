# Fastlane Setup with Conda Ruby

Since you're using Ruby installed via conda, here's the manual setup process:

## Quick Setup Steps

### 1. Activate Conda Base Environment

```powershell
conda activate base
```

### 2. Install Bundler

```powershell
conda run -n base gem install bundler
```

### 3. Install Fastlane Dependencies

```powershell
cd "D:\my work place\PetrolMate"
conda run -n base bundle install
```

### 4. Set Up Google Play Console API

1. Go to [Google Play Console](https://play.google.com/console)
2. Select your app: **com.asentyx.fuelmate**
3. Navigate to **Setup > API access**
4. Click **Create new service account**
5. In Google Cloud Console:
   - Create a service account
   - Download JSON key file
6. Back in Play Console:
   - Grant access to the service account
   - Give **Manage production releases** permission
7. Save the JSON file as: `fastlane/api-key.json`

## Usage

After setup, always use conda prefix for fastlane commands:

### Upload to Play Store

**Internal Testing:**
```powershell
conda activate base
conda run -n base bundle exec fastlane android internal
```

**Alpha:**
```powershell
conda run -n base bundle exec fastlane android alpha
```

**Beta:**
```powershell
conda run -n base bundle exec fastlane android beta
```

**Production:**
```powershell
conda run -n base bundle exec fastlane android production
```

### Upload Existing AAB

```powershell
conda run -n base bundle exec fastlane android upload track:internal
```

### Complete Release

```powershell
conda run -n base bundle exec fastlane android release track:internal
```

## Alternative: Add Ruby to PATH

If you want to use `bundle` directly without `conda run -n base` prefix:

1. Find Ruby location:
   ```powershell
   conda run -n base where.exe ruby
   ```

2. Add to PATH (temporarily for current session):
   ```powershell
   $env:PATH += ";C:\path\to\ruby\bin"
   ```

3. Or add permanently in System Environment Variables

Then you can use:
```powershell
bundle exec fastlane android internal
```

## Troubleshooting

### "bundle: command not found"
- Make sure you're using `conda run -n base bundle`
- Or activate conda base: `conda activate base`

### "Ruby not found"
- Verify: `conda run -n base ruby --version`
- Should show Ruby 4.0.0

### API Key Issues
- Ensure JSON file is at `fastlane/api-key.json`
- Check service account has correct permissions
- Verify JSON file is valid

## Quick Reference

```powershell
# Always prefix with conda run -n base
conda run -n base bundle exec fastlane android [lane]

# Available lanes:
# - build          (build AAB only)
# - internal       (build + upload to internal)
# - alpha          (build + upload to alpha)
# - beta           (build + upload to beta)
# - production     (build + upload to production)
# - upload         (upload existing AAB)
# - release        (bump version + build + upload)
```

