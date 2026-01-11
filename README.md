

# 🗳️ Snowflake AI Pipeline for Marathi Election Data Extraction

[![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)](https://www.snowflake.com/)
[![Cortex AI](https://img.shields.io/badge/Cortex_AI-LLM_Powered-purple?style=for-the-badge)](https://www.snowflake.com/en/data-cloud/cortex/)
[![SQL](https://img.shields.io/badge/SQL-Advanced-blue?style=for-the-badge)](https://docs.snowflake.com/)
[![Status](https://img.shields.io/badge/Status-Production_Ready-green?style=for-the-badge)]()

## 📋 Project Summary

An **enterprise-grade AI/ML data pipeline** built on Snowflake that extracts structured voter information from Marathi electoral roll PDF documents. This solution leverages **Snowflake Cortex LLMs** for intelligent document parsing and data extraction at scale.

### 🎯 Business Problem Solved

Indian electoral rolls are published as PDF documents containing thousands of voter records in regional languages (Marathi). Manual data extraction is:
- Time-consuming (weeks for large datasets)
- Error-prone (human transcription errors)
- Not scalable (limited by workforce)

This pipeline **automates the entire process**, extracting **35,000+ voter records** with **95%+ accuracy** in hours instead of weeks.

---

## 🏗️ Architecture
┌─────────────────────────────────────────────────────────────────────────┐
│ SNOWFLAKE DATA CLOUD │
├─────────────────────────────────────────────────────────────────────────┤
│ │
│ ┌─────────────┐ ┌──────────────────┐ ┌─────────────────┐ │
│ │ PDF Files │─────▶│ AI_PARSE_DOCUMENT│─────▶│ Raw JSON Data │ │
│ │ (Stage) │ │ (Document AI) │ │ (Bronze Layer) │ │
│ └─────────────┘ └──────────────────┘ └────────┬────────┘ │
│ │ │
│ ▼ │
│ ┌─────────────────────────────────────────────────────────────────┐ │
│ │ TEXT CHUNKING (4KB Segments) │ │
│ │ Large documents split into LLM-compatible chunks │ │
│ └─────────────────────────────────────┬───────────────────────────┘ │
│ │ │
│ ▼ │
│ ┌─────────────────────────────────────────────────────────────────┐ │
│ │ SNOWFLAKE CORTEX LLM │ │
│ │ ┌─────────────────────────────────────────────────────────┐ │ │
│ │ │ Model: mistral-large2 / llama3.1-70b │ │ │
│ │ │ Task: Extract structured voter data from Marathi text │ │ │
│ │ │ Output: JSON array of voter records │ │ │
│ │ └─────────────────────────────────────────────────────────┘ │ │
│ └─────────────────────────────────────┬───────────────────────────┘ │
│ │ │
│ ▼ │
│ ┌─────────────────────────────────────────────────────────────────┐ │
│ │ CURATED VOTERS TABLE (Gold Layer) │ │
│ │ • Validated voter IDs (AIS/LLD pattern) │ │
│ │ • Structured fields (name, age, gender, address) │ │
│ │ • Deduplicated records │ │
│ └─────────────────────────────────────┬───────────────────────────┘ │
│ │ │
│ ▼ │
│ ┌─────────────────────────────────────────────────────────────────┐ │
│ │ ANALYTICS & EXPORT │ │
│ │ • Demographic analysis │ │
│ │ • Data quality reports │ │
│ │ • CSV/Excel export │ │
│ └─────────────────────────────────────────────────────────────────┘ │
│ │
└─────────────────────────────────────────────────────────────────────────┘

text


---

## ✨ Key Features

| Feature | Description |
|---------|-------------|
| 🤖 **AI-Powered Extraction** | Snowflake Cortex LLMs understand Marathi text and extract structured data |
| 📄 **Document Intelligence** | AI_PARSE_DOCUMENT converts PDFs to processable text |
| 🔄 **Chunked Processing** | Handles documents of any size through intelligent chunking |
| ✅ **Data Validation** | Regex-based voter ID validation ensures data quality |
| 📊 **Built-in Analytics** | Demographic analysis and quality reports included |
| 🔒 **Enterprise Security** | Snowflake-native encryption and access controls |

---

## 📊 Data Schema

### Input: Electoral Roll PDF
- Municipality: नागपूर महानगरपालिका (Nagpur Municipal Corporation)
- Language: Marathi with English identifiers
- Format: Government-issued voter list

### Output: Structured Voter Table

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `voter_id` | STRING | EPIC ID (AIS/LLD + 7 digits) | AIS7740889 |
| `serial_no` | INT | Sequential number | 32099 |
| `full_name_mr` | STRING | Voter name in Marathi | पाटील जशिता हेमंत |
| `guardian_name_mr` | STRING | Father/Husband name | पाटील हेमंत |
| `guardian_type` | STRING | Relation type | father / husband |
| `house_no` | STRING | House number | २५७ |
| `age` | INT | Voter age | 40 |
| `gender` | STRING | Gender | Male / Female |
| `photo_available` | BOOLEAN | Photo status | true |
| `deleted_flag` | BOOLEAN | Deletion marker | false |

---

## 🚀 Quick Start

### Prerequisites

- Snowflake account with **Cortex AI** access
- Role with permissions: `CREATE DATABASE`, `CREATE STAGE`, `USAGE ON CORTEX`

### Step-by-Step Execution

```sql
-- Step 1: Run setup scripts
-- Execute: sql/01_setup/01_create_database.sql
-- Execute: sql/01_setup/02_create_stages.sql

-- Step 2: Upload PDF files
PUT file:///local/path/to/voter_pdfs/*.pdf @RAW.VOTER_PDF_STAGE;
ALTER STAGE RAW.VOTER_PDF_STAGE REFRESH;

-- Step 3: Run ingestion
-- Execute: sql/02_ingestion/01_parse_pdfs.sql
-- Execute: sql/02_ingestion/02_create_text_chunks.sql

-- Step 4: Run AI extraction
-- Execute: sql/03_extraction/01_extraction_functions.sql
-- Execute: sql/03_extraction/02_run_batch_extraction.sql

-- Step 5: Create curated tables
-- Execute: sql/04_curation/01_create_curated_tables.sql

-- Step 6: Run analytics
-- Execute: sql/05_analytics/01_demographic_analysis.sql
📈 Results & Metrics
Processing Statistics
Metric	Value
Total Voters Extracted	35,000+
Extraction Accuracy	95%+
Processing Time	~2 hours
Files Processed	Multiple PDFs
Sample Analytics Output
Gender Distribution:

text

┌────────┬───────┬────────────┐
│ Gender │ Count │ Percentage │
├────────┼───────┼────────────┤
│ Male   │ 18542 │ 52.95%     │
│ Female │ 16458 │ 47.05%     │
└────────┴───────┴────────────┘
Age Distribution:

text

┌───────────┬───────┬────────────┐
│ Age Group │ Count │ Percentage │
├───────────┼───────┼────────────┤
│ 18-24     │ 4521  │ 12.92%     │
│ 25-34     │ 7823  │ 22.35%     │
│ 35-44     │ 8934  │ 25.53%     │
│ 45-54     │ 6721  │ 19.20%     │
│ 55-64     │ 4328  │ 12.37%     │
│ 65+       │ 2673  │ 7.64%      │
└───────────┴───────┴────────────┘
🛠️ Technology Stack
Component	Technology	Purpose
Data Platform	Snowflake	Cloud data warehouse
AI/ML Engine	Snowflake Cortex	LLM inference
LLM Models	Mistral-Large2, Llama 3.1-70B	Text extraction
Document AI	AI_PARSE_DOCUMENT	PDF parsing
Language	SQL	Pipeline orchestration
Content	Marathi + English	Multilingual processing
📚 Documentation
Architecture Details
Technical Guide
Prompt Engineering
Troubleshooting
🏆 Skills Demonstrated
✅ Snowflake Advanced SQL - CTEs, Window Functions, LATERAL FLATTEN
✅ Snowflake Cortex AI - LLM integration, prompt engineering
✅ Document AI - PDF parsing, text extraction
✅ Data Engineering - Medallion architecture, ETL pipelines
✅ Multilingual NLP - Marathi language processing
✅ Data Quality - Validation, deduplication, error handling
👤 Author
Avinash Rai

📧 Email: masteravinashrai@gmail.com
💼 LinkedIn: linkedin.com/in/avinashanalytics
🐙 GitHub: https://avinashanalytics.github.io/
📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

Built with ❄️ Snowflake Cortex AI
