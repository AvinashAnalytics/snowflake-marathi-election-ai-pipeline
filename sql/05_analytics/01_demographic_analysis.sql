/*
================================================================================
 SNOWFLAKE AI PIPELINE - DEMOGRAPHIC ANALYSIS
================================================================================
 Author      : Avinash Rai
 Description : Voter demographic analysis queries
================================================================================
*/

USE DATABASE MAHARASHTRA_ELECTION_DB;
USE SCHEMA CURATED;

-- =============================================================================
-- ANALYSIS 1: GENDER DISTRIBUTION
-- =============================================================================

SELECT 
    '=== GENDER DISTRIBUTION ===' AS analysis;

SELECT 
    gender,
    COUNT(*) AS voter_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM VOTERS_DEDUPLICATED
WHERE gender IS NOT NULL
GROUP BY gender
ORDER BY voter_count DESC;

-- =============================================================================
-- ANALYSIS 2: AGE DISTRIBUTION
-- =============================================================================

SELECT 
    '=== AGE DISTRIBUTION ===' AS analysis;

SELECT 
    CASE 
        WHEN age BETWEEN 18 AND 24 THEN '18-24 (Young Voters)'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        WHEN age BETWEEN 55 AND 64 THEN '55-64'
        WHEN age >= 65 THEN '65+ (Senior Citizens)'
        ELSE 'Unknown'
    END AS age_group,
    COUNT(*) AS voter_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM VOTERS_DEDUPLICATED
WHERE age IS NOT NULL
GROUP BY 1
ORDER BY 
    CASE 
        WHEN age_group = '18-24 (Young Voters)' THEN 1
        WHEN age_group = '25-34' THEN 2
        WHEN age_group = '35-44' THEN 3
        WHEN age_group = '45-54' THEN 4
        WHEN age_group = '55-64' THEN 5
        WHEN age_group = '65+ (Senior Citizens)' THEN 6
        ELSE 7
    END;

-- =============================================================================
-- ANALYSIS 3: AGE BY GENDER CROSS-TABULATION
-- =============================================================================

SELECT 
    '=== AGE BY GENDER ===' AS analysis;

SELECT 
    CASE 
        WHEN age BETWEEN 18 AND 24 THEN '18-24'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        WHEN age BETWEEN 55 AND 64 THEN '55-64'
        WHEN age >= 65 THEN '65+'
    END AS age_group,
    SUM(CASE WHEN gender = 'Male' THEN 1 ELSE 0 END) AS male_count,
    SUM(CASE WHEN gender = 'Female' THEN 1 ELSE 0 END) AS female_count,
    COUNT(*) AS total
FROM VOTERS_DEDUPLICATED
WHERE age IS NOT NULL AND gender IS NOT NULL
GROUP BY 1
ORDER BY 1;

-- =============================================================================
-- ANALYSIS 4: GUARDIAN TYPE DISTRIBUTION
-- =============================================================================

SELECT 
    '=== GUARDIAN TYPE BY GENDER ===' AS analysis;

SELECT 
    guardian_type,
    gender,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM VOTERS_DEDUPLICATED
WHERE guardian_type IS NOT NULL AND gender IS NOT NULL
GROUP BY guardian_type, gender
ORDER BY guardian_type, gender;

-- =============================================================================
-- ANALYSIS 5: SUMMARY STATISTICS
-- =============================================================================

SELECT 
    '=== SUMMARY STATISTICS ===' AS analysis;

SELECT 
    COUNT(*) AS total_voters,
    COUNT(DISTINCT voter_id) AS unique_voter_ids,
    AVG(age)::INT AS average_age,
    MIN(age) AS min_age,
    MAX(age) AS max_age,
    MODE(gender) AS most_common_gender,
    COUNT(CASE WHEN photo_available = TRUE THEN 1 END) AS voters_with_photo,
    COUNT(CASE WHEN deleted_flag = TRUE THEN 1 END) AS deleted_records
FROM VOTERS_DEDUPLICATED;
