# FuelMate .NET Backend - SQL Server Setup Script
# This script helps set up SQL Server for the FuelMate backend

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SQL Server Setup for FuelMate" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if SQL Server is installed
Write-Host "Checking for SQL Server..." -ForegroundColor Yellow
$sqlServices = Get-Service -Name "MSSQL*" -ErrorAction SilentlyContinue

if ($sqlServices) {
    Write-Host "SQL Server found ✅" -ForegroundColor Green
    foreach ($service in $sqlServices) {
        Write-Host "  - $($service.DisplayName): $($service.Status)" -ForegroundColor Cyan
    }
    Write-Host ""
} else {
    Write-Host "SQL Server not found ❌" -ForegroundColor Red
    Write-Host ""
    Write-Host "To install SQL Server:" -ForegroundColor Yellow
    Write-Host "1. Download SQL Server Express (FREE):" -ForegroundColor White
    Write-Host "   https://www.microsoft.com/en-us/sql-server/sql-server-downloads" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Download SQL Server Management Studio (SSMS - optional but recommended):" -ForegroundColor White
    Write-Host "   https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. During installation:" -ForegroundColor White
    Write-Host "   - Choose 'Mixed Mode Authentication'" -ForegroundColor Gray
    Write-Host "   - Set a strong password for 'sa' user" -ForegroundColor Gray
    Write-Host "   - Enable TCP/IP protocol" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

# Prompt for connection details
Write-Host "Enter your SQL Server connection details:" -ForegroundColor Yellow
Write-Host "(Press Enter to use default values shown in brackets)" -ForegroundColor Gray
Write-Host ""

$server = Read-Host "Server [localhost]"
if ([string]::IsNullOrWhiteSpace($server)) { $server = "localhost" }

$database = Read-Host "Database Name [FuelMate]"
if ([string]::IsNullOrWhiteSpace($database)) { $database = "FuelMate" }

$userId = Read-Host "User ID [sa]"
if ([string]::IsNullOrWhiteSpace($userId)) { $userId = "sa" }

$password = Read-Host "Password (required)" -AsSecureString
$passwordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

if ([string]::IsNullOrWhiteSpace($passwordPlain)) {
    Write-Host "Password is required!" -ForegroundColor Red
    exit 1
}

# Test connection
Write-Host ""
Write-Host "Testing connection..." -ForegroundColor Yellow
$connectionString = "Server=$server;Database=master;User Id=$userId;Password=$passwordPlain;TrustServerCertificate=True;Connection Timeout=10"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $conn.Open()
    Write-Host "Connection successful ✅" -ForegroundColor Green
    
    # Create database if it doesn't exist
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = @"
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = '$database')
BEGIN
    CREATE DATABASE [$database]
    PRINT 'Database created successfully'
END
ELSE
BEGIN
    PRINT 'Database already exists'
END
"@
    $cmd.ExecuteNonQuery() | Out-Null
    Write-Host "Database '$database' is ready ✅" -ForegroundColor Green
    $conn.Close()
    
} catch {
    Write-Host "Connection failed ❌" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host "1. SQL Server service is not running" -ForegroundColor White
    Write-Host "2. TCP/IP protocol is not enabled in SQL Server Configuration Manager" -ForegroundColor White
    Write-Host "3. Incorrect username or password" -ForegroundColor White
    Write-Host "4. SQL Server is not configured for Mixed Mode authentication" -ForegroundColor White
    Write-Host ""
    exit 1
}

# Update appsettings.json
Write-Host ""
Write-Host "Updating appsettings.json..." -ForegroundColor Yellow

$appSettingsPath = Join-Path $PSScriptRoot "appsettings.json"
$newConnectionString = "Server=$server;Database=$database;User Id=$userId;Password=$passwordPlain;TrustServerCertificate=True;"

if (Test-Path $appSettingsPath) {
    $appSettings = Get-Content $appSettingsPath -Raw | ConvertFrom-Json
    $appSettings.ConnectionStrings.DefaultConnection = $newConnectionString
    $appSettings | ConvertTo-Json -Depth 10 | Set-Content $appSettingsPath
    Write-Host "appsettings.json updated ✅" -ForegroundColor Green
} else {
    Write-Host "appsettings.json not found ❌" -ForegroundColor Red
    Write-Host "Please create the file manually with the following connection string:" -ForegroundColor Yellow
    Write-Host $newConnectionString -ForegroundColor Gray
}

# Update appsettings.Development.json
$appSettingsDevPath = Join-Path $PSScriptRoot "appsettings.Development.json"
if (Test-Path $appSettingsDevPath) {
    $appSettingsDev = Get-Content $appSettingsDevPath -Raw | ConvertFrom-Json
    $appSettingsDev.ConnectionStrings.DefaultConnection = $newConnectionString
    $appSettingsDev | ConvertTo-Json -Depth 10 | Set-Content $appSettingsDevPath
    Write-Host "appsettings.Development.json updated ✅" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Setup Complete! ✅" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "You can now start the backend server with:" -ForegroundColor White
Write-Host "  .\START_BACKEND.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "Or run directly with:" -ForegroundColor White
Write-Host "  dotnet run" -ForegroundColor Cyan
Write-Host ""

