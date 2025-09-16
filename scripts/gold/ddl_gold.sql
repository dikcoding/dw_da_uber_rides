/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse.
    The Gold layer represents the final dimension and fact tables (Star Schema).

    Each view performs transformations and combines data from the Silver layer
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_vehicle
-- =============================================================================
IF OBJECT_ID('gold.dim_vehicle', 'V') IS NOT NULL
    DROP VIEW gold.dim_vehicle;
GO

CREATE TABLE gold.dim_vehicle (
    vehicle_key INT IDENTITY(1,1) PRIMARY KEY,
    vehicle_type NVARCHAR(50)
);

INSERT INTO gold.dim_vehicle (vehicle_type)
SELECT DISTINCT vehicle_type
FROM silver.uber_booking_clean
WHERE vehicle_type IS NOT NULL;
GO

-- =============================================================================
-- Create Dimension: gold.dim_location
-- =============================================================================
IF OBJECT_ID('gold.dim_location', 'V') IS NOT NULL
    DROP VIEW gold.dim_location;
GO

CREATE TABLE gold.dim_location (
    location_key INT IDENTITY(1,1) PRIMARY KEY,
    location_name NVARCHAR(100)
);

INSERT INTO gold.dim_location (location_name)
SELECT DISTINCT pickup_location
FROM silver.uber_booking_clean
WHERE pickup_location IS NOT NULL

UNION

SELECT DISTINCT drop_location
FROM silver.uber_booking_clean
WHERE drop_location IS NOT NULL;

GO

-- =============================================================================
-- Create Dimension: gold.dim_date
-- =============================================================================
IF OBJECT_ID('gold.dim_date', 'V') IS NOT NULL
    DROP VIEW gold.dim_date;
GO

CREATE TABLE gold.dim_date (
    date_key INT PRIMARY KEY, 
    full_date DATE,
    day INT,
    month INT,
    year INT
);

INSERT INTO gold.dim_date (date_key, full_date, day, month, year)
SELECT DISTINCT 
    CONVERT(INT, FORMAT(booking_datetime, 'yyyyMMdd')) AS date_key,
    CAST(booking_datetime AS DATE) AS full_date,
    DAY(booking_datetime),
    MONTH(booking_datetime),
    YEAR(booking_datetime)
FROM silver.uber_booking_clean
WHERE booking_datetime IS NOT NULL;

-- =============================================================================
-- Create Dimension: gold.dim_payment
-- =============================================================================
IF OBJECT_ID('gold.dim_payment', 'V') IS NOT NULL
    DROP VIEW gold.dim_payment;
GO

CREATE TABLE gold.dim_payment (
    payment_key INT IDENTITY(1,1) PRIMARY KEY,
    payment_method NVARCHAR(50)
);

INSERT INTO gold.dim_payment (payment_method)
SELECT DISTINCT ISNULL(payment_method, 'Unknown')
FROM silver.uber_booking_clean;
GO

-- =============================================================================
-- Create Dimension: gold.dim_cancellation_reason
-- =============================================================================
IF OBJECT_ID('gold.dim_cancellation_reason', 'V') IS NOT NULL
    DROP VIEW gold.dim_cancellation_reason;
GO

CREATE TABLE gold.dim_cancellation_reason (
    cancel_key INT IDENTITY(1,1) PRIMARY KEY,
    cancellation_reason NVARCHAR(255)
);

INSERT INTO gold.dim_cancellation_reason (cancellation_reason)
SELECT DISTINCT ISNULL(cancellation_reason_customer, 'Unknown')
FROM silver.uber_booking_clean
WHERE cancellation_reason_customer IS NOT NULL

UNION

SELECT DISTINCT ISNULL(cancellation_reason_driver, 'Unknown')
FROM silver.uber_booking_clean
WHERE cancellation_reason_driver IS NOT NULL;
GO

-- =============================================================================
-- Create Fact: gold.fact_booking
-- =============================================================================
IF OBJECT_ID('gold.fact_booking', 'V') IS NOT NULL
    DROP VIEW gold.fact_booking;
GO

CREATE TABLE gold.fact_booking (
    booking_id NVARCHAR(50) PRIMARY KEY,  
    date_key INT FOREIGN KEY REFERENCES gold.dim_date(date_key),
    vehicle_key INT FOREIGN KEY REFERENCES gold.dim_vehicle(vehicle_key),
    pickup_location_key INT FOREIGN KEY REFERENCES gold.dim_location(location_key),
    drop_location_key INT FOREIGN KEY REFERENCES gold.dim_location(location_key),
    payment_key INT FOREIGN KEY REFERENCES gold.dim_payment(payment_key),
    booking_status NVARCHAR(50),
    ride_distance FLOAT,
    booking_value FLOAT,
    driver_rating FLOAT
);

