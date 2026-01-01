# LocalDB Setup - Quick Guide

## ✅ Configuration Updated

Your backend is now configured to use **LocalDB**!

**Connection String:**
```
Server=(localdb)\MSSQLLocalDB;Database=FuelMate;Integrated Security=true;TrustServerCertificate=True;
```

---

## 🚀 Setup in 2 Steps

### Step 1: Create Database & Tables

```powershell
cd "D:\my work place\PetrolMate\backend-dotnet"
.\SETUP_LOCALDB.ps1
```

This script will:
- ✅ Check if LocalDB is available
- ✅ Start LocalDB
- ✅ Create FuelMate database
- ✅ Create all tables (Users, PetrolRequests, Quotes, ChatMessages)
- ✅ Create indexes for performance
- ✅ Update appsettings.json
- ✅ Verify everything works

### Step 2: Start Backend

```powershell
.\START_BACKEND.ps1
```

Or:
```powershell
dotnet run
```

---

## 📝 What Changed

### Before (SQL Server):
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=FuelMate;User Id=sa;Password=YourPassword123!;..."
  }
}
```

### After (LocalDB):
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=(localdb)\\MSSQLLocalDB;Database=FuelMate;Integrated Security=true;..."
  }
}
```

**Key Differences:**
- ✅ No password needed (Windows Authentication)
- ✅ LocalDB is file-based (easier setup)
- ✅ Automatically starts when accessed
- ✅ Perfect for development

---

## 🗄️ Database Structure

### Tables Created:

**1. Users**
```sql
- Id (NVARCHAR(255), Primary Key)
- Name (NVARCHAR(255), Unique)
- Role (NVARCHAR(50))
- CreatedAt (DATETIME2)
- LastLoginAt (DATETIME2)
```

**2. PetrolRequests**
```sql
- Id (NVARCHAR(255), Primary Key)
- NeedyId (NVARCHAR(255))
- NeedyName (NVARCHAR(255))
- Role (NVARCHAR(50))
- Latitude (DECIMAL(10,7))
- Longitude (DECIMAL(10,7))
- Message (NVARCHAR(MAX))
- QuantityLiters (DECIMAL(10,2))
- Urgency (NVARCHAR(50))
- Status (NVARCHAR(50))
- AcceptedBy (NVARCHAR(255))
- CreatedAt (DATETIME2)
- UpdatedAt (DATETIME2)
```

**3. Quotes**
```sql
- Id (NVARCHAR(255), Primary Key)
- RequestId (NVARCHAR(255))
- ProviderId (NVARCHAR(255))
- ProviderName (NVARCHAR(255))
- Price (DECIMAL(10,2))
- Currency (NVARCHAR(10))
- EstimatedDeliveryTime (INT)
- Message (NVARCHAR(MAX))
- Status (NVARCHAR(50))
- CreatedAt (DATETIME2)
- UpdatedAt (DATETIME2)
```

**4. ChatMessages**
```sql
- Id (NVARCHAR(255), Primary Key)
- RequestId (NVARCHAR(255))
- SenderId (NVARCHAR(255))
- SenderName (NVARCHAR(255))
- SenderRole (NVARCHAR(50))
- Message (NVARCHAR(MAX))
- CreatedAt (DATETIME2)
```

---

## 🧪 Test Connection

```powershell
# Test LocalDB connection
cd backend-dotnet
.\TEST_CONNECTION.ps1
```

Or manually:
```powershell
sqlcmd -S "(localdb)\MSSQLLocalDB" -Q "SELECT @@VERSION"
```

---

## 📂 Files Created/Updated

- ✅ `appsettings.json` - Updated with LocalDB connection
- ✅ `appsettings.Development.json` - Updated with LocalDB connection
- ✅ `CreateDatabase.sql` - SQL script to create database & tables
- ✅ `SETUP_LOCALDB.ps1` - PowerShell setup script
- ✅ `LOCALDB_GUIDE.md` - This guide

---

## 🔍 LocalDB Commands

### Start LocalDB
```powershell
sqllocaldb start MSSQLLocalDB
```

### Stop LocalDB
```powershell
sqllocaldb stop MSSQLLocalDB
```

### Get LocalDB Info
```powershell
sqllocaldb info MSSQLLocalDB
```

### List All LocalDB Instances
```powershell
sqllocaldb info
```

### Delete Database (if needed)
```powershell
sqlcmd -S "(localdb)\MSSQLLocalDB" -Q "DROP DATABASE FuelMate"
```

---

## 🛠️ Troubleshooting

### Issue: LocalDB not found

**Solution:** Install SQL Server Express LocalDB
- Download: https://www.microsoft.com/en-us/sql-server/sql-server-downloads
- Or install via Visual Studio Installer

### Issue: Connection timeout

**Solution:** Start LocalDB manually
```powershell
sqllocaldb start MSSQLLocalDB
```

### Issue: Database already exists

**Solution:** Drop and recreate
```powershell
sqlcmd -S "(localdb)\MSSQLLocalDB" -Q "DROP DATABASE FuelMate"
.\SETUP_LOCALDB.ps1
```

### Issue: Access denied

**Solution:** Run PowerShell as Administrator
```powershell
# Right-click PowerShell → Run as Administrator
cd "D:\my work place\PetrolMate\backend-dotnet"
.\SETUP_LOCALDB.ps1
```

---

## 📊 View Database

### Using SQL Server Management Studio (SSMS)
1. Open SSMS
2. Connect to: `(localdb)\MSSQLLocalDB`
3. Authentication: Windows Authentication
4. Browse to FuelMate database

### Using Visual Studio
1. View → SQL Server Object Explorer
2. Expand: SQL Server → (localdb)\MSSQLLocalDB
3. Browse to FuelMate database

### Using sqlcmd
```powershell
# Connect to database
sqlcmd -S "(localdb)\MSSQLLocalDB" -d FuelMate

# List tables
SELECT name FROM sys.tables;
GO

# Query users
SELECT * FROM Users;
GO

# Exit
EXIT
```

---

## 🎯 Quick Start Summary

```powershell
# 1. Create database
cd "D:\my work place\PetrolMate\backend-dotnet"
.\SETUP_LOCALDB.ps1

# 2. Start backend
.\START_BACKEND.ps1

# 3. Test API
Invoke-WebRequest http://localhost:3000/health

# 4. Run Flutter app
cd ..\flutter_app
flutter run
```

---

## ✅ Verification

After running `SETUP_LOCALDB.ps1`, you should see:
```
✅ LocalDB is available
✅ LocalDB started
✅ Connection successful!
✅ Database created successfully!
✅ appsettings.json updated
✅ Tables created:
   ✅ Users
   ✅ PetrolRequests
   ✅ Quotes
   ✅ ChatMessages
```

---

## 📞 Need Help?

If you see the SQL Server connection error again:
1. Run `SETUP_LOCALDB.ps1`
2. Check if LocalDB is started: `sqllocaldb info MSSQLLocalDB`
3. Test connection: `.\TEST_CONNECTION.ps1`
4. Check logs in backend terminal

---

**Ready!** Run: `.\SETUP_LOCALDB.ps1` to create the database! 🚀

