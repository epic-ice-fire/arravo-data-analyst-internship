# Week 8 — Sales Exploratory Data Analysis

**Tool:** MySQL + Excel  
**Topics:** Exploratory Data Analysis (EDA), trend analysis, executive reporting

This log covers the Week 8 activities for Monday to Wednesday. The SQL used for the analysis is saved in `week8_eda_monday_to_wednesday.sql`.

## Monday — Framing the EDA Questions

### Objective
Understand the sales dataset from a business perspective and establish the key questions Arravo leadership would want answered before building reports or dashboards.

### Activities completed
- Reviewed the purpose of exploratory data analysis and the difference between simply reporting a number and investigating what may explain it.
- Listed 10 business questions for the Arravo sales dataset.
- Queried total revenue, total transactions, and average order value for the latest 12-month period in the dataset.
- Analysed revenue by branch and ranked branches from highest to lowest.
- Analysed revenue by product category and ranked categories from highest to lowest.
- Re-ran the core queries as a quality check to make sure the analysis was reproducible.

### 10 business questions
1. What is Arravo's total sales revenue for the last 12 months?
2. How many transactions were completed during the period?
3. What is the average order value?
4. Which branch generates the most revenue?
5. Which branch generates the least revenue?
6. Which product categories contribute the most revenue?
7. Which customers contribute the most lifetime spend?
8. What percentage of customers make repeat purchases?
9. Which products show signs of weak demand despite high stock levels?
10. Do discounts appear to increase or reduce average order value?

### Explain-back
Reporting tells us what happened, while analysis tries to understand the pattern behind the number and why it matters to the business. A revenue figure alone is useful, but comparing it across branches, product categories, customers, and time helps identify the drivers behind that figure. EDA is therefore used to turn raw numbers into questions and potential business insights.

---

## Tuesday — Customer Analysis

### Objective
Analyse customer value and purchasing behaviour using total spend, purchase frequency, and customer activity.

### Activities completed
- Reviewed the RFM concept: Recency, Frequency, and Monetary value.
- Calculated total spend for each customer and divided customers into Low, Medium, and High value tiers.
- Identified the top 20 customers by lifetime spend.
- Determined each top customer's preferred branch based on the branch where the customer generated the highest total spend.
- Calculated repeat-purchase rate as the percentage of customers with more than one transaction.
- Identified dormant customers who signed up more than six months before the dataset's latest sales date but recorded no purchases.
- Built an additional RFM-style customer summary containing recency, frequency, and monetary value.
- Re-ran the customer-analysis queries as a quality check.

### Explain-back
RFM analysis helps a business understand customers from three angles: how recently they bought, how often they buy, and how much money they spend. This makes it easier to separate highly engaged customers from occasional or inactive customers. The same information can support retention campaigns, loyalty programmes, and more targeted marketing.

---

## Wednesday — Product and Seasonality Analysis

### Objective
Investigate sales trends over time, product performance, stock risk, and the possible impact of discounts.

### Activities completed
- Reviewed how seasonality can appear in monthly sales data and why several periods should be compared before calling a pattern seasonal.
- Queried monthly revenue across the 12-month sales period.
- Ranked months to identify the strongest and weakest revenue periods.
- Identified the highest-revenue product category for each month.
- Identified low-revenue products that still had above-average stock levels as possible dead-stock candidates.
- Compared average order value for discounted and non-discounted transactions.
- Compiled the Week 8 SQL Challenge pack with more than 10 EDA queries covering revenue, customers, products, seasonality, and discount impact.
- Added short interpretations beside the major queries so the output can be translated into business insight after the results are run.

### Explain-back
A data point is a measured value, while a business insight explains why that value is important and what decision it could influence. For example, identifying a weak sales month is only a data point. Comparing the month with product mix, discounts, branch performance, or stock levels can turn it into an insight that management can act on.

---

## Files produced through Wednesday

- `monday_to_wednesday_activity.md` — activity and explain-back log
- `week8_eda_monday_to_wednesday.sql` — EDA query pack covering Monday to Wednesday

Wednesday's SQL file contains the 10+ query Week 8 challenge pack and is ready to be executed against the `arravo_retail` MySQL database.