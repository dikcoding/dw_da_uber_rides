/*
===============================================================================
Stored Procedure: Load Bronze Uber Booking Data
===============================================================================
Script Purpose:
    This stored procedure loads Uber booking data into the 'bronze' schema 
    from an external CSV file. 
    It performs the following actions:
    - Truncates the bronze.uber_booking_data table before loading data.
    - Uses the `BULK INSERT` command to load data from csv file to bronze table.

Parameters:
    None. 
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze_uber;
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze_uber AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Bronze Layer - UBER BOOKING DATA';
        PRINT '================================================';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.uber_booking_data';
        TRUNCATE TABLE bronze.uber_booking_data;

        PRINT '>> Inserting Data Into: bronze.uber_booking_data';
        BULK INSERT bronze.uber_booking_data
        FROM 'C:\Project\data-project\ncr_ride_bookings.csv'
        WITH (
            FIRSTROW = 2,               -- Skip header row
            FIELDTERMINATOR = ';',      -- Delimiter is semicolon (;)
            ROWTERMINATOR = '0x0a',     -- Line break
            CODEPAGE = '65001',         -- UTF-8 encoding
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        SET @batch_end_time = GETDATE();
        PRINT '==========================================';
        PRINT 'Loading Bronze Uber Booking Data Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '==========================================';
    END TRY

    BEGIN CATCH
        PRINT '==========================================';
        PRINT 'ERROR OCCURED DURING LOADING BRONZE UBER BOOKING DATA';
        PRINT 'Error Message : ' + ERROR_MESSAGE();
        PRINT 'Error Number  : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State   : ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT 'Error Line    : ' + CAST(ERROR_LINE() AS NVARCHAR);
        PRINT '==========================================';
    END CATCH
END;
GO
