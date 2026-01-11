/*
================================================================================
 SNOWFLAKE AI PIPELINE - STAGE SETUP
================================================================================
 Author      : Avinash Rai
 Description : Creates internal stages for PDF file storage and data export
================================================================================
*/

USE DATABASE MAHARASHTRA_ELECTION_DB;
USE SCHEMA RAW;

-- =============================================================================
-- STEP 1: CREATE STAGE FOR PDF FILES
-- =============================================================================

CREATE OR REPLACE STAGE VOTER_PDF_STAGE
    DIRECTORY = (ENABLE = TRUE)
    ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')
    COMMENT = 'Internal stage for storing voter list PDF files';

-- =============================================================================
-- STEP 2: CREATE STAGE FOR EXPORTS
-- =============================================================================

CREATE OR REPLACE STAGE EXPORT_STAGE
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'Stage for exporting processed voter data to CSV';

-- =============================================================================
-- STEP 3: CREATE FILE FORMATS
-- =============================================================================

-- CSV Format for exports
CREATE OR REPLACE FILE FORMAT CSV_EXPORT_FORMAT
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    COMPRESSION = 'NONE'
    SKIP_HEADER = 0
    NULL_IF = ('NULL', 'null', '');

-- JSON Format for intermediate data
CREATE OR REPLACE FILE FORMAT JSON_FORMAT
    TYPE = 'JSON'
    STRIP_OUTER_ARRAY = TRUE
    COMPRESSION = 'AUTO';

-- =============================================================================
-- STEP 4: VERIFY SETUP
-- =============================================================================

SHOW STAGES IN SCHEMA RAW;
SHOW FILE FORMATS IN SCHEMA RAW;

-- Instructions for uploading files
SELECT '=== FILE UPLOAD INSTRUCTIONS ===' AS message
UNION ALL SELECT ''
UNION ALL SELECT 'Step 1: Upload PDF files:'
UNION ALL SELECT 'PUT file:///path/to/pdfs/*.pdf @RAW.VOTER_PDF_STAGE AUTO_COMPRESS=FALSE;'
UNION ALL SELECT ''
UNION ALL SELECT 'Step 2: Refresh stage directory:'
UNION ALL SELECT 'ALTER STAGE RAW.VOTER_PDF_STAGE REFRESH;'
UNION ALL SELECT ''
UNION ALL SELECT 'Step 3: Verify upload:'
UNION ALL SELECT 'LIST @RAW.VOTER_PDF_STAGE;';
