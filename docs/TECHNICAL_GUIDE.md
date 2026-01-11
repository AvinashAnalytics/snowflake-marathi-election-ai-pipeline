# Technical Guide

## Prerequisites

### Snowflake Requirements
- Account with Cortex AI access
- Role with CREATE DATABASE, CREATE STAGE permissions
- USAGE privilege on SNOWFLAKE.CORTEX

### Supported LLM Models
- `mistral-large2` (recommended)
- `llama3.1-70b`
- `llama3.1-8b` (faster but less accurate)

## Execution Order
sql/01_setup/01_create_database.sql

sql/01_setup/02_create_stages.sql

[Upload PDF files to stage]

sql/02_ingestion/01_parse_pdfs.sql

sql/02_ingestion/02_create_text_chunks.sql

sql/03_extraction/01_extraction_functions.sql

sql/03_extraction/02_run_batch_extraction.sql

sql/04_curation/01_create_curated_tables.sql

sql/05_analytics/01_demographic_analysis.sql

sql/05_analytics/02_data_quality_reports.sql



## Performance Tuning

### For Large Datasets
```sql
-- Use larger warehouse for faster LLM processing
ALTER WAREHOUSE my_warehouse SET WAREHOUSE_SIZE = 'LARGE';

-- Process in batches if needed
CREATE TABLE AI_EXTRACTED_VOTERS_BATCH1 AS
SELECT ... FROM TEXT_CHUNKS WHERE chunk_number <= 100;
Monitoring Progress
SQL

-- Check processing status
SELECT 
    source_file,
    COUNT(*) AS chunks_done,
    SUM(voters_found) AS voters_extracted
FROM AI_EXTRACTED_VOTERS
GROUP BY source_file;
Common Issues and Solutions
Issue: Empty extraction results
Solution: Check if chunk text contains valid voter data

SQL

SELECT chunk_text FROM TEXT_CHUNKS WHERE chunk_number = 1 LIMIT 1;
Issue: JSON parsing errors
Solution: LLM sometimes adds markdown; regex cleaning handles this

Issue: Low extraction accuracy
Solution: Adjust prompt or try different LLM model
