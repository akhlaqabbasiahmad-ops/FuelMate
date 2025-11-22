# Allow Backend Port in Windows Firewall
# Run this script as Administrator to allow mobile app connections

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Configuring Windows Firewall" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "❌ This script must be run as Administrator!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

$port = 3000
$ruleName = "FuelMate Backend API"

Write-Host "Adding firewall rule for port $port..." -ForegroundColor Yellow
Write-Host ""

# Check if rule already exists
$existingRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue

if ($existingRule) {
    Write-Host "⚠️  Firewall rule '$ruleName' already exists" -ForegroundColor Yellow
    Write-Host "Removing existing rule..." -ForegroundColor Yellow
    Remove-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
}

try {
    # Create new firewall rule
    New-NetFirewallRule `
        -DisplayName $ruleName `
        -Direction Inbound `
        -LocalPort $port `
        -Protocol TCP `
        -Action Allow `
        -Description "Allow FuelMate Backend API connections from mobile app" `
        -ErrorAction Stop
    
    Write-Host "✅ Firewall rule created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Backend should now be accessible from mobile app on port $port" -ForegroundColor Green
    Write-Host ""
    
    # Show the rule
    Write-Host "Firewall rule details:" -ForegroundColor Cyan
    Get-NetFirewallRule -DisplayName $ruleName | Format-Table DisplayName, Direction, Action, Enabled -AutoSize
    
} catch {
    Write-Host "❌ Failed to create firewall rule" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Try manually adding the rule:" -ForegroundColor Yellow
    Write-Host "1. Open Windows Defender Firewall" -ForegroundColor White
    Write-Host "2. Advanced Settings > Inbound Rules > New Rule" -ForegroundColor White
    Write-Host "3. Port > TCP > Specific local ports: $port" -ForegroundColor White
    Write-Host "4. Allow the connection" -ForegroundColor White
    Write-Host ""
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

