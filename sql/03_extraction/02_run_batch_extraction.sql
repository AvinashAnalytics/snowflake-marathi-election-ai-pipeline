/*
================================================================================
 SNOWFLAKE AI PIPELINE - BATCH EXTRACTION
================================================================================
 Author      : Avinash Rai
 Description : Runs LLM extraction across all text chunks
               Stores results with metadata for traceability
================================================================================
*/

USE DATABASE MAHARASHTRA_ELECTION_DB;
USE SCHEMA RAW;

-- =============================================================================
-- STEP 1: RUN EXTRACTION ON ALL CHUNKS
-- =============================================================================

CREATE OR REPLACE TABLE AI_EXTRACTED_VOTERS AS
SELECT 
    source_file,
    chunk_number,
    chunk_length,
    EXTRACT_VOTERS_SIMPLE(chunk_text) AS voters_json,
    ARRAY_SIZE(EXTRACT_VOTERS_SIMPLE(chunk_text)) AS voters_found,
    CURRENT_TIMESTAMP() AS processed_at
FROM TEXT_CHUNKS;

-- =============================================================================
-- STEP 2: EXTRACTION STATISTICS
-- =============================================================================

-- Overall extraction summary
SELECT 
    '=== EXTRACTION SUMMARY ===' AS report_section,
    NULL AS metric,
    NULL AS value
UNION ALL
SELECT 
    'Overall',
    'Total Chunks Processed',
    COUNT(*)::STRING
FROM AI_EXTRACTED_VOTERS
UNION ALL
SELECT 
    'Overall',
    'Total Voters Extracted',
    SUM(voters_found)::STRING
FROM AI_EXTRACTED_VOTERS
UNION ALL
SELECT 
    'Overall',
    'Chunks with Data',
    SUM(CASE WHEN voters_found > 0 THEN 1 ELSE 0 END)::STRING
FROM AI_EXTRACTED_VOTERS
UNION ALL
SELECT 
    'Overall',
    'Empty Chunks',
    SUM(CASE WHEN voters_found = 0 THEN 1 ELSE 0 END)::STRING
FROM AI_EXTRACTED_VOTERS
UNION ALL
SELECT 
    'Overall',
    'Avg Voters per Chunk',
    ROUND(AVG(voters_found), 2)::STRING
FROM AI_EXTRACTED_VOTERS;

-- Per-file statistics
SELECT 
    source_file,
    COUNT(*) AS chunks_processed,
    SUM(voters_found) AS total_voters,
    SUM(CASE WHEN voters_found > 0 THEN 1 ELSE 0 END) AS successful_chunks,
    SUM(CASE WHEN voters_found = 0 THEN 1 ELSE 0 END) AS empty_chunks,
    ROUND(AVG(voters_found), 2) AS avg_voters_per_chunk,
    MIN(processed_at) AS started_at,
    MAX(processed_at) AS completed_at
FROM AI_EXTRACTED_VOTERS
GROUP BY source_file
ORDER BY source_file;

-- =============================================================================
-- STEP 3: SAMPLE EXTRACTED DATA
-- =============================================================================

-- View sample extraction results
SELECT 
    source_file,
    chunk_number,
    voters_found,
    voters_json
FROM AI_EXTRACTED_VOTERS
WHERE voters_found > 0
ORDER BY source_file, chunk_number
LIMIT 5;
