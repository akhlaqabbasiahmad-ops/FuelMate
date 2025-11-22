# Fix PlatformConstants Error Script
# This script fixes the "PlatefarmConstant/PlatformConstants could not be found" error

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Fixing PlatformConstants Error" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$mobilePath = Join-Path $PSScriptRoot "mobile"
Set-Location $mobilePath

Write-Host "Step 1: Clearing Metro bundler cache..." -ForegroundColor Yellow
npx expo start --clear

Write-Host ""
Write-Host "If the error persists, try these steps manually:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Stop the Metro bundler (Ctrl+C)" -ForegroundColor Gray
Write-Host "2. Clear cache:" -ForegroundColor Gray
Write-Host "   npx expo start --clear" -ForegroundColor White
Write-Host ""
Write-Host "3. If still not working, reinstall dependencies:" -ForegroundColor Gray
Write-Host "   Remove-Item -Recurse -Force node_modules" -ForegroundColor White
Write-Host "   Remove-Item package-lock.json" -ForegroundColor White
Write-Host "   npm install --legacy-peer-deps" -ForegroundColor White
Write-Host ""
Write-Host "4. Restart Metro bundler:" -ForegroundColor Gray
Write-Host "   npx expo start --clear" -ForegroundColor White

