# Firebase Index Creation Script
# This script opens browser tabs to create required Firestore indexes

Write-Host ""
Write-Host "Firebase Index Creation Helper" -ForegroundColor Cyan
Write-Host ""

Write-Host "This script will open the Firebase Console to create required indexes." -ForegroundColor Yellow
Write-Host ""

Write-Host "Required Indexes:" -ForegroundColor Green
Write-Host "  1. Provider Requests (status + createdAt)"
Write-Host "  2. Needy Requests (userId + createdAt)"
Write-Host "  3. History Query - Needy (status + userId + createdAt)"
Write-Host "  4. History Query - Provider (status + acceptedBy + createdAt - MANUAL)"
Write-Host "  5. Quotes Query (requestId + createdAt)"
Write-Host ""

Write-Host "Indexes typically take 5-10 minutes to build." -ForegroundColor Yellow
Write-Host "You will receive an email when they are ready."
Write-Host ""

$continue = Read-Host "Open index creation pages in browser? (Y/n)"

if ($continue -eq "" -or $continue -eq "Y" -or $continue -eq "y") {
    Write-Host ""
    Write-Host "Opening browser tabs..." -ForegroundColor Cyan
    Write-Host ""
    
    # Index 1: Provider Requests
    Write-Host "Opening Index 1: Provider Requests..." -ForegroundColor Green
    Start-Process "https://console.firebase.google.com/v1/r/project/fuelmate-73aaf/firestore/indexes?create_composite=ClVwcm9qZWN0cy9mdWVsbWF0ZS03M2FhZi9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvcGV0cm9sUmVxdWVzdHMvaW5kZXhlcy9fEAEaCgoGc3RhdHVzEAEaDQoJY3JlYXRlZEF0EAIaDAoIX19uYW1lX18QAg"
    Start-Sleep -Seconds 2
    
    # Index 2: Needy Requests
    Write-Host "Opening Index 2: Needy Requests..." -ForegroundColor Green
    Start-Process "https://console.firebase.google.com/v1/r/project/fuelmate-73aaf/firestore/indexes?create_composite=ClVwcm9qZWN0cy9mdWVsbWF0ZS03M2FhZi9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvcGV0cm9sUmVxdWVzdHMvaW5kZXhlcy9fEAEaCgoGdXNlcklkEAEaDQoJY3JlYXRlZEF0EAIaDAoIX19uYW1lX18QAg"
    Start-Sleep -Seconds 2
    
    # Index 3: History (Needy)
    Write-Host "Opening Index 3: History Query - Needy..." -ForegroundColor Green
    Start-Process "https://console.firebase.google.com/v1/r/project/fuelmate-73aaf/firestore/indexes?create_composite=ClVwcm9qZWN0cy9mdWVsbWF0ZS03M2FhZi9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvcGV0cm9sUmVxdWVzdHMvaW5kZXhlcy9fEAEaCgoGc3RhdHVzEAEaCgoGdXNlcklkEAEaDQoJY3JlYXRlZEF0EAIaDAoIX19uYW1lX18QAg"
    Start-Sleep -Seconds 2
    
    # Index 4: History (Provider) - Manual
    Write-Host "Opening Firestore Indexes page for manual creation..." -ForegroundColor Green
    Start-Process "https://console.firebase.google.com/project/fuelmate-73aaf/firestore/indexes"
    Start-Sleep -Seconds 2
    
    # Index 5: Quotes Query
    Write-Host "Opening Index 5: Quotes Query..." -ForegroundColor Green
    Start-Process "https://console.firebase.google.com/v1/r/project/fuelmate-73aaf/firestore/indexes?create_composite=Ck1wcm9qZWN0cy9mdWVsbWF0ZS03M2FhZi9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvcXVvdGVzL2luZGV4ZXMvXxABGg0KCXJlcXVlc3RJZBABGg0KCWNyZWF0ZWRBdBACGgwKCF9fbmFtZV9fEAI"
    
    Write-Host ""
    Write-Host "SUCCESS: Browser tabs opened!" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "  1. Click 'Create Index' button on each page"
    Write-Host "  2. For Index 4 (Provider History), create manually with:"
    Write-Host "     - Collection: petrolRequests"
    Write-Host "     - Fields: status (Asc), acceptedBy (Asc), createdAt (Desc)"
    Write-Host "  3. Wait for email notifications - takes 5 to 10 minutes"
    Write-Host "  4. Restart your Flutter app"
    Write-Host ""
    
    Write-Host "TIP: Keep this window open and run the app after indexes are ready!" -ForegroundColor Yellow
    Write-Host ""
    
}
else {
    Write-Host ""
    Write-Host "Cancelled. You can run this script again anytime." -ForegroundColor Red
    Write-Host ""
}

# Keep window open
Write-Host "Press Enter to close this window..."
$null = Read-Host
