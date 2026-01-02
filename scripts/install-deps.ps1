# FuelMate Mobile - Dependency Installation Script
# This script handles dependency installation with proper conflict resolution

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  FuelMate Mobile - Installing Dependencies" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Navigate to mobile directory
$projectRoot = Split-Path $PSScriptRoot -Parent
$mobilePath = Join-Path $projectRoot "mobile"
Set-Location $mobilePath

# Clean previous installations
Write-Host "Cleaning previous installations..." -ForegroundColor Yellow
if (Test-Path "node_modules") {
    Remove-Item -Recurse -Force node_modules
    Write-Host "Removed node_modules" -ForegroundColor Gray
}
if (Test-Path "package-lock.json") {
    Remove-Item -Force package-lock.json
    Write-Host "Removed package-lock.json" -ForegroundColor Gray
}

# Clear npm cache
Write-Host "Clearing npm cache..." -ForegroundColor Yellow
npm cache clean --force

Write-Host ""
Write-Host "Installing dependencies with legacy peer deps..." -ForegroundColor Yellow
Write-Host "This resolves React Navigation version conflicts" -ForegroundColor Gray
Write-Host ""

# Install with legacy peer deps to resolve conflicts
npm install --legacy-peer-deps

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Dependencies installed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Run: npm start" -ForegroundColor Gray
    Write-Host "2. Press 'a' for Android, 'i' for iOS, 'w' for web" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "Installation failed. Trying alternative method..." -ForegroundColor Yellow
    Write-Host "Installing with --force flag..." -ForegroundColor Gray
    npm install --force
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Dependencies installed with --force!" -ForegroundColor Green
    } else {
        Write-Host "Installation failed. Please check the error messages above." -ForegroundColor Red
        exit 1
    }
}

