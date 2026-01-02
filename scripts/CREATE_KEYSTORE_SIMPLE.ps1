# Simple automated keystore creation for FuelMate

Write-Host ""
Write-Host "Creating FuelMate Release Keystore..." -ForegroundColor Cyan
Write-Host ""

$keystorePath = "D:\my work place\PetrolMate\fuelmate-release.jks"

# Check if already exists
if (Test-Path $keystorePath) {
    Write-Host "Keystore already exists at: $keystorePath" -ForegroundColor Yellow
    $overwrite = Read-Host "Overwrite? (yes/no)"
    if ($overwrite -ne "yes") {
        Write-Host "Using existing keystore." -ForegroundColor Green
        exit 0
    }
    Remove-Item $keystorePath -Force
}

Write-Host "Enter a secure password for your keystore:" -ForegroundColor Yellow
Write-Host "(You'll need this for all future app updates!)" -ForegroundColor Red
$password = Read-Host "Password" -AsSecureString
$passwordPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

Write-Host ""
Write-Host "Creating keystore with automated settings..." -ForegroundColor Green

# Create keystore with all details pre-filled (non-interactive)
$process = Start-Process -FilePath "keytool" -ArgumentList @(
    "-genkeypair",
    "-v",
    "-keystore", $keystorePath,
    "-alias", "fuelmate",
    "-keyalg", "RSA",
    "-keysize", "2048",
    "-validity", "10000",
    "-storepass", $passwordPlain,
    "-keypass", $passwordPlain,
    "-dname", "CN=FuelMate App, OU=Asentyx, O=Asentyx, L=Lahore, ST=Punjab, C=PK"
) -NoNewWindow -Wait -PassThru

if ($process.ExitCode -eq 0) {
    Write-Host ""
    Write-Host "SUCCESS! Keystore created!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Location: $keystorePath" -ForegroundColor White
    Write-Host "Alias: fuelmate" -ForegroundColor White
    Write-Host ""
    
    # Show SHA1 fingerprint
    Write-Host "Your SHA1 fingerprint:" -ForegroundColor Cyan
    keytool -list -v -keystore $keystorePath -storepass $passwordPlain -alias fuelmate | Select-String "SHA1:"
    
    Write-Host ""
    Write-Host "IMPORTANT: Backup this file immediately!" -ForegroundColor Red
    Write-Host "  - Copy to external drive" -ForegroundColor Yellow
    Write-Host "  - Upload to cloud storage" -ForegroundColor Yellow
    Write-Host "  - Save password in password manager" -ForegroundColor Yellow
    Write-Host ""
    
    # Now create key.properties automatically
    Write-Host "Creating key.properties file..." -ForegroundColor Green
    
    $keyPropertiesPath = "D:\my work place\PetrolMate\flutter_app\android\key.properties"
    $keyPropertiesContent = @"
storePassword=$passwordPlain
keyPassword=$passwordPlain
keyAlias=fuelmate
storeFile=../../fuelmate-release.jks
"@
    
    $keyPropertiesContent | Out-File -FilePath $keyPropertiesPath -Encoding UTF8 -Force
    Write-Host "Created: $keyPropertiesPath" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "Setup complete! Now run:" -ForegroundColor Cyan
    Write-Host "  .\scripts\BUILD_AAB_RELEASE.ps1" -ForegroundColor White
    Write-Host ""
    
} else {
    Write-Host ""
    Write-Host "ERROR: Failed to create keystore!" -ForegroundColor Red
    Write-Host "Make sure Java/keytool is installed." -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "Press Enter to close..."
$null = Read-Host

