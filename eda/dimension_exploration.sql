/*
===============================================================================
Exploratory Data Analysis (EDA) Script: Dimension Exploration
===============================================================================
Script Purpose:
    This script explores the categorical dimensions in the Uber Gold Layer.
    The focus is on unique values, distributions, and data quality.

    Dimensions explored:
    - Vehicle
    - Location
    - Payment
    - Cancellation Reason

Usage:
    - Run this script after populating Gold Dimension tables.
===============================================================================
*/

-- =============================================================================
-- Explore Dimension: gold.dim_vehicle
-- =============================================================================
SELECT COUNT(*) AS total_vehicle_types,
       COUNT(DISTINCT vehicle_type) AS unique_vehicle_types
FROM gold.dim_vehicle;

SELECT TOP 10 vehicle_type
FROM gold.dim_vehicle
ORDER BY vehicle_type;

-- =============================================================================
-- Explore Dimension: gold.dim_location
-- =============================================================================
SELECT COUNT(*) AS total_locations,
       COUNT(DISTINCT location_name) AS unique_locations
FROM gold.dim_location;

SELECT TOP 10 location_name
FROM gold.dim_location
ORDER BY location_name;

-- =============================================================================
-- Explore Dimension: gold.dim_payment
-- =============================================================================
SELECT COUNT(*) AS total_payment_methods,
       COUNT(DISTINCT payment_method) AS unique_payment_methods
FROM gold.dim_payment;

SELECT payment_method, COUNT(*) AS usage_count
FROM gold.fact_booking fb
JOIN gold.dim_payment dp ON fb.payment_key = dp.payment_key
GROUP BY payment_method
ORDER BY usage_count DESC;

-- =============================================================================
-- Explore Dimension: gold.dim_cancellation_reason
-- =============================================================================
SELECT COUNT(*) AS total_cancellation_reasons,
       COUNT(DISTINCT cancellation_reason) AS unique_cancellation_reasons
FROM gold.dim_cancellation_reason;

SELECT TOP 10 cancellation_reason
FROM gold.dim_cancellation_reason
ORDER BY cancellation_reason;
