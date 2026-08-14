-- Week 4 — Ranking & Performance Analytics
-- CASE, subqueries, window functions
USE arravo_retail;

-- 1 Salary bands with CASE
SELECT employee_id,first_name,last_name,monthly_salary,
CASE
  WHEN monthly_salary < 150000 THEN 'Junior'
  WHEN monthly_salary < 300000 THEN 'Mid'
  WHEN monthly_salary < 500000 THEN 'Senior'
  ELSE 'Executive'
END AS salary_band
FROM employees;

-- 2 Sale size labels
SELECT sale_id,total_amount,
CASE
  WHEN total_amount < 100000 THEN 'Small'
  WHEN total_amount < 300000 THEN 'Medium'
  ELSE 'Large'
END AS sale_size
FROM sales;

-- 3 New vs Returning using 2026-06-30 as analysis date
SELECT customer_id,customer_name,signup_date,
CASE WHEN signup_date >= DATE_SUB('2026-06-30',INTERVAL 6 MONTH)
     THEN 'New' ELSE 'Returning' END AS customer_status
FROM customers;

-- 4 Large sales per branch
SELECT branch_id,
       SUM(CASE WHEN total_amount >= 300000 THEN 1 ELSE 0 END) AS large_sales
FROM sales GROUP BY branch_id;

-- 5 Employees above company average salary
SELECT employee_id,first_name,last_name,monthly_salary
FROM employees
WHERE monthly_salary > (SELECT AVG(monthly_salary) FROM employees);

-- 6 Products priced above category average
SELECT p.product_id,p.product_name,p.category,p.unit_price
FROM products p
WHERE p.unit_price > (
  SELECT AVG(p2.unit_price)
  FROM products p2
  WHERE p2.category=p.category
);

-- 7 Customers above average customer spend
SELECT c.customer_id,c.customer_name
FROM customers c
WHERE c.customer_id IN (
  SELECT customer_id
  FROM sales
  GROUP BY customer_id
  HAVING SUM(total_amount) > (
    SELECT AVG(customer_total)
    FROM (
      SELECT customer_id,SUM(total_amount) AS customer_total
      FROM sales GROUP BY customer_id
    ) x
  )
);

-- 8 Same idea using JOIN/CTE
WITH spend AS (
  SELECT customer_id,SUM(total_amount) AS total_spend
  FROM sales GROUP BY customer_id
),
avg_spend AS (
  SELECT AVG(total_spend) AS avg_total FROM spend
)
SELECT c.customer_id,c.customer_name,s.total_spend
FROM customers c
JOIN spend s ON s.customer_id=c.customer_id
CROSS JOIN avg_spend a
WHERE s.total_spend>a.avg_total;

-- 9 RANK employees by salary within department
SELECT employee_id,first_name,last_name,department_id,monthly_salary,
       RANK() OVER(PARTITION BY department_id ORDER BY monthly_salary DESC) AS salary_rank
FROM employees;

-- 10 DENSE_RANK employees by salary within department
SELECT employee_id,first_name,last_name,department_id,monthly_salary,
       DENSE_RANK() OVER(PARTITION BY department_id ORDER BY monthly_salary DESC) AS salary_dense_rank
FROM employees;

-- 11 ROW_NUMBER employees by salary within department
SELECT employee_id,first_name,last_name,department_id,monthly_salary,
       ROW_NUMBER() OVER(PARTITION BY department_id ORDER BY monthly_salary DESC,employee_id) AS salary_row_number
FROM employees;

-- 12 Branch monthly revenue with national rank
WITH monthly_branch AS (
  SELECT branch_id,DATE_FORMAT(sale_date,'%Y-%m') AS month,SUM(total_amount) AS revenue
  FROM sales GROUP BY branch_id,DATE_FORMAT(sale_date,'%Y-%m')
)
SELECT month,branch_id,revenue,
       RANK() OVER(PARTITION BY month ORDER BY revenue DESC) AS branch_rank
FROM monthly_branch;

