# Arravo Data Analyst Internship — Reconstructed Weeks 1–7

This repository contains reconstructed technical work for Weeks 1–7 of the Arravo Technology Limited Data Analyst Internship Program (Program Code: ARR-DA-INT-2026-001).

## Important note

The original local work was lost with an old laptop. These files were reconstructed on **14 August 2026** from:
- the official Arravo Retail Group dataset supplied for the internship; and
- the official Daily Task Edition curriculum.

The reconstruction is intentionally **not backdated**. It recreates the technical deliverables and supporting notes, but it does not pretend that mentor demos, peer reviews, Trello updates, or historical GitHub commits occurred when they did not.

## Week folders

- `week-01-database-setup` — schema checks, SELECT queries, ER diagram
- `week-02-hr-sales-reporting` — filtering, aggregation, HAVING, ORDER BY, LIMIT, 15 reports
- `week-03-joins` — JOIN/UNION/string functions, gap analysis, performance reports
- `week-04-ranking-performance` — CASE, subqueries, window functions, 20 complex queries
- `week-05-finance-reporting` — CTEs, temporary tables, stored procedures
- `week-06-audit-events` — triggers, history tables, scheduled event
- `week-07-data-cleaning` — staging, cleaning, deduplication, validation, report

## Dataset summary

The Arravo Retail Group training database contains 10 tables:
`branches`, `departments`, `positions`, `employees`, `salaries`, `attendance`, `suppliers`, `products`, `customers`, and `sales`.

Expected row counts:

| Table | Rows |
|---|---:|
| branches | 5 |
| departments | 8 |
| positions | 20 |
| employees | 120 |
| salaries | 1,407 |
| attendance | 2,280 |
| suppliers | 20 |
| products | 180 |
| customers | 400 |
| sales | 3,000 |

## MySQL setup

Import the supplied seed file first:

```bash
mysql -u root -p < arravo_retail_schema_and_seed.sql
```

Then run the scripts in week order.
