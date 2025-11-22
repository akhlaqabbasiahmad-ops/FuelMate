# Find Your Local IP Address
# This script helps you find your computer's IP address for mobile app connection

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Finding Your Local IP Address" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get network adapters with IPv4 addresses
$adapters = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
    $_.IPAddress -notlike "127.*" -and 
    $_.IPAddress -notlike "169.254.*" -and
    $_.PrefixOrigin -eq "Dhcp" -or $_.PrefixOrigin -eq "Manual"
} | Select-Object IPAddress, InterfaceAlias

if ($adapters) {
    Write-Host "Your Local IP Addresses:" -ForegroundColor Green
    Write-Host ""
    foreach ($adapter in $adapters) {
        Write-Host "  IP: $($adapter.IPAddress)" -ForegroundColor Yellow
        Write-Host "  Adapter: $($adapter.InterfaceAlias)" -ForegroundColor Gray
        Write-Host ""
    }
    Write-Host "Use this IP in your mobile app:" -ForegroundColor Cyan
    Write-Host "  http://$($adapters[0].IPAddress):3000" -ForegroundColor White
    Write-Host ""
    Write-Host "Update mobile/src/services/api.ts with this IP for physical device testing" -ForegroundColor Gray
} else {
    Write-Host "Could not find local IP address." -ForegroundColor Red
    Write-Host "Run this command manually:" -ForegroundColor Yellow
    Write-Host "  ipconfig" -ForegroundColor White
    Write-Host ""
    Write-Host "Look for 'IPv4 Address' under your active network adapter" -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

