# Week 4 Reconstructed Daily Notes

## Monday — CASE
`CASE` applies conditional logic inside SQL and can turn numeric values into business categories such as Junior/Mid/Senior/Executive or Small/Medium/Large.

## Tuesday — Subqueries
A subquery can calculate a value or result set that the outer query uses. A correlated subquery references the current row of the outer query, while a non-correlated subquery can run independently.

## Wednesday — Window functions
`RANK`, `DENSE_RANK`, and `ROW_NUMBER` calculate rankings without collapsing rows. `RANK` leaves gaps after ties, `DENSE_RANK` does not, and `ROW_NUMBER` always assigns a unique sequence.

## Thursday — Running totals and LAG
Windowed `SUM` can create a running total while preserving daily rows. `LAG` makes the previous row's value available so month-over-month changes can be calculated directly in SQL.

## Friday — Ranking interpretation
`PARTITION BY` restarts a window calculation for each logical group. Correct partitioning is important because an incorrect partition can produce a technically valid but misleading ranking.
