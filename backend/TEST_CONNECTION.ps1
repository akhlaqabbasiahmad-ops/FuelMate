# Test Backend Connection
# This script tests if the backend is accessible

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Testing Backend Connection" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Testing localhost:3000..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/health" -TimeoutSec 5 -UseBasicParsing
    Write-Host "✅ Backend is accessible!" -ForegroundColor Green
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Backend is NOT accessible" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Make sure backend is running:" -ForegroundColor Yellow
    Write-Host "  cd backend" -ForegroundColor White
    Write-Host "  npm run start:dev" -ForegroundColor White
}

Write-Host ""
Write-Host "Testing 0.0.0.0:3000..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://0.0.0.0:3000/health" -TimeoutSec 5 -UseBasicParsing
    Write-Host "✅ Backend accessible on 0.0.0.0" -ForegroundColor Green
} catch {
    Write-Host "⚠️  0.0.0.0 test failed (this is normal)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

