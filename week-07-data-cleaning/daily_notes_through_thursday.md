# Week 7 Daily Notes (through Thursday)

## Monday — First look at messy data

Messy data is normal in real analyst work because operational systems collect information from different people, interfaces and processes. Before cleaning, I first need to profile the data so I know the size and type of each problem. The raw customer file has 419 rows but only 400 unique customer IDs, so duplicate handling is necessary.

## Tuesday — Standardising text fields

Inconsistent categories silently split what should be one group into several groups. For example, `SME` and `sme` are different strings to SQL even though they mean the same business segment. Standardisation ensures later `GROUP BY` reports produce reliable totals.

## Wednesday — Fixing dates and duplicates

Cleaning decisions should be documented because another analyst needs to understand how the final data was produced. Recording the rule used for duplicate removal, date parsing and missing values makes the process auditable and reproducible.

## Thursday — Validating the clean dataset

Data validation is the final proof that cleaning worked. It checks expected row counts, required fields, uniqueness and data formats rather than assuming that successful SQL execution means the data is correct. Validation matters because downstream dashboards and reports inherit any mistakes left in the cleaned table.