-- 13 Single top-selling product per category
WITH product_sales AS (
  SELECT p.product_id,p.product_name,p.category,SUM(s.quantity) AS units_sold
  FROM products p JOIN sales s ON s.product_id=p.product_id
  GROUP BY p.product_id,p.product_name,p.category
),
ranked AS (
  SELECT *,ROW_NUMBER() OVER(PARTITION BY category ORDER BY units_sold DESC,product_id) AS rn
  FROM product_sales
)
SELECT * FROM ranked WHERE rn=1;

-- 14 Sales rep ranking per branch
WITH rep_sales AS (
  SELECT branch_id,employee_id,SUM(total_amount) AS revenue
  FROM sales GROUP BY branch_id,employee_id
)
SELECT branch_id,employee_id,revenue,
       RANK() OVER(PARTITION BY branch_id ORDER BY revenue DESC) AS rep_rank
FROM rep_sales;

-- 15 Branch ranking nationally
WITH branch_sales AS (
  SELECT branch_id,SUM(total_amount) AS revenue
  FROM sales GROUP BY branch_id
)
SELECT branch_id,revenue,RANK() OVER(ORDER BY revenue DESC) AS national_rank
FROM branch_sales;

-- 16 Best sales rep of each month
WITH rep_month AS (
  SELECT DATE_FORMAT(sale_date,'%Y-%m') AS month,employee_id,SUM(total_amount) AS revenue
  FROM sales GROUP BY DATE_FORMAT(sale_date,'%Y-%m'),employee_id
),
ranked AS (
  SELECT *,ROW_NUMBER() OVER(PARTITION BY month ORDER BY revenue DESC,employee_id) AS rn
  FROM rep_month
)
SELECT month,employee_id,revenue FROM ranked WHERE rn=1 ORDER BY month;

-- 17 Average sale value per rep
SELECT employee_id,COUNT(*) AS transactions,
       ROUND(AVG(total_amount),2) AS avg_sale_value
FROM sales GROUP BY employee_id ORDER BY avg_sale_value DESC;

-- 18 Category performance ranking
WITH category_sales AS (
  SELECT p.category,SUM(s.total_amount) AS revenue
  FROM sales s JOIN products p ON p.product_id=s.product_id
  GROUP BY p.category
)
SELECT category,revenue,RANK() OVER(ORDER BY revenue DESC) AS category_rank
FROM category_sales;

-- 19 Running total of daily sales
WITH daily AS (
  SELECT sale_date,SUM(total_amount) AS daily_revenue
  FROM sales GROUP BY sale_date
)
SELECT sale_date,daily_revenue,
       SUM(daily_revenue) OVER(ORDER BY sale_date) AS running_revenue
FROM daily ORDER BY sale_date;

-- 20 Month-over-month revenue with LAG
WITH monthly AS (
  SELECT DATE_FORMAT(sale_date,'%Y-%m') AS month,SUM(total_amount) AS revenue
  FROM sales GROUP BY DATE_FORMAT(sale_date,'%Y-%m')
)
SELECT month,revenue,
       LAG(revenue) OVER(ORDER BY month) AS previous_month_revenue,
       revenue-LAG(revenue) OVER(ORDER BY month) AS change_amount,
       ROUND(100*(revenue-LAG(revenue) OVER(ORDER BY month))
             /NULLIF(LAG(revenue) OVER(ORDER BY month),0),2) AS change_pct
FROM monthly ORDER BY month;

-- Extra: flag branch month-over-month drops
WITH monthly_branch AS (
  SELECT branch_id,DATE_FORMAT(sale_date,'%Y-%m') AS month,SUM(total_amount) AS revenue
  FROM sales GROUP BY branch_id,DATE_FORMAT(sale_date,'%Y-%m')
),
lagged AS (
  SELECT *,LAG(revenue) OVER(PARTITION BY branch_id ORDER BY month) AS previous_revenue
  FROM monthly_branch
)
SELECT *,CASE WHEN previous_revenue IS NULL THEN 'First month'
              WHEN revenue<previous_revenue THEN 'Dropped'
              ELSE 'Stable/Grew' END AS trend
FROM lagged ORDER BY branch_id,month;
