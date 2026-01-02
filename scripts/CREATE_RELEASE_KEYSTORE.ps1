# PowerShell script to create release keystore for FuelMate app

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   FuelMate - Release Keystore Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$keystorePath = "D:\my work place\PetrolMate\fuelmate-release.jks"
$keyAlias = "fuelmate"

Write-Host "This script will create a release keystore for signing your app." -ForegroundColor Yellow
Write-Host ""
Write-Host "IMPORTANT: Keep the passwords safe! You'll need them for all future updates." -ForegroundColor Red
Write-Host ""

# Check if keystore already exists
if (Test-Path $keystorePath) {
    Write-Host "WARNING: Keystore already exists at:" -ForegroundColor Red
    Write-Host "  $keystorePath" -ForegroundColor White
    Write-Host ""
    $overwrite = Read-Host "Do you want to overwrite it? (yes/no)"
    if ($overwrite -ne "yes") {
        Write-Host "Aborted. Using existing keystore." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Press Enter to continue with existing keystore setup..."
        $null = Read-Host
        exit 0
    }
    Remove-Item $keystorePath -Force
}

Write-Host "Generating release keystore..." -ForegroundColor Green
Write-Host ""
Write-Host "You will be prompted for:" -ForegroundColor Yellow
Write-Host "  1. Keystore password (remember this!)" -ForegroundColor White
Write-Host "  2. Key password (can be same as keystore password)" -ForegroundColor White
Write-Host "  3. Your name" -ForegroundColor White
Write-Host "  4. Organization name (optional, can press Enter)" -ForegroundColor White
Write-Host "  5. Other details (can press Enter to skip)" -ForegroundColor White
Write-Host ""

# Generate keystore
keytool -genkey -v -keystore $keystorePath -keyalg RSA -keysize 2048 -validity 10000 -alias $keyAlias

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "SUCCESS: Keystore created!" -ForegroundColor Green
    Write-Host "Location: $keystorePath" -ForegroundColor White
    Write-Host ""
    
    # Show fingerprint
    Write-Host "Your keystore SHA1 fingerprint:" -ForegroundColor Cyan
    keytool -list -v -keystore $keystorePath -alias $keyAlias
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "   IMPORTANT: Save These Details" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Keystore Path: $keystorePath" -ForegroundColor White
    Write-Host "Key Alias: $keyAlias" -ForegroundColor White
    Write-Host ""
    Write-Host "BACKUP THIS FILE:" -ForegroundColor Red
    Write-Host "  - Copy to external drive" -ForegroundColor White
    Write-Host "  - Upload to secure cloud storage" -ForegroundColor White
    Write-Host "  - Store passwords in password manager" -ForegroundColor White
    Write-Host ""
    Write-Host "Without this file and password, you CANNOT update your app!" -ForegroundColor Red
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "ERROR: Keystore creation failed!" -ForegroundColor Red
    Write-Host "Please ensure Java/keytool is installed and try again." -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "Press Enter to close..."
$null = Read-Host

