# Fix All Version Mismatches
# Run this after COMPLETE_FIX.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Fixing Version Mismatches" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Step 1: Installing missing peer dependency..." -ForegroundColor Yellow
npx expo install expo-font

Write-Host ""
Write-Host "Step 2: Fixing all version mismatches..." -ForegroundColor Yellow
npx expo install --fix

Write-Host ""
Write-Host "Step 3: Removing duplicate dependencies..." -ForegroundColor Yellow
Remove-Item -Recurse -Force node_modules
Remove-Item package-lock.json
npm install --legacy-peer-deps

Write-Host ""
Write-Host "Step 4: Verifying installation..." -ForegroundColor Yellow
npx expo-doctor

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Version Fix Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Now start the app with:" -ForegroundColor Yellow
Write-Host "  npx expo start --clear" -ForegroundColor White
Write-Host ""