INSERT INTO gold.fact_booking (
    booking_id, date_key, vehicle_key, pickup_location_key, drop_location_key, 
    payment_key, booking_status, ride_distance, booking_value, driver_rating
)
SELECT 
    b.booking_id,
    CONVERT(INT, FORMAT(b.booking_datetime, 'yyyyMMdd')) AS date_key,
    v.vehicle_key,
    pl.location_key AS pickup_location_key,
    dl.location_key AS drop_location_key,
    p.payment_key,
    b.booking_status,
    b.ride_distance,
    b.booking_value,
    b.driver_rating
FROM silver.uber_booking_clean b
LEFT JOIN gold.dim_vehicle v ON b.vehicle_type = v.vehicle_type
LEFT JOIN gold.dim_location pl ON b.pickup_location = pl.location_name
LEFT JOIN gold.dim_location dl ON b.drop_location = dl.location_name
LEFT JOIN gold.dim_payment p ON b.payment_method = p.payment_method;

GO

-- =============================================================================
-- Create Fact: gold.fact_cancellation
-- =============================================================================
IF OBJECT_ID('gold.fact_cancellation', 'V') IS NOT NULL
    DROP VIEW gold.fact_cancellation;
GO

CREATE TABLE gold.fact_cancellation (
    cancellation_id INT IDENTITY(1,1) PRIMARY KEY,
    booking_id NVARCHAR(50) FOREIGN KEY REFERENCES gold.fact_booking(booking_id),
    cancelled_by NVARCHAR(50), -- Customer / Driver
    cancellation_reason NVARCHAR(255)
);

INSERT INTO gold.fact_cancellation (
    booking_id, cancelled_by, cancellation_reason
)
SELECT
    b.booking_id,
    CASE 
        WHEN b.cancelled_by_customer = 1 THEN 'Customer'
        WHEN b.cancelled_by_driver = 1 THEN 'Driver'
        ELSE 'Unknown'
    END AS cancelled_by,
    COALESCE(b.cancellation_reason_customer, b.cancellation_reason_driver, 'Unknown') AS cancellation_reason
FROM silver.uber_booking_clean b
WHERE b.cancelled_by_customer = 1 OR b.cancelled_by_driver = 1;
GO

-- =============================================================================
-- Create Fact: gold.fact_revenue
-- =============================================================================
IF OBJECT_ID('gold.fact_revenue', 'V') IS NOT NULL
    DROP VIEW gold.fact_revenue;
GO

CREATE TABLE gold.fact_revenue (
    revenue_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    booking_id BIGINT,
    date_key INT FOREIGN KEY REFERENCES gold.dim_date(date_key),
    vehicle_key INT FOREIGN KEY REFERENCES gold.dim_vehicle(vehicle_key),
    payment_key INT FOREIGN KEY REFERENCES gold.dim_payment(payment_key),
    revenue FLOAT
);

INSERT INTO gold.fact_revenue (booking_id, date_key, vehicle_key, payment_key, revenue)
SELECT 
    b.booking_id,
    CONVERT(INT, FORMAT(b.booking_datetime, 'yyyyMMddHH')) AS date_key,
    v.vehicle_key,
    p.payment_key,
    b.booking_value
FROM silver.uber_booking_clean b
LEFT JOIN gold.dim_vehicle v ON b.vehicle_type = v.vehicle_type
LEFT JOIN gold.dim_payment p ON b.payment_method = p.payment_method
WHERE b.booking_status = 'Completed' AND b.booking_value IS NOT NULL;

GO

-- =============================================================================
-- Create Report: gold.report_success_rate
-- =============================================================================
IF OBJECT_ID('gold.report_success_rate', 'V') IS NOT NULL
    DROP VIEW gold.report_success_rate;
GO

CREATE TABLE gold.report_success_rate (
    date_key INT,
    total_booking INT,
    completed_booking INT,
    cancelled_booking INT,
    success_rate FLOAT
);

