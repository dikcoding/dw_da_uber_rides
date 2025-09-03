/*===============================================================================
  File   : ddl_bronze_uber.sql
  Purpose: Create Bronze Layer table for Uber Booking Data
===============================================================================*/

-- Drop schema if needed (optional, uncomment if required)
-- DROP SCHEMA IF EXISTS bronze;

-- Create schema if not exists
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'bronze')
BEGIN
    EXEC('CREATE SCHEMA bronze');
END;
GO

IF OBJECT_ID('bronze.uber_booking_data', 'U') IS NOT NULL
    DROP TABLE bronze.uber_booking_data;
GO

CREATE TABLE bronze.uber_booking_data (
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
    payment_method VARCHAR(100) NULL
);
GO
