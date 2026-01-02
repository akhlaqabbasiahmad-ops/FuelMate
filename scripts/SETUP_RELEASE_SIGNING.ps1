# PowerShell script to configure release signing for FuelMate app

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   FuelMate - Configure Release Signing" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$keystorePath = "D:\my work place\PetrolMate\fuelmate-release.jks"
$keyPropertiesPath = "D:\my work place\PetrolMate\flutter_app\android\key.properties"

# Check if keystore exists
if (-not (Test-Path $keystorePath)) {
    Write-Host "ERROR: Keystore not found!" -ForegroundColor Red
    Write-Host "Expected location: $keystorePath" -ForegroundColor White
    Write-Host ""
    Write-Host "Please run CREATE_RELEASE_KEYSTORE.ps1 first to create the keystore." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press Enter to exit..."
    $null = Read-Host
    exit 1
}

Write-Host "Keystore found: $keystorePath" -ForegroundColor Green
Write-Host ""

# Get credentials
Write-Host "Please enter your keystore credentials:" -ForegroundColor Yellow
Write-Host ""

$storePassword = Read-Host "Keystore password" -AsSecureString
$storePasswordPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($storePassword))

$keyPassword = Read-Host "Key password (press Enter if same as keystore password)" -AsSecureString
$keyPasswordPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($keyPassword))

if ([string]::IsNullOrWhiteSpace($keyPasswordPlain)) {
    $keyPasswordPlain = $storePasswordPlain
}

$keyAlias = Read-Host "Key alias (default: fuelmate)"
if ([string]::IsNullOrWhiteSpace($keyAlias)) {
    $keyAlias = "fuelmate"
}

# Create key.properties file
Write-Host ""
Write-Host "Creating key.properties file..." -ForegroundColor Green

$keyPropertiesContent = @"
storePassword=$storePasswordPlain
keyPassword=$keyPasswordPlain
keyAlias=$keyAlias
storeFile=../../fuelmate-release.jks
"@

$keyPropertiesContent | Out-File -FilePath $keyPropertiesPath -Encoding UTF8 -Force

Write-Host "Created: $keyPropertiesPath" -ForegroundColor Green
Write-Host ""

# Update .gitignore to exclude key.properties
$gitignorePath = "D:\my work place\PetrolMate\flutter_app\android\.gitignore"
$gitignoreContent = Get-Content $gitignorePath -ErrorAction SilentlyContinue

if ($gitignoreContent -notcontains "key.properties") {
    Write-Host "Adding key.properties to .gitignore..." -ForegroundColor Green
    Add-Content -Path $gitignorePath -Value "`nkey.properties"
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Configuration Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. The build.gradle.kts has been configured" -ForegroundColor White
Write-Host "  2. Run: .\scripts\BUILD_AAB_RELEASE.ps1" -ForegroundColor White
Write-Host "  3. Upload the new AAB to Play Store" -ForegroundColor White
Write-Host ""
Write-Host "IMPORTANT: Backup your keystore file!" -ForegroundColor Red
Write-Host "  Location: $keystorePath" -ForegroundColor White
Write-Host ""

Write-Host "Press Enter to close..."
$null = Read-Host

