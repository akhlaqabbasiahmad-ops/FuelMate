# Quick keystore creator - usage: .\QUICK_KEYSTORE.ps1 YourPassword123

param(
    [Parameter(Mandatory=$true)]
    [string]$Password
)

Write-Host ""
Write-Host "Creating FuelMate Release Keystore..." -ForegroundColor Cyan
Write-Host ""

$keystorePath = "D:\my work place\PetrolMate\fuelmate-release.jks"

# Check if already exists
if (Test-Path $keystorePath) {
    Write-Host "WARNING: Keystore already exists!" -ForegroundColor Yellow
    Write-Host "Delete it first if you want to recreate it." -ForegroundColor Yellow
    exit 1
}

Write-Host "Creating keystore with password: $('*' * $Password.Length)" -ForegroundColor Green
Write-Host ""

# Create keystore (non-interactive)
$arguments = @(
    "-genkeypair"
    "-v"
    "-keystore", "`"$keystorePath`""
    "-alias", "fuelmate"
    "-keyalg", "RSA"
    "-keysize", "2048"
    "-validity", "10000"
    "-storepass", $Password
    "-keypass", $Password
    "-dname", "`"CN=FuelMate App, OU=Asentyx, O=Asentyx, L=Lahore, ST=Punjab, C=PK`""
)

$process = Start-Process -FilePath "keytool" -ArgumentList $arguments -NoNewWindow -Wait -PassThru

if ($process.ExitCode -eq 0 -and (Test-Path $keystorePath)) {
    Write-Host ""
    Write-Host "SUCCESS! Keystore created!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Location: $keystorePath" -ForegroundColor White
    Write-Host "Alias: fuelmate" -ForegroundColor White
    Write-Host "Password: $Password" -ForegroundColor White
    Write-Host ""
    
    # Show SHA1 fingerprint
    Write-Host "Your SHA1 fingerprint:" -ForegroundColor Cyan
    $fingerprintOutput = keytool -list -v -keystore $keystorePath -storepass $Password -alias fuelmate 2>&1
    $fingerprintOutput | Select-String "SHA1:" | ForEach-Object { Write-Host $_.Line -ForegroundColor Yellow }
    
    Write-Host ""
    Write-Host "Creating key.properties file..." -ForegroundColor Green
    
    $keyPropertiesPath = "D:\my work place\PetrolMate\flutter_app\android\key.properties"
    $keyPropertiesContent = @"
storePassword=$Password
keyPassword=$Password
keyAlias=fuelmate
storeFile=../../fuelmate-release.jks
"@
    
    $keyPropertiesContent | Out-File -FilePath $keyPropertiesPath -Encoding UTF8 -Force
    Write-Host "Created: $keyPropertiesPath" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "   SETUP COMPLETE!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "IMPORTANT: Save this information!" -ForegroundColor Red
    Write-Host "  Keystore: $keystorePath" -ForegroundColor White
    Write-Host "  Alias: fuelmate" -ForegroundColor White
    Write-Host "  Password: $Password" -ForegroundColor White
    Write-Host ""
    Write-Host "Backup the keystore file to:" -ForegroundColor Yellow
    Write-Host "  - External drive" -ForegroundColor White
    Write-Host "  - Cloud storage" -ForegroundColor White
    Write-Host "  - Password manager" -ForegroundColor White
    Write-Host ""
    Write-Host "Now run: .\scripts\BUILD_AAB_RELEASE.ps1" -ForegroundColor Cyan
    Write-Host ""
    
} else {
    Write-Host ""
    Write-Host "ERROR: Failed to create keystore!" -ForegroundColor Red
    Write-Host "Exit code: $($process.ExitCode)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Make sure:" -ForegroundColor Yellow
    Write-Host "  1. Java JDK is installed" -ForegroundColor White
    Write-Host "  2. keytool is in your PATH" -ForegroundColor White
    Write-Host ""
    Write-Host "Check if keytool is available:" -ForegroundColor Yellow
    Write-Host "  keytool -version" -ForegroundColor White
    Write-Host ""
}

