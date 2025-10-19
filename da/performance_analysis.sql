/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/
WITH yearly_vehicle_revenue AS (
    SELECT
        d.year AS order_year,      
        v.vehicle_type,
        SUM(r.revenue) AS current_revenue
    FROM dw_uber.gold.fact_revanue r
    LEFT JOIN dw_uber.gold.dim_vehicle v
        ON r.vehicle_key = v.vehicle_key
    LEFT JOIN dw_uber.gold.dim_date d
        ON r.date_key = d.date_key
    WHERE d.year IS NOT NULL
    GROUP BY 
        d.year,
        v.vehicle_type
)
SELECT
    order_year,
    vehicle_type,
    current_revenue,
    AVG(current_revenue) OVER (PARTITION BY vehicle_type) AS avg_revenue,
    current_revenue - AVG(current_revenue) OVER (PARTITION BY vehicle_type) AS diff_avg,
    CASE 
        WHEN current_revenue - AVG(current_revenue) OVER (PARTITION BY vehicle_type) > 0 THEN 'Above Avg'
        WHEN current_revenue - AVG(current_revenue) OVER (PARTITION BY vehicle_type) < 0 THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_change,
    LAG(current_revenue) OVER (PARTITION BY vehicle_type ORDER BY order_year) AS py_revenue,
    current_revenue - LAG(current_revenue) OVER (PARTITION BY vehicle_type ORDER BY order_year) AS diff_py,
    CASE 
        WHEN current_revenue - LAG(current_revenue) OVER (PARTITION BY vehicle_type ORDER BY order_year) > 0 THEN 'Increase'
        WHEN current_revenue - LAG(current_revenue) OVER (PARTITION BY vehicle_type ORDER BY order_year) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS py_change
FROM yearly_vehicle_revenue
ORDER BY vehicle_type, order_year;
