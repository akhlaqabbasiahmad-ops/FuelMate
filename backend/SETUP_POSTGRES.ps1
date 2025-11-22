# PostgreSQL Setup Script for FuelMate Backend
# This script helps you create the .env file with PostgreSQL credentials

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PostgreSQL Setup for FuelMate" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if .env file already exists
if (Test-Path ".env") {
    Write-Host "⚠️  .env file already exists!" -ForegroundColor Yellow
    $overwrite = Read-Host "Do you want to overwrite it? (y/n)"
    if ($overwrite -ne "y") {
        Write-Host "Setup cancelled." -ForegroundColor Yellow
        exit
    }
}

Write-Host "Please provide your PostgreSQL connection details:" -ForegroundColor Green
Write-Host ""

$dbHost = Read-Host "Database Host [default: localhost]"
if ([string]::IsNullOrWhiteSpace($dbHost)) { $dbHost = "localhost" }

$dbPort = Read-Host "Database Port [default: 5432]"
if ([string]::IsNullOrWhiteSpace($dbPort)) { $dbPort = "5432" }

$dbUsername = Read-Host "Database Username [default: postgres]"
if ([string]::IsNullOrWhiteSpace($dbUsername)) { $dbUsername = "postgres" }

$dbPassword = Read-Host "Database Password" -AsSecureString
$dbPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($dbPassword))

if ([string]::IsNullOrWhiteSpace($dbPasswordPlain)) {
    Write-Host "⚠️  Password cannot be empty!" -ForegroundColor Red
    exit
}

$dbName = Read-Host "Database Name [default: fuelmate]"
if ([string]::IsNullOrWhiteSpace($dbName)) { $dbName = "fuelmate" }

# Create .env file
$envContent = @"
# PostgreSQL Database Configuration
DB_HOST=$dbHost
DB_PORT=$dbPort
DB_USERNAME=$dbUsername
DB_PASSWORD=$dbPasswordPlain
DB_NAME=$dbName

# Environment
NODE_ENV=development
PORT=3000
"@

$envContent | Out-File -FilePath ".env" -Encoding utf8 -NoNewline

Write-Host ""
Write-Host "✅ .env file created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Make sure PostgreSQL is running" -ForegroundColor White
Write-Host "2. Create the database if it doesn't exist:" -ForegroundColor White
Write-Host "   CREATE DATABASE $dbName;" -ForegroundColor Gray
Write-Host "3. Restart the backend server: npm run start:dev" -ForegroundColor White
Write-Host ""

