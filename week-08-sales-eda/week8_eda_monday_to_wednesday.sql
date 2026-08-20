-- Week 8 — Sales Exploratory Data Analysis
-- Monday to Wednesday EDA query pack
-- Tool: MySQL

USE arravo_retail;

/* ============================================================
   MONDAY — FRAMING THE EDA QUESTIONS
   ============================================================ */

-- Query 1: Total revenue, transactions, and average order value
-- Interpretation: Establishes the headline sales KPIs for the latest 12 months.
WITH bounds AS (
    SELECT
        DATE_SUB(DATE_FORMAT(MAX(sale_date), '%Y-%m-01'), INTERVAL 11 MONTH) AS start_date,
        LAST_DAY(MAX(sale_date)) AS end_date
    FROM sales
)
SELECT
    ROUND(SUM(s.total_amount), 2) AS total_revenue,
    COUNT(s.sale_id) AS total_transactions,
    ROUND(AVG(s.total_amount), 2) AS average_order_value
FROM sales s
CROSS JOIN bounds b
WHERE s.sale_date BETWEEN b.start_date AND b.end_date;

-- Query 2: Revenue by branch
-- Interpretation: Shows which locations contribute the most and least sales revenue.
SELECT
    b.branch_id,
    b.branch_name,
    ROUND(SUM(s.total_amount), 2) AS revenue,
    DENSE_RANK() OVER (ORDER BY SUM(s.total_amount) DESC) AS revenue_rank
FROM sales s
JOIN branches b ON b.branch_id = s.branch_id
GROUP BY b.branch_id, b.branch_name
ORDER BY revenue DESC;

-- Query 3: Revenue by product category
-- Interpretation: Identifies the product categories driving the largest share of sales.
SELECT
    p.category,
    ROUND(SUM(s.total_amount), 2) AS revenue,
    DENSE_RANK() OVER (ORDER BY SUM(s.total_amount) DESC) AS category_rank
FROM sales s
JOIN products p ON p.product_id = s.product_id
GROUP BY p.category
ORDER BY revenue DESC;

/* ============================================================
   TUESDAY — CUSTOMER ANALYSIS
   ============================================================ */

-- Query 4: Customer value tiers based on total spend
-- Interpretation: Splits customers into three relative value groups using lifetime spend.
WITH customer_spend AS (
    SELECT
        c.customer_id,
        c.customer_name,
        COALESCE(SUM(s.total_amount), 0) AS total_spend
    FROM customers c
    LEFT JOIN sales s ON s.customer_id = c.customer_id
    GROUP BY c.customer_id, c.customer_name
),
tiered AS (
    SELECT
        customer_id,
        customer_name,
        total_spend,
        NTILE(3) OVER (ORDER BY total_spend) AS spend_tier
    FROM customer_spend
)
SELECT
    customer_id,
    customer_name,
    ROUND(total_spend, 2) AS total_spend,
    CASE spend_tier
        WHEN 1 THEN 'Low Value'
        WHEN 2 THEN 'Medium Value'
        WHEN 3 THEN 'High Value'
    END AS customer_value_tier
FROM tiered
ORDER BY total_spend DESC;

-- Query 5: Top 20 customers by lifetime spend
-- Interpretation: Highlights the customers contributing the most revenue overall.
SELECT
    c.customer_id,
    c.customer_name,
    ROUND(SUM(s.total_amount), 2) AS lifetime_spend,
    COUNT(s.sale_id) AS transactions
FROM sales s
JOIN customers c ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY lifetime_spend DESC
LIMIT 20;

