# Running this practice database on Snowflake

This is the same retail star schema as the SQLite version, set up for a Snowflake trial
account. Use it for dialect practice and to get comfortable with the Snowsight UI, since
that's what shows up in interviews and job postings, not SQLite.

## 1. Get a trial account

1. Go to <https://signup.snowflake.com> and sign up (email, no credit card). You get a
   30-day trial with $400 of credit, which is far more than this will use.
2. Pick the **Standard** edition and any nearby region (for Stockholm, an EU region such
   as `eu-central-1` or `eu-west-1` keeps things closer, but it doesn't matter for practice).
3. Log in to **Snowsight** (the web UI) once your account is ready.

## 2. Create a database, schema and warehouse

In a Snowsight worksheet, run:

```sql
CREATE OR REPLACE WAREHOUSE practice_wh WITH WAREHOUSE_SIZE = 'XSMALL' AUTO_SUSPEND = 60 AUTO_RESUME = TRUE;
CREATE OR REPLACE DATABASE retail_practice;
CREATE OR REPLACE SCHEMA retail_practice.public;
USE WAREHOUSE practice_wh;
USE DATABASE retail_practice;
USE SCHEMA public;
```

`AUTO_SUSPEND = 60` stops the compute warehouse after 60 seconds idle, which conserves your
trial credit. `XSMALL` is the smallest and cheapest size, and plenty for this dataset.

## 3. Create the tables

Open `snowflake_ddl.sql` from this folder, paste it into a new worksheet, and run it. It
creates the same 7 tables as the SQLite version (`dim_customer`, `dim_product`, `dim_date`,
`fact_orders`, `fact_order_lines`, `sales_targets`, `raw_customers`) with Snowflake types.

## 4. Load the data

The `data_csv/` folder has one CSV per table, already exported from the practice database
(with headers). The easiest way to load them, with no command line needed:

1. In Snowsight, go to **Data > Databases**, drill into `RETAIL_PRACTICE.PUBLIC`, and click a
   table (for example `DIM_CUSTOMER`).
2. Click **Load Data**, choose the matching CSV from `data_csv/`, and let Snowflake auto-detect
   the file format. Under **Header**, choose "Skip first line" since the CSV has a header row.
3. Match columns automatically (the CSV headers match the table columns) and load.
4. Repeat for all 7 tables. Load `dim_date` and `dim_product` first, since they're small and
   let you confirm the process before doing the bigger fact tables.

(If you prefer the command line instead: install SnowSQL, `PUT` the CSVs to a stage, and
`COPY INTO` each table. The UI method above is simpler for a first pass.)

## 5. Check the load

```sql
SELECT 'dim_customer' AS t, COUNT(*) FROM dim_customer
UNION ALL SELECT 'dim_product', COUNT(*) FROM dim_product
UNION ALL SELECT 'dim_date', COUNT(*) FROM dim_date
UNION ALL SELECT 'fact_orders', COUNT(*) FROM fact_orders
UNION ALL SELECT 'fact_order_lines', COUNT(*) FROM fact_order_lines
UNION ALL SELECT 'sales_targets', COUNT(*) FROM sales_targets
UNION ALL SELECT 'raw_customers', COUNT(*) FROM raw_customers;
```

Expected counts: dim_customer 150, dim_product 30, dim_date 731, fact_orders 700,
fact_order_lines 1381, sales_targets 60, raw_customers 70.

## 6. Which exercises to use

Files `01`, `02` and most of `03` and `05` run on Snowflake **with no changes** — standard
joins, `GROUP BY`, `CASE`, CTEs, `LIMIT`, `RANK()`, `ROW_NUMBER()`, `NTILE()`, `LAG()` and
`TRIM`/`COALESCE`/`NULLIF` all work exactly the same. Paste them straight from the
`exercises/` folder.

File `04` (dates and cohorts) uses SQLite-only functions (`strftime`, `julianday`,
`date(..., '+1 month')`), so use `04_dates_cohorts_retention_snowflake.sql` in this folder
instead — same 7 questions, Snowflake syntax.

## Dialect cheat sheet: SQLite vs Snowflake vs SQL Server

You already know the SQL Server column; this bridges to Snowflake.

| Task | SQLite (repo default) | Snowflake | SQL Server |
|---|---|---|---|
| Limit rows | `LIMIT 5` | `LIMIT 5` (or `TOP 5`) | `TOP 5` |
| Null fallback | `COALESCE(a, b)` | `COALESCE(a, b)` | `ISNULL(a, b)` or `COALESCE` |
| Today | `date('now')` | `CURRENT_DATE()` | `GETDATE()` |
| Format date as text | `strftime('%Y-%m', d)` | `TO_CHAR(d, 'YYYY-MM')` | `FORMAT(d, 'yyyy-MM')` |
| Add a month | `date(d, '+1 month')` | `DATEADD('month', 1, d)` | `DATEADD(month, 1, d)` |
| Days between dates | `julianday(b) - julianday(a)` | `DATEDIFF('day', a, b)` | `DATEDIFF(day, a, b)` |
| Parse text to date | `date(text)` | `TO_DATE(text)` | `CAST(text AS DATE)` |
| String concat | `a \|\| b` | `a \|\| b` | `a + b` |
| String length | `LENGTH(x)` | `LENGTH(x)` | `LEN(x)` |
| Cast to text | `CAST(x AS TEXT)` | `TO_VARCHAR(x)` or `CAST(x AS VARCHAR)` | `CAST(x AS VARCHAR)` |

Everything else — joins, `GROUP BY`/`HAVING`, subqueries, CTEs, window functions
(`ROW_NUMBER`, `RANK`, `LAG`/`LEAD`, `NTILE`, `SUM() OVER (...)`), and `CASE` — is the same
across all three, which is why most of the exercise files need no changes at all.

## Managing trial costs

- The `XSMALL` warehouse with `AUTO_SUSPEND = 60` costs credits only while it's actually
  running a query, so casual daily practice uses very little of your $400.
- Check usage any time under **Admin > Usage** in Snowsight.
- When the 30-day trial ends, you can either start a new trial with a different email, or
  keep using the SQLite version, which has no time limit.
