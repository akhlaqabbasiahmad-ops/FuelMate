# Quick Start Guide - .NET 8 Backend

## ⚡ TL;DR - Get Started in 3 Steps

### Step 1: Install Prerequisites

**Install .NET 8 SDK:**
```bash
# Download from: https://dotnet.microsoft.com/download/dotnet/8.0
# Verify:
dotnet --version  # Should show 8.x.x
```

**Install SQL Server Express (FREE):**
```
Download: https://www.microsoft.com/en-us/sql-server/sql-server-downloads
Install: Choose "Mixed Mode" + set sa password
```

### Step 2: Setup Database

```powershell
cd "D:\my work place\PetrolMate\backend-dotnet"
.\SETUP_SQLSERVER.ps1
```

Follow the prompts to configure your database connection.

### Step 3: Run the Server

```powershell
.\START_BACKEND.ps1
```

**Done!** Server running at http://localhost:3000 🎉

API Docs: http://localhost:3000/api/docs

---

## 🔄 Switch from NestJS

### Stop NestJS:
```bash
# Press Ctrl+C in NestJS terminal
```

### Start .NET:
```powershell
cd backend-dotnet
.\START_BACKEND.ps1
```

**No mobile app changes needed!** Same API, same port, same everything! ✅

---

## 🐛 Quick Fixes

### SQL Server not connecting?
```powershell
Get-Service -Name "MSSQL*"
Start-Service -Name "MSSQL$SQLEXPRESS"
.\SETUP_SQLSERVER.ps1
```

### Port 3000 in use?
```powershell
# Stop NestJS backend first (Ctrl+C)
# OR change port in appsettings.json
```

### Mobile app can't connect?
```powershell
# Open firewall:
New-NetFirewallRule -DisplayName "FuelMate API" -Direction Inbound -LocalPort 3000 -Protocol TCP -Action Allow

# Get your IP:
ipconfig  # Use IPv4 Address in mobile app
```

---

## 📝 Configuration

**Edit `appsettings.json`:**

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=FuelMate;User Id=sa;Password=YOUR_PASSWORD;TrustServerCertificate=True;"
  },
  "Port": "3000"
}
```

---

## 🚀 Common Commands

```powershell
# Setup (one-time)
.\SETUP_SQLSERVER.ps1

# Test connection
.\TEST_CONNECTION.ps1

# Start server
.\START_BACKEND.ps1

# Build manually
dotnet build

# Run manually
dotnet run

# Run with auto-reload
dotnet watch run
```

---

## 📚 Documentation

- **README.md** - Complete guide
- **MIGRATION_GUIDE.md** - Migrate from NestJS
- **CONVERSION_SUMMARY.md** - What was converted
- **API Docs** - http://localhost:3000/api/docs

---

## ✅ Verification Checklist

After starting the server:

- [ ] Visit http://localhost:3000/health
- [ ] Visit http://localhost:3000/api/docs
- [ ] Test user registration endpoint
- [ ] Connect mobile/Flutter app
- [ ] Create a test request

---

**Need Help?** Read the full documentation in `README.md`

**Happy Coding! 🚀**

