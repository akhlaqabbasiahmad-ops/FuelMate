# FuelMate .NET 8 Backend Startup Script
# Run this script to start the backend server

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  FuelMate .NET 8 Backend Server" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Navigate to backend directory
$backendPath = Join-Path $PSScriptRoot "backend-dotnet"
Set-Location $backendPath

# Check if project file exists
if (-not (Test-Path "FuelMateBackend.csproj")) {
    Write-Host "Project file not found!" -ForegroundColor Red
    Write-Host "Make sure you're in the correct directory." -ForegroundColor Red
    exit 1
}

# Check if SQL Server is accessible
Write-Host "Checking SQL Server connection..." -ForegroundColor Yellow
$connectionString = "Server=localhost;Database=master;User Id=sa;Password=YourPassword123!;TrustServerCertificate=True;Connection Timeout=5"
try {
    $conn = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $conn.Open()
    $conn.Close()
    Write-Host "SQL Server is accessible ✅" -ForegroundColor Green
} catch {
    Write-Host "⚠️ WARNING: Cannot connect to SQL Server" -ForegroundColor Yellow
    Write-Host "   Make sure SQL Server is running" -ForegroundColor Yellow
    Write-Host "   Update connection string in appsettings.json if needed" -ForegroundColor Yellow
    Write-Host ""
}

# Restore dependencies
Write-Host "Restoring dependencies..." -ForegroundColor Yellow
dotnet restore
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to restore dependencies!" -ForegroundColor Red
    exit 1
}

# Build the project
Write-Host "Building project..." -ForegroundColor Yellow
dotnet build --no-restore
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "Build successful!" -ForegroundColor Green
Write-Host ""

# Start the server
Write-Host "Starting backend server..." -ForegroundColor Yellow
Write-Host "Server will run on http://localhost:3000" -ForegroundColor Green
Write-Host "API Documentation: http://localhost:3000/api/docs" -ForegroundColor Green
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Gray
Write-Host ""

dotnet run

