/*
===============================================================================
Exploratory Data Analysis (EDA) Script: Database Exploration
===============================================================================
Script Purpose:
    This script performs initial exploration on the Uber Gold Layer database.
    The goal is to understand available schemas, tables, and row counts.

    Database Exploration is the first step before diving into dimensions,
    dates, measures, magnitude, and ranking analysis.

Usage:
    - Run this script once to validate schema and table structures.
===============================================================================
*/

-- =============================================================================
-- Show all schemas and tables
-- =============================================================================
SELECT * FROM INFORMATION_SCHEMA.TABLES

-- =============================================================================
-- Get row counts for all tables in Gold schema
-- =============================================================================
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'gold.fact_booking'

SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'gold.cancellation'

SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'gold.revanue'
