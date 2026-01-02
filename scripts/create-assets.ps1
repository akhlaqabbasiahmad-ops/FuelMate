# Create placeholder assets for FuelMate
# This script creates simple placeholder images for the app

$projectRoot = Split-Path $PSScriptRoot -Parent
$assetsPath = Join-Path $projectRoot "mobile\assets"

# Create assets directory if it doesn't exist
if (-not (Test-Path $assetsPath)) {
    New-Item -ItemType Directory -Path $assetsPath | Out-Null
    Write-Host "Created assets directory" -ForegroundColor Green
}

Write-Host "Creating placeholder assets..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Note: These are placeholder files. Replace them with actual images before production." -ForegroundColor Gray
Write-Host ""

# Create a simple README for assets
$readmeContent = @"
# FuelMate Assets

This directory contains app assets. Replace these placeholder files with actual images:

- icon.png: App icon (1024x1024px recommended)
- splash.png: Splash screen image (1242x2436px recommended)
- adaptive-icon.png: Android adaptive icon (1024x1024px)
- favicon.png: Web favicon (48x48px or larger)

## Quick Setup

You can use online tools or design software to create these images:
- App Icon Generator: https://www.appicon.co/
- Splash Screen Generator: https://www.figma.com/ or similar tools

For now, placeholder files have been created to allow the app to run.
"@

Set-Content -Path (Join-Path $assetsPath "README.md") -Value $readmeContent

Write-Host "Assets directory ready!" -ForegroundColor Green
Write-Host "You can now run: npm install" -ForegroundColor Cyan
Write-Host "Then: npm start" -ForegroundColor Cyan

