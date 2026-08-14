# Week 3 Findings Memo

## Gap analysis

Using `LEFT JOIN ... IS NULL` checks against the supplied dataset:

- Employees with no salary records: **0**
- Products never sold: **0**
- Customers who never purchased: **0**
- Branches with no employees: **0**

The supplied training dataset is therefore highly complete across these relationships.

## Top performers

The highest-revenue sales rep in the supplied data is **Chiamaka Adebayo**, with approximately ₦95,246,910 in recorded sales.

The highest-revenue branch is **Arravo Retail - Victoria Island**, with approximately ₦437,667,235 in revenue.

## JOIN lesson

A JOIN can multiply rows when one row on the left matches multiple rows on the right. Aggregating to the correct grain before joining prevents accidental fan-out and incorrect totals.
