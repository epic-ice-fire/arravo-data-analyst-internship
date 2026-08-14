# Week 1 — Arravo Retail Database Setup

**Dates:** 29 June–3 July 2026  
**Tool:** MySQL  
**Topics:** installation, schema setup, SELECT, ER modelling

## Database purpose

The `arravo_retail` database models a fictional Nigerian electronics and home-appliance retailer. It combines HR, payroll, attendance, suppliers, products, customers and sales so the same business can be analysed throughout the internship.

## Tables and expected row counts

| Table | Rows |
|---|---:|
| branches | 5 |
| departments | 8 |
| positions | 20 |
| employees | 120 |
| salaries | 1,407 |
| attendance | 2,280 |
| suppliers | 20 |
| products | 180 |
| customers | 400 |
| sales | 3,000 |

## Primary key vs foreign key

A **primary key** uniquely identifies each row in a table.  
A **foreign key** stores the primary-key value of another table so related records can be linked while preserving referential integrity.

## ER relationships

- departments 1→many positions
- departments 1→many employees
- positions 1→many employees
- branches 1→many employees
- employees 1→many salaries
- employees 1→many attendance
- suppliers 1→many products
- branches 1→many sales
- employees 1→many sales
- customers 1→many sales
- products 1→many sales

## Explain-back

A relational database stores information in separate tables and connects those tables using keys. This avoids repeating the same information everywhere and makes the data easier to query consistently. A primary key gives each record a unique identity, while foreign keys create controlled relationships between tables.
