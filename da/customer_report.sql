/*
===============================================================================
Uber Customer Report
===============================================================================
Purpose:
    - Menggabungkan berbagai metrik utama pelanggan dari data Uber

Highlights:
    1. Mengambil data booking, revenue, payment, vehicle, dan cancellation.
    2. Menghitung total booking, total revenue, jarak rata-rata, dan transaksi.
    3. Membuat segmentasi pelanggan berdasarkan total spending & frekuensi.
    4. Menghitung recency dan lifespan aktivitas pelanggan.
===============================================================================
*/

-- =============================================================================
-- Create Report: gold.report_customer_uber
-- =============================================================================
IF OBJECT_ID('gold.report_customer_uber', 'V') IS NOT NULL
    DROP VIEW gold.report_customer_uber;
GO

CREATE VIEW gold.report_customer_uber AS

WITH base_data AS (
/*---------------------------------------------------------------------------
1) Base Query: Gabungkan tabel utama fact_booking dengan dimensi terkait
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
    b.drop_location_key,
    dl.location_name AS drop_location,
    b.booking_status,
    b.ride_distance,
    b.booking_value,
    b.driver_rating,
    r.revenue,
    c.cancel_key,
    cr.cancellation_reason,
    c.cancelled_by
FROM dw_uber.gold.fact_booking b
LEFT JOIN dw_uber.gold.dim_date d ON b.date_key = d.date_key
LEFT JOIN dw_uber.gold.dim_vehicle v ON b.vehicle_key = v.vehicle_key
LEFT JOIN dw_uber.gold.dim_payment p ON b.payment_key = p.payment_key
LEFT JOIN dw_uber.gold.dim_location pl ON b.pickup_location_key = pl.location_key
LEFT JOIN dw_uber.gold.dim_location dl ON b.drop_location_key = dl.location_key
LEFT JOIN dw_uber.gold.fact_revanue r ON b.booking_id = r.booking_id
LEFT JOIN dw_uber.gold.fact_cancellation c ON b.booking_id = c.booking_id
LEFT JOIN dw_uber.gold.dim_cancellation_reason cr ON c.cancel_key = cr.cancel_key
WHERE b.booking_id IS NOT NULL
)

, customer_summary AS (
/*---------------------------------------------------------------------------
2) Customer Aggregations: Hitung metrik utama per pelanggan (berdasarkan lokasi pickup)
---------------------------------------------------------------------------*/
SELECT 
    pickup_location AS customer_identifier,
    COUNT(DISTINCT booking_id) AS total_bookings,
    SUM(booking_value) AS total_booking_value,
    SUM(ISNULL(revenue, 0)) AS total_revenue,
    AVG(ride_distance) AS avg_ride_distance,
    AVG(driver_rating) AS avg_driver_rating,
    COUNT(DISTINCT vehicle_type) AS total_vehicle_types,
    COUNT(DISTINCT payment_method) AS total_payment_methods,
    MAX(full_date) AS last_booking_date,
    MIN(full_date) AS first_booking_date,
    DATEDIFF(month, MIN(full_date), MAX(full_date)) AS lifespan_months
FROM base_data
GROUP BY pickup_location
)

SELECT
    customer_identifier,
    total_bookings,
    total_booking_value,
    total_revenue,
    avg_ride_distance,
    avg_driver_rating,
    total_vehicle_types,
    total_payment_methods,
    lifespan_months,
    last_booking_date,
    DATEDIFF(month, last_booking_date, GETDATE()) AS recency_months,

    -- Segmentasi pelanggan berdasarkan spending & lama aktif
    CASE 
        WHEN total_revenue > 10000 AND lifespan_months >= 12 THEN 'VIP Customer'
        WHEN total_revenue BETWEEN 5000 AND 10000 THEN 'Loyal Customer'
        WHEN total_revenue < 5000 AND total_bookings > 3 THEN 'Regular Customer'
        ELSE 'New / Inactive Customer'
    END AS customer_segment,

    -- KPI tambahan
    CASE WHEN total_bookings = 0 THEN 0
         ELSE total_revenue / total_bookings
    END AS avg_revenue_per_booking,

    CASE WHEN lifespan_months = 0 THEN total_revenue
         ELSE total_revenue / lifespan_months
    END AS avg_monthly_revenue

FROM customer_summary;
