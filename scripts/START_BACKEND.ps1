# Start Backend Server on All Network Interfaces
# This allows mobile app to connect from emulator or physical device

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Starting FuelMate Backend Server" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$projectRoot = Split-Path $PSScriptRoot -Parent
$backendPath = Join-Path $projectRoot "backend"
Set-Location $backendPath

# Check if node_modules exists
if (-not (Test-Path "node_modules")) {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    npm install
    Write-Host ""
}

Write-Host "Starting backend server..." -ForegroundColor Yellow
Write-Host "Server will be accessible on:" -ForegroundColor Green
Write-Host "  - http://localhost:3000" -ForegroundColor White
Write-Host "  - http://0.0.0.0:3000" -ForegroundColor White
Write-Host ""
Write-Host "For mobile app connection:" -ForegroundColor Cyan
Write-Host "  - Android Emulator: http://10.0.2.2:3000" -ForegroundColor White
Write-Host "  - Physical Device: Use your local IP (run FIND_IP.ps1)" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Gray
Write-Host ""

npm run start:dev

