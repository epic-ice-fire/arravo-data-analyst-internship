# Week 5 — Stored Procedure Usage Guide

## `GenerateMonthlyBranchReport(branch_id)`

Returns monthly transaction count and revenue for one branch.

```sql
CALL GenerateMonthlyBranchReport(1);
```

## `GenerateCustomerStatement(customer_id)`

Returns a customer's purchase history. If the ID does not exist, the procedure returns a readable message instead of an empty-looking result.

```sql
CALL GenerateCustomerStatement(177);
```

## `GenerateEmployeePayslip(employee_id, pay_month)`

Returns base salary, bonus, deductions and net pay for one employee/month. `pay_month` is stored as `YYYY-MM`.

```sql
CALL GenerateEmployeePayslip(1, '2026-06');
```

## `GenerateBranchReportByDateRange(branch_id, start_date, end_date)`

Returns transaction count and revenue for a branch over a chosen date range.

```sql
CALL GenerateBranchReportByDateRange(1, '2026-01-01', '2026-06-30');
```

Stored procedures are useful for non-technical users because the approved query logic can be packaged behind a simple `CALL`, reducing accidental edits to complex SQL.
