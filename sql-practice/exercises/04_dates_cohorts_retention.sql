-- 04 - Dates, cohorts and retention
-- Date handling and the cohort queries analysts are asked about in interviews.
-- Write your answer under each question. Run it, then compare the row count and
-- first row with the 'Expected' line. When it matches, peek at the solutions file.
-- Database: practice.db (see README.md for setup). SQLite dialect.

-- ==========================================================================
-- Q1 [Easy] Signups per month
-- How many customers signed up in each month? Columns: signup_month (YYYY-
-- MM), customers. Ordered by month.
--
-- Hint: strftime('%Y-%m', signup_date) gives the month. (T-SQL: FORMAT or
-- DATEFROMPARTS.)
-- Expected: 25 rows. Columns: signup_month, customers.
-- First row: 2023-06, 6
-- ==========================================================================



-- ==========================================================================
-- Q2 [Medium] Acquisition cohorts
-- Group customers by the month of their first non-cancelled order. Columns:
-- cohort_month (YYYY-MM), new_customers. Ordered by month.
--
-- Hint: CTE: MIN(ym) per customer, then GROUP BY that month.
-- Expected: 24 rows. Columns: cohort_month, new_customers.
-- First row: 2024-01, 7
-- ==========================================================================



-- ==========================================================================
-- Q3 [Medium] Repeat purchase rate
-- Among customers with at least one non-cancelled order, what share placed
-- 2 or more? One row: customers_with_orders, repeat_customers,
-- repeat_rate_pct (1 decimal).
--
-- Hint: Count orders per customer in a CTE, then use SUM(CASE WHEN orders
-- >= 2 THEN 1 ELSE 0 END).
-- Expected: 1 row. Columns: customers_with_orders, repeat_customers,
-- repeat_rate_pct.
-- First row: 106, 73, 68.9
-- ==========================================================================



-- ==========================================================================
-- Q4 [Medium] Monthly active customers
-- For each month: the number of distinct customers who placed a non-
-- cancelled order, and the number of orders. Columns: order_month (YYYY-
-- MM), active_customers, orders.
--
-- Hint: COUNT(DISTINCT customer_key) and COUNT(*) grouped by month.
-- Expected: 24 rows. Columns: order_month, active_customers, orders.
-- First row: 2024-01, 7, 11
-- ==========================================================================



-- ==========================================================================
-- Q5 [Hard] Month-1 retention
-- For each first-order cohort month (non-cancelled orders), how many cohort
-- customers ordered again in the calendar month right after their first
-- month? Columns: cohort_month, cohort_size, retained_next_month,
-- retention_pct (1 decimal).
--
-- Hint: Build first_order per customer. Then check for any order in the
-- next month, e.g. strftime('%Y-%m', date(cohort_month || '-01', '+1
-- month')). LEFT JOIN or EXISTS keeps cohorts with zero retained. The
-- newest cohort cannot show retention yet, which is a real-world caveat to
-- mention in an interview.
-- Expected: 24 rows. Columns: cohort_month, cohort_size,
-- retained_next_month, retention_pct.
-- First row: 2024-01, 7, 3, 42.9
-- ==========================================================================



-- ==========================================================================
-- Q6 [Medium] Late deliveries by month
-- For delivered orders, what share took more than 7 days? By order month.
-- Columns: order_month (YYYY-MM), delivered_orders, late_orders, late_pct
-- (1 decimal).
--
-- Hint: SUM(CASE WHEN delivery_days > 7 THEN 1 ELSE 0 END) for late orders.
-- Expected: 24 rows. Columns: order_month, delivered_orders, late_orders,
-- late_pct.
-- First row: 2024-01, 11, 0, 0.0
-- ==========================================================================



-- ==========================================================================
-- Q7 [Medium] Weekend vs weekday
-- Compare weekends and weekdays (non-cancelled orders): day_type ('Weekend'
-- or 'Weekday'), orders, revenue (2 decimals), avg_order_value (2 decimals,
-- revenue divided by orders).
--
-- Hint: dim_date.is_weekend is 1 or 0. CASE WHEN turns it into a label.
-- Count distinct order_id since lines repeat orders.
-- Expected: 2 rows. Columns: day_type, orders, revenue, avg_order_value.
-- First row: Weekend, 190, 349280.55, 1838.32
-- ==========================================================================


