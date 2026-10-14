-- 01 - Select, filter and join
-- Warm-up: filtering, sorting, joins and anti-joins on the star schema.
-- Write your answer under each question. Run it, then compare the row count and
-- first row with the 'Expected' line. When it matches, peek at the solutions file.
-- Database: practice.db (see README.md for setup). SQLite dialect.

-- ==========================================================================
-- Q1 [Easy] Customers in Stockholm
-- List the name and signup date of every customer in Stockholm, ordered by
-- name.
--
-- Hint: WHERE city = 'Stockholm' and ORDER BY.
-- Expected: 40 rows. Columns: customer_name, signup_date.
-- First row: Aisha Rossi, 2024-07-10
-- ==========================================================================



-- ==========================================================================
-- Q2 [Easy] Most expensive electronics
-- Return the 5 most expensive products in the Electronics category
-- (product_name, unit_price), most expensive first.
--
-- Hint: ORDER BY ... DESC with LIMIT 5. (In T-SQL you would use TOP 5.)
-- Expected: 5 rows. Columns: product_name, unit_price.
-- First row: Smartwatch, 1899.0
-- ==========================================================================



-- ==========================================================================
-- Q3 [Easy] Orders by status
-- How many orders exist for each status? Return status and order_count,
-- biggest count first.
--
-- Hint: GROUP BY status, COUNT(*), ORDER BY the count.
-- Expected: 4 rows. Columns: status, order_count.
-- First row: delivered, 576
-- ==========================================================================



-- ==========================================================================
-- Q4 [Easy] Order lines with product details
-- For orders 1001 to 1010, list each order line with its product: order_id,
-- line_number, product_name, category, net_revenue. Order by order_id,
-- line_number.
--
-- Hint: JOIN fact_order_lines to dim_product on product_key. Use BETWEEN
-- for the order range.
-- Expected: 21 rows. Columns: order_id, line_number, product_name,
-- category, net_revenue.
-- First row: 1001, 1, Storage Boxes, Home, 224.1
-- ==========================================================================



-- ==========================================================================
-- Q5 [Medium] Customers who never ordered
-- Which customers have never placed an order? Return customer_key and
-- customer_name, ordered by customer_key.
--
-- Hint: Anti-join: LEFT JOIN fact_orders and keep rows where the order side
-- IS NULL.
-- Expected: 40 rows. Columns: customer_key, customer_name.
-- First row: 1, Priya Nilsson
-- ==========================================================================



-- ==========================================================================
-- Q6 [Medium] Products that never sold
-- Which products never appear on any order line? Return product_name and
-- category.
--
-- Hint: Same anti-join pattern, this time from dim_product to
-- fact_order_lines.
-- Expected: 2 rows. Columns: product_name, category.
-- First row: Scented Candle, Home
-- ==========================================================================



-- ==========================================================================
-- Q7 [Medium] Delivered orders in March 2025
-- List delivered orders placed in March 2025: order_id, customer_name,
-- city, full_date. Order by full_date, then order_id.
--
-- Hint: Join fact_orders to dim_customer and to dim_date (order_date_key =
-- date_key). Filter on d.year and d.month.
-- Expected: 24 rows. Columns: order_id, customer_name, city, full_date.
-- First row: 1307, Ida Andersson, Malmö, 2025-03-01
-- ==========================================================================



-- ==========================================================================
-- Q8 [Easy] Corporate signups in 2024
-- List Corporate-segment customers who signed up during 2024: customer_name
-- and signup_date, oldest signup first.
--
-- Hint: Dates are ISO text, so range comparisons like >= '2024-01-01' AND <
-- '2025-01-01' work.
-- Expected: 17 rows. Columns: customer_name, signup_date.
-- First row: Lars Svensson, 2024-01-03
-- ==========================================================================


