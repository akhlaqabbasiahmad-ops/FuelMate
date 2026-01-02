# Setup fastlane for Play Store automation
# Based on: https://docs.fastlane.tools/getting-started/android/setup/

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Fastlane Setup for FuelMate" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Ruby is installed
Write-Host "Step 1: Checking Ruby installation..." -ForegroundColor Yellow

# Try to find Ruby in common locations
$rubyPaths = @(
    "ruby",
    "conda run -n base ruby",
    "$env:CONDA_PREFIX\Scripts\ruby.exe",
    "$env:CONDA_PREFIX\Library\bin\ruby.exe",
    "C:\Ruby*\bin\ruby.exe"
)

$rubyFound = $false
$rubyVersion = $null
$rubyCommand = $null

# Check conda first since user is using conda
if (Get-Command conda -ErrorAction SilentlyContinue) {
    $result = conda run -n base ruby --version 2>&1
    if ($LASTEXITCODE -eq 0 -or ($result -and $result -notmatch "error" -and $result -notmatch "not found")) {
        $rubyVersion = $result
        $rubyCommand = "conda run -n base ruby"
        $gemCommand = "conda run -n base gem"
        $bundleCommand = "conda run -n base bundle"
        $rubyFound = $true
    }
}

# If conda Ruby not found, try direct Ruby
if (-not $rubyFound) {
    foreach ($path in $rubyPaths) {
        if ($path -eq "ruby") {
            $result = ruby --version 2>$null
            if ($LASTEXITCODE -eq 0 -or $result) {
                $rubyVersion = $result
                $rubyCommand = "ruby"
                $gemCommand = "gem"
                $bundleCommand = "bundle"
                $rubyFound = $true
                break
            }
        } elseif ($path -like "C:\Ruby*\bin\ruby.exe") {
            $foundRuby = Get-ChildItem -Path "C:\Ruby*\bin\ruby.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($foundRuby) {
                $result = & $foundRuby.FullName --version 2>$null
                if ($LASTEXITCODE -eq 0) {
                    $rubyVersion = $result
                    $rubyCommand = $foundRuby.FullName
                    $gemCommand = Join-Path (Split-Path $foundRuby.FullName) "gem.exe"
                    $bundleCommand = Join-Path (Split-Path $foundRuby.FullName) "bundle.exe"
                    $rubyFound = $true
                    break
                }
            }
        }
    }
}

