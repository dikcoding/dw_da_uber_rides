/*
===============================================================================
Exploratory Data Analysis (EDA) Script: Magnitude Analysis
===============================================================================
Script Purpose:
    This script explores magnitude of measures grouped by dimensions.
    Examples include total booking value per vehicle, revenue per payment type,
    and cancellations by reason.

Usage:
    - Run this script to get aggregated measure values by category.
===============================================================================
*/

-- =============================================================================
-- Total booking value by Vehicle Type
-- =============================================================================
SELECT v.vehicle_type, COUNT(*) AS total_bookings
FROM gold.fact_booking b
JOIN gold.dim_vehicle v ON b.vehicle_key = v.vehicle_key
GROUP BY v.vehicle_type;

-- =============================================================================
-- Total revenue by Payment Method
-- =============================================================================
SELECT p.payment_method, COUNT(*) AS total_bookings
FROM gold.fact_booking b
JOIN gold.dim_payment p ON b.payment_key = p.payment_key
GROUP BY p.payment_method;

-- =============================================================================
-- Average trip distance (ride_distance) per vehicle type
-- =============================================================================
SELECT v.vehicle_type, AVG(b.ride_distance) AS avg_distance
FROM gold.fact_booking b
JOIN gold.dim_vehicle v ON b.vehicle_key = v.vehicle_key
WHERE b.ride_distance IS NOT NULL
GROUP BY v.vehicle_type;

-- =============================================================================
-- Total revenue per payment method
-- =============================================================================
SELECT p.payment_method, SUM(r.revenue) AS total_revenue
FROM gold.fact_revenue r
JOIN gold.dim_payment p ON r.payment_key = p.payment_key
GROUP BY p.payment_method;

-- =============================================================================
-- Average revenue per vehicle type
-- =============================================================================
SELECT v.vehicle_type, AVG(r.revenue) AS avg_revenue
FROM gold.fact_revenue r
JOIN gold.dim_vehicle v ON r.vehicle_key = v.vehicle_key
GROUP BY v.vehicle_type;

-- =============================================================================
-- Number of cancellations per reason
-- =============================================================================
SELECT c.cancellation_reason, COUNT(*) AS total_cancellations
FROM gold.fact_cancellation f
JOIN gold.dim_cancellation_reason c ON f.cancel_key = c.cancel_key
GROUP BY c.cancellation_reason;

-- =============================================================================
-- Who cancels most often (driver vs customer vs unknown)
-- =============================================================================
SELECT f.cancelled_by, COUNT(*) AS total_cancellations
FROM gold.fact_cancellation f
GROUP BY f.cancelled_by;

-- =============================================================================
-- Booking & revenue per month
-- =============================================================================
SELECT d.year, d.month, COUNT(b.booking_id) AS total_bookings, SUM(r.revenue) AS total_revenue
FROM gold.fact_booking b
JOIN gold.dim_date d ON b.date_key = d.date_key
JOIN gold.fact_revenue r ON b.booking_id = r.booking_id
GROUP BY d.year, d.month
ORDER BY d.year, d.month;
