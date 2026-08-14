-- Week 5 — Finance Reporting Engine
-- CTEs, temporary tables, stored procedures
USE arravo_retail;

-- CTE 1: monthly branch revenue
WITH monthly_branch_revenue AS (
  SELECT branch_id,DATE_FORMAT(sale_date,'%Y-%m') AS month,SUM(total_amount) AS revenue
  FROM sales
  GROUP BY branch_id,DATE_FORMAT(sale_date,'%Y-%m')
)
SELECT * FROM monthly_branch_revenue ORDER BY month,branch_id;

-- CTE 2: employee total sales and ranking
WITH employee_sales AS (
  SELECT employee_id,SUM(total_amount) AS revenue
  FROM sales GROUP BY employee_id
)
SELECT employee_id,revenue,RANK() OVER(ORDER BY revenue DESC) AS sales_rank
FROM employee_sales;

-- Chained CTEs: month-over-month revenue
WITH monthly AS (
  SELECT DATE_FORMAT(sale_date,'%Y-%m') AS month,SUM(total_amount) AS revenue
  FROM sales GROUP BY DATE_FORMAT(sale_date,'%Y-%m')
),
comparison AS (
  SELECT month,revenue,LAG(revenue) OVER(ORDER BY month) AS prior_revenue
  FROM monthly
)
SELECT month,revenue,prior_revenue,revenue-prior_revenue AS change_amount
FROM comparison;

-- Temporary table: active employees with latest salary month
DROP TEMPORARY TABLE IF EXISTS active_employee_latest_salary;
CREATE TEMPORARY TABLE active_employee_latest_salary AS
SELECT e.employee_id,e.first_name,e.last_name,e.monthly_salary,
       MAX(s.pay_month) AS latest_pay_month
FROM employees e
LEFT JOIN salaries s ON s.employee_id=e.employee_id
WHERE e.employment_status='Active'
GROUP BY e.employee_id,e.first_name,e.last_name,e.monthly_salary;

SELECT * FROM active_employee_latest_salary;

-- Temporary table: latest month present in the dataset
DROP TEMPORARY TABLE IF EXISTS latest_month_sales;
CREATE TEMPORARY TABLE latest_month_sales AS
SELECT *
FROM sales
WHERE DATE_FORMAT(sale_date,'%Y-%m')=(SELECT DATE_FORMAT(MAX(sale_date),'%Y-%m') FROM sales);

SELECT COUNT(*) AS rows_in_latest_month FROM latest_month_sales;
SELECT branch_id,SUM(total_amount) AS revenue
FROM latest_month_sales GROUP BY branch_id ORDER BY revenue DESC;

-- Temporary table: top 20 customers by spend
DROP TEMPORARY TABLE IF EXISTS top20_customers;
CREATE TEMPORARY TABLE top20_customers AS
SELECT customer_id,SUM(total_amount) AS total_spend
FROM sales GROUP BY customer_id ORDER BY total_spend DESC LIMIT 20;

SELECT c.customer_name,t.total_spend,s.sale_id,s.sale_date,s.total_amount
FROM top20_customers t
JOIN customers c ON c.customer_id=t.customer_id
JOIN sales s ON s.customer_id=t.customer_id
ORDER BY t.total_spend DESC,s.sale_date;

DROP PROCEDURE IF EXISTS GenerateMonthlyBranchReport;
DROP PROCEDURE IF EXISTS GenerateCustomerStatement;
DROP PROCEDURE IF EXISTS GenerateEmployeePayslip;
DROP PROCEDURE IF EXISTS GenerateBranchReportByDateRange;

DELIMITER $$

CREATE PROCEDURE GenerateMonthlyBranchReport(IN p_branch_id INT)
BEGIN
  SELECT b.branch_id,b.branch_name,DATE_FORMAT(s.sale_date,'%Y-%m') AS month,
         COUNT(*) AS transactions,SUM(s.total_amount) AS revenue
  FROM sales s JOIN branches b ON b.branch_id=s.branch_id
  WHERE s.branch_id=p_branch_id
  GROUP BY b.branch_id,b.branch_name,DATE_FORMAT(s.sale_date,'%Y-%m')
  ORDER BY month;
END$$

CREATE PROCEDURE GenerateCustomerStatement(IN p_customer_id INT)
BEGIN
  IF NOT EXISTS (SELECT 1 FROM customers WHERE customer_id=p_customer_id) THEN
    SELECT CONCAT('Customer ',p_customer_id,' not found') AS message;
  ELSE
    SELECT c.customer_id,c.customer_name,s.sale_id,s.sale_date,p.product_name,
           s.quantity,s.unit_price,s.discount_pct,s.total_amount,s.payment_method
    FROM customers c
    LEFT JOIN sales s ON s.customer_id=c.customer_id
    LEFT JOIN products p ON p.product_id=s.product_id
    WHERE c.customer_id=p_customer_id
    ORDER BY s.sale_date,s.sale_id;
  END IF;
END$$

CREATE PROCEDURE GenerateEmployeePayslip(IN p_employee_id INT,IN p_pay_month VARCHAR(7))
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM salaries
    WHERE employee_id=p_employee_id AND pay_month=p_pay_month
  ) THEN
    SELECT CONCAT('No salary record for employee ',p_employee_id,' in ',p_pay_month) AS message;
  ELSE
    SELECT e.employee_id,CONCAT(e.first_name,' ',e.last_name) AS employee_name,
           s.pay_month,s.base_salary,s.bonus,s.deductions,s.net_pay
    FROM salaries s JOIN employees e ON e.employee_id=s.employee_id
    WHERE s.employee_id=p_employee_id AND s.pay_month=p_pay_month;
  END IF;
END$$

CREATE PROCEDURE GenerateBranchReportByDateRange(
  IN p_branch_id INT,IN p_start_date DATE,IN p_end_date DATE
)
BEGIN
  IF p_start_date>p_end_date THEN
    SELECT 'Start date must be before end date' AS message;
  ELSE
    SELECT b.branch_id,b.branch_name,p_start_date AS start_date,p_end_date AS end_date,
           COUNT(s.sale_id) AS transactions,
           COALESCE(SUM(s.total_amount),0) AS revenue
    FROM branches b
    LEFT JOIN sales s
      ON s.branch_id=b.branch_id
     AND s.sale_date BETWEEN p_start_date AND p_end_date
    WHERE b.branch_id=p_branch_id
    GROUP BY b.branch_id,b.branch_name;
  END IF;
END$$

DELIMITER ;

-- Sample calls
CALL GenerateMonthlyBranchReport(1);
CALL GenerateMonthlyBranchReport(4);
CALL GenerateCustomerStatement(1);
CALL GenerateCustomerStatement(177);
CALL GenerateEmployeePayslip(1,'2026-06');
CALL GenerateEmployeePayslip(9999,'2026-06');
CALL GenerateBranchReportByDateRange(1,'2026-01-01','2026-06-30');
