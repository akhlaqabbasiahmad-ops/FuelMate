# FuelMate - Run Backend and Flutter App Together
# This script runs both the .NET backend and Flutter app

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  FuelMate - Start Backend & Flutter" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get current IP address
$ipAddress = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Wi-Fi*","Ethernet*" | Where-Object {$_.IPAddress -notlike "169.254.*"} | Select-Object -First 1).IPAddress

if (-not $ipAddress) {
    $ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike "127.0.0.1" -and $_.IPAddress -notlike "169.254.*"} | Select-Object -First 1).IPAddress
}

Write-Host "📡 Network Configuration:" -ForegroundColor Yellow
Write-Host "   Your IP Address: $ipAddress" -ForegroundColor Cyan
Write-Host "   Backend Port: 3000" -ForegroundColor Cyan
Write-Host "   Backend URL: http://$ipAddress:3000" -ForegroundColor Green
Write-Host ""

# Check if Flutter app config needs updating
$flutterConfigPath = Join-Path $PSScriptRoot "flutter_app\lib\config\api_config.dart"
if (Test-Path $flutterConfigPath) {
    $configContent = Get-Content $flutterConfigPath -Raw
    if ($configContent -match "apiHostIp = '([^']+)'") {
        $currentIp = $matches[1]
        if ($currentIp -ne $ipAddress) {
            Write-Host "⚠️  Flutter app is configured for IP: $currentIp" -ForegroundColor Yellow
            Write-Host "   Your current IP is: $ipAddress" -ForegroundColor Yellow
            Write-Host ""
            $updateConfig = Read-Host "   Update Flutter config to use $ipAddress? (Y/N)"
            if ($updateConfig -eq "Y" -or $updateConfig -eq "y") {
                $configContent = $configContent -replace "apiHostIp = '$currentIp'", "apiHostIp = '$ipAddress'"
                Set-Content $flutterConfigPath $configContent -NoNewline
                Write-Host "   ✅ Flutter config updated!" -ForegroundColor Green
            }
        } else {
            Write-Host "✅ Flutter app is already configured for IP: $ipAddress" -ForegroundColor Green
        }
    }
    Write-Host ""
}

# Check prerequisites
Write-Host "🔍 Checking prerequisites..." -ForegroundColor Yellow
Write-Host ""

# Check .NET
$dotnetVersion = dotnet --version 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ .NET SDK: $dotnetVersion" -ForegroundColor Green
} else {
    Write-Host "❌ .NET SDK not found!" -ForegroundColor Red
    Write-Host "   Download: https://dotnet.microsoft.com/download/dotnet/8.0" -ForegroundColor Yellow
    exit 1
}

# Check Flutter
$flutterVersion = flutter --version 2>&1 | Select-String "Flutter" | Select-Object -First 1
if ($flutterVersion) {
    Write-Host "✅ Flutter: $($flutterVersion.Line.Trim())" -ForegroundColor Green
} else {
    Write-Host "❌ Flutter not found!" -ForegroundColor Red
    Write-Host "   Download: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Yellow
    exit 1
}

