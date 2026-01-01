# SQL Server Quick Setup Guide

## The Error
Your backend can't connect to SQL Server because it's either:
1. Not installed
2. Not running
3. Not configured correctly

## Quick Fix Steps

### Step 1: Check if SQL Server is Installed

```powershell
Get-Service -Name "MSSQL*"
```

**If you see services:** SQL Server is installed, go to Step 2  
**If you see nothing:** SQL Server is not installed, go to Step 3

### Step 2: Start SQL Server (if installed)

```powershell
# List SQL Server services
Get-Service -Name "MSSQL*"

# Start the service (replace with your service name)
Start-Service -Name "MSSQL`$SQLEXPRESS"

# Or start all SQL services
Get-Service -Name "MSSQL*" | Start-Service
```

Then restart your backend:
```powershell
cd "D:\my work place\PetrolMate\backend-dotnet"
dotnet run
```

### Step 3: Install SQL Server Express (FREE)

**Download:**
https://www.microsoft.com/en-us/sql-server/sql-server-downloads

**Choose:** SQL Server 2022 Express (FREE)

**Installation Steps:**
1. Run the installer
2. Choose **"Basic"** installation
3. Accept license terms
4. Choose installation location
5. Click **Install**
6. Wait for installation (~5-10 minutes)

**After Installation:**
```powershell
cd "D:\my work place\PetrolMate\backend-dotnet"
.\SETUP_SQLSERVER.ps1
```

### Step 4: Alternative - Use LocalDB (Simpler)

LocalDB is a lightweight version of SQL Server, perfect for development.

**Check if LocalDB is installed:**
```powershell
sqllocaldb info
```

**If installed, update connection string:**

Edit `backend-dotnet/appsettings.json`:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=FuelMate;Trusted_Connection=True;"
  }
}
```

Then run:
```powershell
cd backend-dotnet
dotnet run
```

## Quick Test

After fixing, test the connection:
```powershell
cd backend-dotnet
.\TEST_CONNECTION.ps1
```

## Still Having Issues?

Try the temporary in-memory solution (see TEMPORARY_FIX.md)

