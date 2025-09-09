/*===============================================================================
  File   : ddl_silver_uber.sql
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

-- Buat Silver Table dengan numeric column
CREATE TABLE silver.uber_booking_clean (
    booking_id                  VARCHAR(50)   NOT NULL,
    booking_datetime            DATETIME      NOT NULL,
    booking_status              VARCHAR(100)  NULL,
    vehicle_type                VARCHAR(50)   NULL,
    pickup_location             VARCHAR(255)  NULL,
    drop_location               VARCHAR(255)  NULL,
    booking_value               DECIMAL(18,2) NULL,
    ride_distance               DECIMAL(18,2) NULL,
    cancelled_by_customer       BIT           NULL,
    cancellation_reason_customer VARCHAR(255) NULL,
    cancelled_by_driver         BIT           NULL,
    cancellation_reason_driver  VARCHAR(255) NULL,
    incomplete_ride_flag        BIT           NULL,
    incomplete_ride_reason      VARCHAR(255) NULL,
    driver_rating               DECIMAL(5,2)  NULL,
    customer_rating             DECIMAL(5,2)  NULL,
    payment_method              VARCHAR(100)  NULL,
    avg_vtat                    DECIMAL(18,2) NULL,   
    avg_ctat                    DECIMAL(18,2) NULL,   
    dwh_create_date             DATETIME      NOT NULL
);
GO
