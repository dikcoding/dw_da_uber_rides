/*
===============================================================================
Vehicle Report (Uber Analytics)
===============================================================================
Purpose:
    - This report consolidates key vehicle performance metrics and usage behaviors.

Highlights:
    1. Gathers essential fields such as vehicle type, payment method, and booking value.
    2. Segments vehicles by total revenue to identify High-, Mid-, or Low-Performers.
    3. Aggregates vehicle-level metrics:
       - total bookings
       - total revenue
       - total distance
       - total customers (unique pickup locations)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last ride)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/

-- =============================================================================
-- Create Report: gold.report_vehicle_performance
-- =============================================================================
IF OBJECT_ID('gold.report_vehicle_performance', 'V') IS NOT NULL
    DROP VIEW gold.report_vehicle_performance;
GO

CREATE VIEW gold.report_vehicle_performance AS

WITH base_query AS (
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from fact_booking, fact_revenue & dim_vehicle
---------------------------------------------------------------------------*/
    SELECT
        b.booking_id,
        b.date_key,
        d.full_date,
        b.vehicle_key,
        v.vehicle_type,
        b.payment_key,
        p.payment_method,
        b.pickup_location_key,
        pl.location_name AS pickup_location,
        b.booking_value,
        b.ride_distance,
        b.driver_rating,
        r.revenue
    FROM dw_uber.gold.fact_booking b
    LEFT JOIN dw_uber.gold.dim_vehicle v 
        ON b.vehicle_key = v.vehicle_key
    LEFT JOIN dw_uber.gold.dim_payment p 
        ON b.payment_key = p.payment_key
    LEFT JOIN dw_uber.gold.dim_location pl 
        ON b.pickup_location_key = pl.location_key
    LEFT JOIN dw_uber.gold.dim_date d 
        ON b.date_key = d.date_key
    LEFT JOIN dw_uber.gold.fact_revanue r 
        ON b.booking_id = r.booking_id
    WHERE b.booking_status IS NOT NULL
),

vehicle_aggregations AS (
/*---------------------------------------------------------------------------
2) Vehicle Aggregations: Summarizes key metrics at the vehicle type level
---------------------------------------------------------------------------*/
    SELECT
        vehicle_key,
        vehicle_type,
        COUNT(DISTINCT booking_id) AS total_bookings,
        COUNT(DISTINCT pickup_location) AS total_customers,
        SUM(ISNULL(revenue, 0)) AS total_revenue,
        SUM(ISNULL(booking_value, 0)) AS total_booking_value,
        SUM(ISNULL(ride_distance, 0)) AS total_distance,
        AVG(driver_rating) AS avg_driver_rating,
        MAX(full_date) AS last_ride_date,
        MIN(full_date) AS first_ride_date,
        DATEDIFF(MONTH, MIN(full_date), MAX(full_date)) AS lifespan_months
    FROM base_query
    GROUP BY vehicle_key, vehicle_type
)

/*---------------------------------------------------------------------------
3) Final Query: Combines all results into one output
---------------------------------------------------------------------------*/
SELECT
    vehicle_key,
    vehicle_type,
    last_ride_date,
    DATEDIFF(MONTH, last_ride_date, GETDATE()) AS recency_in_months,
    lifespan_months,
    total_bookings,
    total_customers,
    total_distance,
    total_revenue,
    total_booking_value,
    avg_driver_rating,

    -- Vehicle Segment
    CASE
        WHEN total_revenue > 100000 THEN 'High-Performer'
        WHEN total_revenue BETWEEN 30000 AND 100000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS vehicle_segment,

    -- Average Order Revenue (AOR)
    CASE
        WHEN total_bookings = 0 THEN 0
        ELSE total_revenue / total_bookings
    END AS avg_order_revenue,

    -- Average Monthly Revenue
    CASE
        WHEN lifespan_months = 0 THEN total_revenue
        ELSE total_revenue / lifespan_months
    END AS avg_monthly_revenue

FROM vehicle_aggregations;
