-- 05 - Cleaning and data quality - SOLUTIONS
-- Try each question yourself first. There is usually more than one correct way.

-- --------------------------------------------------------------------------
-- Q1 [Easy] Clean the raw customers
-- --------------------------------------------------------------------------
SELECT customer_id,
       TRIM(full_name) AS full_name,
       LOWER(TRIM(email)) AS email,
       COALESCE(TRIM(city), 'Unknown') AS city
FROM raw_customers;

-- --------------------------------------------------------------------------
-- Q2 [Easy] Find duplicate IDs
-- --------------------------------------------------------------------------
SELECT customer_id, COUNT(*) AS row_count
FROM raw_customers
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY row_count DESC, customer_id;

-- --------------------------------------------------------------------------
-- Q3 [Medium] Keep the latest row per ID
-- --------------------------------------------------------------------------
WITH ranked AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY updated_at DESC) AS rn
  FROM raw_customers
)
SELECT customer_id, full_name, email, city, updated_at
FROM ranked
WHERE rn = 1
ORDER BY customer_id;

-- --------------------------------------------------------------------------
-- Q4 [Easy] Missing emails
-- --------------------------------------------------------------------------
SELECT SUM(CASE WHEN email IS NULL OR TRIM(email) = '' THEN 1 ELSE 0 END) AS missing_email_rows,
       COUNT(*) AS total_rows,
       ROUND(100.0 * SUM(CASE WHEN email IS NULL OR TRIM(email) = '' THEN 1 ELSE 0 END) / COUNT(*), 1) AS missing_pct
FROM raw_customers;

-- --------------------------------------------------------------------------
-- Q5 [Medium] Build a staging view
-- --------------------------------------------------------------------------
DROP VIEW IF EXISTS stg_customers;

CREATE VIEW stg_customers AS
WITH ranked AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY updated_at DESC) AS rn
  FROM raw_customers
)
SELECT customer_id,
       TRIM(full_name) AS full_name,
       NULLIF(LOWER(TRIM(email)), '') AS email,
       COALESCE(TRIM(city), 'Unknown') AS city,
       updated_at
FROM ranked
WHERE rn = 1;

SELECT * FROM stg_customers ORDER BY customer_id;

-- --------------------------------------------------------------------------
-- Q6 [Medium] Data-quality test: revenue math
-- --------------------------------------------------------------------------
WITH checked AS (
  SELECT order_id, line_number, net_revenue,
         ROUND(quantity * unit_price * (1 - discount_pct / 100.0), 2) AS expected_revenue
  FROM fact_order_lines
)
SELECT order_id, line_number, net_revenue, expected_revenue
FROM checked
WHERE ABS(net_revenue - expected_revenue) > 0.01
ORDER BY order_id, line_number;

-- --------------------------------------------------------------------------
-- Q7 [Medium] Data-quality test: relationships
-- --------------------------------------------------------------------------
SELECT 'lines_without_order' AS check_name, COUNT(*) AS failing_rows
FROM fact_order_lines AS l
LEFT JOIN fact_orders AS o ON o.order_id = l.order_id
WHERE o.order_id IS NULL
UNION ALL
SELECT 'orders_without_customer', COUNT(*)
FROM fact_orders AS o
LEFT JOIN dim_customer AS c ON c.customer_key = o.customer_key
WHERE c.customer_key IS NULL;

-- --------------------------------------------------------------------------
-- Q8 [Hard] Modelling question (written, no SQL result)
-- --------------------------------------------------------------------------
-- (a) fact_orders: one row per order (header level: status, delivery_days, customer, date).
--     fact_order_lines: one row per product on an order (line level: quantity, price, discount, revenue).
--     Keep both so order-level measures (delivery days, status) are not repeated and
--     double-counted on every line, and line-level measures can be analysed by product.
--
-- (b) Type 2 SCD: add surrogate key (customer_sk), keep customer_key as the business key,
--     plus valid_from, valid_to and is_current. A city change closes the old row
--     (valid_to = change date, is_current = 0) and inserts a new row. Facts store customer_sk.
--     Query at time of order:
--       SELECT c.city, SUM(l.net_revenue)
--       FROM fact_orders o
--       JOIN fact_order_lines l ON l.order_id = o.order_id
--       JOIN dim_date d ON d.date_key = o.order_date_key
--       JOIN dim_customer_scd c
--         ON c.customer_key = o.customer_key
--        AND d.full_date >= c.valid_from
--        AND d.full_date <  COALESCE(c.valid_to, '9999-12-31')
--       GROUP BY c.city;
--     (If the fact stores customer_sk at load time, a plain join on customer_sk is enough.)
--
-- (c) dbt tests: unique on (order_id, line_number) via a unique combination test;
--     not_null on order_id, product_key, quantity; relationships to fact_orders and dim_product;
--     accepted_values on discount_pct; and a custom test that net_revenue matches
--     quantity * unit_price * (1 - discount_pct / 100).