INSERT INTO gold.report_success_rate (date_key, total_booking, completed_booking, cancelled_booking, success_rate)
SELECT 
    fb.date_key,
    COUNT(*) AS total_booking,
    SUM(CASE WHEN fb.booking_status = 'Completed' THEN 1 ELSE 0 END) AS completed_booking,
    SUM(CASE WHEN fb.booking_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_booking,
    CAST(SUM(CASE WHEN fb.booking_status = 'Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS FLOAT) AS success_rate
FROM gold.fact_booking fb
GROUP BY fb.date_key;

GO

-- =============================================================================
-- Create Report: gold.report_revenue_distribution
-- =============================================================================
IF OBJECT_ID('gold.report_revenue_distribution', 'V') IS NOT NULL
    DROP VIEW gold.report_revenue_distribution;
GO

CREATE TABLE gold.report_revenue_distribution (
    date_key INT,
    vehicle_key INT,
    payment_key INT,
    total_revenue FLOAT,
    ride_count INT
);

INSERT INTO gold.report_revenue_distribution (date_key, vehicle_key, payment_key, total_revenue, ride_count)
SELECT 
    fr.date_key,
    fr.vehicle_key,
    fr.payment_key,
    SUM(fr.revenue) AS total_revenue,
    COUNT(*) AS ride_count
FROM gold.fact_revenue fr
GROUP BY fr.date_key, fr.vehicle_key, fr.payment_key;

GO

-- =============================================================================
-- Create Report: gold.report_cancellation_reason
-- =============================================================================
IF OBJECT_ID('gold.report_cancellation_reason', 'V') IS NOT NULL
    DROP VIEW gold.report_cancellation_reason;
GO

CREATE VIEW gold.report_cancellation_reason AS
SELECT
    fc.date_key,
    fc.cancelled_by,
    r.cancellation_reason,
    COUNT(*) AS cancel_count
FROM gold.fact_cancellation fc
LEFT JOIN gold.dim_cancellation_reason r ON fc.cancel_key = r.cancel_key
GROUP BY fc.date_key, fc.cancelled_by, r.cancellation_reason;
GO

-- =============================================================================
-- Create Report: gold.report_cancellation_reason
-- =============================================================================
IF OBJECT_ID('gold.report_cancellation_reason', 'U') IS NOT NULL
    DROP TABLE gold.report_cancellation_reason;
GO

CREATE TABLE gold.report_cancellation_reason (
    date_key INT,
    cancelled_by NVARCHAR(50),
    cancellation_reason NVARCHAR(255),
    cancel_count INT
);

INSERT INTO gold.report_cancellation_reason (date_key, cancelled_by, cancellation_reason, cancel_count)
SELECT
    fr.date_key,                          -- pastikan fact_cancellation ada kolom ini
    fr.cancelled_by,
    fr.cancellation_reason,
    COUNT(*) AS cancel_count
FROM gold.fact_cancellation fr
GROUP BY fr.date_key, fr.cancelled_by, fr.cancellation_reason;

GO

-- =============================================================================
-- Create View: gold.vw_booking_analysis
-- =============================================================================
IF OBJECT_ID('gold.vw_booking_analysis', 'U') IS NOT NULL
    DROP TABLE gold.vw_booking_analysis;
GO
    
CREATE OR ALTER VIEW gold.vw_booking_analysis AS
SELECT 
    fb.booking_id,
    d.full_date,
    v.vehicle_type,
    pl.location_name AS pickup_location,
    dl.location_name AS drop_location,
    p.payment_method,
    fb.booking_status,
    fb.ride_distance,
    fb.booking_value,
    fb.driver_rating
FROM gold.fact_booking fb
LEFT JOIN gold.dim_date d ON fb.date_key = d.date_key
LEFT JOIN gold.dim_vehicle v ON fb.vehicle_key = v.vehicle_key
LEFT JOIN gold.dim_location pl ON fb.pickup_location_key = pl.location_key
LEFT JOIN gold.dim_location dl ON fb.drop_location_key = dl.location_key
LEFT JOIN gold.dim_payment p ON fb.payment_key = p.payment_key;

GO

-- =============================================================================
-- Create View: gold.vw_cancellation_analysis
-- =============================================================================
IF OBJECT_ID('gold.vw_booking_analysis', 'U') IS NOT NULL
    DROP TABLE gold.vw_booking_analysis;
GO

CREATE OR ALTER VIEW gold.vw_cancellation_analysis AS
SELECT 
    fc.booking_id,
    d.full_date,
    v.vehicle_type,
    pl.location_name AS pickup_location,
    dl.location_name AS drop_location,
    fc.cancelled_by,
    fc.cancellation_reason,
    fc.ride_distance,
    fc.booking_value
FROM gold.fact_cancellation fc
LEFT JOIN gold.fact_booking fb ON fc.booking_id = fb.booking_id
LEFT JOIN gold.dim_date d ON fc.date_key = d.date_key
LEFT JOIN gold.dim_vehicle v ON fb.vehicle_key = v.vehicle_key
LEFT JOIN gold.dim_location pl ON fb.pickup_location_key = pl.location_key
LEFT JOIN gold.dim_location dl ON fb.drop_location_key = dl.location_key;

GO

-- =============================================================================
-- Create View: gold.vw_revenue_analysis
-- =============================================================================
    
IF OBJECT_ID('gold.vw_revenue_analysis', 'U') IS NOT NULL
    DROP TABLE gold.vw_revenue_analysis;
GO

CREATE OR ALTER VIEW gold.vw_revenue_analysis AS
SELECT 
    fr.revenue_id,
    fb.booking_id,
    d.full_date,
    v.vehicle_type,
    pl.location_name AS pickup_location,
    dl.location_name AS drop_location,
    p.payment_method,
    fr.revenue
FROM gold.fact_revenue fr
LEFT JOIN gold.fact_booking fb ON fr.booking_id = fb.booking_id
LEFT JOIN gold.dim_date d ON fr.date_key = d.date_key
LEFT JOIN gold.dim_vehicle v ON fr.vehicle_key = v.vehicle_key
LEFT JOIN gold.dim_location pl ON fb.pickup_location_key = pl.location_key
LEFT JOIN gold.dim_location dl ON fb.drop_location_key = dl.location_key
LEFT JOIN gold.dim_payment p ON fb.payment_key = p.payment_key

GO
