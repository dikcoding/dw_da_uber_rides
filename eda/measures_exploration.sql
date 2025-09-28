/*
===============================================================================
Exploratory Data Analysis (EDA) Script: Measures Exploration
===============================================================================
Script Purpose:
    This script explores continuous measures such as ride distance,
    booking value, revenue, and driver rating.

Usage:
    - Run this script to profile numerical measures in Gold Layer.
===============================================================================
*/

-- =============================================================================
-- Explore Gold Fact Booking
-- =============================================================================
SELECT
	MIN(driver_rating) AS lowest_rating,
	MAX(driver_rating) AS highest_rating
FROM dw_uber.gold.fact_booking;

SELECT
	MIN(ride_distance) AS shortest_ride,
	MAX(ride_distance) AS longest_ride
FROM dw_uber.gold.fact_booking;

SELECT
	MIN(booking_value) AS lowest_booking_value,
	MAX(booking_value) AS highest_booking_value
FROM dw_uber.gold.fact_booking;

-- =============================================================================
-- Explore Fact Cancellation
-- =============================================================================
SELECT
	MIN(ride_distance) AS shortest_cancelled_ride,
	MAX(ride_distance) AS longest_cancelled_ride,
	MIN(booking_value) AS lowest_cancelled_value,
	MAX(booking_value) AS highest_cancelled_value
FROM dw_uber.gold.fact_cancellation
WHERE ride_distance IS NOT NULL
      AND booking_value IS NOT NULL;

SELECT 
    cancelled_by,
    COUNT(*) AS total_cancellations
FROM dw_uber.gold.fact_cancellation
GROUP BY cancelled_by
ORDER BY total_cancellations DESC;

-- =============================================================================
-- Explore Ract Revenue
-- =============================================================================
SELECT 
    MIN(revenue) AS lowest_revenue,
    MAX(revenue) AS highest_revenue,
    AVG(revenue) AS avg_revenue,
    SUM(revenue) AS total_revenue
FROM dw_uber.gold.fact_revenue;

SELECT 
    p.payment_method,
    COUNT(*) AS total_transactions,
    SUM(f.revenue) AS total_revenue,
    AVG(f.revenue) AS avg_revenue
FROM dw_uber.gold.fact_revenue f
JOIN dw_uber.gold.dim_payment p 
    ON f.payment_key = p.payment_key
GROUP BY p.payment_method
ORDER BY total_revenue DESC;

SELECT 
    v.vehicle_type,
    COUNT(*) AS total_transactions,
    SUM(f.revenue) AS total_revenue,
    AVG(f.revenue) AS avg_revenue
FROM dw_uber.gold.fact_revenue f
JOIN dw_uber.gold.dim_vehicle v 
    ON f.vehicle_key = v.vehicle_key
GROUP BY v.vehicle_type
ORDER BY total_revenue DESC;

-- =============================================================================
-- Explore Documantasi Measures Exploration Across Fact Tables
-- =============================================================================

-- fact_booking
SELECT 'Min Driver Rating' AS measure_name, MIN(driver_rating) AS measure_value FROM dw_uber.gold.fact_booking
UNION ALL
SELECT 'Max Driver Rating', MAX(driver_rating) FROM dw_uber.gold.fact_booking
UNION ALL
SELECT 'Min Ride Distance', MIN(ride_distance) FROM dw_uber.gold.fact_booking
UNION ALL
SELECT 'Max Ride Distance', MAX(ride_distance) FROM dw_uber.gold.fact_booking
UNION ALL
SELECT 'Min Booking Value', MIN(booking_value) FROM dw_uber.gold.fact_booking
UNION ALL
SELECT 'Max Booking Value', MAX(booking_value) FROM dw_uber.gold.fact_booking

-- fact_cancellation
UNION ALL
SELECT 'Min Cancelled Ride Distance', MIN(ride_distance)
FROM dw_uber.gold.fact_cancellation
WHERE ride_distance IS NOT NULL
UNION ALL
SELECT 'Max Cancelled Ride Distance', MAX(ride_distance)
FROM dw_uber.gold.fact_cancellation
WHERE ride_distance IS NOT NULL
UNION ALL
SELECT 'Min Cancelled Booking Value', MIN(booking_value)
FROM dw_uber.gold.fact_cancellation
WHERE booking_value IS NOT NULL
UNION ALL
SELECT 'Max Cancelled Booking Value', MAX(booking_value)
FROM dw_uber.gold.fact_cancellation
WHERE booking_value IS NOT NULL

-- fact_revenue
UNION ALL
SELECT 'Min Revenue', MIN(revenue)
FROM dw_uber.gold.fact_revenue
UNION ALL
SELECT 'Max Revenue', MAX(revenue)
FROM dw_uber.gold.fact_revenue
UNION ALL
SELECT 'Avg Revenue', AVG(revenue)
FROM dw_uber.gold.fact_revenue
UNION ALL
SELECT 'Total Revenue', SUM(revenue)
FROM dw_uber.gold.fact_revenue;
