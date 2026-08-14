-- Week 3 — Joins Across the Business
USE arravo_retail;

-- Monday: INNER JOIN
SELECT s.sale_id,s.sale_date,p.product_name,s.quantity,s.total_amount
FROM sales s INNER JOIN products p ON p.product_id=s.product_id;

SELECT s.sale_id,s.sale_date,c.customer_name,c.city,s.total_amount
FROM sales s INNER JOIN customers c ON c.customer_id=s.customer_id;

SELECT s.sale_id,s.sale_date,CONCAT(e.first_name,' ',e.last_name) AS employee_name,s.total_amount
FROM sales s INNER JOIN employees e ON e.employee_id=s.employee_id;

SELECT s.sale_id,s.sale_date,p.product_name,c.customer_name,s.quantity,s.total_amount
FROM sales s
JOIN products p ON p.product_id=s.product_id
JOIN customers c ON c.customer_id=s.customer_id;

SELECT s.sale_id,s.sale_date,p.product_name,c.customer_name,
       CONCAT(e.first_name,' ',e.last_name) AS employee_name,
       s.quantity,s.total_amount
FROM sales s
JOIN products p ON p.product_id=s.product_id
JOIN customers c ON c.customer_id=s.customer_id
JOIN employees e ON e.employee_id=s.employee_id;

-- Tuesday: LEFT JOIN gap analysis
SELECT e.employee_id,e.first_name,e.last_name
FROM employees e LEFT JOIN salaries sa ON sa.employee_id=e.employee_id
WHERE sa.salary_id IS NULL;

SELECT p.product_id,p.product_name
FROM products p LEFT JOIN sales s ON s.product_id=p.product_id
WHERE s.sale_id IS NULL;

SELECT c.customer_id,c.customer_name
FROM customers c LEFT JOIN sales s ON s.customer_id=c.customer_id
WHERE s.sale_id IS NULL;

SELECT b.branch_id,b.branch_name,COUNT(e.employee_id) AS employee_count
FROM branches b LEFT JOIN employees e ON e.branch_id=b.branch_id
GROUP BY b.branch_id,b.branch_name;

-- Wednesday: UNION and string functions
WITH high_spend AS (
    SELECT customer_id
    FROM sales
    GROUP BY customer_id
    HAVING SUM(total_amount) > 500000
)
SELECT customer_id,customer_name,'Corporate segment' AS reason
FROM customers WHERE customer_segment='Corporate'
UNION
SELECT c.customer_id,c.customer_name,'High spend' AS reason
FROM customers c JOIN high_spend h ON h.customer_id=c.customer_id;

SELECT b.branch_name,SUM(s.total_amount) AS revenue,'Lagos' AS group_name
FROM sales s JOIN branches b ON b.branch_id=s.branch_id
WHERE b.city='Lagos'
GROUP BY b.branch_id,b.branch_name
UNION ALL
SELECT b.branch_name,SUM(s.total_amount) AS revenue,'Other cities' AS group_name
FROM sales s JOIN branches b ON b.branch_id=s.branch_id
WHERE b.city<>'Lagos'
GROUP BY b.branch_id,b.branch_name;

SELECT customer_id,
       CONCAT(customer_name,' | ',phone) AS customer_label
FROM customers;

-- Weekly challenge 1: sales reps with most transactions
SELECT e.employee_id,CONCAT(e.first_name,' ',e.last_name) AS sales_rep,
       COUNT(*) AS transactions
FROM sales s JOIN employees e ON e.employee_id=s.employee_id
GROUP BY e.employee_id,e.first_name,e.last_name
ORDER BY transactions DESC;

-- Challenge 2: sales reps with highest total revenue
SELECT e.employee_id,CONCAT(e.first_name,' ',e.last_name) AS sales_rep,
       SUM(s.total_amount) AS revenue
FROM sales s JOIN employees e ON e.employee_id=s.employee_id
GROUP BY e.employee_id,e.first_name,e.last_name
ORDER BY revenue DESC;

-- Challenge 3: customer purchase history
SELECT c.customer_id,c.customer_name,s.sale_date,p.product_name,
       s.quantity,s.total_amount
FROM customers c
JOIN sales s ON s.customer_id=c.customer_id
JOIN products p ON p.product_id=s.product_id
ORDER BY c.customer_id,s.sale_date;

-- Challenge 4: transactions per branch per month
SELECT b.branch_name,DATE_FORMAT(s.sale_date,'%Y-%m') AS month,
       COUNT(*) AS transactions,SUM(s.total_amount) AS revenue
FROM sales s JOIN branches b ON b.branch_id=s.branch_id
GROUP BY b.branch_id,b.branch_name,DATE_FORMAT(s.sale_date,'%Y-%m')
ORDER BY month,b.branch_name;

-- Challenge 5: revenue per sales rep per branch
SELECT b.branch_name,e.employee_id,
       CONCAT(e.first_name,' ',e.last_name) AS sales_rep,
       COUNT(*) AS transactions,SUM(s.total_amount) AS revenue
FROM sales s
JOIN branches b ON b.branch_id=s.branch_id
JOIN employees e ON e.employee_id=s.employee_id
GROUP BY b.branch_id,b.branch_name,e.employee_id,e.first_name,e.last_name
ORDER BY b.branch_name,revenue DESC;

-- Thursday: string cleaning examples
SELECT customer_id,TRIM(customer_name) AS cleaned_name FROM customers;

SELECT customer_id,
       CASE WHEN phone LIKE '+234%' THEN CONCAT('0',SUBSTRING(phone,5))
            ELSE phone END AS normalized_phone
FROM customers;

SELECT customer_id,phone
FROM customers
WHERE phone IS NOT NULL
  AND LENGTH(REPLACE(phone,'+234','0')) <> 11;

-- Avoid join fan-out: aggregate sales before joining
WITH customer_spend AS (
    SELECT customer_id,SUM(total_amount) AS total_spend
    FROM sales GROUP BY customer_id
)
SELECT c.customer_id,TRIM(c.customer_name) AS customer_name,cs.total_spend
FROM customers c JOIN customer_spend cs ON cs.customer_id=c.customer_id
ORDER BY cs.total_spend DESC;
