/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse.
    The Gold layer represents the final dimension and fact tables (Star Schema).

    Each view performs transformations and combines data from the Silver layer
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_vehicle
-- =============================================================================
IF OBJECT_ID('gold.dim_vehicle', 'V') IS NOT NULL
    DROP VIEW gold.dim_vehicle;
GO

CREATE VIEW gold.dim_vehicle AS
SELECT
    ROW_NUMBER() OVER (ORDER BY vehicle_type) AS vehicle_key, -- Surrogate key
    vehicle_type
FROM (
    SELECT DISTINCT vehicle_type
    FROM silver.uber_booking_clean
    WHERE vehicle_type IS NOT NULL
) v;
GO

-- =============================================================================
-- Create Dimension: gold.dim_location
-- =============================================================================
IF OBJECT_ID('gold.dim_location', 'V') IS NOT NULL
    DROP VIEW gold.dim_location;
GO

CREATE VIEW gold.dim_location AS
SELECT
    ROW_NUMBER() OVER (ORDER BY location_name) AS location_key, -- Surrogate key
    location_name
FROM (
    SELECT DISTINCT pickup_location AS location_name
    FROM silver.uber_booking_clean
    WHERE pickup_location IS NOT NULL
    UNION
    SELECT DISTINCT drop_location
    FROM silver.uber_booking_clean
    WHERE drop_location IS NOT NULL
) l;
GO

-- =============================================================================
-- Create Dimension: gold.dim_date
-- =============================================================================
IF OBJECT_ID('gold.dim_date', 'V') IS NOT NULL
    DROP VIEW gold.dim_date;
GO

CREATE VIEW gold.dim_date AS
SELECT DISTINCT
    CONVERT(INT, FORMAT(booking_datetime, 'yyyyMMdd')) AS date_key,
    CAST(booking_datetime AS DATE) AS full_date,
    DAY(booking_datetime) AS day,
    MONTH(booking_datetime) AS month,
    YEAR(booking_datetime) AS year
FROM silver.uber_booking_clean
WHERE booking_datetime IS NOT NULL;
GO

-- =============================================================================
-- Create Dimension: gold.dim_payment
-- =============================================================================
IF OBJECT_ID('gold.dim_payment', 'V') IS NOT NULL
    DROP VIEW gold.dim_payment;
GO

CREATE VIEW gold.dim_payment AS
SELECT
    ROW_NUMBER() OVER (ORDER BY payment_method) AS payment_key, -- Surrogate key
    ISNULL(payment_method, 'Unknown') AS payment_method
FROM (
    SELECT DISTINCT ISNULL(payment_method, 'Unknown') AS payment_method
    FROM silver.uber_booking_clean
) p;
GO

-- =============================================================================
-- Create Dimension: gold.dim_cancellation_reason
-- =============================================================================
IF OBJECT_ID('gold.dim_cancellation_reason', 'V') IS NOT NULL
    DROP VIEW gold.dim_cancellation_reason;
GO

CREATE VIEW gold.dim_cancellation_reason AS
SELECT
    ROW_NUMBER() OVER (ORDER BY cancellation_reason) AS cancel_key,
    cancellation_reason
FROM (
    SELECT DISTINCT ISNULL(cancellation_reason_customer, 'Unknown') AS cancellation_reason
    FROM silver.uber_booking_clean
    WHERE cancellation_reason_customer IS NOT NULL
    UNION
    SELECT DISTINCT ISNULL(cancellation_reason_driver, 'Unknown')
    FROM silver.uber_booking_clean
    WHERE cancellation_reason_driver IS NOT NULL
) r;
GO

-- =============================================================================
-- Create Fact: gold.fact_booking
-- =============================================================================
IF OBJECT_ID('gold.fact_booking', 'V') IS NOT NULL
    DROP VIEW gold.fact_booking;
GO

CREATE VIEW gold.fact_booking AS
SELECT
    b.booking_id,
    CONVERT(INT, FORMAT(b.booking_datetime, 'yyyyMMdd')) AS date_key,
    v.vehicle_key,
    pl.location_key AS pickup_location_key,
    dl.location_key AS drop_location_key,
    p.payment_key,
    b.booking_status,
    b.ride_distance,
    b.booking_value,
    b.driver_rating
