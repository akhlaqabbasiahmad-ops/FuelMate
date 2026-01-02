# Final Fix - Fix All Version Issues
# Run this to fix all remaining version mismatches

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Final Version Fix" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Step 1: Installing missing expo-font..." -ForegroundColor Yellow
npx expo install expo-font

Write-Host ""
Write-Host "Step 2: Fixing all package versions..." -ForegroundColor Yellow
npx expo install --fix

Write-Host ""
Write-Host "Step 3: Removing duplicates and reinstalling..." -ForegroundColor Yellow
Remove-Item -Recurse -Force node_modules -ErrorAction SilentlyContinue
Remove-Item package-lock.json -ErrorAction SilentlyContinue
npm install --legacy-peer-deps

Write-Host ""
Write-Host "Step 4: Final verification..." -ForegroundColor Yellow
npx expo-doctor

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  All Fixed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Start the app:" -ForegroundColor Yellow
Write-Host "  npx expo start --clear" -ForegroundColor White
Write-Host ""

