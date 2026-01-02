# FuelMate Mobile App Startup Script
# Run this script to start the mobile app

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  FuelMate Mobile App" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Navigate to mobile directory
$projectRoot = Split-Path $PSScriptRoot -Parent
$mobilePath = Join-Path $projectRoot "mobile"
Set-Location $mobilePath

# Check if node_modules exists
if (-not (Test-Path "node_modules")) {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to install dependencies!" -ForegroundColor Red
        exit 1
    }
    Write-Host "Dependencies installed successfully!" -ForegroundColor Green
    Write-Host ""
}

# Check API configuration
Write-Host "IMPORTANT: Make sure API URL is configured correctly!" -ForegroundColor Yellow
Write-Host "Edit mobile/src/services/api.ts if needed:" -ForegroundColor Gray
Write-Host "  - Android Emulator: http://10.0.2.2:3000" -ForegroundColor Gray
Write-Host "  - iOS Simulator: http://localhost:3000" -ForegroundColor Gray
Write-Host "  - Physical Device: http://YOUR_LOCAL_IP:3000" -ForegroundColor Gray
Write-Host ""

# Start Expo
Write-Host "Starting Expo development server..." -ForegroundColor Yellow
Write-Host "Press 'a' for Android, 'i' for iOS, 'w' for web" -ForegroundColor Green
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Gray
Write-Host ""

npm start

