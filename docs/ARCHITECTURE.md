# Architecture Documentation

## Overview

This pipeline implements a **Medallion Architecture** pattern on Snowflake for processing Marathi electoral roll PDFs.

## Data Flow
PDF Files → Stage → AI_PARSE_DOCUMENT → Raw JSON → Text Chunks → Cortex LLM → Curated Tables → Analytics

text


## Layer Descriptions

### Bronze Layer (RAW Schema)

| Table | Purpose | Key Columns |
|-------|---------|-------------|
| `PDF_PARSED_JSON` | Raw AI parsing output | source_file, doc_json |
| `PDF_TEXT` | Extracted full text | source_file, full_text |
| `TEXT_CHUNKS` | 4KB text segments | source_file, chunk_number, chunk_text |
| `AI_EXTRACTED_VOTERS` | LLM extraction results | source_file, voters_json |

### Gold Layer (CURATED Schema)

| Table/View | Purpose | Key Columns |
|------------|---------|-------------|
| `VOTERS` | Validated voter records | voter_id, full_name_mr, age, gender |
| `VOTERS_DEDUPLICATED` | Unique voter records | All voter fields |

## Key Design Decisions

### 1. Chunking Strategy
- **Size**: 4000 characters per chunk
- **Reason**: Fits within LLM token limits while maintaining context
- **Method**: Recursive CTE for efficient splitting

### 2. LLM Model Selection
- **Primary**: `mistral-large2` - Best balance of speed and accuracy
- **Alternative**: `llama3.1-70b` - Better for complex edge cases

### 3. Validation Approach
- Regex validation for voter ID format
- Type casting with TRY_CAST for error handling
- Deduplication using ROW_NUMBER window function
