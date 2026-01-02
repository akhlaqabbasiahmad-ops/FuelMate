# Verify Backend Connection from Network
# This script tests if the backend is accessible from the network IP

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Verifying Backend Network Connection" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get network IP addresses
$adapters = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
    $_.IPAddress -notlike "127.*" -and 
    $_.IPAddress -notlike "169.254.*"
} | Select-Object IPAddress, InterfaceAlias

if (-not $adapters) {
    Write-Host "❌ No network IP addresses found!" -ForegroundColor Red
    Write-Host ""
    exit 1
}

$testIP = $adapters[0].IPAddress
Write-Host "Testing backend connection on: $testIP" -ForegroundColor Yellow
Write-Host ""

# Test localhost first
Write-Host "1. Testing localhost:3000..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/health" -TimeoutSec 5 -UseBasicParsing
    Write-Host "   ✅ Backend is running on localhost" -ForegroundColor Green
    Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Gray
} catch {
    Write-Host "   ❌ Backend is NOT running on localhost" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "   Start the backend first:" -ForegroundColor Yellow
    Write-Host "     cd backend" -ForegroundColor White
    Write-Host "     npm run start:dev" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host ""

# Test network IP
Write-Host "2. Testing network IP: $testIP:3000..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://${testIP}:3000/health" -TimeoutSec 5 -UseBasicParsing
    Write-Host "   ✅ Backend is accessible from network!" -ForegroundColor Green
    Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   Mobile app should use: http://${testIP}:3000" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Backend is NOT accessible from network" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "   Possible issues:" -ForegroundColor Yellow
    Write-Host "   1. Windows Firewall is blocking port 3000" -ForegroundColor White
    Write-Host "   2. Backend is not listening on 0.0.0.0" -ForegroundColor White
    Write-Host ""
    Write-Host "   Solutions:" -ForegroundColor Yellow
    Write-Host "   - Check backend/src/main.ts has: app.listen(port, '0.0.0.0')" -ForegroundColor White
    Write-Host "   - Allow port 3000 in Windows Firewall" -ForegroundColor White
    Write-Host "   - Run PowerShell as Administrator and allow:" -ForegroundColor White
    Write-Host "     New-NetFirewallRule -DisplayName 'FuelMate Backend' -Direction Inbound -LocalPort 3000 -Protocol TCP -Action Allow" -ForegroundColor Gray
    Write-Host ""
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

