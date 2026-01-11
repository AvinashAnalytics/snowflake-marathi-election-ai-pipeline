/*
================================================================================
 SNOWFLAKE AI PIPELINE - LLM EXTRACTION FUNCTIONS
================================================================================
 Author      : Avinash Rai
 Description : Custom SQL UDFs using Snowflake Cortex for voter data extraction
               Optimized prompts for Marathi electoral roll documents
================================================================================
*/

USE DATABASE MAHARASHTRA_ELECTION_DB;
USE SCHEMA RAW;

-- =============================================================================
-- FUNCTION 1: OPTIMIZED EXTRACTION (Full Details)
-- =============================================================================

CREATE OR REPLACE FUNCTION EXTRACT_VOTERS_OPTIMIZED(
    input_text STRING, 
    chunk_number INT DEFAULT 1
)
RETURNS VARIANT
LANGUAGE SQL
COMMENT = 'Extracts detailed voter records from Marathi electoral roll text using Cortex LLM'
AS
$$
    COALESCE(
        TRY_PARSE_JSON(
            REGEXP_SUBSTR(
                REGEXP_REPLACE(
                    REGEXP_REPLACE(
                        SNOWFLAKE.CORTEX.COMPLETE(
                            'mistral-large2',
                            'You are an expert data extraction system for Indian government voter lists.

DOCUMENT CONTEXT:
- Source: Nagpur Municipal Corporation (नागपूर महानगरपालिका)
- Document Type: Draft Voter List (मूळ प्रारूप मतदार यादी)
- Language: Marathi with English identifiers

TASK: Extract ALL voter records from the text below into a JSON array.

VOTER ID PATTERN (REQUIRED):
- Format: "AIS" or "LLD" followed by exactly 7 digits
- Examples: AIS7740889, LLD1234567
- SKIP any record without a valid voter ID

FIELDS TO EXTRACT:
1. serial_no (INT): Sequential voter number
2. voter_id (STRING): EPIC ID starting with AIS or LLD - REQUIRED
3. part_reference (STRING): Part number like "53/263/605"
4. full_name_mr (STRING): Full name in Marathi (मतदाराचे नाव)
5. guardian_name_mr (STRING): Father/Husband name in Marathi
6. guardian_type (STRING): "father" if वडिलांचे/वडील, "husband" if पतीचे/पती
7. house_no (STRING): House number (preserve Marathi numerals like २५७)
8. age (INT): Voter age (valid range: 18-120)
9. gender (STRING): "Male" if पुरुष/पु/पम, "Female" if स्त्री/स्त्रि/सद
10. photo_available (BOOLEAN): true if "Photo Available" or "फोटो" mentioned
11. deleted_flag (BOOLEAN): true if "DELETED" marker present

OUTPUT RULES:
1. Return ONLY a valid JSON array - NO markdown, NO explanation
2. Return empty array [] if no valid voters found
3. Use null for missing optional fields
4. Ensure proper JSON escaping for Marathi characters

EXAMPLE OUTPUT:
[{"serial_no":32099,"voter_id":"AIS7740889","part_reference":"53/263/605","full_name_mr":"पाटील जशिता हेमंत","guardian_name_mr":"पाटील हेमंत","guardian_type":"husband","house_no":"२५७","age":40,"gender":"Female","photo_available":true,"deleted_flag":false}]

TEXT TO PARSE (Chunk #' || chunk_number::STRING || '):
' || LEFT(input_text, 3500)
                        ),
                        '```json\\s*', ''
                    ),
                    '```', ''
                ),
                '\\[.*\\]',
                1, 1, 's'
            )
        ),
        PARSE_JSON('[]')
    )
$$;

-- =============================================================================
-- FUNCTION 2: SIMPLE EXTRACTION (Faster Processing)
-- =============================================================================

CREATE OR REPLACE FUNCTION EXTRACT_VOTERS_SIMPLE(input_text STRING)
RETURNS VARIANT
LANGUAGE SQL
COMMENT = 'Simplified voter extraction for high-volume processing'
AS
$$
    COALESCE(
        TRY_PARSE_JSON(
            REGEXP_SUBSTR(
                SNOWFLAKE.CORTEX.COMPLETE(
                    'mistral-large2',
                    'Extract voter records from this Nagpur voter list. Return JSON array only.

VOTER ID FORMAT: AIS or LLD + 7 digits (e.g., AIS7740889)

EXTRACT THESE FIELDS:
- serial_no: number
- voter_id: AIS/LLD ID (REQUIRED - skip if missing)
- full_name_mr: Marathi name
- guardian_name_mr: Father/Husband name
- guardian_type: "father" or "husband"
- house_no: house number
- age: number (18-120)
- gender: "Male" or "Female" (पुरुष=Male, स्त्री=Female)
- photo_available: true/false
- deleted_flag: true if DELETED present

RULES:
- Return ONLY JSON array, no other text
- Return [] if no voters found
- Use null for missing fields

TEXT:
' || LEFT(input_text, 3500)
                ),
                '\\[.*\\]',
                1, 1, 's'
            )
        ),
        PARSE_JSON('[]')
    )
$$;

-- =============================================================================
-- TEST FUNCTIONS
-- =============================================================================

-- Test on single chunk
SELECT 
    source_file,
    chunk_number,
    chunk_length,
    LEFT(chunk_text, 200) AS text_preview,
    EXTRACT_VOTERS_SIMPLE(chunk_text) AS extracted_voters,
    ARRAY_SIZE(EXTRACT_VOTERS_SIMPLE(chunk_text)) AS voters_found
FROM TEXT_CHUNKS
WHERE chunk_number = 1
LIMIT 1;
