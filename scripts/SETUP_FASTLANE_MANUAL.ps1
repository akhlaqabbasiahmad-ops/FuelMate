# Manual Fastlane Setup for Conda Ruby Users
# Run these commands manually in conda base environment

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Fastlane Manual Setup Guide" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Since you're using conda Ruby, run these commands manually:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Step 1: Activate conda base environment" -ForegroundColor Cyan
Write-Host "  conda activate base" -ForegroundColor White
Write-Host ""
Write-Host "Step 2: Install Bundler" -ForegroundColor Cyan
Write-Host "  conda run -n base gem install bundler" -ForegroundColor White
Write-Host ""
Write-Host "Step 3: Install fastlane dependencies" -ForegroundColor Cyan
Write-Host "  cd `"D:\my work place\PetrolMate`"" -ForegroundColor White
Write-Host "  conda run -n base bundle install" -ForegroundColor White
Write-Host ""
Write-Host "Step 4: Set up Google Play API key" -ForegroundColor Cyan
Write-Host "  1. Go to: https://play.google.com/console" -ForegroundColor White
Write-Host "  2. Select app: com.asentyx.fuelmate" -ForegroundColor White
Write-Host "  3. Go to Setup > API access" -ForegroundColor White
Write-Host "  4. Create service account and download JSON key" -ForegroundColor White
Write-Host "  5. Save as: fastlane\api-key.json" -ForegroundColor White
Write-Host ""
Write-Host "After setup, you can use fastlane:" -ForegroundColor Green
Write-Host "  conda run -n base bundle exec fastlane android internal" -ForegroundColor White
Write-Host ""

