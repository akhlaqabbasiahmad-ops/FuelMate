-- FuelMate Database Creation Script
-- For LocalDB (localdb)\MSSQLLocalDB
-- Run this script to create all tables

USE master;
GO

-- Create database if it doesn't exist
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'FuelMate')
BEGIN
    CREATE DATABASE FuelMate;
    PRINT 'Database FuelMate created successfully';
END
ELSE
BEGIN
    PRINT 'Database FuelMate already exists';
END
GO

-- Switch to FuelMate database
USE FuelMate;
GO

-- ============================================
-- Users Table
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Users]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Users] (
        [Id] NVARCHAR(255) NOT NULL PRIMARY KEY,
        [Name] NVARCHAR(255) NOT NULL UNIQUE,
        [Role] NVARCHAR(50) NOT NULL,
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [LastLoginAt] DATETIME2 NOT NULL DEFAULT GETDATE()
    );
    PRINT 'Table Users created successfully';
END
ELSE
BEGIN
    PRINT 'Table Users already exists';
END
GO

-- ============================================
-- PetrolRequests Table
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PetrolRequests]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[PetrolRequests] (
        [Id] NVARCHAR(255) NOT NULL PRIMARY KEY,
        [NeedyId] NVARCHAR(255) NOT NULL,
        [NeedyName] NVARCHAR(255) NULL,
        [Role] NVARCHAR(50) NOT NULL,
        [Latitude] DECIMAL(10, 7) NOT NULL,
        [Longitude] DECIMAL(10, 7) NOT NULL,
        [Message] NVARCHAR(MAX) NOT NULL,
        [QuantityLiters] DECIMAL(10, 2) NULL,
        [Urgency] NVARCHAR(50) NOT NULL DEFAULT 'normal',
        [Status] NVARCHAR(50) NOT NULL DEFAULT 'pending',
        [AcceptedBy] NVARCHAR(255) NULL,
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [UpdatedAt] DATETIME2 NOT NULL DEFAULT GETDATE()
    );
    PRINT 'Table PetrolRequests created successfully';
END
ELSE
BEGIN
    PRINT 'Table PetrolRequests already exists';
END
GO

-- ============================================
-- Quotes Table
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Quotes]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Quotes] (
        [Id] NVARCHAR(255) NOT NULL PRIMARY KEY,
        [RequestId] NVARCHAR(255) NOT NULL,
        [ProviderId] NVARCHAR(255) NOT NULL,
        [ProviderName] NVARCHAR(255) NULL,
        [Price] DECIMAL(10, 2) NOT NULL,
        [Currency] NVARCHAR(10) NOT NULL DEFAULT 'PKR',
        [EstimatedDeliveryTime] INT NULL,
        [Message] NVARCHAR(MAX) NULL,
        [Status] NVARCHAR(50) NOT NULL DEFAULT 'pending',
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [UpdatedAt] DATETIME2 NOT NULL DEFAULT GETDATE()
    );
    PRINT 'Table Quotes created successfully';
END
ELSE
BEGIN
    PRINT 'Table Quotes already exists';
END
GO

-- ============================================
-- ChatMessages Table
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ChatMessages]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[ChatMessages] (
        [Id] NVARCHAR(255) NOT NULL PRIMARY KEY,
        [RequestId] NVARCHAR(255) NOT NULL,
        [SenderId] NVARCHAR(255) NOT NULL,
        [SenderName] NVARCHAR(255) NOT NULL,
        [SenderRole] NVARCHAR(50) NOT NULL,
        [Message] NVARCHAR(MAX) NOT NULL,
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETDATE()
    );
    PRINT 'Table ChatMessages created successfully';
END
ELSE
BEGIN
    PRINT 'Table ChatMessages already exists';
END
GO

-- ============================================
-- Create Indexes for Performance
-- ============================================

-- Index on Users.Name for quick lookups
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Users_Name' AND object_id = OBJECT_ID('Users'))
BEGIN
    CREATE INDEX IX_Users_Name ON Users(Name);
    PRINT 'Index IX_Users_Name created';
END
GO

-- Index on PetrolRequests.Status for filtering
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PetrolRequests_Status' AND object_id = OBJECT_ID('PetrolRequests'))
BEGIN
    CREATE INDEX IX_PetrolRequests_Status ON PetrolRequests(Status);
    PRINT 'Index IX_PetrolRequests_Status created';
END
GO

-- Index on PetrolRequests.NeedyId for user requests
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PetrolRequests_NeedyId' AND object_id = OBJECT_ID('PetrolRequests'))
BEGIN
    CREATE INDEX IX_PetrolRequests_NeedyId ON PetrolRequests(NeedyId);
    PRINT 'Index IX_PetrolRequests_NeedyId created';
END
GO

-- Index on Quotes.RequestId for request quotes
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Quotes_RequestId' AND object_id = OBJECT_ID('Quotes'))
BEGIN
    CREATE INDEX IX_Quotes_RequestId ON Quotes(RequestId);
    PRINT 'Index IX_Quotes_RequestId created';
END
GO

-- Index on ChatMessages.RequestId for chat lookups
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ChatMessages_RequestId' AND object_id = OBJECT_ID('ChatMessages'))
BEGIN
    CREATE INDEX IX_ChatMessages_RequestId ON ChatMessages(RequestId);
    PRINT 'Index IX_ChatMessages_RequestId created';
END
GO

-- ============================================
-- Verify Tables
-- ============================================
PRINT '';
PRINT '========================================';
PRINT 'Database Setup Complete!';
PRINT '========================================';
PRINT '';
PRINT 'Tables created:';
SELECT 
    name AS TableName,
    create_date AS CreatedDate
FROM sys.tables
WHERE name IN ('Users', 'PetrolRequests', 'Quotes', 'ChatMessages')
ORDER BY name;
GO

-- Show row counts
PRINT '';
PRINT 'Current row counts:';
SELECT 'Users' AS TableName, COUNT(*) AS RowCount FROM Users
UNION ALL
SELECT 'PetrolRequests', COUNT(*) FROM PetrolRequests
UNION ALL
SELECT 'Quotes', COUNT(*) FROM Quotes
UNION ALL
SELECT 'ChatMessages', COUNT(*) FROM ChatMessages;
GO

PRINT '';
PRINT 'Database is ready to use!';
PRINT 'Connection String: Server=(localdb)\MSSQLLocalDB;Database=FuelMate;Integrated Security=true;';
GO

