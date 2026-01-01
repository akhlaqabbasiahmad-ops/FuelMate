# ====================================
# Add Password Field to Database
# Run this script to migrate the database
# ====================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  FuelMate - Database Migration" -ForegroundColor Cyan
Write-Host "  Adding Password Authentication" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if SQL Server LocalDB is available
Write-Host "📊 Checking SQL Server LocalDB..." -ForegroundColor Yellow
$sqlCmd = Get-Command sqlcmd -ErrorAction SilentlyContinue

if (-not $sqlCmd) {
    Write-Host "❌ Error: sqlcmd not found" -ForegroundColor Red
    Write-Host "   Please install SQL Server Command Line Utilities" -ForegroundColor Red
    Write-Host "   https://docs.microsoft.com/en-us/sql/tools/sqlcmd-utility" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ sqlcmd found" -ForegroundColor Green
Write-Host ""

# Run the migration script
Write-Host "🔄 Running database migration..." -ForegroundColor Yellow
Write-Host ""

$scriptPath = Join-Path $PSScriptRoot "AddPasswordField.sql"

if (-not (Test-Path $scriptPath)) {
    Write-Host "❌ Error: Migration script not found" -ForegroundColor Red
    Write-Host "   Expected: $scriptPath" -ForegroundColor Red
    exit 1
}

try {
    sqlcmd -S "(localdb)\MSSQLLocalDB" -i $scriptPath
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "  ✅ Migration completed successfully!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "📋 Next steps:" -ForegroundColor Cyan
        Write-Host "   1. Restart the backend: .\START_BACKEND.ps1" -ForegroundColor White
        Write-Host "   2. Run the Flutter app: cd ..\flutter_app && flutter run" -ForegroundColor White
        Write-Host ""
        Write-Host "⚠️  Note: Existing users will need to set a password" -ForegroundColor Yellow
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "❌ Migration failed with exit code: $LASTEXITCODE" -ForegroundColor Red
        Write-Host ""
        Write-Host "💡 Troubleshooting:" -ForegroundColor Yellow
        Write-Host "   1. Make sure LocalDB is running" -ForegroundColor White
        Write-Host "   2. Check if FuelMate database exists" -ForegroundColor White
        Write-Host "   3. Run .\SETUP_LOCALDB.ps1 first if you haven't" -ForegroundColor White
        Write-Host ""
        exit 1
    }
} catch {
    Write-Host ""
    Write-Host "❌ Error running migration: $_" -ForegroundColor Red
    Write-Host ""
    exit 1
}

