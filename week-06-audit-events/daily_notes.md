# Week 6 Reconstructed Daily Notes

## Monday — Triggers
Inside a MySQL trigger, `NEW` represents the new row values being inserted or updated, while `OLD` represents the previous row values available during updates or deletes.

## Tuesday — Audit history
An audit trail records who/what changed and when. For sensitive business records such as salary data, preserving the old and new values improves accountability, troubleshooting, and compliance.

## Wednesday — Trigger vs event
A trigger reacts to a data-changing statement such as `INSERT`, `UPDATE`, or `DELETE`. A scheduled event runs because a defined time is reached, even when no user is actively running a query.

## Thursday — Scheduled jobs
Recurring events can automate daily summaries so the same report does not have to be rebuilt manually each morning. The event scheduler must be enabled and the event definition should be checked when a job does not run.

## Friday — Automation
Automation reduces repetitive work and makes routine logging more consistent, but the generated logs and summaries still require human review and business interpretation.
