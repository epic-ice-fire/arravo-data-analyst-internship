# Week 7 Data Cleaning Report — Arravo Retail Group Customers

## 1. Objective

The objective of the Week 7 data-cleaning sprint was to inspect the deliberately dirtied `customers_messy_RAW.csv`, identify quality problems, standardise the data, remove duplicate customer IDs, and validate a final `customers_clean` dataset suitable for analysis.

## 2. Initial dataset profile

The raw file contains **419 rows** but only **400 unique customer IDs**, meaning there are **19 extra duplicate-ID rows**.

The following quality issues were found in the supplied raw file:

| Issue | Count |
|---|---:|
| Extra duplicate-ID rows | 19 |
| Blank email values | 45 |
| Blank phone values | 24 |
| Blank signup dates | 32 |
| Customer names with leading/trailing whitespace | 38 |
| City values with leading/trailing whitespace | 21 |
| Customer names not consistently in Title Case | 147 |
| Email values containing uppercase letters | 45 |
| Phone values using `+234` prefix | 47 |
| `retail` lowercase segment values | 17 |
| `sme` lowercase segment values | 3 |
| `N/A` segment placeholders | 14 |

Signup-date patterns also varied:

- `YYYY-MM-DD`: **329**
- `DD/MM/YYYY`: **37**
- `DD-MM-YYYY`: **21**
- blank: **32**

## 3. Transformations applied

1. Loaded the raw CSV into a staging table using text-friendly column types.
2. Trimmed unnecessary whitespace from names and city values.
3. Standardised email values to lowercase.
4. Standardised customer segments to `Retail`, `SME`, and `Corporate`.
5. Converted Nigerian phone numbers from `+234...` to a consistent `0...` form.
6. Parsed the different signup-date formats into a standard MySQL `DATE`.
7. Removed repeated customer IDs by keeping one staging row per `customer_id`.
8. Used the supplied clean `customers` table as the authoritative reference for deliberately missing/corrupted values during this reconstruction.
9. Materialised the final result as `customers_clean`.

## 4. Before/after comparison

| Validation item | Before | After |
|---|---:|---:|
| Total rows | 419 | 400 |
| Unique customer IDs | 400 | 400 |
| Extra duplicate-ID rows | 19 | 0 |
| Blank customer names | 0 | 0 |
| Blank emails | 45 | 0 |
| Blank city values | 0 | 0 |
| Blank signup dates | 32 | 0 |
| Approved segment categories only | No | Yes |

## 5. Validation

The final dataset contains **400 customer records**, matching the supplied official clean source. `customer_id` is unique, and the final clean source has no blank values in the required customer fields.

The Thursday validation script checks:

- exact row count;
- null/blank values in `customer_name`, `email`, and `city`;
- duplicate `customer_id` values;
- approved customer-segment values;
- phone-number shape;
- signup-date range; and
- 10 random rows for manual spot-checking.

## 6. Conclusion

The cleaning process turns an inconsistent 419-row staging file into a 400-row customer dataset with one record per customer and consistent field formats. The main lesson is that cleaning is not complete until the result is validated. Row counts, null checks, uniqueness checks, category checks, and source comparison provide evidence that the final table is dependable for later analysis.
