# ====================================
# FuelMate - Deploy Authentication
# Run this to set up authentication
# ====================================

Write-Host ""
Write-Host "╔════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                ║" -ForegroundColor Cyan
Write-Host "║      FuelMate Authentication Deployment       ║" -ForegroundColor Cyan
Write-Host "║                                                ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Step 1: Database Migration
Write-Host "📊 Step 1: Running Database Migration..." -ForegroundColor Yellow
Write-Host ""

Push-Location backend-dotnet

try {
    & .\MIGRATE_ADD_PASSWORD.ps1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "❌ Migration failed!" -ForegroundColor Red
        Write-Host "   Please run backend-dotnet\SETUP_LOCALDB.ps1 first" -ForegroundColor Yellow
        Pop-Location
        exit 1
    }
} catch {
    Write-Host ""
    Write-Host "❌ Error running migration: $_" -ForegroundColor Red
    Pop-Location
    exit 1
}

Pop-Location

Write-Host ""
Write-Host "✅ Migration completed successfully!" -ForegroundColor Green
Write-Host ""

# Step 2: Start Backend
Write-Host "🚀 Step 2: Starting Backend Server..." -ForegroundColor Yellow
Write-Host ""

Push-Location backend-dotnet

Write-Host "   Starting on http://192.168.1.8:3000" -ForegroundColor Cyan
Write-Host "   Press Ctrl+C to stop the backend" -ForegroundColor Yellow
Write-Host ""

try {
    & dotnet watch run
} catch {
    Write-Host ""
    Write-Host "❌ Backend failed to start: $_" -ForegroundColor Red
    Pop-Location
    exit 1
}

Pop-Location

