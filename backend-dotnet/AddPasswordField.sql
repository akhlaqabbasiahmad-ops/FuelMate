-- =============================================
-- Add Password Field to Users Table
-- Run this script after CreateDatabase.sql
-- =============================================

USE FuelMate;
GO

-- Add PasswordHash column if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE object_id = OBJECT_ID(N'Users') 
               AND name = 'PasswordHash')
BEGIN
    PRINT '📝 Adding PasswordHash column to Users table...';
    ALTER TABLE Users 
    ADD PasswordHash NVARCHAR(255) NULL;
    PRINT '✅ PasswordHash column added successfully!';
END
ELSE
BEGIN
    PRINT 'ℹ️ PasswordHash column already exists.';
END
GO

-- Set empty string for existing users (they'll need to set password on next login)
UPDATE Users 
SET PasswordHash = '' 
WHERE PasswordHash IS NULL;
PRINT '✅ Updated existing users with empty password hash.';
GO

-- Make PasswordHash required (NOT NULL)
IF EXISTS (SELECT * FROM sys.columns 
           WHERE object_id = OBJECT_ID(N'Users') 
           AND name = 'PasswordHash' 
           AND is_nullable = 1)
BEGIN
    PRINT '📝 Making PasswordHash column NOT NULL...';
    ALTER TABLE Users 
    ALTER COLUMN PasswordHash NVARCHAR(255) NOT NULL;
    PRINT '✅ PasswordHash is now required!';
END
GO

-- Display updated table structure
PRINT '📊 Updated Users table structure:';
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Users'
ORDER BY ORDINAL_POSITION;
GO

PRINT '';
PRINT '🎉 Database migration completed successfully!';
PRINT '';
PRINT '⚠️ Note: Existing users have empty passwords.';
PRINT '   They will need to set a password on next login.';
PRINT '';
GO

