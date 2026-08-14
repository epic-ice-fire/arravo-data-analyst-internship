# Week 6 — Audit & Automation Summary

The Week 6 system adds automatic controls around four business areas:

- **Sales inserts:** every new sale is logged in `audit_log`.
- **Employee salary changes:** old and new salary values are captured in `salary_history`.
- **Customer deletion:** the full customer row is preserved as JSON in `deleted_records_log` before deletion.
- **Low stock:** when stock falls from 5 or more units to below 5, `stock_alerts` records the event.
- **Daily sales summary:** a scheduled MySQL event refreshes `daily_sales_summary` once per day.

## What is automatic

Triggers react immediately to qualifying `INSERT`, `UPDATE`, or `DELETE` statements. The scheduled event performs a recurring aggregation without requiring an analyst to run the report manually.

## What remains manual

An analyst still needs to review the logs, investigate unusual changes, verify the event scheduler is enabled after server changes, and decide what business action to take from alerts.

## Trigger vs event

A **trigger** fires because a table-changing statement occurs. A scheduled **event** fires because a time condition is reached. Both reduce repetitive work, but they solve different automation problems.
