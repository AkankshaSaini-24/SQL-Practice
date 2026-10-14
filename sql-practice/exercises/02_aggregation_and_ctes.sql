-- 02 - Aggregation and CTEs
-- GROUP BY, HAVING, CASE, CTEs and conditional aggregation.
-- Write your answer under each question. Run it, then compare the row count and
-- first row with the 'Expected' line. When it matches, peek at the solutions file.
-- Database: practice.db (see README.md for setup). SQLite dialect.

-- ==========================================================================
-- Q1 [Easy] Revenue by category
-- Total net revenue by product category, highest first. Exclude cancelled
-- orders. Columns: category, revenue (rounded to 2 decimals).
--
-- Hint: Join lines -> orders (for status) and lines -> products (for
-- category).
-- Expected: 5 rows. Columns: category, revenue.
-- First row: Electronics, 338629.35
-- ==========================================================================



-- ==========================================================================
-- Q2 [Easy] Cities with more than 10 customers
-- Which cities have more than 10 customers? Return city and customer_count,
-- biggest first.
--
-- Hint: HAVING filters after grouping. Watch the boundary: 'more than' 10
-- excludes cities with exactly 10.
-- Expected: 6 rows. Columns: city, customer_count.
-- First row: Stockholm, 40
-- ==========================================================================



-- ==========================================================================
-- Q3 [Medium] Average delivery time by city
-- Average delivery days by customer city, for delivered orders only,
-- rounded to 1 decimal. Columns: city, avg_delivery_days. Fastest city
-- first.
--
-- Hint: fact_orders joined to dim_customer; AVG(delivery_days); filter
-- status = 'delivered'.
-- Expected: 7 rows. Columns: city, avg_delivery_days.
-- First row: Örebro, 3.4
-- ==========================================================================



-- ==========================================================================
-- Q4 [Medium] Monthly revenue 2025
-- Monthly net revenue for 2025, excluding cancelled orders. Columns: year,
-- month, revenue (2 decimals). Ordered by month.
--
-- Hint: Join lines, orders and dim_date. Group by d.year, d.month.
-- Expected: 12 rows. Columns: year, month, revenue.
-- First row: 2025, 1, 31805.75
-- ==========================================================================



-- ==========================================================================
-- Q5 [Medium] Top 5 products by gross margin
-- Top 5 products by gross margin, excluding cancelled orders. Margin =
-- SUM(net_revenue) - SUM(quantity * unit_cost). Columns: product_name,
-- revenue, margin (2 decimals).
--
-- Hint: unit_cost lives on dim_product. Compute both sums in the same GROUP
-- BY.
-- Expected: 5 rows. Columns: product_name, revenue, margin.
-- First row: Smartwatch, 131505.75, 51781.11
-- ==========================================================================



-- ==========================================================================
-- Q6 [Medium] Above-average customers (CTE)
-- Using a CTE, list customers whose lifetime net revenue (excluding
-- cancelled orders) is above the average lifetime revenue of customers who
-- ordered. Columns: customer_name, lifetime_revenue (2 decimals), highest
-- first.
--
-- Hint: CTE 1: revenue per customer. Then compare to (SELECT
-- AVG(lifetime_revenue) FROM cte).
-- Expected: 20 rows. Columns: customer_name, lifetime_revenue.
-- First row: Erik Berg, 345294.85
-- ==========================================================================



-- ==========================================================================
-- Q7 [Medium] Order value buckets
-- Bucket non-cancelled orders by total value (sum of net_revenue over their
-- lines): '<500', '500-1499', '1500+'. Columns: bucket, order_count. Order
-- from the lowest bucket to the highest.
--
-- Hint: CTE for the order totals, then CASE WHEN to assign buckets, then
-- GROUP BY the bucket.
-- Expected: 3 rows. Columns: bucket, order_count.
-- First row: <500, 131
-- ==========================================================================



-- ==========================================================================
-- Q8 [Hard] Pivot: segment x category
-- Build a pivot using conditional aggregation: one row per customer
-- segment, one column per category (Electronics, Home, Sports, Books,
-- Clothing) with net revenue (2 decimals, excluding cancelled orders).
--
-- Hint: SUM(CASE WHEN p.category = 'Electronics' THEN l.net_revenue ELSE 0
-- END) AS electronics, and so on.
-- Expected: 3 rows. Columns: segment, electronics, home, sports, books,
-- clothing.
-- First row: Consumer, 177503.1, 108691.6, 86069.65, 59448.05, 129064.75
-- ==========================================================================


