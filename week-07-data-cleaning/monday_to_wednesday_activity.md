# Week 7 — Monday to Wednesday Activity Log

## Monday — First look at messy data

- Imported `customers_messy_RAW.csv` into MySQL as `customers_staging`.
- Compared the staging row count with the clean customer table and confirmed 419 staging rows versus 400 expected clean customer records.
- Checked for repeated `customer_id` values and identified the need for duplicate handling.
- Profiled the staging table for NULL and empty values across the main customer fields.
- Reviewed common data-quality issues such as duplicates, missing values, inconsistent text and inconsistent formats.

### Main SQL work
```sql
SELECT COUNT(*) AS staging_rows FROM customers_staging;
SELECT COUNT(DISTINCT customer_id) AS unique_customer_ids FROM customers_staging;

SELECT customer_id, COUNT(*) AS occurrences
FROM customers_staging
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT
  SUM(customer_name IS NULL OR TRIM(customer_name)='') AS missing_customer_name,
  SUM(email IS NULL OR TRIM(email)='') AS missing_email,
  SUM(phone IS NULL OR TRIM(phone)='') AS missing_phone,
  SUM(city IS NULL OR TRIM(city)='') AS missing_city,
  SUM(signup_date_raw IS NULL OR TRIM(signup_date_raw)='') AS missing_signup_date,
  SUM(customer_segment IS NULL OR TRIM(customer_segment)='') AS missing_segment
FROM customers_staging;
```

## Tuesday — Standardising text fields

- Removed leading and trailing spaces from customer names and city values using `TRIM()`.
- Standardised email addresses to lowercase.
- Standardised customer segments so values such as `sme` and `SME` were treated consistently.
- Converted Nigerian phone numbers using the `+234` prefix into a consistent `0`-prefixed format.
- Previewed the standardised values before creating the final cleaned dataset.

### Main SQL work
```sql
SELECT customer_id,
       TRIM(customer_name) AS trimmed_name,
       LOWER(NULLIF(TRIM(email),'')) AS normalized_email,
       TRIM(city) AS trimmed_city,
       CASE
         WHEN phone LIKE '+234%' THEN CONCAT('0', SUBSTRING(phone,5))
         ELSE NULLIF(TRIM(phone),'')
       END AS normalized_phone,
       CASE
         WHEN LOWER(TRIM(customer_segment))='retail' THEN 'Retail'
         WHEN LOWER(TRIM(customer_segment))='sme' THEN 'SME'
         WHEN LOWER(TRIM(customer_segment))='corporate' THEN 'Corporate'
         ELSE NULL
       END AS normalized_segment
FROM customers_staging;
```

## Wednesday — Fixing dates and removing duplicates

- Identified the different `signup_date` formats present in the staging dataset.
- Used `STR_TO_DATE()` rules to convert the different date formats into a consistent MySQL `DATE` value.
- Applied a documented rule for blank or invalid dates.
- Used `ROW_NUMBER()` to identify duplicate customer IDs and retained the first occurrence of each customer.
- Created the normalized staging view and materialised the final `customers_clean` table.
- Added `customer_id` as the primary key to enforce uniqueness in the cleaned table.

### Main SQL work
```sql
SELECT
  CASE
    WHEN signup_date_raw IS NULL OR TRIM(signup_date_raw)='' THEN 'blank'
    WHEN signup_date_raw REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN 'YYYY-MM-DD'
    WHEN signup_date_raw REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' THEN 'DD/MM/YYYY'
    WHEN signup_date_raw REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' THEN 'DD-MM-YYYY'
    ELSE 'other'
  END AS date_pattern,
  COUNT(*) AS rows_in_pattern
FROM customers_staging
GROUP BY date_pattern;

WITH ranked AS (
  SELECT cs.*,
         ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY staging_id) AS rn
  FROM customers_staging cs
)
SELECT *
FROM ranked
WHERE rn = 1;
```

These activities form the first three days of the Week 7 Data Cleaning Sprint and lead into Thursday's validation of `customers_clean`.
