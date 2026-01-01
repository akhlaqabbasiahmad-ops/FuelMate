# Test SQL Server Connection

Write-Host "Testing SQL Server Connection..." -ForegroundColor Cyan
Write-Host ""

$appSettingsPath = Join-Path $PSScriptRoot "appsettings.json"

if (-not (Test-Path $appSettingsPath)) {
    Write-Host "appsettings.json not found!" -ForegroundColor Red
    exit 1
}

$appSettings = Get-Content $appSettingsPath -Raw | ConvertFrom-Json
$connectionString = $appSettings.ConnectionStrings.DefaultConnection

Write-Host "Connection String: $connectionString" -ForegroundColor Gray
Write-Host ""

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $conn.Open()
    
    Write-Host "✅ Connection successful!" -ForegroundColor Green
    Write-Host "   Server: $($conn.DataSource)" -ForegroundColor Cyan
    Write-Host "   Database: $($conn.Database)" -ForegroundColor Cyan
    Write-Host "   Server Version: $($conn.ServerVersion)" -ForegroundColor Cyan
    
    $conn.Close()
} catch {
    Write-Host "❌ Connection failed!" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Make sure SQL Server is running" -ForegroundColor White
    Write-Host "2. Check if the connection string is correct" -ForegroundColor White
    Write-Host "3. Run SETUP_SQLSERVER.ps1 to configure the database" -ForegroundColor White
}

