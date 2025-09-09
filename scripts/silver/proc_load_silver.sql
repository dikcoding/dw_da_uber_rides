/*=================================================================================
  File   : proc_load_silver.sql
  Purpose: Cleanse & Load Data from Bronze to Silver Layer
  Author : Andika
==================================================================================*/

-- 1. Deduplicate booking_id & clean data
--    Ambil record terbaru berdasarkan booking_datetime_clean
--    Terapkan standardisasi & cleansing di tahap SELECT
-- ===============================================================================

INSERT INTO silver.uber_booking_clean
(
    booking_id,
    booking_datetime,
    booking_status,
    vehicle_type,
    pickup_location,
    drop_location,
    booking_value,
    ride_distance,
    cancelled_by_customer,
    cancellation_reason_customer,
    cancelled_by_driver,
    cancellation_reason_driver,
    incomplete_ride_flag,
    incomplete_ride_reason,
    driver_rating,
    customer_rating,
    payment_method,
    avg_vtat,
    avg_ctat,
    dwh_create_date
)
SELECT
    booking_id,
    booking_datetime_clean AS booking_datetime,
    UPPER(TRIM(booking_status)) AS booking_status,
    UPPER(TRIM(vehicle_type)) AS vehicle_type,
    TRIM(pickup_location) AS pickup_location,
    TRIM(drop_location) AS drop_location,
    TRY_CONVERT(DECIMAL(18,2), booking_value) AS booking_value,  
    TRY_CONVERT(DECIMAL(18,2), ride_distance) AS ride_distance,   
    ISNULL(TRY_CONVERT(BIT, cancelled_by_customer), 0) AS cancelled_by_customer, 
    cancellation_reason_customer,
    ISNULL(TRY_CONVERT(BIT, cancelled_by_driver), 0) AS cancelled_by_driver,     
    cancellation_reason_driver,
    ISNULL(TRY_CONVERT(BIT, incomplete_ride_flag), 0) AS incomplete_ride_flag,   
    incomplete_ride_reason,
    ISNULL(TRY_CONVERT(DECIMAL(5,2), driver_rating), 0) AS driver_rating,   
    ISNULL(TRY_CONVERT(DECIMAL(5,2), customer_rating), 0) AS customer_rating,
    UPPER(TRIM(payment_method)) AS payment_method,
    TRY_CONVERT(DECIMAL(18,2), avg_vtat) AS avg_vtat,   
    TRY_CONVERT(DECIMAL(18,2), avg_ctat) AS avg_ctat,   
    GETDATE() AS dwh_create_date
FROM (
    SELECT * ,
           ROW_NUMBER() OVER (PARTITION BY booking_id ORDER BY booking_datetime_clean DESC) AS rn
    FROM bronze.uber_booking_data
) t
WHERE rn = 1;

