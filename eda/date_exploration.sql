/*
===============================================================================
Exploratory Data Analysis (EDA) Script: Date Exploration
===============================================================================
Script Purpose:
    This script explores the Date Dimension in the Uber Gold Layer.
    It is useful for understanding coverage, gaps, and data seasonality.

Usage:
    - Run this script after populating gold.dim_date.
===============================================================================
*/

-- =============================================================================
-- Explore date coverage
-- =============================================================================
SELECT MIN(full_date) AS start_date,
       MAX(full_date) AS end_date,
       COUNT(*) AS total_days
FROM gold.dim_date;

-- =============================================================================
-- Displays the earliest and latest booking dates.
-- =============================================================================
SELECT
	MIN(d.full_date) AS first_booking_date,
	MAX(d.full_date) AS last_booking_date,
	DATEDIFF(MONTH, MIN(d.full_date), MAX(d.full_date)) AS booking_month_range,
	DATEDIFF(DAY, MIN(d.full_date), MAX(d.full_date)) AS booking_day_range
FROM dw_uber.gold.fact_booking f
JOIN dw_uber.gold.dim_date d
	ON f.date_key = d.date_key;

-- =============================================================================
-- Displays the earliest and latest cancellation dates.
-- =============================================================================
SELECT
	MIN(d.full_date) AS first_cancellation_date,
	MAX(d.full_date) AS last_cancellation_date,
	DATEDIFF(MONTH, MIN(d.full_date), MAX(d.full_date)) AS cancellation_month_range,
	DATEDIFF(DAY, MIN(d.full_date), MAX(d.full_date)) AS cancellation_day_range
FROM dw_uber.gold.fact_cancellation f
JOIN dw_uber.gold.dim_date d
	ON f.date_key = d.date_key;

-- =============================================================================
-- Displays the earliest and latest revenue dates.
-- =============================================================================
SELECT
	MIN(d.full_date) AS first_revenue_date,
	MAX(d.full_date) AS last_revenue_date,
	DATEDIFF(MONTH, MIN(d.full_date), MAX(d.full_date)) AS revenue_month_range,
	DATEDIFF(DAY, MIN(d.full_date), MAX(d.full_date)) AS revenue_day_range
FROM dw_uber.gold.fact_revenue f
JOIN dw_uber.gold.dim_date d
    ON f.date_key = d.date_key;
