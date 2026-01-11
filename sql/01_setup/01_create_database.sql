/*
================================================================================
 SNOWFLAKE AI PIPELINE - DATABASE SETUP
================================================================================
 Author      : Avinash Rai
 Created     : 2026
 Description : Creates database and schema infrastructure for the Marathi 
               election data extraction pipeline using Medallion Architecture
================================================================================
*/

-- =============================================================================
-- STEP 1: CREATE DATABASE
-- =============================================================================

CREATE DATABASE IF NOT EXISTS MAHARASHTRA_ELECTION_DB
    COMMENT = 'Database for Maharashtra election voter data extraction using Snowflake Cortex AI';

USE DATABASE MAHARASHTRA_ELECTION_DB;

-- =============================================================================
-- STEP 2: CREATE SCHEMAS (Medallion Architecture)
-- =============================================================================

-- RAW Schema (Bronze Layer)
-- Stores: Raw parsed PDF data, text chunks, AI extraction results
CREATE SCHEMA IF NOT EXISTS RAW
    COMMENT = 'Bronze layer - Raw parsed PDF data and AI extraction results';

-- CURATED Schema (Gold Layer)  
-- Stores: Validated, cleaned voter records
CREATE SCHEMA IF NOT EXISTS CURATED
    COMMENT = 'Gold layer - Validated and deduplicated voter records';

-- ANALYTICS Schema
-- Stores: Aggregated reports and analysis views
CREATE SCHEMA IF NOT EXISTS ANALYTICS
    COMMENT = 'Analytics layer - Demographic analysis and reporting';

-- =============================================================================
-- STEP 3: VERIFY SETUP
-- =============================================================================

SHOW SCHEMAS IN DATABASE MAHARASHTRA_ELECTION_DB;

SELECT 
    'Database Setup Complete' AS status,
    CURRENT_DATABASE() AS database_name,
    CURRENT_TIMESTAMP() AS created_at;
