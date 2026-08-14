# Week 4 — Ranking & Performance Analytics

**Dates:** 20–24 July 2026  
**Topics:** `CASE`, subqueries, `RANK`, `DENSE_RANK`, `ROW_NUMBER`, running totals, `LAG`

## Explain-back notes

`CASE` lets SQL assign a value based on conditions for each row, so it is useful for business categories such as salary bands or sale sizes.

A non-correlated subquery can run independently of the outer query. A correlated subquery references a value from the current outer row, so it is evaluated in relation to that row.

`RANK()` leaves gaps after ties, `DENSE_RANK()` does not leave gaps, and `ROW_NUMBER()` always assigns a unique sequence number.

`PARTITION BY` restarts a window calculation for each group while keeping the original row-level detail.