FROM silver.uber_booking_clean b
LEFT JOIN gold.dim_vehicle v ON b.vehicle_type = v.vehicle_type
LEFT JOIN gold.dim_location pl ON b.pickup_location = pl.location_name
LEFT JOIN gold.dim_location dl ON b.drop_location = dl.location_name
LEFT JOIN gold.dim_payment p ON b.payment_method = p.payment_method;
GO

-- =============================================================================
-- Create Fact: gold.fact_cancellation
-- =============================================================================
IF OBJECT_ID('gold.fact_cancellation', 'V') IS NOT NULL
    DROP VIEW gold.fact_cancellation;
GO

CREATE VIEW gold.fact_cancellation AS
SELECT
    b.booking_id,
    CONVERT(INT, FORMAT(b.booking_datetime, 'yyyyMMdd')) AS date_key,
    CASE 
        WHEN b.cancelled_by_customer = 1 THEN 'Customer'
        WHEN b.cancelled_by_driver = 1 THEN 'Driver'
    END AS cancelled_by,
    r.cancel_key
FROM silver.uber_booking_clean b
LEFT JOIN gold.dim_cancellation_reason r 
       ON COALESCE(b.cancellation_reason_customer, b.cancellation_reason_driver) = r.cancellation_reason
WHERE b.booking_status = 'Cancelled';
GO

-- =============================================================================
-- Create Fact: gold.fact_revenue
-- =============================================================================
IF OBJECT_ID('gold.fact_revenue', 'V') IS NOT NULL
    DROP VIEW gold.fact_revenue;
GO

CREATE VIEW gold.fact_revenue AS
SELECT
    b.booking_id,
    CONVERT(INT, FORMAT(b.booking_datetime, 'yyyyMMddHH')) AS date_key,
    v.vehicle_key,
    p.payment_key,
    b.booking_value AS revenue
FROM silver.uber_booking_clean b
LEFT JOIN gold.dim_vehicle v ON b.vehicle_type = v.vehicle_type
LEFT JOIN gold.dim_payment p ON b.payment_method = p.payment_method
WHERE b.booking_status = 'Completed' 
  AND b.booking_value IS NOT NULL;
GO

-- =============================================================================
-- Create Report: gold.report_success_rate
-- =============================================================================
IF OBJECT_ID('gold.report_success_rate', 'V') IS NOT NULL
    DROP VIEW gold.report_success_rate;
GO

CREATE VIEW gold.report_success_rate AS
SELECT
    fb.date_key,
    COUNT(*) AS total_booking,
    SUM(CASE WHEN fb.booking_status = 'Completed' THEN 1 ELSE 0 END) AS completed_booking,
    SUM(CASE WHEN fb.booking_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_booking,
    CAST(SUM(CASE WHEN fb.booking_status = 'Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS FLOAT) AS success_rate
FROM gold.fact_booking fb
GROUP BY fb.date_key;
GO

-- =============================================================================
-- Create Report: gold.report_revenue_distribution
-- =============================================================================
IF OBJECT_ID('gold.report_revenue_distribution', 'V') IS NOT NULL
    DROP VIEW gold.report_revenue_distribution;
GO

CREATE VIEW gold.report_revenue_distribution AS
SELECT
    fr.date_key,
    fr.vehicle_key,
    fr.payment_key,
    SUM(fr.revenue) AS total_revenue,
    COUNT(*) AS ride_count
FROM gold.fact_revenue fr
GROUP BY fr.date_key, fr.vehicle_key, fr.payment_key;
GO

-- =============================================================================
-- Create Report: gold.report_cancellation_reason
-- =============================================================================
IF OBJECT_ID('gold.report_cancellation_reason', 'V') IS NOT NULL
    DROP VIEW gold.report_cancellation_reason;
GO

CREATE VIEW gold.report_cancellation_reason AS
SELECT
    fc.date_key,
    fc.cancelled_by,
    r.cancellation_reason,
    COUNT(*) AS cancel_count
FROM gold.fact_cancellation fc
LEFT JOIN gold.dim_cancellation_reason r ON fc.cancel_key = r.cancel_key
GROUP BY fc.date_key, fc.cancelled_by, r.cancellation_reason;
GO
