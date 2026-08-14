# Week 5 Reconstructed Daily Notes

## Monday — CTEs
A Common Table Expression gives a temporary name to an intermediate query. It makes multi-step logic easier to read and debug than deeply nested subqueries.

## Tuesday — Temporary tables
A temporary table exists only for the current database session. It is useful for staging intermediate results that will be reused several times without creating a permanent business table.

## Wednesday — Stored procedures
Stored procedures package approved SQL logic behind a simple `CALL`. Parameters allow the same procedure to serve different branches, customers, employees, or date ranges.

## Thursday — Parameters and control flow
`IF` conditions allow procedures to return useful messages for invalid inputs. `DELIMITER` is needed in MySQL clients so semicolons inside a multi-statement procedure body are not mistaken for the end of the `CREATE PROCEDURE` command.

## Friday — Business use
A callable procedure is safer for a non-technical user than a raw query because the underlying logic can be controlled, tested, and reused without asking the user to edit SQL.
