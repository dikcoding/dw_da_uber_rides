/*
===============================================================================
Exploratory Data Analysis (EDA) Script: Ranking Analysis
===============================================================================
Script Purpose:
    This script ranks dimension values based on aggregated measures
    to identify top/bottom performers. Examples include:
    - Top 5 vehicles by revenue
    - Bottom 3 customers by bookings
    - Most frequent cancellation reasons

    Ranking is implemented using ORDER BY, TOP, and Window Functions.

Usage:
    - Run this script to quickly identify best/worst performing categories.
===============================================================================
*/

-- =============================================================================
-- Top 5 Vehicle Types by Total Revenue
-- =============================================================================
SELECT TOP 5 v.vehicle_type,
       SUM(fr.revenue) AS total_revenue
FROM gold.fact_revenue fr
JOIN gold.dim_vehicle v ON fr.vehicle_key = v.vehicle_key
GROUP BY v.vehicle_type
ORDER BY total_revenue DESC;

-- =============================================================================
-- Top 5 Locations by Booking Count
-- =============================================================================
SELECT TOP 5 pl.location_name AS pickup_location,
       COUNT(fb.booking_id) AS booking_count
FROM gold.fact_booking fb
JOIN gold.dim_location pl ON fb.pickup_location_key = pl.location_key
GROUP BY pl.location_name
ORDER BY booking_count DESC;

-- =============================================================================
-- Worst 3 Cancellation Reasons (Most Frequent)
-- =============================================================================
SELECT TOP 3 r.cancellation_reason,
       COUNT(*) AS cancel_count
FROM gold.fact_cancellation fc
JOIN gold.dim_cancellation_reason r ON fc.cancel_key = r.cancel_key
GROUP BY r.cancellation_reason
ORDER BY cancel_count DESC;

-- =============================================================================
-- Rank Payment Methods by Revenue using Window Function
-- =============================================================================
SELECT dp.payment_method,
       SUM(fr.revenue) AS total_revenue,
       RANK() OVER (ORDER BY SUM(fr.revenue) DESC) AS revenue_rank
FROM gold.fact_revenue fr
JOIN gold.dim_payment dp ON fr.payment_key = dp.payment_key
GROUP BY dp.payment_method;
