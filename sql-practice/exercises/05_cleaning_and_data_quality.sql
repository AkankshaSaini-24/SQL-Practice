-- 05 - Cleaning and data quality
-- Analytics-engineering skills: de-duplication, staging views, dbt-style tests, modelling.
-- Write your answer under each question. Run it, then compare the row count and
-- first row with the 'Expected' line. When it matches, peek at the solutions file.
-- Database: practice.db (see README.md for setup). SQLite dialect.

-- ==========================================================================
-- Q1 [Easy] Clean the raw customers
-- raw_customers is messy (extra spaces, mixed-case emails, NULL cities).
-- Return every row with: customer_id, full_name (trimmed), email (trimmed
-- and lower-case), city (trimmed, NULL replaced by 'Unknown').
--
-- Hint: TRIM, LOWER and COALESCE. Note that an empty-string email is not
-- NULL yet.
-- Expected: 70 rows. Columns: customer_id, full_name, email, city.
-- First row: 5022, Leila Silva, leila.silva@example.com, Uppsala
-- ==========================================================================



-- ==========================================================================
-- Q2 [Easy] Find duplicate IDs
-- Which customer_ids appear more than once in raw_customers? Columns:
-- customer_id, row_count. Most duplicated first, then by customer_id.
--
-- Hint: GROUP BY customer_id HAVING COUNT(*) > 1.
-- Expected: 16 rows. Columns: customer_id, row_count.
-- First row: 5004, 3
-- ==========================================================================



-- ==========================================================================
-- Q3 [Medium] Keep the latest row per ID
-- De-duplicate raw_customers: keep only the most recent row (by updated_at)
-- for each customer_id. Return all columns, ordered by customer_id.
--
-- Hint: ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY updated_at
-- DESC) then keep rn = 1.
-- Expected: 45 rows. Columns: customer_id, full_name, email, city,
-- updated_at.
-- First row: 5001, Anna Lindberg, ANNA.LINDBERG@EXAMPLE.COM, Uppsala,
-- 2025-01-07 18:51:00
-- ==========================================================================



-- ==========================================================================
-- Q4 [Easy] Missing emails
-- How many raw_customers rows have a missing email (NULL or empty/blank
-- text), and what percentage of all rows is that? One row:
-- missing_email_rows, total_rows, missing_pct (1 decimal).
--
-- Hint: email IS NULL OR TRIM(email) = ''. Use SUM(CASE ...) to count.
-- Expected: 1 row. Columns: missing_email_rows, total_rows, missing_pct.
-- First row: 7, 70, 10.0
-- ==========================================================================



-- ==========================================================================
-- Q5 [Medium] Build a staging view
-- Create a view called stg_customers that is de-duplicated (latest row per
-- customer_id) AND cleaned (as in the first exercise; also turn empty
-- emails into NULL with NULLIF). Then check it with SELECT * FROM
-- stg_customers ORDER BY customer_id; The view is your staging layer, the
-- same idea as a dbt staging model.
--
-- Hint: Combine the de-dup CTE with the cleaning expressions inside CREATE
-- VIEW ... AS. Start with DROP VIEW IF EXISTS so you can re-run it.
-- Expected: 45 rows. Columns: customer_id, full_name, email, city,
-- updated_at.
-- First row: 5001, Anna Lindberg, anna.lindberg@example.com, Uppsala,
-- 2025-01-07 18:51:00
-- ==========================================================================



-- ==========================================================================
-- Q6 [Medium] Data-quality test: revenue math
-- Write a dbt-style test that returns failing rows: order lines where
-- net_revenue differs from ROUND(quantity * unit_price * (1 - discount_pct
-- / 100.0), 2) by more than 0.01. Columns: order_id, line_number,
-- net_revenue, expected_revenue. A passing test returns zero rows, so this
-- one should find problems.
--
-- Hint: Compute expected_revenue in a subquery/CTE and compare with
-- ABS(net_revenue - expected_revenue) > 0.01.
-- Expected: 6 rows. Columns: order_id, line_number, net_revenue,
-- expected_revenue.
-- First row: 1006, 2, 224.0, 299.0
-- ==========================================================================



-- ==========================================================================
-- Q7 [Medium] Data-quality test: relationships
-- Write one query using UNION ALL that returns two rows: check_name /
-- failing_rows for (1) order lines whose order_id has no matching order and
-- (2) orders whose customer_key has no matching customer. This is the SQL
-- behind dbt's 'relationships' test. Both should be 0 here.
--
-- Hint: Anti-join each pair with LEFT JOIN ... IS NULL and COUNT(*), then
-- UNION ALL the two results.
-- Expected: 2 rows. Columns: check_name, failing_rows.
-- First row: lines_without_order, 0
-- ==========================================================================



-- ==========================================================================
-- Q8 [Hard] Modelling question (written, no SQL result)
-- Answer in comments or in your own notes, then compare with the solution
-- file:
--   (a) What is the grain of fact_orders and of fact_order_lines? Why keep
--   both?
--   (b) A customer moves from Malmö to Stockholm. Sketch a Type 2 slowly
--   changing dimension for dim_customer: which columns would you add, and
--   how would a query 'revenue by the customer's city at the time of the
--   order' join to it?
--   (c) Which dbt tests would you add to the fact_order_lines model?
--
-- Hint: You have built these exact things in DataStage and SQL Server.
-- Explain it as you would to an interviewer.
-- Expected: written answer, no result set.
-- ==========================================================================


