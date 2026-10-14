-- 03 - Window functions
-- RANK, ROW_NUMBER, LAG, running totals, moving averages, NTILE.
-- Write your answer under each question. Run it, then compare the row count and
-- first row with the 'Expected' line. When it matches, peek at the solutions file.
-- Database: practice.db (see README.md for setup). SQLite dialect.

-- ==========================================================================
-- Q1 [Medium] Rank products within category
-- Rank products by net revenue within their category (excluding cancelled
-- orders). Columns: category, product_name, revenue (2 decimals),
-- rank_in_category. Use RANK(). Order by category, rank.
--
-- Hint: CTE with revenue per product, then RANK() OVER (PARTITION BY
-- category ORDER BY revenue DESC).
-- Expected: 28 rows. Columns: category, product_name, revenue,
-- rank_in_category.
-- First row: Books, SQL Cookbook, 35039.6, 1
-- ==========================================================================



-- ==========================================================================
-- Q2 [Medium] Top 3 products per category
-- Return only the top 3 products per category by net revenue (excluding
-- cancelled orders): category, product_name, revenue (2 decimals),
-- rank_in_category.
--
-- Hint: You cannot filter on a window function in WHERE. Wrap the ranked
-- query in a CTE or subquery, then filter rank <= 3.
-- Expected: 15 rows. Columns: category, product_name, revenue,
-- rank_in_category.
-- First row: Books, SQL Cookbook, 35039.6, 1
-- ==========================================================================



-- ==========================================================================
-- Q3 [Medium] First order per customer
-- Return each customer's first order (all statuses): customer_key,
-- order_id, full_date. Use ROW_NUMBER() and order by customer_key.
--
-- Hint: ROW_NUMBER() OVER (PARTITION BY customer_key ORDER BY full_date,
-- order_id) then keep row number 1.
-- Expected: 110 rows. Columns: customer_key, order_id, full_date.
-- First row: 2, 1232, 2024-12-15
-- ==========================================================================



-- ==========================================================================
-- Q4 [Medium] Running total of 2025 revenue
-- Monthly net revenue for 2025 (excluding cancelled orders) with a running
-- total. Columns: year_month (YYYY-MM), revenue, running_total (both 2
-- decimals).
--
-- Hint: Aggregate by month in a CTE, then SUM(revenue) OVER (ORDER BY
-- month).
-- Expected: 12 rows. Columns: year_month, revenue, running_total.
-- First row: 2025-01, 31805.75, 31805.75
-- ==========================================================================



-- ==========================================================================
-- Q5 [Hard] Month-over-month change
-- For every month in 2024-2025 (excluding cancelled orders): year_month,
-- revenue, prev_month_revenue, pct_change (1 decimal). Use LAG(). The first
-- month has no previous value.
--
-- Hint: LAG(revenue) OVER (ORDER BY year, month). pct_change = 100.0 *
-- (revenue - prev) / prev.
-- Expected: 24 rows. Columns: year_month, revenue, prev_month_revenue,
-- pct_change.
-- First row: 2024-01, 20080.15, NULL, NULL
-- ==========================================================================



-- ==========================================================================
-- Q6 [Hard] 3-month moving average
-- Monthly revenue with a 3-month moving average (the current and the two
-- previous months), excluding cancelled orders. Columns: year_month,
-- revenue, moving_avg_3m (both 2 decimals).
--
-- Hint: AVG(revenue) OVER (ORDER BY year, month ROWS BETWEEN 2 PRECEDING
-- AND CURRENT ROW).
-- Expected: 24 rows. Columns: year_month, revenue, moving_avg_3m.
-- First row: 2024-01, 20080.15, 20080.15
-- ==========================================================================



-- ==========================================================================
-- Q7 [Hard] Days between orders
-- For each customer order that has a previous order, return customer_key,
-- order_id, full_date and days_since_previous_order. Order by customer_key,
-- full_date, order_id.
--
-- Hint: LAG(full_date) OVER (PARTITION BY customer_key ORDER BY full_date,
-- order_id), then julianday(a) - julianday(b) for the difference.
-- Expected: 590 rows. Columns: customer_key, order_id, full_date,
-- days_since_previous_order.
-- First row: 2, 1699, 2025-12-31, 381
-- ==========================================================================



-- ==========================================================================
-- Q8 [Medium] Line share of order total
-- For orders 1001 to 1005 show each line's share of its order: order_id,
-- line_number, net_revenue, order_total, pct_of_order (1 decimal). Use
-- SUM() OVER (PARTITION BY ...).
--
-- Hint: SUM(net_revenue) OVER (PARTITION BY order_id) gives the order total
-- on every line without collapsing rows.
-- Expected: 9 rows. Columns: order_id, line_number, net_revenue,
-- order_total, pct_of_order.
-- First row: 1001, 1, 224.1, 224.1, 100.0
-- ==========================================================================



-- ==========================================================================
-- Q9 [Hard] Customer revenue quartiles
-- Split customers who ordered into 4 quartiles by lifetime net revenue
-- (excluding cancelled orders) using NTILE(4), where quartile 1 is the top
-- spenders. Return quartile, customer_count and total_revenue (2 decimals)
-- per quartile.
--
-- Hint: CTE for revenue per customer, NTILE(4) OVER (ORDER BY
-- lifetime_revenue DESC), then GROUP BY the quartile.
-- Expected: 4 rows. Columns: quartile, customer_count, total_revenue.
-- First row: 1, 27, 851670.4
-- ==========================================================================


