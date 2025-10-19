/*
===============================================================================
Uber Analytics Project – Data Segmentation
===============================================================================
Purpose:
    - To segment Uber bookings based on booking value and vehicle type.
    - Helps identify low, medium, and high-value trip categories.
    - Useful for pricing strategy, customer targeting, and revenue optimization.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into meaningful segments.
===============================================================================
*/

-- Segment Uber trips based on booking value
WITH booking_segments AS (
    SELECT
        b.booking_id,
        v.vehicle_type,
        b.booking_value,
        CASE 
            WHEN b.booking_value < 50000 THEN 'Low Value Ride'
            WHEN b.booking_value BETWEEN 50000 AND 150000 THEN 'Medium Value Ride'
            WHEN b.booking_value BETWEEN 150000 AND 300000 THEN 'High Value Ride'
            ELSE 'Premium Ride'
        END AS booking_value_segment
    FROM [dw_uber].[gold].[fact_booking] b
    LEFT JOIN [dw_uber].[gold].[dim_vehicle] v
        ON v.vehicle_key = b.vehicle_key
)
SELECT 
    booking_value_segment,
    vehicle_type,
    COUNT(booking_id) AS total_bookings,
    ROUND(AVG(booking_value), 2) AS avg_booking_value
FROM booking_segments
GROUP BY booking_value_segment, vehicle_type
ORDER BY avg_booking_value DESC;
