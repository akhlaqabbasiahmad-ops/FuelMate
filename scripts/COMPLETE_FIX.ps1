# Complete Fix for PlatformConstants Error
# Run this script from the mobile directory

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Complete PlatformConstants Fix" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Step 1: Stopping any running processes..." -ForegroundColor Yellow
Write-Host "Please stop Metro bundler if running (Ctrl+C)" -ForegroundColor Gray
Start-Sleep -Seconds 2

Write-Host ""
Write-Host "Step 2: Removing old installations..." -ForegroundColor Yellow
if (Test-Path "node_modules") {
    Remove-Item -Recurse -Force node_modules
    Write-Host "Removed node_modules" -ForegroundColor Green
}
if (Test-Path "package-lock.json") {
    Remove-Item -Force package-lock.json
    Write-Host "Removed package-lock.json" -ForegroundColor Green
}
if (Test-Path ".expo") {
    Remove-Item -Recurse -Force .expo
    Write-Host "Removed .expo cache" -ForegroundColor Green
}

Write-Host ""
Write-Host "Step 3: Clearing npm cache..." -ForegroundColor Yellow
npm cache clean --force
Write-Host "Cache cleared" -ForegroundColor Green

Write-Host ""
Write-Host "Step 4: Installing correct versions using Expo..." -ForegroundColor Yellow
Write-Host "This will ensure all packages are compatible with Expo SDK 54" -ForegroundColor Gray
Write-Host ""

# Use expo install to get correct versions
npx expo install --fix

Write-Host ""
Write-Host "Step 5: Installing dependencies..." -ForegroundColor Yellow
npm install --legacy-peer-deps

Write-Host ""
Write-Host "Step 6: Verifying installation..." -ForegroundColor Yellow
npx expo-doctor

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Fix Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Now start the app with:" -ForegroundColor Yellow
Write-Host "  npx expo start --clear" -ForegroundColor White
Write-Host ""
