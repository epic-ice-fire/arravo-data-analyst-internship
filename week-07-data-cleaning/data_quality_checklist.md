# Reusable Data-Quality Checklist

## Structure
- [ ] Confirm expected columns exist.
- [ ] Confirm data types are appropriate.
- [ ] Record raw row count.
- [ ] Count unique primary-key values.

## Missing values
- [ ] Count NULLs and blank strings per column.
- [ ] Decide whether to exclude, flag, or impute missing values.
- [ ] Document the reason for each decision.

## Duplicates
- [ ] Find duplicate primary keys.
- [ ] Find exact duplicate rows.
- [ ] Decide which record to keep and why.

## Text consistency
- [ ] Trim leading/trailing whitespace.
- [ ] Standardise casing.
- [ ] Standardise category labels.
- [ ] Check email and phone formatting.

## Dates and numbers
- [ ] Identify all date formats.
- [ ] Parse dates to one standard date type.
- [ ] Check impossible/out-of-range dates.
- [ ] Check numeric values for unexpected negatives or extreme values.

## Validation
- [ ] Re-run row counts.
- [ ] Re-run NULL/blank checks.
- [ ] Re-run uniqueness checks.
- [ ] Check foreign-key relationships where relevant.
- [ ] Spot-check random records against source data.
- [ ] Save the cleaning SQL and a transformation log.
