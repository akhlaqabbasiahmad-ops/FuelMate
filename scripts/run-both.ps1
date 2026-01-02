# FuelMate - Run Both Backend and Mobile App
# This script starts both applications in separate windows

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  FuelMate - Starting Both Apps" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

# Start backend in new window
Write-Host "Starting backend server in new window..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-File", "`"$scriptPath\run-backend.ps1`""

# Wait a bit for backend to start
Start-Sleep -Seconds 3

# Start mobile app in new window
Write-Host "Starting mobile app in new window..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-File", "`"$scriptPath\run-mobile.ps1`""

Write-Host ""
Write-Host "Both applications are starting in separate windows!" -ForegroundColor Green
Write-Host "Backend: http://localhost:3000" -ForegroundColor Gray
Write-Host "Mobile: Check the Expo window for QR code" -ForegroundColor Gray
Write-Host ""
Write-Host "Press any key to exit this window..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

