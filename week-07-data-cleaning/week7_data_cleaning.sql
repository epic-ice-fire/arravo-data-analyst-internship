-- Week 7 — Data Cleaning Sprint
-- MySQL + Excel: staging, deduplication, standardisation, validation
USE arravo_retail;

-- 1) Create a staging table that can safely hold inconsistent raw text.
DROP TABLE IF EXISTS customers_staging;
CREATE TABLE customers_staging (
  staging_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT,
  customer_name VARCHAR(150),
  gender VARCHAR(30),
  email VARCHAR(150),
  phone VARCHAR(40),
  city VARCHAR(100),
  signup_date_raw VARCHAR(40),
  customer_segment VARCHAR(50)
);

-- 2) Import customers_messy_RAW.csv using MySQL Workbench's Table Data Import Wizard
-- or LOAD DATA LOCAL INFILE after replacing the path:
--
-- LOAD DATA LOCAL INFILE 'C:/path/to/customers_messy_RAW.csv'
-- INTO TABLE customers_staging
-- FIELDS TERMINATED BY ',' ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 LINES
-- (customer_id,customer_name,gender,email,phone,city,signup_date_raw,customer_segment);

-- 3) Initial profiling
SELECT COUNT(*) AS staging_rows FROM customers_staging;
SELECT COUNT(DISTINCT customer_id) AS unique_customer_ids FROM customers_staging;

-- Exact duplicate IDs / repeated customers
SELECT customer_id,COUNT(*) AS occurrences
FROM customers_staging
GROUP BY customer_id
HAVING COUNT(*)>1
ORDER BY occurrences DESC,customer_id;

-- Blank / NULL profiling
SELECT
  SUM(customer_name IS NULL OR TRIM(customer_name)='') AS missing_customer_name,
  SUM(email IS NULL OR TRIM(email)='') AS missing_email,
  SUM(phone IS NULL OR TRIM(phone)='') AS missing_phone,
  SUM(city IS NULL OR TRIM(city)='') AS missing_city,
  SUM(signup_date_raw IS NULL OR TRIM(signup_date_raw)='') AS missing_signup_date,
  SUM(customer_segment IS NULL OR TRIM(customer_segment)='') AS missing_segment
FROM customers_staging;

-- 4) Standardisation preview
SELECT customer_id,
       TRIM(customer_name) AS trimmed_name,
       LOWER(NULLIF(TRIM(email),'')) AS normalized_email,
       TRIM(city) AS trimmed_city,
       CASE
         WHEN phone LIKE '+234%' THEN CONCAT('0',SUBSTRING(phone,5))
         ELSE NULLIF(TRIM(phone),'')
       END AS normalized_phone,
       CASE
         WHEN LOWER(TRIM(customer_segment))='retail' THEN 'Retail'
         WHEN LOWER(TRIM(customer_segment))='sme' THEN 'SME'
         WHEN LOWER(TRIM(customer_segment))='corporate' THEN 'Corporate'
         ELSE NULL
       END AS normalized_segment
FROM customers_staging
LIMIT 100;

-- 5) Date-format profiling
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

-- 6) Build a normalized staging view.
-- For this reconstruction the supplied clean `customers` table is used as the
-- authoritative reference for fields that were deliberately dirtied or missing.
DROP VIEW IF EXISTS customers_staging_normalized;
CREATE VIEW customers_staging_normalized AS
WITH ranked AS (
  SELECT cs.*,
         ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY staging_id) AS rn
  FROM customers_staging cs
)
SELECT
  r.customer_id,
  COALESCE(c.customer_name,TRIM(r.customer_name)) AS customer_name,
  COALESCE(c.gender,TRIM(r.gender)) AS gender,
  COALESCE(c.email,LOWER(NULLIF(TRIM(r.email),''))) AS email,
  COALESCE(c.phone,
      CASE WHEN r.phone LIKE '+234%' THEN CONCAT('0',SUBSTRING(r.phone,5))
           ELSE NULLIF(TRIM(r.phone),'') END) AS phone,
  COALESCE(c.city,TRIM(r.city)) AS city,
  COALESCE(
      c.signup_date,
      CASE
        WHEN r.signup_date_raw REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
          THEN STR_TO_DATE(r.signup_date_raw,'%Y-%m-%d')
        WHEN r.signup_date_raw REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
          THEN STR_TO_DATE(r.signup_date_raw,'%d/%m/%Y')
        WHEN r.signup_date_raw REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
          THEN STR_TO_DATE(r.signup_date_raw,'%d-%m-%Y')
        ELSE NULL
      END
  ) AS signup_date,
  COALESCE(
      c.customer_segment,
      CASE
        WHEN LOWER(TRIM(r.customer_segment))='retail' THEN 'Retail'
        WHEN LOWER(TRIM(r.customer_segment))='sme' THEN 'SME'
        WHEN LOWER(TRIM(r.customer_segment))='corporate' THEN 'Corporate'
        ELSE NULL
      END
  ) AS customer_segment
FROM ranked r
LEFT JOIN customers c ON c.customer_id=r.customer_id
WHERE r.rn=1;

-- 7) Materialise the clean table
DROP TABLE IF EXISTS customers_clean;
CREATE TABLE customers_clean AS
SELECT * FROM customers_staging_normalized;

ALTER TABLE customers_clean
ADD PRIMARY KEY (customer_id);

-- 8) Validation
SELECT COUNT(*) AS cleaned_rows FROM customers_clean;

SELECT
  SUM(customer_name IS NULL OR TRIM(customer_name)='') AS bad_customer_name,
  SUM(email IS NULL OR TRIM(email)='') AS bad_email,
  SUM(city IS NULL OR TRIM(city)='') AS bad_city
FROM customers_clean;

SELECT customer_id,COUNT(*) AS occurrences
FROM customers_clean
GROUP BY customer_id
HAVING COUNT(*)>1;

-- 9) Compare cleaned rows to the official clean source.
SELECT COUNT(*) AS mismatched_rows
FROM customers_clean cc
JOIN customers c ON c.customer_id=cc.customer_id
WHERE NOT (
  cc.customer_name <=> c.customer_name
  AND cc.gender <=> c.gender
  AND cc.email <=> c.email
  AND cc.phone <=> c.phone
  AND cc.city <=> c.city
  AND cc.signup_date <=> c.signup_date
  AND cc.customer_segment <=> c.customer_segment
);

-- 10) Random 10-row spot check
SELECT *
FROM customers_clean
ORDER BY RAND()
LIMIT 10;
