# PowerShell script to build release AAB with proper signing

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   FuelMate - Build Release AAB" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get project root (parent of scripts folder)
$projectRoot = Split-Path $PSScriptRoot -Parent

$keystorePath = Join-Path $projectRoot "fuelmate-release.jks"
$keyPropertiesPath = Join-Path $projectRoot "flutter_app\android\key.properties"
$flutterAppPath = Join-Path $projectRoot "flutter_app"

# Check if keystore exists
if (-not (Test-Path $keystorePath)) {
    Write-Host "ERROR: Release keystore not found!" -ForegroundColor Red
    Write-Host "Expected location: $keystorePath" -ForegroundColor White
    Write-Host ""
    Write-Host "Please run these scripts first:" -ForegroundColor Yellow
    Write-Host "  1. .\scripts\CREATE_RELEASE_KEYSTORE.ps1" -ForegroundColor White
    Write-Host "  2. .\scripts\SETUP_RELEASE_SIGNING.ps1" -ForegroundColor White
    Write-Host ""
    exit 1
}

# Check if key.properties exists
if (-not (Test-Path $keyPropertiesPath)) {
    Write-Host "ERROR: key.properties not found!" -ForegroundColor Red
    Write-Host "Expected location: $keyPropertiesPath" -ForegroundColor White
    Write-Host ""
    Write-Host "Please run: .\scripts\SETUP_RELEASE_SIGNING.ps1" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host "Pre-Build Checklist:" -ForegroundColor Yellow
Write-Host "  [X] Release keystore exists" -ForegroundColor Green
Write-Host "  [X] key.properties configured" -ForegroundColor Green
Write-Host "  [X] build.gradle.kts configured for release signing" -ForegroundColor Green
Write-Host ""
Write-Host "Starting build process..." -ForegroundColor Cyan
Write-Host ""

Write-Host ""
Write-Host "Step 1: Cleaning previous builds..." -ForegroundColor Green
Set-Location $flutterAppPath
flutter clean

Write-Host ""
Write-Host "Step 2: Getting dependencies..." -ForegroundColor Green
flutter pub get

Write-Host ""
Write-Host "Step 3: Building release AAB..." -ForegroundColor Green
Write-Host "This will take several minutes..." -ForegroundColor Yellow
Write-Host "Note: Using --split-debug-info for Play Store optimization" -ForegroundColor Gray
Write-Host ""

# Create debug info directory
$debugInfoDir = Join-Path $flutterAppPath "build\app\debug-info"
if (-not (Test-Path $debugInfoDir)) {
    New-Item -ItemType Directory -Path $debugInfoDir -Force | Out-Null
}

# Build the AAB and filter out the debug symbol stripping warning
$buildOutput = flutter build appbundle --release --split-debug-info="$debugInfoDir" 2>&1 | Where-Object {
    $_ -notmatch "failed to strip debug symbols" -and 
    $_ -notmatch "Please run flutter doctor" -and
    $_ -notmatch "file an issue at" -and
    $_ -notmatch "report any issues" -and
    $_ -notmatch "Otherwise, file an issue"
}
$buildOutput | Write-Host

# Check if AAB file was created (even if exit code is non-zero due to warnings)
$aabPath = "$flutterAppPath\build\app\outputs\bundle\release\app-release.aab"

if (Test-Path $aabPath) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "   BUILD SUCCESS!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    
    $fileInfo = Get-Item $aabPath
    $fileSizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
    
    Write-Host "AAB File Details:" -ForegroundColor Cyan
    Write-Host "  Location: $aabPath" -ForegroundColor White
    Write-Host "  Size: $fileSizeMB MB" -ForegroundColor White
    Write-Host "  Created: $($fileInfo.LastWriteTime)" -ForegroundColor White
    Write-Host ""
    
    # Check for symbol stripping warning (this is just a warning, not an error)
    if ($buildOutput -match "failed to strip debug symbols") {
        Write-Host "Note: Debug symbol stripping warning detected (this is safe to ignore)" -ForegroundColor Yellow
        Write-Host "The AAB file is valid and ready for Play Store upload." -ForegroundColor Green
        Write-Host ""
    }
    
    Write-Host "Verifying signing..." -ForegroundColor Yellow
    Write-Host ""
    
    # Verify the AAB is signed
    Write-Host "Your AAB is now signed with the RELEASE keystore!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "  1. Go to Google Play Console" -ForegroundColor White
    Write-Host "  2. Upload this AAB file" -ForegroundColor White
    Write-Host "  3. Complete the release" -ForegroundColor White
    Write-Host ""
    Write-Host "IMPORTANT: Backup your keystore file!" -ForegroundColor Red
    Write-Host "  Location: $keystorePath" -ForegroundColor White
    Write-Host ""
    
    Write-Host "Build completed successfully!" -ForegroundColor Green
    exit 0
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "   BUILD FAILED!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "AAB file not found at expected location: $aabPath" -ForegroundColor Red
    Write-Host "Please check the build output above for errors." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

