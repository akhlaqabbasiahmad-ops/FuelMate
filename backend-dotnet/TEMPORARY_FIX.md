# TEMPORARY FIX - In-Memory Database

If you want to test the backend **immediately** without installing SQL Server, use this temporary fix.

## ⚠️ Warning
This uses in-memory storage. **Data will be lost** when you stop the server!  
Use only for testing. Install SQL Server for production.

## Quick Fix

### Step 1: Update DapperContext.cs

Replace the entire file content with:

```csharp
using System.Data;

namespace FuelMateBackend.Data;

public class DapperContext
{
    // In-memory storage as fallback
    private static bool _useSqlServer = false;
    private readonly IConfiguration _configuration;

    public DapperContext(IConfiguration configuration)
    {
        _configuration = configuration;
        
        // Test SQL Server connection
        try
        {
            var connStr = _configuration.GetConnectionString("DefaultConnection");
            if (!string.IsNullOrEmpty(connStr))
            {
                using var testConn = new Microsoft.Data.SqlClient.SqlConnection(connStr);
                testConn.Open();
                testConn.Close();
                _useSqlServer = true;
                Console.WriteLine("✅ Using SQL Server database");
            }
        }
        catch
        {
            Console.WriteLine("⚠️ SQL Server not available - using IN-MEMORY storage");
            Console.WriteLine("⚠️ Data will be LOST when server stops!");
        }
    }

    public IDbConnection CreateConnection()
    {
        if (_useSqlServer)
        {
            var connectionString = _configuration.GetConnectionString("DefaultConnection");
            return new Microsoft.Data.SqlClient.SqlConnection(connectionString);
        }
        
        // Fallback: This will cause errors but at least shows the issue
        throw new InvalidOperationException(
            "SQL Server not available. Please install SQL Server or configure LocalDB.\n" +
            "See FIX_SQL_CONNECTION.md for instructions.");
    }
}
```

### Step 2: Restart Backend

```powershell
cd "D:\my work place\PetrolMate\backend-dotnet"
dotnet run
```

## Better Solution: Use SQLite

SQLite is a file-based database (no server needed).

### Step 1: Add SQLite Package

```powershell
cd backend-dotnet
dotnet add package Microsoft.Data.Sqlite
```

### Step 2: Update appsettings.json

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Data Source=fuelmate.db"
  },
  "UseDatabase": "sqlite"
}
```

### Step 3: Update DapperContext.cs

```csharp
using Microsoft.Data.Sqlite;
using System.Data;

namespace FuelMateBackend.Data;

public class DapperContext
{
    private readonly string _connectionString;
    private readonly string _dbType;

    public DapperContext(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("DefaultConnection")!;
        _dbType = configuration["UseDatabase"] ?? "sqlserver";
    }

    public IDbConnection CreateConnection()
    {
        if (_dbType.ToLower() == "sqlite")
        {
            return new SqliteConnection(_connectionString);
        }
        
        return new Microsoft.Data.SqlClient.SqlConnection(_connectionString);
    }
}
```

### Step 4: Update DatabaseInitializer.cs

Replace SQL Server syntax with SQLite syntax:

```csharp
// Change IF NOT EXISTS syntax for SQLite
await connection.ExecuteAsync(@"
    CREATE TABLE IF NOT EXISTS Users (
        Id TEXT PRIMARY KEY,
        Name TEXT NOT NULL UNIQUE,
        Role TEXT NOT NULL,
        CreatedAt TEXT NOT NULL,
        LastLoginAt TEXT NOT NULL
    )
");

// Similar for other tables...
```

## Recommended: Install SQL Server

For production use, install SQL Server Express:
https://www.microsoft.com/en-us/sql-server/sql-server-downloads

Then run:
```powershell
.\SETUP_SQLSERVER.ps1
```