-- Query 6: Top 20 customers and their preferred branch
-- Preferred branch = branch where the customer generated the highest total spend.
-- Interpretation: Links high-value customers to the location they spend most with.
WITH customer_branch_spend AS (
    SELECT
        s.customer_id,
        s.branch_id,
        SUM(s.total_amount) AS branch_spend
    FROM sales s
    GROUP BY s.customer_id, s.branch_id
),
ranked_branch AS (
    SELECT
        customer_id,
        branch_id,
        branch_spend,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY branch_spend DESC, branch_id
        ) AS rn
    FROM customer_branch_spend
),
customer_total AS (
    SELECT
        customer_id,
        SUM(total_amount) AS lifetime_spend
    FROM sales
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    ROUND(ct.lifetime_spend, 2) AS lifetime_spend,
    b.branch_name AS preferred_branch,
    ROUND(rb.branch_spend, 2) AS spend_at_preferred_branch
FROM customer_total ct
JOIN customers c ON c.customer_id = ct.customer_id
JOIN ranked_branch rb ON rb.customer_id = ct.customer_id AND rb.rn = 1
JOIN branches b ON b.branch_id = rb.branch_id
ORDER BY ct.lifetime_spend DESC
LIMIT 20;

-- Query 7: Repeat-purchase rate
-- Interpretation: Measures how much of the customer base returns for more than one purchase.
WITH customer_transactions AS (
    SELECT
        c.customer_id,
        COUNT(s.sale_id) AS transaction_count
    FROM customers c
    LEFT JOIN sales s ON s.customer_id = c.customer_id
    GROUP BY c.customer_id
)
SELECT
    COUNT(*) AS total_customers,
    SUM(transaction_count > 1) AS repeat_customers,
    ROUND(100.0 * SUM(transaction_count > 1) / COUNT(*), 2) AS repeat_purchase_rate_pct
FROM customer_transactions;

-- Query 8: Dormant customers
-- Rule: signed up at least six months before the latest sale date and have zero purchases.
-- Interpretation: Identifies older customer records that have never converted into a sale.
WITH anchor_date AS (
    SELECT MAX(sale_date) AS latest_sale_date
    FROM sales
)
SELECT
    c.customer_id,
    c.customer_name,
    c.signup_date,
    c.customer_segment
FROM customers c
CROSS JOIN anchor_date a
LEFT JOIN sales s ON s.customer_id = c.customer_id
WHERE c.signup_date <= DATE_SUB(a.latest_sale_date, INTERVAL 6 MONTH)
GROUP BY c.customer_id, c.customer_name, c.signup_date, c.customer_segment
HAVING COUNT(s.sale_id) = 0
ORDER BY c.signup_date;

-- Query 9: RFM-style customer summary
-- Interpretation: Combines recency, frequency, and monetary value for customer behaviour analysis.
WITH anchor_date AS (
    SELECT MAX(sale_date) AS latest_sale_date
    FROM sales
)
SELECT
    c.customer_id,
    c.customer_name,
    DATEDIFF(a.latest_sale_date, MAX(s.sale_date)) AS recency_days,
    COUNT(s.sale_id) AS frequency,
    ROUND(COALESCE(SUM(s.total_amount), 0), 2) AS monetary_value
FROM customers c
CROSS JOIN anchor_date a
LEFT JOIN sales s ON s.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name, a.latest_sale_date
ORDER BY monetary_value DESC;

/* ============================================================
   WEDNESDAY — PRODUCT AND SEASONALITY ANALYSIS
   ============================================================ */

-- Query 10: Monthly revenue trend
-- Interpretation: Shows the direction and size of revenue changes across the 12-month period.
SELECT
    DATE_FORMAT(sale_date, '%Y-%m') AS sales_month,
    COUNT(sale_id) AS transactions,
    ROUND(SUM(total_amount), 2) AS revenue,
    ROUND(AVG(total_amount), 2) AS average_order_value
FROM sales
GROUP BY DATE_FORMAT(sale_date, '%Y-%m')
ORDER BY sales_month;

-- Query 11: Strongest and weakest revenue months
-- Interpretation: Quickly identifies the best and worst monthly revenue periods.
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(sale_date, '%Y-%m') AS sales_month,
        SUM(total_amount) AS revenue
    FROM sales
    GROUP BY DATE_FORMAT(sale_date, '%Y-%m')
),
ranked AS (
    SELECT
        sales_month,
        revenue,
        DENSE_RANK() OVER (ORDER BY revenue DESC) AS strongest_rank,
        DENSE_RANK() OVER (ORDER BY revenue ASC) AS weakest_rank
    FROM monthly_revenue
)
SELECT
    sales_month,
    ROUND(revenue, 2) AS revenue,
    CASE
        WHEN strongest_rank = 1 THEN 'Strongest Month'
        WHEN weakest_rank = 1 THEN 'Weakest Month'
    END AS performance_flag
FROM ranked
WHERE strongest_rank = 1 OR weakest_rank = 1
ORDER BY revenue DESC;

-- Query 12: Best-selling product category by revenue for each month
-- Interpretation: Reveals changes in category leadership that may indicate seasonality.
WITH monthly_category_revenue AS (
    SELECT
        DATE_FORMAT(s.sale_date, '%Y-%m') AS sales_month,
        p.category,
        SUM(s.total_amount) AS revenue
    FROM sales s
    JOIN products p ON p.product_id = s.product_id
    GROUP BY DATE_FORMAT(s.sale_date, '%Y-%m'), p.category
),
ranked AS (
    SELECT
        sales_month,
        category,
        revenue,
        ROW_NUMBER() OVER (
            PARTITION BY sales_month
            ORDER BY revenue DESC, category
        ) AS rn
    FROM monthly_category_revenue
)
SELECT
    sales_month,
    category AS top_category,
    ROUND(revenue, 2) AS category_revenue
FROM ranked
WHERE rn = 1
ORDER BY sales_month;

-- Query 13: Dead-stock candidates
-- Rule: products with above-average current stock but among the lowest revenue performers.
-- Interpretation: Flags stock tied up in products generating relatively little revenue.
WITH product_performance AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        p.stock_qty,
        COALESCE(SUM(s.quantity), 0) AS units_sold,
        COALESCE(SUM(s.total_amount), 0) AS revenue
    FROM products p
    LEFT JOIN sales s ON s.product_id = p.product_id
    GROUP BY p.product_id, p.product_name, p.category, p.stock_qty
)
SELECT
    product_id,
    product_name,
    category,
    stock_qty,
    units_sold,
    ROUND(revenue, 2) AS revenue
FROM product_performance
WHERE stock_qty >= (SELECT AVG(stock_qty) FROM products)
ORDER BY revenue ASC, stock_qty DESC
LIMIT 10;

-- Query 14: Discount impact on average order value
-- Interpretation: Compares order size and revenue for discounted versus non-discounted transactions.
SELECT
    CASE
        WHEN discount_pct > 0 THEN 'Discounted'
        ELSE 'Not Discounted'
    END AS discount_status,
    COUNT(sale_id) AS transactions,
    ROUND(AVG(total_amount), 2) AS average_order_value,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    ROUND(AVG(discount_pct), 2) AS average_discount_pct
FROM sales
GROUP BY
    CASE
        WHEN discount_pct > 0 THEN 'Discounted'
        ELSE 'Not Discounted'
    END
ORDER BY discount_status;

/* ============================================================
   WEEKLY SQL CHALLENGE CHECK
   ============================================================
   This file contains 14 EDA queries covering:
   - Revenue and headline KPIs
   - Branch performance
   - Product-category performance
   - Customer value and RFM-style analysis
   - Repeat purchases and dormant customers
   - Monthly trends and seasonality
   - Dead-stock candidates
   - Discount impact

   Each major query includes a one-line interpretation as required.
   ============================================================ */
