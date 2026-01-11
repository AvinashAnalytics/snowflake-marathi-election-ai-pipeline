# Troubleshooting Guide

## Common Errors and Solutions

### Error: "Function SNOWFLAKE.CORTEX.COMPLETE does not exist"
**Cause**: Cortex AI not enabled for your account
**Solution**: Contact Snowflake support to enable Cortex

### Error: "Insufficient privileges"
**Cause**: Missing permissions
**Solution**: 
```sql
GRANT USAGE ON DATABASE MAHARASHTRA_ELECTION_DB TO ROLE your_role;
GRANT ALL ON SCHEMA RAW TO ROLE your_role;
Error: JSON parsing failures
Cause: LLM returns malformed JSON
Solution: Already handled by TRY_PARSE_JSON and COALESCE

Error: No voters extracted
Causes:

PDF not properly parsed
Text chunks too small
Prompt not matching document format
Debugging Steps:

SQL

-- Check if PDF was parsed
SELECT COUNT(*) FROM RAW.PDF_PARSED_JSON;

-- Check text extraction
SELECT LEFT(full_text, 1000) FROM RAW.PDF_TEXT LIMIT 1;

-- Check chunk content
SELECT chunk_text FROM RAW.TEXT_CHUNKS WHERE chunk_number = 1 LIMIT 1;

-- Test LLM directly
SELECT SNOWFLAKE.CORTEX.COMPLETE('mistral-large2', 'Hello, respond with OK');
Performance Issues
Slow extraction
Use larger warehouse size
Process fewer chunks at a time
Consider using faster model (llama3.1-8b)
Memory errors
Reduce chunk size from 4000 to 3000 characters
Process files individually
