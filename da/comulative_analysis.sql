/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate cumulative revenue over time (running total).
    - To measure progressive business growth rather than isolated performance.
    - Helps understand overall trend and momentum of Uber rides.

Business Relevance for Uber:
    - Track total revenue accumulation month-by-month or year-by-year.
    - Identify growth trend of each vehicle type.
    - Detect stagnation or decline early by visualizing progressive values.

SQL Functions Used:
    - SUM() OVER (ORDER BY ...)
    - PARTITION BY for segmentation per vehicle type
===============================================================================
*/

-- Calculate monthly revenue per vehicle type
-- and cumulative (running total) revenue over time
SELECT
    order_year,
    order_month,
    vehicle_type,
    current_revenue,
    SUM(current_revenue) OVER (
        PARTITION BY vehicle_type
        ORDER BY order_year, order_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_revenue
FROM
(
    SELECT 
        d.year AS order_year,
        d.month AS order_month,
        v.vehicle_type,
        SUM(r.revenue) AS current_revenue
    FROM dw_uber.gold.fact_revanue r
    LEFT JOIN dw_uber.gold.dim_vehicle v
        ON r.vehicle_key = v.vehicle_key
    LEFT JOIN dw_uber.gold.dim_date d
        ON r.date_key = d.date_key
    WHERE d.year IS NOT NULL AND d.month IS NOT NULL
    GROUP BY
        d.year,
        d.month,
        v.vehicle_type
) t
ORDER BY vehicle_type, order_year, order_month;
