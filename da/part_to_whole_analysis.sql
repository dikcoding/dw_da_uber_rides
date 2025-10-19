/*
===============================================================================
Uber Analytics Project – Part-to-Whole Analysis
===============================================================================
Purpose:
    - To analyze which vehicle type contributes the most to Uber's total revenue.
    - Helps identify the most profitable service types (e.g., UberX, UberBlack).
    - Useful for pricing, marketing, and fleet optimization strategies.

SQL Functions Used:
    - SUM(): Aggregates revenue for each vehicle type.
    - Window Functions: SUM() OVER() to calculate total revenue for percentage.
===============================================================================
*/

-- Which vehicle types contribute the most to Uber's total revenue?
WITH vehicle_revenue AS (
    SELECT
        v.vehicle_type,
        SUM(r.revenue) AS total_revenue
    FROM [dw_uber].[gold].[fact_revanue] r
    LEFT JOIN [dw_uber].[gold].[dim_vehicle] v
        ON v.vehicle_key = r.vehicle_key
    GROUP BY v.vehicle_type
)
SELECT
    vehicle_type,
    total_revenue,
    SUM(total_revenue) OVER () AS overall_revenue,
    ROUND((CAST(total_revenue AS FLOAT) / SUM(total_revenue) OVER ()) * 100, 2) AS percentage_of_total
FROM vehicle_revenue
ORDER BY total_revenue DESC;
