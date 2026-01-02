# ========================================
# Deploy Firebase Cloud Functions
# ========================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  DEPLOYING CLOUD FUNCTIONS" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

# Navigate to project root
$projectRoot = "D:\my work place\PetrolMate"
Set-Location $projectRoot

# Check if Firebase CLI is installed
Write-Host "Checking Firebase CLI..." -ForegroundColor Yellow
$firebaseVersion = firebase --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Firebase CLI not found!" -ForegroundColor Red
    Write-Host "   Install it with: npm install -g firebase-tools" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ Firebase CLI version: $firebaseVersion" -ForegroundColor Green

# Check if user is logged in
Write-Host "`nChecking Firebase login..." -ForegroundColor Yellow
$loginStatus = firebase login:list 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Not logged in to Firebase!" -ForegroundColor Red
    Write-Host "   Run: firebase login" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ Logged in to Firebase" -ForegroundColor Green

# Deploy functions
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  DEPLOYING FUNCTIONS..." -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Cyan

firebase deploy --only functions

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  ✅ DEPLOYMENT SUCCESSFUL!" -ForegroundColor Green
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    Write-Host "Your Cloud Functions are now live! 🎉" -ForegroundColor Green
    Write-Host "`nDeployed Functions:" -ForegroundColor Yellow
    Write-Host "  • onNewMessage - Sends notifications for new chat messages" -ForegroundColor White
    Write-Host "  • onNewQuote - Sends notifications for new quotes" -ForegroundColor White
    Write-Host "  • onNewRequest - Sends notifications for new petrol requests" -ForegroundColor White
    Write-Host "  • onQuoteAccepted - Sends notifications when a quote is accepted" -ForegroundColor White
    Write-Host "  • onRequestCompleted - Sends notifications when a request is completed" -ForegroundColor White
    Write-Host "  • testNotification - Test function for debugging" -ForegroundColor White
    
    Write-Host "`nNext Steps:" -ForegroundColor Yellow
    Write-Host "  1. Test the app with notifications when closed" -ForegroundColor Cyan
    Write-Host "  2. Check Firebase Console for function logs" -ForegroundColor Cyan
    Write-Host "  3. Monitor function usage and costs" -ForegroundColor Cyan
    
    Write-Host "`nView Logs:" -ForegroundColor Yellow
    Write-Host "  firebase functions:log" -ForegroundColor Gray
    
    Write-Host "`n========================================`n" -ForegroundColor Cyan
} else {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  ❌ DEPLOYMENT FAILED!" -ForegroundColor Red
    Write-Host "========================================`n" -ForegroundColor Cyan
    Write-Host "Check the error messages above for details." -ForegroundColor Yellow
    exit 1
}

