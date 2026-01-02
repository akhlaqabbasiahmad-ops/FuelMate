# FuelMate Flutter App Setup Script
# Run this script to set up and run the Flutter app

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FuelMate Flutter App Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter is installed
Write-Host "Checking Flutter installation..." -ForegroundColor Yellow
$flutterInstalled = Get-Command flutter -ErrorAction SilentlyContinue

if (-not $flutterInstalled) {
    Write-Host "❌ Flutter is not installed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Flutter first:" -ForegroundColor Yellow
    Write-Host "1. Download from: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor White
    Write-Host "2. Extract to C:\flutter" -ForegroundColor White
    Write-Host "3. Add C:\flutter\bin to PATH" -ForegroundColor White
    Write-Host "4. Restart PowerShell and run this script again" -ForegroundColor White
    exit 1
}

Write-Host "✅ Flutter is installed" -ForegroundColor Green
flutter --version
Write-Host ""

# Run flutter doctor
Write-Host "Running Flutter doctor..." -ForegroundColor Yellow
flutter doctor
Write-Host ""

# Install dependencies
Write-Host "Installing Flutter dependencies..." -ForegroundColor Yellow
flutter pub get

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Dependencies installed successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to install dependencies" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Check for connected devices
Write-Host "Checking for connected devices..." -ForegroundColor Yellow
flutter devices
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Make sure backend is running (port 3000 or 4000)" -ForegroundColor White
Write-Host "2. Update API IP in lib/config/api_config.dart" -ForegroundColor White
Write-Host "3. Connect a device or start an emulator" -ForegroundColor White
Write-Host "4. Run: flutter run" -ForegroundColor White
Write-Host ""
Write-Host "To run the app now, type: flutter run" -ForegroundColor Cyan


