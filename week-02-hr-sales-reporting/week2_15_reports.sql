-- Week 2 — HR & Sales Reporting
-- WHERE, GROUP BY, HAVING, ORDER BY, LIMIT
USE arravo_retail;

-- Monday: WHERE
SELECT * FROM employees WHERE department_id = 1;
SELECT * FROM employees WHERE monthly_salary > 250000;
SELECT * FROM customers WHERE city = 'Lagos';
SELECT * FROM sales WHERE total_amount BETWEEN 100000 AND 300000;
SELECT * FROM products WHERE category LIKE '%Phone%';

-- Tuesday: GROUP BY
SELECT department_id, COUNT(*) AS employee_count
FROM employees GROUP BY department_id ORDER BY employee_count DESC;

SELECT branch_id, SUM(total_amount) AS revenue
FROM sales GROUP BY branch_id ORDER BY revenue DESC;

SELECT department_id, AVG(monthly_salary) AS avg_salary
FROM employees GROUP BY department_id ORDER BY avg_salary DESC;

SELECT payment_method, COUNT(*) AS transactions
FROM sales GROUP BY payment_method ORDER BY transactions DESC;

SELECT product_id, SUM(quantity) AS quantity_sold
FROM sales GROUP BY product_id ORDER BY quantity_sold DESC LIMIT 10;

-- Wednesday: HAVING
SELECT department_id, COUNT(*) AS employee_count
FROM employees GROUP BY department_id
HAVING COUNT(*) > 10;

SELECT branch_id, SUM(total_amount) AS revenue
FROM sales GROUP BY branch_id
HAVING SUM(total_amount) > 5000000
ORDER BY revenue DESC;

SELECT product_id, SUM(quantity) AS total_units
FROM sales GROUP BY product_id
HAVING SUM(quantity) > 20
ORDER BY total_units DESC;

SELECT branch_id, AVG(monthly_salary) AS avg_salary
FROM employees
WHERE employment_status = 'Active'
GROUP BY branch_id
HAVING AVG(monthly_salary) > 150000
ORDER BY avg_salary DESC;

-- Thursday: ORDER BY / LIMIT
SELECT employee_id, first_name, last_name, department_id, monthly_salary
FROM employees
ORDER BY department_id, monthly_salary DESC;

SELECT *
FROM sales
ORDER BY total_amount DESC
LIMIT 1 OFFSET 1;

SELECT branch_id, SUM(total_amount) AS revenue
FROM sales GROUP BY branch_id
ORDER BY revenue DESC LIMIT 5;

SELECT branch_id, SUM(total_amount) AS revenue
FROM sales GROUP BY branch_id
ORDER BY revenue ASC LIMIT 5;

-- 15-report weekly challenge

-- 1 Top earners
SELECT employee_id, first_name, last_name, monthly_salary
FROM employees ORDER BY monthly_salary DESC LIMIT 10;

-- 2 Average salary by department
SELECT d.department_name, ROUND(AVG(e.monthly_salary),2) AS avg_salary
FROM employees e JOIN departments d ON d.department_id=e.department_id
GROUP BY d.department_id,d.department_name ORDER BY avg_salary DESC;

-- 3 Department headcount
SELECT d.department_name, COUNT(*) AS headcount
FROM employees e JOIN departments d ON d.department_id=e.department_id
GROUP BY d.department_id,d.department_name ORDER BY headcount DESC;

-- 4 Highest attendance rate
SELECT e.employee_id, CONCAT(e.first_name,' ',e.last_name) AS employee_name,
       ROUND(100*SUM(a.status IN ('Present','Late'))/COUNT(*),2) AS attendance_rate_pct
FROM employees e JOIN attendance a ON a.employee_id=e.employee_id
GROUP BY e.employee_id,e.first_name,e.last_name
ORDER BY attendance_rate_pct DESC, e.employee_id LIMIT 10;

-- 5 Employees hired in the 12 months ending 2026-06-30
SELECT employee_id, first_name, last_name, hire_date
FROM employees
WHERE hire_date BETWEEN '2025-07-01' AND '2026-06-30'
ORDER BY hire_date DESC;

-- 6 Top 5 branches by revenue
SELECT b.branch_name, SUM(s.total_amount) AS revenue
FROM sales s JOIN branches b ON b.branch_id=s.branch_id
GROUP BY b.branch_id,b.branch_name ORDER BY revenue DESC LIMIT 5;

-- 7 Top 10 products by quantity sold
SELECT p.product_name, SUM(s.quantity) AS units_sold
FROM sales s JOIN products p ON p.product_id=s.product_id
GROUP BY p.product_id,p.product_name ORDER BY units_sold DESC LIMIT 10;

-- 8 Sales by payment method
SELECT payment_method, COUNT(*) AS transactions, SUM(total_amount) AS revenue
FROM sales GROUP BY payment_method ORDER BY transactions DESC;

-- 9 Customers by segment
SELECT customer_segment, COUNT(*) AS customers
FROM customers GROUP BY customer_segment ORDER BY customers DESC;

-- 10 Average sale value by branch
SELECT b.branch_name, ROUND(AVG(s.total_amount),2) AS avg_sale_value
FROM sales s JOIN branches b ON b.branch_id=s.branch_id
GROUP BY b.branch_id,b.branch_name ORDER BY avg_sale_value DESC;

-- 11 Late attendance count by employee
SELECT e.employee_id, CONCAT(e.first_name,' ',e.last_name) AS employee_name,
       COUNT(*) AS late_count
FROM attendance a JOIN employees e ON e.employee_id=a.employee_id
WHERE a.status='Late'
GROUP BY e.employee_id,e.first_name,e.last_name
ORDER BY late_count DESC, e.employee_id;

-- 12 Out-of-stock products
SELECT product_id, product_name, stock_qty
FROM products WHERE stock_qty=0;

-- 13 Top 5 customers by total spend
SELECT c.customer_id,c.customer_name,SUM(s.total_amount) AS total_spend
FROM sales s JOIN customers c ON c.customer_id=s.customer_id
GROUP BY c.customer_id,c.customer_name ORDER BY total_spend DESC LIMIT 5;

-- 14 Revenue by product category
SELECT p.category,SUM(s.total_amount) AS revenue
FROM sales s JOIN products p ON p.product_id=s.product_id
GROUP BY p.category ORDER BY revenue DESC;

-- 15 Monthly sales trend
SELECT DATE_FORMAT(sale_date,'%Y-%m') AS month,
       COUNT(*) AS transactions,
       SUM(total_amount) AS revenue
FROM sales
GROUP BY DATE_FORMAT(sale_date,'%Y-%m')
ORDER BY month;
