
USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'portfolio')
BEGIN
    DROP DATABASE portfolio;
END
GO

CREATE DATABASE portfolio;
GO

USE portfolio;
GO

-- Drop schemas if they already exist
IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'bronze')
BEGIN
    DROP SCHEMA bronze;
END
GO

IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'silver')
BEGIN
    DROP SCHEMA silver;
END
GO

IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'gold')
BEGIN
    DROP SCHEMA gold;
END
GO

-- Create schemas for each data layer
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO