/*
================================================================================
 SNOWFLAKE AI PIPELINE - PDF PARSING
================================================================================
 Author      : Avinash Rai
 Description : Parses uploaded PDF files using Snowflake AI_PARSE_DOCUMENT
               Converts PDFs to structured JSON with extracted text
================================================================================
*/

USE DATABASE MAHARASHTRA_ELECTION_DB;
USE SCHEMA RAW;

-- =============================================================================
-- STEP 1: REFRESH STAGE DIRECTORY
-- =============================================================================

ALTER STAGE VOTER_PDF_STAGE REFRESH;

-- Verify uploaded files
SELECT 
    RELATIVE_PATH AS file_name,
    SIZE AS file_size_bytes,
    ROUND(SIZE / 1024.0 / 1024.0, 2) AS file_size_mb,
    LAST_MODIFIED
FROM DIRECTORY(@VOTER_PDF_STAGE)
WHERE RELATIVE_PATH LIKE '%.pdf'
ORDER BY RELATIVE_PATH;

-- =============================================================================
-- STEP 2: PARSE PDFs USING AI_PARSE_DOCUMENT
-- =============================================================================

CREATE OR REPLACE TABLE PDF_PARSED_JSON AS
SELECT 
    RELATIVE_PATH AS source_file,
    SIZE AS file_size_bytes,
    LAST_MODIFIED AS upload_timestamp,
    AI_PARSE_DOCUMENT(
        TO_FILE('@VOTER_PDF_STAGE', RELATIVE_PATH)
    ) AS doc_json,
    CURRENT_TIMESTAMP() AS parsed_at
FROM DIRECTORY('@VOTER_PDF_STAGE')
WHERE RELATIVE_PATH LIKE '%.pdf';

-- =============================================================================
-- STEP 3: VALIDATE PARSING RESULTS
-- =============================================================================

-- Check total files parsed
SELECT 
    COUNT(*) AS total_files_parsed,
    SUM(file_size_bytes) / 1024 / 1024 AS total_size_mb
FROM PDF_PARSED_JSON;

-- Check JSON structure
SELECT 
    source_file,
    TYPEOF(doc_json) AS json_type,
    OBJECT_KEYS(doc_json) AS available_keys
FROM PDF_PARSED_JSON
LIMIT 5;

-- Preview extracted content
SELECT 
    source_file,
    LENGTH(doc_json:content::STRING) AS content_length,
    LEFT(doc_json:content::STRING, 500) AS content_preview
FROM PDF_PARSED_JSON
LIMIT 3;

-- =============================================================================
-- STEP 4: EXTRACT TEXT TO DEDICATED TABLE
-- =============================================================================

CREATE OR REPLACE TABLE PDF_TEXT AS
SELECT 
    source_file,
    doc_json:content::STRING AS full_text,
    LENGTH(doc_json:content::STRING) AS text_length,
    parsed_at
FROM PDF_PARSED_JSON
WHERE doc_json:content IS NOT NULL;

-- Verify text extraction
SELECT 
    source_file,
    text_length,
    LEFT(full_text, 300) AS preview
FROM PDF_TEXT
ORDER BY source_file;

-- Summary statistics
SELECT 
    COUNT(*) AS total_documents,
    SUM(text_length) AS total_characters,
    AVG(text_length)::INT AS avg_doc_length,
    MIN(text_length) AS min_doc_length,
    MAX(text_length) AS max_doc_length
FROM PDF_TEXT;
