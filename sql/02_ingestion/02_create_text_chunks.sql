/*
================================================================================
 SNOWFLAKE AI PIPELINE - TEXT CHUNKING
================================================================================
 Author      : Avinash Rai
 Description : Splits large PDF text into 4KB chunks for LLM processing
               Uses recursive CTE for efficient chunking
================================================================================
*/

USE DATABASE MAHARASHTRA_ELECTION_DB;
USE SCHEMA RAW;

-- =============================================================================
-- STEP 1: CREATE TEXT CHUNKS TABLE
-- Chunk size: 4000 characters (fits within LLM token limits)
-- =============================================================================

CREATE OR REPLACE TABLE TEXT_CHUNKS AS
WITH RECURSIVE text_splitter (
    source_file, 
    chunk_number, 
    chunk_text, 
    remaining_text
) AS (
    -- Base case: First chunk from each document
    SELECT 
        source_file,
        1 AS chunk_number,
        SUBSTRING(full_text, 1, 4000) AS chunk_text,
        SUBSTRING(full_text, 4001) AS remaining_text
    FROM PDF_TEXT
    
    UNION ALL
    
    -- Recursive case: Subsequent chunks
    SELECT 
        source_file,
        chunk_number + 1,
        SUBSTRING(remaining_text, 1, 4000),
        SUBSTRING(remaining_text, 4001)
    FROM text_splitter
    WHERE LENGTH(remaining_text) > 0
      AND chunk_number < 500  -- Safety limit to prevent infinite loops
)
SELECT 
    source_file,
    chunk_number,
    chunk_text,
    LENGTH(chunk_text) AS chunk_length,
    CURRENT_TIMESTAMP() AS created_at
FROM text_splitter
WHERE LENGTH(chunk_text) > 100;  -- Filter out tiny remnants

-- =============================================================================
-- STEP 2: VERIFY CHUNKING RESULTS
-- =============================================================================

-- Chunks per file
SELECT 
    source_file,
    COUNT(*) AS total_chunks,
    SUM(chunk_length) AS total_characters,
    MIN(chunk_length) AS min_chunk_size,
    MAX(chunk_length) AS max_chunk_size,
    AVG(chunk_length)::INT AS avg_chunk_size
FROM TEXT_CHUNKS
GROUP BY source_file
ORDER BY source_file;

-- Total chunks across all files
SELECT 
    COUNT(*) AS total_chunks,
    COUNT(DISTINCT source_file) AS total_files,
    SUM(chunk_length) AS total_characters
FROM TEXT_CHUNKS;

-- Preview first chunk of each file
SELECT 
    source_file,
    chunk_number,
    chunk_length,
    LEFT(chunk_text, 300) AS chunk_preview
FROM TEXT_CHUNKS
WHERE chunk_number = 1;
