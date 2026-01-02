# Play Store Build Script
# This script builds an Android App Bundle (AAB) ready for Play Store upload

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   FuelMate - Play Store Build" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Navigate to flutter app directory
Set-Location "D:\my work place\PetrolMate\flutter_app"

Write-Host "Pre-Build Checklist:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  [X] Updated version number in pubspec.yaml" -ForegroundColor White
Write-Host "  [X] All permissions configured in AndroidManifest.xml" -ForegroundColor White
Write-Host "  [X] Firebase configuration added (google-services.json)" -ForegroundColor White
Write-Host "  [X] App icon added" -ForegroundColor White
Write-Host "  [X] ProGuard rules configured" -ForegroundColor White
Write-Host ""

$continue = Read-Host "Continue with build? (Y/n)"

if ($continue -eq "" -or $continue -eq "Y" -or $continue -eq "y") {
    Write-Host ""
    Write-Host "Step 1: Cleaning previous builds..." -ForegroundColor Cyan
    flutter clean
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Clean successful!" -ForegroundColor Green
        Write-Host ""
        
        Write-Host "Step 2: Getting dependencies..." -ForegroundColor Cyan
        flutter pub get
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Dependencies fetched!" -ForegroundColor Green
            Write-Host ""
            
            Write-Host "Step 3: Building AAB (Android App Bundle)..." -ForegroundColor Cyan
            Write-Host "This may take 5-10 minutes..." -ForegroundColor Yellow
            Write-Host ""
            
            flutter build appbundle --release
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host ""
                Write-Host "========================================" -ForegroundColor Green
                Write-Host "   BUILD SUCCESSFUL!" -ForegroundColor Green
                Write-Host "========================================" -ForegroundColor Green
                Write-Host ""
                Write-Host "AAB Location:" -ForegroundColor Cyan
                Write-Host "   build\app\outputs\bundle\release\app-release.aab" -ForegroundColor White
                Write-Host ""
                Write-Host "Build Statistics:" -ForegroundColor Cyan
                $aabFile = "build\app\outputs\bundle\release\app-release.aab"
                if (Test-Path $aabFile) {
                    $fileSize = (Get-Item $aabFile).Length / 1MB
                    Write-Host "   Size: $([math]::Round($fileSize, 2)) MB" -ForegroundColor White
                }
                Write-Host ""
                Write-Host "Next Steps:" -ForegroundColor Yellow
                Write-Host "   1. Open Google Play Console" -ForegroundColor White
                Write-Host "   2. Create new app or go to existing app" -ForegroundColor White
                Write-Host "   3. Navigate to: Production -> Create new release" -ForegroundColor White
                Write-Host "   4. Upload the AAB file above" -ForegroundColor White
                Write-Host "   5. Fill in release notes and submit" -ForegroundColor White
                Write-Host ""
                Write-Host "IMPORTANT:" -ForegroundColor Red
                Write-Host "   - Before uploading, ensure you have configured release signing" -ForegroundColor Yellow
                Write-Host "   - Currently using DEBUG keystore (not suitable for production!)" -ForegroundColor Yellow
                Write-Host "   - See PLAY_STORE_GUIDE.md for signing configuration" -ForegroundColor Yellow
                Write-Host ""
                
                # Open the folder
                Write-Host "Opening output folder..." -ForegroundColor Cyan
                explorer "build\app\outputs\bundle\release\"
            } else {
                Write-Host ""
                Write-Host "Build failed!" -ForegroundColor Red
                Write-Host ""
                Write-Host "Common issues:" -ForegroundColor Yellow
                Write-Host "  - Check for compilation errors above" -ForegroundColor White
                Write-Host "  - Ensure all dependencies are compatible" -ForegroundColor White
                Write-Host "  - Check ProGuard rules if obfuscation errors" -ForegroundColor White
                Write-Host ""
            }
        } else {
            Write-Host ""
            Write-Host "Failed to get dependencies!" -ForegroundColor Red
            Write-Host ""
        }
    } else {
        Write-Host ""
        Write-Host "Clean failed!" -ForegroundColor Red
        Write-Host ""
    }
} else {
    Write-Host ""
    Write-Host "Build cancelled by user." -ForegroundColor Red
    Write-Host ""
}

Write-Host "Press Enter to close..."
$null = Read-Host

