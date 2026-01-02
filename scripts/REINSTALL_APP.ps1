# Quick Reinstall Script for Map Feature Update

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   PetrolMate - Reinstall App" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This will reinstall the app with the map feature fixes:" -ForegroundColor Yellow
Write-Host "  ✅ Needy can see distance to provider (when accepted)" -ForegroundColor Green
Write-Host "  ✅ Create Request button text is now visible" -ForegroundColor Green
Write-Host "  ✅ Android manifest updated for maps compatibility" -ForegroundColor Green
Write-Host ""

# Navigate to flutter app directory
Set-Location "D:\my work place\PetrolMate\flutter_app"

Write-Host "📱 Step 1: Building APK..." -ForegroundColor Cyan
flutter build apk --debug

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build successful!" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "📲 Step 2: Installing on device..." -ForegroundColor Cyan
    flutter install
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "   ✅ Installation Complete!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "🧪 Test the new features:" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "As Needy:" -ForegroundColor Cyan
        Write-Host "  1. Create request" -ForegroundColor White
        Write-Host "  2. Wait for provider to accept" -ForegroundColor White
        Write-Host "  3. See distance to provider + map button" -ForegroundColor White
        Write-Host ""
        Write-Host "As Provider:" -ForegroundColor Cyan
        Write-Host "  1. View nearby requests" -ForegroundColor White
        Write-Host "  2. See distance to each needy" -ForegroundColor White
        Write-Host "  3. Click 'Open Map' to navigate" -ForegroundColor White
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "❌ Installation failed!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Try manually:" -ForegroundColor Yellow
        Write-Host "  1. Uninstall FuelMate from your device" -ForegroundColor White
        Write-Host "  2. Run: flutter run" -ForegroundColor White
        Write-Host ""
    }
} else {
    Write-Host ""
    Write-Host "❌ Build failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Try running: flutter clean" -ForegroundColor Yellow
    Write-Host "Then run this script again" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