if (-not $rubyFound) {
    Write-Host "❌ Ruby not found in PATH!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Since you're using conda, try running:" -ForegroundColor Yellow
    Write-Host "  conda activate base" -ForegroundColor White
    Write-Host "  ruby --version" -ForegroundColor White
    Write-Host ""
    Write-Host "Or install Ruby:" -ForegroundColor Yellow
    Write-Host "  1. Download RubyInstaller: https://rubyinstaller.org/" -ForegroundColor White
    Write-Host "  2. Install Ruby 2.7+ (recommended: Ruby+Devkit)" -ForegroundColor White
    Write-Host "  3. Make sure Ruby is in your PATH" -ForegroundColor White
    Write-Host ""
    Write-Host "Alternatively, run this script from conda environment:" -ForegroundColor Yellow
    Write-Host "  conda activate base" -ForegroundColor White
    Write-Host "  .\scripts\SETUP_FASTLANE.ps1" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host "✅ Ruby found: $rubyVersion" -ForegroundColor Green
Write-Host "   Using: $rubyCommand" -ForegroundColor Gray

# Check Ruby version
$rubyVersionNumber = ($rubyVersion | Select-String -Pattern "(\d+\.\d+)" | ForEach-Object { $_.Matches[0].Value })
if ($rubyVersionNumber) {
    $majorVersion = [int]($rubyVersionNumber.Split('.')[0])
    $minorVersion = [int]($rubyVersionNumber.Split('.')[1])

    if ($majorVersion -lt 2 -or ($majorVersion -eq 2 -and $minorVersion -lt 5)) {
        Write-Host "❌ Ruby 2.5+ required. You have: $rubyVersionNumber" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "⚠️  Could not parse Ruby version, but continuing..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Step 2: Installing Bundler..." -ForegroundColor Yellow

# Use the correct gem command (already set above)
Write-Host "   Running: $gemCommand install bundler" -ForegroundColor Gray
& $gemCommand.Split(' ') install bundler 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Bundler installed" -ForegroundColor Green
} else {
    Write-Host "⚠️  Bundler installation had issues, but continuing..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Step 3: Installing fastlane dependencies..." -ForegroundColor Yellow

# Run bundle install with the correct command
Write-Host "   Running: $bundleCommand install" -ForegroundColor Gray
& $bundleCommand.Split(' ') install

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Fastlane dependencies installed" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to install dependencies" -ForegroundColor Red
    Write-Host ""
    Write-Host "Try running manually:" -ForegroundColor Yellow
    if ($bundleCommand -like "*conda*") {
        Write-Host "  conda activate base" -ForegroundColor White
        Write-Host "  bundle install" -ForegroundColor White
    } else {
        Write-Host "  $bundleCommand install" -ForegroundColor White
    }
    exit 1
}

Write-Host ""
Write-Host "Step 4: Setting up Google Play Console API..." -ForegroundColor Yellow
Write-Host ""
Write-Host "To upload to Play Store, you need to set up Google Play Console API:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Go to Google Play Console: https://play.google.com/console" -ForegroundColor White
Write-Host "2. Select your app (com.asentyx.fuelmate)" -ForegroundColor White
Write-Host "3. Go to Setup > API access" -ForegroundColor White
Write-Host "4. Create a Service Account:" -ForegroundColor White
Write-Host "   - Click 'Create new service account'" -ForegroundColor Gray
Write-Host "   - Follow the link to Google Cloud Console" -ForegroundColor Gray
Write-Host "   - Create a service account and download JSON key" -ForegroundColor Gray
Write-Host "   - Return to Play Console and grant access" -ForegroundColor Gray
Write-Host ""
Write-Host "5. Save the JSON key file as:" -ForegroundColor White
Write-Host "   fastlane/api-key.json" -ForegroundColor Cyan
Write-Host ""

$setupApi = Read-Host "Have you already set up the API key? (y/n)"
if ($setupApi -eq "y" -or $setupApi -eq "Y") {
    $apiKeyPath = "fastlane\api-key.json"
    if (Test-Path $apiKeyPath) {
        Write-Host "✅ API key found at: $apiKeyPath" -ForegroundColor Green
    } else {
        Write-Host "⚠️  API key not found. Please place it at: $apiKeyPath" -ForegroundColor Yellow
    }
} else {
    Write-Host ""
    Write-Host "After setting up the API key, place it at: fastlane\api-key.json" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "   Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Usage Examples:" -ForegroundColor Cyan
Write-Host ""

# Determine the correct bundle command for fastlane
if ($bundleCommand -like "*conda*") {
    $fastlanePrefix = "conda run -n base bundle exec fastlane"
} else {
    $fastlanePrefix = "bundle exec fastlane"
}

Write-Host "  # Build AAB only:" -ForegroundColor White
Write-Host "  $fastlanePrefix android build" -ForegroundColor Gray
Write-Host ""
Write-Host "  # Upload to Internal Testing:" -ForegroundColor White
Write-Host "  $fastlanePrefix android internal" -ForegroundColor Gray
Write-Host ""
Write-Host "  # Upload to Alpha:" -ForegroundColor White
Write-Host "  $fastlanePrefix android alpha" -ForegroundColor Gray
Write-Host ""
Write-Host "  # Upload to Beta:" -ForegroundColor White
Write-Host "  $fastlanePrefix android beta" -ForegroundColor Gray
Write-Host ""
Write-Host "  # Upload to Production:" -ForegroundColor White
Write-Host "  $fastlanePrefix android production" -ForegroundColor Gray
Write-Host ""
Write-Host "  # Upload existing AAB:" -ForegroundColor White
Write-Host "  $fastlanePrefix android upload track:internal" -ForegroundColor Gray
Write-Host ""
Write-Host "  # Complete release (bump version + build + upload):" -ForegroundColor White
Write-Host "  $fastlanePrefix android release track:internal" -ForegroundColor Gray
Write-Host ""

if ($bundleCommand -like "*conda*") {
    Write-Host "Note: Make sure to activate conda base environment:" -ForegroundColor Yellow
    Write-Host "  conda activate base" -ForegroundColor White
    Write-Host ""
}

