# Setup LocalDB Database for FuelMate
# This script creates the database and all tables

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  FuelMate LocalDB Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptPath = Join-Path $PSScriptRoot "CreateDatabase.sql"
$connectionString = "Server=(localdb)\MSSQLLocalDB;Database=master;Integrated Security=true;TrustServerCertificate=True;"

# Check if LocalDB is available
Write-Host "🔍 Checking LocalDB..." -ForegroundColor Yellow
try {
    $localDbInfo = sqllocaldb info MSSQLLocalDB 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ LocalDB is available" -ForegroundColor Green
    } else {
        throw "LocalDB not found"
    }
} catch {
    Write-Host "   ❌ LocalDB is not installed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "To install LocalDB:" -ForegroundColor Yellow
    Write-Host "1. Download SQL Server Express LocalDB:" -ForegroundColor White
    Write-Host "   https://www.microsoft.com/en-us/sql-server/sql-server-downloads" -ForegroundColor Gray
    Write-Host "2. Or install via Visual Studio Installer" -ForegroundColor White
    Write-Host ""
    exit 1
}

# Start LocalDB if not running
Write-Host ""
Write-Host "🚀 Starting LocalDB..." -ForegroundColor Yellow
try {
    sqllocaldb start MSSQLLocalDB 2>&1 | Out-Null
    Write-Host "   ✅ LocalDB started" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  LocalDB may already be running" -ForegroundColor Yellow
}

# Test connection
Write-Host ""
Write-Host "🔌 Testing connection..." -ForegroundColor Yellow
try {
    $conn = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $conn.Open()
    Write-Host "   ✅ Connection successful!" -ForegroundColor Green
    Write-Host "   Server: $($conn.DataSource)" -ForegroundColor Cyan
    Write-Host "   Server Version: $($conn.ServerVersion)" -ForegroundColor Cyan
    $conn.Close()
} catch {
    Write-Host "   ❌ Connection failed!" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Yellow
    exit 1
}

# Run SQL script
Write-Host ""
Write-Host "📝 Creating database and tables..." -ForegroundColor Yellow
Write-Host ""

if (-not (Test-Path $scriptPath)) {
    Write-Host "   ❌ SQL script not found: $scriptPath" -ForegroundColor Red
    exit 1
}

try {
    # Use SqlCmd if available, otherwise use .NET
    $sqlCmd = Get-Command sqlcmd -ErrorAction SilentlyContinue
    
    if ($sqlCmd) {
        # Use SqlCmd
        Write-Host "   Using sqlcmd..." -ForegroundColor Gray
        sqlcmd -S "(localdb)\MSSQLLocalDB" -i "$scriptPath" -b
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "   ✅ Database created successfully!" -ForegroundColor Green
        } else {
            throw "SqlCmd execution failed"
        }
    } else {
        # Use .NET SqlConnection
        Write-Host "   Using .NET SqlConnection..." -ForegroundColor Gray
        $sqlScript = Get-Content $scriptPath -Raw
        
        $conn = New-Object System.Data.SqlClient.SqlConnection($connectionString)
        $conn.Open()
        
        # Split script by GO statements
        $batches = $sqlScript -split '\r?\nGO\r?\n'
        
        foreach ($batch in $batches) {
            if ($batch.Trim() -ne "") {
                $cmd = $conn.CreateCommand()
                $cmd.CommandText = $batch
                $cmd.CommandTimeout = 60
                
                try {
                    $result = $cmd.ExecuteNonQuery()
                } catch {
                    # Some commands like PRINT don't return rows, that's OK
                    if ($_.Exception.Message -notlike "*affected*") {
                        Write-Host "   ⚠️  $($_.Exception.Message)" -ForegroundColor Yellow
                    }
                }
            }
        }
        
        $conn.Close()
        Write-Host ""
        Write-Host "   ✅ Database created successfully!" -ForegroundColor Green
    }
} catch {
    Write-Host ""
    Write-Host "   ❌ Error creating database!" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Yellow
    exit 1
}

# Update appsettings.json
Write-Host ""
Write-Host "🔧 Updating configuration..." -ForegroundColor Yellow

$appSettingsPath = Join-Path $PSScriptRoot "appsettings.json"
$newConnectionString = "Server=(localdb)\\MSSQLLocalDB;Database=FuelMate;Integrated Security=true;TrustServerCertificate=True;"

if (Test-Path $appSettingsPath) {
    try {
        $appSettings = Get-Content $appSettingsPath -Raw | ConvertFrom-Json
        $appSettings.ConnectionStrings.DefaultConnection = $newConnectionString
        $appSettings | ConvertTo-Json -Depth 10 | Set-Content $appSettingsPath
        Write-Host "   ✅ appsettings.json updated" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠️  Could not update appsettings.json automatically" -ForegroundColor Yellow
        Write-Host "   Please update manually with:" -ForegroundColor Yellow
        Write-Host "   $newConnectionString" -ForegroundColor Gray
    }
}

# Update appsettings.Development.json
$appSettingsDevPath = Join-Path $PSScriptRoot "appsettings.Development.json"
if (Test-Path $appSettingsDevPath) {
    try {
        $appSettingsDev = Get-Content $appSettingsDevPath -Raw | ConvertFrom-Json
        $appSettingsDev.ConnectionStrings.DefaultConnection = $newConnectionString
        $appSettingsDev | ConvertTo-Json -Depth 10 | Set-Content $appSettingsDevPath
        Write-Host "   ✅ appsettings.Development.json updated" -ForegroundColor Green
    } catch {
        # Silent fail for dev settings
    }
}

# Verify database
Write-Host ""
Write-Host "✔️ Verifying database..." -ForegroundColor Yellow

try {
    $verifyConnString = "Server=(localdb)\MSSQLLocalDB;Database=FuelMate;Integrated Security=true;"
    $conn = New-Object System.Data.SqlClient.SqlConnection($verifyConnString)
    $conn.Open()
    
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT name FROM sys.tables WHERE name IN ('Users', 'PetrolRequests', 'Quotes', 'ChatMessages')"
    $reader = $cmd.ExecuteReader()
    
    $tables = @()
    while ($reader.Read()) {
        $tables += $reader["name"]
    }
    $reader.Close()
    $conn.Close()
    
    Write-Host ""
    Write-Host "   Tables created:" -ForegroundColor Cyan
    foreach ($table in $tables) {
        Write-Host "      ✅ $table" -ForegroundColor Green
    }
} catch {
    Write-Host "   ⚠️  Could not verify tables" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Setup Complete! ✅" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Database Details:" -ForegroundColor Cyan
Write-Host "   Server: (localdb)\MSSQLLocalDB" -ForegroundColor White
Write-Host "   Database: FuelMate" -ForegroundColor White
Write-Host "   Authentication: Windows Authentication (Integrated Security)" -ForegroundColor White
Write-Host ""
Write-Host "Connection String:" -ForegroundColor Cyan
Write-Host "   $newConnectionString" -ForegroundColor Gray
Write-Host ""
Write-Host "You can now start the backend:" -ForegroundColor Yellow
Write-Host "   .\START_BACKEND.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "Or run directly:" -ForegroundColor Yellow
Write-Host "   dotnet run" -ForegroundColor Cyan
Write-Host ""

