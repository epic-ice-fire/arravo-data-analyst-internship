# Week 2 Reconstructed Daily Notes

## Monday — WHERE
`WHERE` filters individual rows before aggregation. Operators such as `=`, `>`, `BETWEEN`, `IN`, and `LIKE` let an analyst narrow a table to the records relevant to a business question.

## Tuesday — GROUP BY
`GROUP BY` changes the grain of a result by producing one summary row per group. Aggregate functions such as `COUNT`, `SUM`, and `AVG` then describe each group.

## Wednesday — HAVING
`WHERE` filters source rows before grouping, while `HAVING` filters the aggregated groups after `GROUP BY`. This is why aggregate conditions such as `HAVING SUM(total_amount) > 5000000` belong in `HAVING`.

## Thursday — ORDER BY / LIMIT
`ORDER BY` controls result order and `LIMIT` restricts how many rows are returned. Adding `OFFSET` skips a chosen number of ordered rows, which can be used for pagination or to find the next-ranked result.

## Friday — Reporting
A useful analyst report should combine correct SQL with a plain-language explanation of what the result means for the business.
