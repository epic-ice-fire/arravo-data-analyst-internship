-- Week 7 Thursday — Validation checks
USE arravo_retail;

-- Row count must be 400
SELECT COUNT(*) AS customers_clean_rows
FROM customers_clean;

-- Required fields must have no null/blank values
SELECT
  SUM(customer_name IS NULL OR TRIM(customer_name)='') AS customer_name_issues,
  SUM(email IS NULL OR TRIM(email)='') AS email_issues,
  SUM(city IS NULL OR TRIM(city)='') AS city_issues
FROM customers_clean;

-- customer_id must be unique
SELECT customer_id,COUNT(*) AS duplicate_count
FROM customers_clean
GROUP BY customer_id
HAVING COUNT(*)>1;

-- Customer segment should have only three approved values
SELECT customer_segment,COUNT(*) AS records
FROM customers_clean
GROUP BY customer_segment
ORDER BY customer_segment;

-- Phone-number length validation
SELECT customer_id,customer_name,phone
FROM customers_clean
WHERE phone IS NULL OR LENGTH(phone)<>11 OR phone NOT LIKE '0%';

-- Date range sanity check
SELECT MIN(signup_date) AS earliest_signup,
       MAX(signup_date) AS latest_signup
FROM customers_clean;

-- Ten random records for manual source comparison
SELECT *
FROM customers_clean
ORDER BY RAND()
LIMIT 10;
