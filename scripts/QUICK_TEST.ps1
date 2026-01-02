# Quick Test Script - Run Everything at Once
# Usage: .\QUICK_TEST.ps1

Write-Host ""
Write-Host "🚀 PETROLMATE QUICK TEST STARTUP" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Check if backend is already running
$backendRunning = Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -like "*FuelMate*" }

if (-not $backendRunning) {
    Write-Host "📦 Starting Backend..." -ForegroundColor Yellow
    
    # Start backend in new window
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd 'D:\my work place\PetrolMate'; Write-Host '🔧 Starting .NET Backend...' -ForegroundColor Green; .\scripts\START_BACKEND.ps1"
    
    Write-Host "⏳ Waiting for backend to start..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
} else {
    Write-Host "✅ Backend already running" -ForegroundColor Green
}

Write-Host ""
Write-Host "📱 Starting Flutter App..." -ForegroundColor Yellow
Write-Host ""

# Navigate to flutter app directory
cd "D:\my work place\PetrolMate\flutter_app"

# Run flutter app
Write-Host "🎯 Running: flutter run" -ForegroundColor Cyan
flutter run

Write-Host ""
Write-Host "✅ Test session complete!" -ForegroundColor Green

