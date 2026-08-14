# Week 3 Reconstructed Daily Notes

## Monday — INNER JOIN
A JOIN combines rows from related tables using matching key values. `INNER JOIN` keeps only rows where the relationship exists on both sides.

## Tuesday — LEFT JOIN
`LEFT JOIN` keeps every row from the left table even when no match exists on the right. Filtering for `right_table.key IS NULL` is a common way to find missing relationships.

## Wednesday — UNION
`UNION` stacks compatible result sets and removes duplicates. `UNION ALL` keeps duplicates and is usually faster because it does not perform duplicate elimination.

## Thursday — String functions and fan-out
Functions such as `TRIM`, `REPLACE`, `LENGTH`, and `CONCAT` help standardise and present text. Joins can silently multiply row counts when one row matches several rows, so I must always check the intended grain before aggregating.

## Friday — Performance reporting
Combining sales, employees, branches, products, and customers makes it possible to move from raw transactions to business questions such as who sells the most, which branches perform best, and whether any products or customers are disconnected from activity.
