# Prompt Engineering Guide

## Prompt Structure

### 1. Role Definition
You are an expert data extraction system for Indian government voter lists.

text


### 2. Context Setting
DOCUMENT CONTEXT:

Source: Nagpur Municipal Corporation
Document Type: Draft Voter List
Language: Marathi with English identifiers
text


### 3. Task Definition
TASK: Extract ALL voter records from the text below into a JSON array.

text


### 4. Pattern Specification
VOTER ID PATTERN:

Format: "AIS" or "LLD" followed by exactly 7 digits
Examples: AIS7740889, LLD1234567
text


### 5. Output Format
OUTPUT RULES:

Return ONLY a valid JSON array
Return [] if no voters found
Use null for missing fields
text


## Marathi Language Mappings

### Gender
| Marathi | Standardized |
|---------|--------------|
| पुरुष, पु, पम | Male |
| स्त्री, स्त्रि, सद | Female |

### Guardian Type
| Marathi | Standardized |
|---------|--------------|
| वडिलांचे, वडील, पिता | father |
| पतीचे, पती | husband |

## Prompt Optimization Tips

1. **Be explicit** about required vs optional fields
2. **Provide examples** of expected output
3. **Set clear boundaries** (no markdown, JSON only)
4. **Handle edge cases** explicitly (empty results = [])
