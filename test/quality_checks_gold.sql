/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency, 
    and accuracy of the Gold Layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Usage Notes:
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'gold.dim_vehicle'
-- ====================================================================
-- Expectation: No duplicate vehicle_key
SELECT 
    vehicle_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_vehicle
GROUP BY vehicle_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'gold.dim_location'
-- ====================================================================
-- Expectation: No duplicate location_key
SELECT 
    location_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_location
GROUP BY location_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'gold.dim_date'
-- ====================================================================
-- Expectation: No duplicate date_key
SELECT 
    date_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_date
GROUP BY date_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'gold.dim_payment'
-- ====================================================================
-- Expectation: No duplicate payment_key
SELECT 
    payment_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_payment
GROUP BY payment_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'gold.dim_cancellation_reason'
-- ====================================================================
-- Expectation: No duplicate cancel_key
SELECT 
    cancel_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_cancellation_reason
GROUP BY cancel_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking Referential Integrity in 'gold.fact_booking'
-- ====================================================================
-- Expectation: All foreign keys should map to existing dimension records
SELECT fb.*
FROM gold.fact_booking fb
LEFT JOIN gold.dim_date d ON fb.date_key = d.date_key
LEFT JOIN gold.dim_vehicle v ON fb.vehicle_key = v.vehicle_key
LEFT JOIN gold.dim_location pl ON fb.pickup_location_key = pl.location_key
LEFT JOIN gold.dim_location dl ON fb.drop_location_key = dl.location_key
LEFT JOIN gold.dim_payment p ON fb.payment_key = p.payment_key
WHERE d.date_key IS NULL
   OR v.vehicle_key IS NULL
   OR pl.location_key IS NULL
   OR dl.location_key IS NULL
   OR p.payment_key IS NULL;

-- ====================================================================
-- Checking Referential Integrity in 'gold.fact_cancellation'
-- ====================================================================
-- Expectation: All cancel_key and date_key exist in dimensions
SELECT fc.*
FROM gold.fact_cancellation fc
LEFT JOIN gold.dim_date d ON fc.date_key = d.date_key
LEFT JOIN gold.dim_cancellation_reason r ON fc.cancel_key = r.cancel_key
WHERE d.date_key IS NULL OR r.cancel_key IS NULL;

-- ====================================================================
-- Checking Referential Integrity in 'gold.fact_revenue'
-- ====================================================================
-- Expectation: All foreign keys should map to existing dimension records
SELECT fr.*
FROM gold.fact_revenue fr
LEFT JOIN gold.dim_date d ON fr.date_key = d.date_key
LEFT JOIN gold.dim_vehicle v ON fr.vehicle_key = v.vehicle_key
LEFT JOIN gold.dim_payment p ON fr.payment_key = p.payment_key
WHERE d.date_key IS NULL
   OR v.vehicle_key IS NULL
   OR p.payment_key IS NULL;

-- ====================================================================
-- Sanity Checks for Reports
-- ====================================================================
-- 1. Success rate should be between 0 and 100
SELECT *
FROM gold.report_success_rate
WHERE success_rate < 0 OR success_rate > 100;

-- 2. Revenue should never be negative
SELECT *
FROM gold.report_revenue_distribution
WHERE total_revenue < 0;

-- 3. Cancellation counts should not be negative (sanity check)
SELECT *
FROM gold.report_cancellation_reason
WHERE cancel_count < 0;
