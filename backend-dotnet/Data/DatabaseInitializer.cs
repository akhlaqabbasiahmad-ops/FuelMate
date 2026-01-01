using Dapper;

namespace FuelMateBackend.Data;

public static class DatabaseInitializer
{
    public static async Task InitializeDatabaseAsync(DapperContext context)
    {
        using var connection = context.CreateConnection();
        
        // Create Users table
        await connection.ExecuteAsync(@"
            IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Users' AND xtype='U')
            CREATE TABLE Users (
                Id NVARCHAR(255) PRIMARY KEY,
                Name NVARCHAR(255) NOT NULL UNIQUE,
                Role NVARCHAR(50) NOT NULL,
                CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
                LastLoginAt DATETIME2 NOT NULL DEFAULT GETDATE()
            )
        ");

        // Create PetrolRequests table
        await connection.ExecuteAsync(@"
            IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='PetrolRequests' AND xtype='U')
            CREATE TABLE PetrolRequests (
                Id NVARCHAR(255) PRIMARY KEY,
                NeedyId NVARCHAR(255) NOT NULL,
                NeedyName NVARCHAR(255),
                Role NVARCHAR(50) NOT NULL,
                Latitude DECIMAL(10, 7) NOT NULL,
                Longitude DECIMAL(10, 7) NOT NULL,
                Message NVARCHAR(MAX) NOT NULL,
                QuantityLiters DECIMAL(10, 2),
                Urgency NVARCHAR(50) NOT NULL DEFAULT 'normal',
                Status NVARCHAR(50) NOT NULL DEFAULT 'pending',
                AcceptedBy NVARCHAR(255),
                CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
                UpdatedAt DATETIME2 NOT NULL DEFAULT GETDATE()
            )
        ");

        // Create Quotes table
        await connection.ExecuteAsync(@"
            IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Quotes' AND xtype='U')
            CREATE TABLE Quotes (
                Id NVARCHAR(255) PRIMARY KEY,
                RequestId NVARCHAR(255) NOT NULL,
                ProviderId NVARCHAR(255) NOT NULL,
                ProviderName NVARCHAR(255),
                Price DECIMAL(10, 2) NOT NULL,
                Currency NVARCHAR(10) NOT NULL DEFAULT 'PKR',
                EstimatedDeliveryTime INT,
                Message NVARCHAR(MAX),
                Status NVARCHAR(50) NOT NULL DEFAULT 'pending',
                CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
                UpdatedAt DATETIME2 NOT NULL DEFAULT GETDATE()
            )
        ");

        // Create ChatMessages table
        await connection.ExecuteAsync(@"
            IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='ChatMessages' AND xtype='U')
            CREATE TABLE ChatMessages (
                Id NVARCHAR(255) PRIMARY KEY,
                RequestId NVARCHAR(255) NOT NULL,
                SenderId NVARCHAR(255) NOT NULL,
                SenderName NVARCHAR(255) NOT NULL,
                SenderRole NVARCHAR(50) NOT NULL,
                Message NVARCHAR(MAX) NOT NULL,
                CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE()
            )
        ");

        Console.WriteLine("✅ Database tables initialized successfully");
    }
}

