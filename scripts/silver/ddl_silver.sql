/*===============================================================================
  File   : ddl_silver.sql
  Purpose: Create Silver Layer table for Uber Booking Data
===============================================================================

Overview:
  The Silver layer ensures that data is clean, consistent, and standardized 
  before moving into the Gold layer.

Process:
  • Load data from Bronze to Silver using a full load method 
    (truncate followed by insert).
  • Apply multiple transformations, including:
      - Data Cleaning
      - Data Standardization
      - Data Normalization
      - Derived Columns
      - Data Enrichment

Notes:
  The table structure in Silver is identical to Bronze. 
  The main difference is the schema name, 
  so the DDL script can be adapted from Bronze by replacing the schema.
===============================================================================*/

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'silver')
BEGIN
    EXEC('CREATE SCHEMA silver');
END;
GO

IF OBJECT_ID('silver.uber_booking_clean', 'U') IS NOT NULL
    DROP TABLE silver.uber_booking_clean;
GO

CREATE TABLE silver.uber_booking_clean (
    [date] VARCHAR(50) NULL,
    [time] VARCHAR(50) NULL,
    booking_id VARCHAR(50) NULL,
    booking_status VARCHAR(100) NULL,
    customer_id VARCHAR(50) NULL,
    vehicle_type VARCHAR(50) NULL,
    pickup_location VARCHAR(255) NULL,
    drop_location VARCHAR(255) NULL,
    avg_vtat VARCHAR(50) NULL,
    avg_ctat VARCHAR(50) NULL,
    cancelled_by_customer VARCHAR(10) NULL,
    cancellation_reason_customer VARCHAR(255) NULL,
    cancelled_by_driver VARCHAR(10) NULL,
    cancellation_reason_driver VARCHAR(255) NULL,
    incomplete_ride_flag VARCHAR(10) NULL,
    incomplete_ride_reason VARCHAR(255) NULL,
    booking_value VARCHAR(50) NULL,
    ride_distance VARCHAR(50) NULL,
    driver_rating VARCHAR(50) NULL,
    customer_rating VARCHAR(50) NULL,
    payment_method VARCHAR(100) NULL,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO
