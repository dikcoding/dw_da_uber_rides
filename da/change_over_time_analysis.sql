/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    - To analyze how key Uber metrics evolve over time.
    - To identify trends, growth patterns, and seasonality.
    - To measure performance changes in rides, revenue, and customer engagement.

Uber Business Metrics:
    - Total Revenue
    - Total Rides (Completed Bookings)
    - Average Ride Distance
    - Booking Value Trend

SQL Functions Used:
    - Date Functions: YEAR(), MONTH(), FORMAT()
    - Aggregate Functions: SUM(), COUNT(), AVG()
===============================================================================
*/

-------------------------------------------------------------------------------
-- 1. Change Over Time (Year + Month)
-- Tracking revenue and total rides per month over years
-------------------------------------------------------------------------------
SELECT
    d.year AS order_year,
    d.month AS order_month,
    SUM(r.revenue) AS total_revenue,
    COUNT(b.booking_id) AS total_rides,
    AVG(b.ride_distance) AS avg_distance
FROM dw_uber.gold.fact_revanue r
LEFT JOIN dw_uber.gold.dim_date d
    ON r.date_key = d.date_key
LEFT JOIN dw_uber.gold.fact_booking b
    ON r.booking_id = b.booking_id
WHERE d.year IS NOT NULL AND d.month IS NOT NULL
GROUP BY d.year, d.month
ORDER BY d.year, d.month;


-------------------------------------------------------------------------------
-- 2. Change Over Time using DATETRUNC (Monthly Trend)
-------------------------------------------------------------------------------
SELECT
    FORMAT(d.full_date, 'yyyy-MM') AS order_month,
    SUM(r.revenue) AS total_revenue,
    COUNT(b.booking_id) AS total_rides,
    AVG(b.ride_distance) AS avg_distance
FROM dw_uber.gold.fact_revanue r
LEFT JOIN dw_uber.gold.dim_date d
    ON r.date_key = d.date_key
LEFT JOIN dw_uber.gold.fact_booking b
    ON r.booking_id = b.booking_id
WHERE d.full_date IS NOT NULL
GROUP BY FORMAT(d.full_date, 'yyyy-MM')
ORDER BY FORMAT(d.full_date, 'yyyy-MM');


-------------------------------------------------------------------------------
-- 3. Change Over Time using FORMAT (Yearly Trend)
-------------------------------------------------------------------------------
SELECT
    d.year AS order_year,
    SUM(r.revenue) AS yearly_revenue,
    COUNT(b.booking_id) AS yearly_rides,
    AVG(b.ride_distance) AS avg_distance
FROM dw_uber.gold.fact_revanue r
LEFT JOIN dw_uber.gold.dim_date d
    ON r.date_key = d.date_key
LEFT JOIN dw_uber.gold.fact_booking b
    ON r.booking_id = b.booking_id
WHERE d.year IS NOT NULL
GROUP BY d.year
ORDER BY d.year;
