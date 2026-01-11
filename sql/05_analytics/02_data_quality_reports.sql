/*
================================================================================
 SNOWFLAKE AI PIPELINE - DATA QUALITY REPORTS
================================================================================
 Author      : Avinash Rai
 Description : Data quality assessment and export functionality
================================================================================
*/

USE DATABASE MAHARASHTRA_ELECTION_DB;
USE SCHEMA CURATED;

-- =============================================================================
-- REPORT 1: FIELD COMPLETENESS
-- =============================================================================

SELECT 
    '=== FIELD COMPLETENESS REPORT ===' AS report;

SELECT 
    'voter_id' AS field_name,
    COUNT(*) AS total_records,
    COUNT(voter_id) AS populated,
    COUNT(*) - COUNT(voter_id) AS missing,
    ROUND(COUNT(voter_id) * 100.0 / COUNT(*), 2) AS completeness_pct
FROM VOTERS_DEDUPLICATED
UNION ALL
SELECT 'full_name_mr', COUNT(*), COUNT(full_name_mr), COUNT(*) - COUNT(full_name_mr), ROUND(COUNT(full_name_mr) * 100.0 / COUNT(*), 2) FROM VOTERS_DEDUPLICATED
UNION ALL
SELECT 'guardian_name_mr', COUNT(*), COUNT(guardian_name_mr), COUNT(*) - COUNT(guardian_name_mr), ROUND(COUNT(guardian_name_mr) * 100.0 / COUNT(*), 2) FROM VOTERS_DEDUPLICATED
UNION ALL
SELECT 'guardian_type', COUNT(*), COUNT(guardian_type), COUNT(*) - COUNT(guardian_type), ROUND(COUNT(guardian_type) * 100.0 / COUNT(*), 2) FROM VOTERS_DEDUPLICATED
UNION ALL
SELECT 'house_no', COUNT(*), COUNT(house_no), COUNT(*) - COUNT(house_no), ROUND(COUNT(house_no) * 100.0 / COUNT(*), 2) FROM VOTERS_DEDUPLICATED
UNION ALL
SELECT 'age', COUNT(*), COUNT(age), COUNT(*) - COUNT(age), ROUND(COUNT(age) * 100.0 / COUNT(*), 2) FROM VOTERS_DEDUPLICATED
UNION ALL
SELECT 'gender', COUNT(*), COUNT(gender), COUNT(*) - COUNT(gender), ROUND(COUNT(gender) * 100.0 / COUNT(*), 2) FROM VOTERS_DEDUPLICATED
ORDER BY completeness_pct DESC;

-- =============================================================================
-- REPORT 2: DATA VALIDATION CHECKS
-- =============================================================================

SELECT 
    '=== DATA VALIDATION REPORT ===' AS report;

-- Age range validation
SELECT 
    'Age Range Check' AS validation,
    SUM(CASE WHEN age >= 18 AND age <= 120 THEN 1 ELSE 0 END) AS valid_records,
    SUM(CASE WHEN age < 18 OR age > 120 THEN 1 ELSE 0 END) AS invalid_records,
    ROUND(SUM(CASE WHEN age >= 18 AND age <= 120 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS valid_pct
FROM VOTERS_DEDUPLICATED
WHERE age IS NOT NULL;

-- Gender value validation
SELECT 
    'Gender Values' AS validation,
    SUM(CASE WHEN gender IN ('Male', 'Female') THEN 1 ELSE 0 END) AS valid_records,
    SUM(CASE WHEN gender NOT IN ('Male', 'Female') THEN 1 ELSE 0 END) AS invalid_records,
    ROUND(SUM(CASE WHEN gender IN ('Male', 'Female') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS valid_pct
FROM VOTERS_DEDUPLICATED
WHERE gender IS NOT NULL;

-- =============================================================================
-- REPORT 3: PROCESSING SUMMARY
-- =============================================================================

SELECT 
    '=== PROCESSING SUMMARY ===' AS report;

SELECT 
    source_file,
    COUNT(*) AS voters_extracted,
    COUNT(DISTINCT voter_id) AS unique_voters,
    MIN(extracted_at) AS first_extracted,
    MAX(extracted_at) AS last_extracted
FROM VOTERS_DEDUPLICATED
GROUP BY source_file
ORDER BY source_file;

-- =============================================================================
-- EXPORT: FINAL VOTER DATA TO CSV
-- =============================================================================

-- Export to stage
COPY INTO @RAW.EXPORT_STAGE/voters_final_export.csv
FROM (
    SELECT 
        voter_id,
        serial_no,
        full_name_mr,
        guardian_name_mr,
        guardian_type,
        house_no,
        age,
        gender,
        photo_available,
        deleted_flag,
        source_file,
        curated_at
    FROM VOTERS_DEDUPLICATED
    ORDER BY source_file, serial_no
)
FILE_FORMAT = (
    TYPE = 'CSV' 
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    COMPRESSION = 'NONE'
)
SINGLE = TRUE
HEADER = TRUE
OVERWRITE = TRUE;

-- Verify export
SELECT 
    '=== EXPORT VERIFICATION ===' AS report;
    
LIST @RAW.EXPORT_STAGE PATTERN='.*voters_final_export.*';

-- Download instruction
SELECT 
    'Download exported file using:' AS instruction,
    'GET @RAW.EXPORT_STAGE/voters_final_export.csv file:///local/path/;' AS command;
