-- Week 1 — Arravo Retail Database Setup
-- Reconstructed 2026-08-14
USE arravo_retail;

-- Verify schema
SHOW TABLES;

-- Row counts
SELECT 'branches' AS table_name, COUNT(*) AS row_count FROM branches
UNION ALL SELECT 'departments', COUNT(*) FROM departments
UNION ALL SELECT 'positions', COUNT(*) FROM positions
UNION ALL SELECT 'employees', COUNT(*) FROM employees
UNION ALL SELECT 'salaries', COUNT(*) FROM salaries
UNION ALL SELECT 'attendance', COUNT(*) FROM attendance
UNION ALL SELECT 'suppliers', COUNT(*) FROM suppliers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'sales', COUNT(*) FROM sales;

-- 1. Inspect employees
SELECT * FROM employees;

-- 2. Inspect products
SELECT * FROM products;

-- 3. Inspect sales
SELECT * FROM sales;

-- 4. Inspect customers
SELECT * FROM customers;

-- 5. Select specific employee columns
SELECT first_name, last_name, monthly_salary
FROM employees;

-- 6. Distinct departments represented by employees
SELECT DISTINCT department_id
FROM employees
ORDER BY department_id;

-- 7. Distinct customer cities
SELECT DISTINCT city
FROM customers
ORDER BY city;

-- 8. Ten most expensive products
SELECT product_name, unit_price
FROM products
ORDER BY unit_price DESC
LIMIT 10;

-- 9. Five highest-paid employees
SELECT employee_id, first_name, last_name, monthly_salary
FROM employees
ORDER BY monthly_salary DESC
LIMIT 5;

-- 10. Out-of-stock products
SELECT product_id, product_name, stock_qty
FROM products
WHERE stock_qty = 0;

-- Extra: cash sales and count
SELECT *
FROM sales
WHERE payment_method = 'Cash';

SELECT COUNT(*) AS cash_sales_count
FROM sales
WHERE payment_method = 'Cash';

-- Week 1 SQL Challenge
SELECT COUNT(*) AS total_employees FROM employees;
SELECT COUNT(*) AS total_products FROM products;
SELECT COUNT(*) AS total_customers FROM customers;
SELECT COUNT(*) AS total_branches FROM branches;
SELECT COUNT(DISTINCT payment_method) AS distinct_payment_methods FROM sales;

-- Debug exercise (intentionally wrong; keep commented)
-- SELECT employee_name FROM employees;
-- Expected MySQL error: Unknown column 'employee_name' in 'field list'

-- Corrected version
SELECT CONCAT(first_name, ' ', last_name) AS employee_name
FROM employees;
