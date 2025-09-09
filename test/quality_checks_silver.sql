/*=================================================================================
  File   : quality_check_silver.sql
  Purpose: Validate Data Quality in Silver Layer
==================================================================================*/

-- 1. Check for Unwanted Spaces
-- ===============================================================================

SELECT COUNT(*) AS invalid_spaces_booking_status
FROM silver.uber_booking_clean
WHERE booking_status != TRIM(booking_status);

SELECT COUNT(*) AS invalid_spaces_vehicle_type
FROM silver.uber_booking_clean
WHERE vehicle_type != TRIM(vehicle_type);

SELECT COUNT(*) AS invalid_spaces_payment_method
FROM silver.uber_booking_clean
WHERE payment_method != TRIM(payment_method);


-- 2. Check Booking Status Consistency
-- ===============================================================================

SELECT DISTINCT booking_status
FROM silver.uber_booking_clean
ORDER BY booking_status;


-- 3. Check Vehicle Type Consistency
-- ===============================================================================

SELECT DISTINCT vehicle_type
FROM silver.uber_booking_clean
ORDER BY vehicle_type;


-- 4. Check Payment Method Consistency
-- ===============================================================================

SELECT DISTINCT payment_method
FROM silver.uber_booking_clean
ORDER BY payment_method;


-- 5. Check Datetime Range
-- ===============================================================================

SELECT 
    MIN(booking_datetime) AS earliest_booking,
    MAX(booking_datetime) AS latest_booking
FROM silver.uber_booking_clean;


-- 6. Check for Negative or NULL values in numeric columns
-- ===============================================================================

SELECT COUNT(*) AS invalid_booking_value
FROM silver.uber_booking_clean
WHERE booking_value < 0 OR booking_value IS NULL;

SELECT COUNT(*) AS invalid_ride_distance
FROM silver.uber_booking_clean
WHERE ride_distance < 0 OR ride_distance IS NULL;

SELECT COUNT(*) AS invalid_avg_vtat
FROM silver.uber_booking_clean
WHERE avg_vtat < 0 OR avg_vtat IS NULL;

SELECT COUNT(*) AS invalid_avg_ctat
FROM silver.uber_booking_clean
WHERE avg_ctat < 0 OR avg_ctat IS NULL;