# Check SQL Server
$sqlService = Get-Service -Name "MSSQL*" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($sqlService) {
    if ($sqlService.Status -eq "Running") {
        Write-Host "✅ SQL Server: Running" -ForegroundColor Green
    } else {
        Write-Host "⚠️  SQL Server: Not running" -ForegroundColor Yellow
        Write-Host "   Starting SQL Server..." -ForegroundColor Yellow
        Start-Service $sqlService.Name -ErrorAction SilentlyContinue
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✅ SQL Server started" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Could not start SQL Server automatically" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "⚠️  SQL Server not found - backend may not work" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Starting Services" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Open firewall port
Write-Host "🔥 Configuring firewall..." -ForegroundColor Yellow
$firewallRule = Get-NetFirewallRule -DisplayName "FuelMate API" -ErrorAction SilentlyContinue
if (-not $firewallRule) {
    try {
        New-NetFirewallRule -DisplayName "FuelMate API" -Direction Inbound -LocalPort 3000 -Protocol TCP -Action Allow -ErrorAction SilentlyContinue | Out-Null
        Write-Host "   ✅ Firewall rule created for port 3000" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠️  Could not create firewall rule (may need admin)" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ✅ Firewall rule already exists" -ForegroundColor Green
}
Write-Host ""

# Start backend in new window
Write-Host "🚀 Starting .NET Backend..." -ForegroundColor Yellow
$backendPath = Join-Path $PSScriptRoot "backend-dotnet"
if (Test-Path $backendPath) {
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$backendPath'; Write-Host '=== FuelMate Backend ===' -ForegroundColor Cyan; dotnet run"
    Write-Host "   ✅ Backend starting in new window..." -ForegroundColor Green
    Write-Host "   URL: http://$ipAddress:3000" -ForegroundColor Cyan
    Write-Host "   Docs: http://$ipAddress:3000/api/docs" -ForegroundColor Cyan
} else {
    Write-Host "   ❌ Backend directory not found: $backendPath" -ForegroundColor Red
    exit 1
}

# Wait for backend to start
Write-Host ""
Write-Host "⏳ Waiting for backend to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Test backend
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/health" -TimeoutSec 5 -UseBasicParsing -ErrorAction SilentlyContinue
    if ($response.StatusCode -eq 200) {
        Write-Host "   ✅ Backend is running!" -ForegroundColor Green
    }
} catch {
    Write-Host "   ⚠️  Backend may still be starting..." -ForegroundColor Yellow
}

Write-Host ""

# Start Flutter app in new window
Write-Host "📱 Starting Flutter App..." -ForegroundColor Yellow
$flutterPath = Join-Path $PSScriptRoot "flutter_app"
if (Test-Path $flutterPath) {
    # Ask which device to use
    Write-Host ""
    Write-Host "Select device:" -ForegroundColor Cyan
    Write-Host "  1) Physical device (uses IP: $ipAddress)" -ForegroundColor White
    Write-Host "  2) Android emulator (uses 10.0.2.2)" -ForegroundColor White
    Write-Host "  3) Chrome (web)" -ForegroundColor White
    $deviceChoice = Read-Host "Enter choice (1-3)"
    
    $flutterCommand = "cd '$flutterPath'; Write-Host '=== FuelMate Flutter App ===' -ForegroundColor Cyan; "
    
    switch ($deviceChoice) {
        "1" { 
            $flutterCommand += "Write-Host 'Using Physical Device - API: http://$ipAddress:3000' -ForegroundColor Green; flutter run"
        }
        "2" { 
            $flutterCommand += "Write-Host 'Using Android Emulator - API: http://10.0.2.2:3000' -ForegroundColor Green; flutter run"
        }
        "3" { 
            $flutterCommand += "Write-Host 'Using Chrome - API: http://localhost:3000' -ForegroundColor Green; flutter run -d chrome"
        }
        default { 
            $flutterCommand += "Write-Host 'Using default device' -ForegroundColor Green; flutter run"
        }
    }
    
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $flutterCommand
    Write-Host "   ✅ Flutter app starting in new window..." -ForegroundColor Green
} else {
    Write-Host "   ❌ Flutter app directory not found: $flutterPath" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Services Started! ✅" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Backend:" -ForegroundColor Cyan
Write-Host "  - Running on: http://$ipAddress:3000" -ForegroundColor White
Write-Host "  - API Docs: http://$ipAddress:3000/api/docs" -ForegroundColor White
Write-Host "  - Health Check: http://$ipAddress:3000/health" -ForegroundColor White
Write-Host ""
Write-Host "Flutter App:" -ForegroundColor Cyan
Write-Host "  - API URL configured: http://$ipAddress:3000" -ForegroundColor White
Write-Host "  - Running in separate window" -ForegroundColor White
Write-Host ""
Write-Host "📱 On your mobile device:" -ForegroundColor Yellow
Write-Host "   Make sure you're on the same WiFi network" -ForegroundColor White
Write-Host "   API URL: http://$ipAddress:3000" -ForegroundColor Green
Write-Host ""
Write-Host "Press any key to close this window..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

