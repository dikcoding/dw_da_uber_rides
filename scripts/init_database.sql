/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DW_Financial' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
	
WARNING:
    Running this script will drop the entire 'DW_Financial' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Drop and recreate the 'DW_Financial' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DW_Financial')
BEGIN
    ALTER DATABASE DW_Financial SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DW_Financial;
END;
GO

-- Create the 'DW_Financial' database
CREATE DATABASE DW_Financial;
GO

USE DW_Financial;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
