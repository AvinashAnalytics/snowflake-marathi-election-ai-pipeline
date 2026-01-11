/*
================================================================================
 SNOWFLAKE AI PIPELINE - CURATED VOTER TABLE
================================================================================
 Author      : Avinash Rai
 Description : Creates final validated voter records table
               Includes data validation, flattening, and deduplication
================================================================================
*/

USE DATABASE MAHARASHTRA_ELECTION_DB;
USE SCHEMA CURATED;

-- =============================================================================
-- STEP 1: CREATE CURATED VOTERS TABLE
-- Flatten JSON arrays and validate voter IDs
-- =============================================================================

CREATE OR REPLACE TABLE VOTERS AS
SELECT 
    -- Source tracking
    ae.source_file,
    ae.chunk_number,
    
    -- Voter information
    v.value:serial_no::INT AS serial_no,
    v.value:voter_id::STRING AS voter_id,
    v.value:part_reference::STRING AS part_reference,
    v.value:full_name_mr::STRING AS full_name_mr,
    v.value:guardian_name_mr::STRING AS guardian_name_mr,
    v.value:guardian_type::STRING AS guardian_type,
    v.value:house_no::STRING AS house_no,
    v.value:age::INT AS age,
    v.value:gender::STRING AS gender,
    v.value:photo_available::BOOLEAN AS photo_available,
    v.value:deleted_flag::BOOLEAN AS deleted_flag,
    
    -- Metadata
    ae.processed_at AS extracted_at,
    CURRENT_TIMESTAMP() AS curated_at
    
FROM RAW.AI_EXTRACTED_VOTERS ae,
LATERAL FLATTEN(input => ae.voters_json) v

-- Validate voter ID format: AIS or LLD followed by 7 digits
WHERE v.value:voter_id IS NOT NULL
  AND v.value:voter_id::STRING RLIKE '^(AIS|LLD)[0-9]{7}$';

-- =============================================================================
-- STEP 2: DATA QUALITY VALIDATION
-- =============================================================================

-- Total records
SELECT 
    'Total Valid Voters' AS metric,
    COUNT(*) AS value
FROM VOTERS;

-- Voter ID prefix distribution
SELECT 
    LEFT(voter_id, 3) AS id_prefix,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM VOTERS
GROUP BY LEFT(voter_id, 3)
ORDER BY count DESC;

-- Null analysis for key fields
SELECT 
    'voter_id' AS field, 
    COUNT(*) AS total_records,
    COUNT(voter_id) AS non_null,
    COUNT(*) - COUNT(voter_id) AS null_count
FROM VOTERS
UNION ALL
SELECT 'full_name_mr', COUNT(*), COUNT(full_name_mr), COUNT(*) - COUNT(full_name_mr) FROM VOTERS
UNION ALL
SELECT 'age', COUNT(*), COUNT(age), COUNT(*) - COUNT(age) FROM VOTERS
UNION ALL
SELECT 'gender', COUNT(*), COUNT(gender), COUNT(*) - COUNT(gender) FROM VOTERS
UNION ALL
SELECT 'house_no', COUNT(*), COUNT(house_no), COUNT(*) - COUNT(house_no) FROM VOTERS;

-- Check for duplicates
SELECT 
    voter_id,
    COUNT(*) AS occurrences
FROM VOTERS
GROUP BY voter_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC
LIMIT 10;

-- =============================================================================
-- STEP 3: CREATE DEDUPLICATED VIEW
-- =============================================================================

CREATE OR REPLACE VIEW VOTERS_DEDUPLICATED AS
SELECT *
FROM (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY voter_id 
            ORDER BY extracted_at DESC  -- Keep most recent extraction
        ) AS row_num
    FROM VOTERS
)
WHERE row_num = 1;

-- Compare original vs deduplicated counts
SELECT 
    'Original Table' AS dataset,
    COUNT(*) AS record_count
FROM VOTERS
UNION ALL
SELECT 
    'Deduplicated View',
    COUNT(*)
FROM VOTERS_DEDUPLICATED;

-- =============================================================================
-- STEP 4: SAMPLE DATA PREVIEW
-- =============================================================================

SELECT 
    voter_id,
    full_name_mr,
    guardian_name_mr,
    guardian_type,
    age,
    gender,
    house_no
FROM VOTERS_DEDUPLICATED
LIMIT 20;
