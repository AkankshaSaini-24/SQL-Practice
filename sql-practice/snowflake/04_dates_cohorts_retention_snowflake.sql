-- 04 - Dates, cohorts and retention (SNOWFLAKE VERSION)
-- Same 7 questions as the SQLite file, converted to Snowflake SQL.
-- Differences used below: TO_CHAR for date formatting, DATEADD for date math,
-- TO_DATE to parse a 'YYYY-MM-01' string back into a date.

-- --------------------------------------------------------------------------
-- Q1 [Easy] Signups per month
-- How many customers signed up in each month? Columns: signup_month (YYYY-MM), customers. Ordered by month.
-- --------------------------------------------------------------------------
SELECT TO_CHAR(signup_date, 'YYYY-MM') AS signup_month, COUNT(*) AS customers
FROM dim_customer
GROUP BY signup_month
ORDER BY signup_month;

-- --------------------------------------------------------------------------
-- Q2 [Medium] Acquisition cohorts
-- Group customers by the month of their first non-cancelled order. Columns: cohort_month (YYYY-MM), new_customers. Ordered by month.
-- --------------------------------------------------------------------------
WITH orders_ok AS (
  SELECT o.order_id, o.customer_key, d.full_date,
         TO_CHAR(d.full_date, 'YYYY-MM') AS ym
  FROM fact_orders AS o
  JOIN dim_date AS d ON d.date_key = o.order_date_key
  WHERE o.status <> 'cancelled'
),
first_order AS (
  SELECT customer_key, MIN(ym) AS cohort_month
  FROM orders_ok
  GROUP BY customer_key
)
SELECT cohort_month, COUNT(*) AS new_customers
FROM first_order
GROUP BY cohort_month
ORDER BY cohort_month;

-- --------------------------------------------------------------------------
-- Q3 [Medium] Repeat purchase rate
-- Among customers with at least one non-cancelled order, what share placed 2 or more? One row: customers_with_orders, repeat_customers, repeat_rate_pct (1 decimal).
-- --------------------------------------------------------------------------
WITH orders_ok AS (
  SELECT o.order_id, o.customer_key, d.full_date,
         TO_CHAR(d.full_date, 'YYYY-MM') AS ym
  FROM fact_orders AS o
  JOIN dim_date AS d ON d.date_key = o.order_date_key
  WHERE o.status <> 'cancelled'
),
per_customer AS (
  SELECT customer_key, COUNT(*) AS order_count
  FROM orders_ok
  GROUP BY customer_key
)
SELECT COUNT(*) AS customers_with_orders,
       SUM(CASE WHEN order_count >= 2 THEN 1 ELSE 0 END) AS repeat_customers,
       ROUND(100.0 * SUM(CASE WHEN order_count >= 2 THEN 1 ELSE 0 END) / COUNT(*), 1) AS repeat_rate_pct
FROM per_customer;

-- --------------------------------------------------------------------------
-- Q4 [Medium] Monthly active customers
-- For each month: the number of distinct customers who placed a non-cancelled order, and the number of orders. Columns: order_month (YYYY-MM), active_customers, orders.
-- --------------------------------------------------------------------------
WITH orders_ok AS (
  SELECT o.order_id, o.customer_key, d.full_date,
         TO_CHAR(d.full_date, 'YYYY-MM') AS ym
  FROM fact_orders AS o
  JOIN dim_date AS d ON d.date_key = o.order_date_key
  WHERE o.status <> 'cancelled'
)
SELECT ym AS order_month,
       COUNT(DISTINCT customer_key) AS active_customers,
       COUNT(*) AS orders
FROM orders_ok
GROUP BY ym
ORDER BY ym;

-- --------------------------------------------------------------------------
-- Q5 [Hard] Month-1 retention
-- For each first-order cohort month (non-cancelled orders), how many cohort customers ordered again in the calendar month right after their first month? Columns: cohort_month, cohort_size, retained_next_month, retention_pct (1 decimal).
-- --------------------------------------------------------------------------
WITH orders_ok AS (
  SELECT o.order_id, o.customer_key, d.full_date,
         TO_CHAR(d.full_date, 'YYYY-MM') AS ym
  FROM fact_orders AS o
  JOIN dim_date AS d ON d.date_key = o.order_date_key
  WHERE o.status <> 'cancelled'
),
first_order AS (
  SELECT customer_key, MIN(ym) AS cohort_month
  FROM orders_ok
  GROUP BY customer_key
),
retained AS (
  SELECT f.customer_key
  FROM first_order AS f
  WHERE EXISTS (
    SELECT 1
    FROM orders_ok AS x
    WHERE x.customer_key = f.customer_key
      AND x.ym = TO_CHAR(DATEADD('month', 1, TO_DATE(f.cohort_month || '-01')), 'YYYY-MM')
  )
)
SELECT f.cohort_month,
       COUNT(*) AS cohort_size,
       COUNT(r.customer_key) AS retained_next_month,
       ROUND(100.0 * COUNT(r.customer_key) / COUNT(*), 1) AS retention_pct
FROM first_order AS f
LEFT JOIN retained AS r ON r.customer_key = f.customer_key
GROUP BY f.cohort_month
ORDER BY f.cohort_month;

-- --------------------------------------------------------------------------
-- Q6 [Medium] Late deliveries by month
-- For delivered orders, what share took more than 7 days? By order month. Columns: order_month (YYYY-MM), delivered_orders, late_orders, late_pct (1 decimal).
-- --------------------------------------------------------------------------
SELECT TO_CHAR(d.full_date, 'YYYY-MM') AS order_month,
       COUNT(*) AS delivered_orders,
       SUM(CASE WHEN o.delivery_days > 7 THEN 1 ELSE 0 END) AS late_orders,
       ROUND(100.0 * SUM(CASE WHEN o.delivery_days > 7 THEN 1 ELSE 0 END) / COUNT(*), 1) AS late_pct
FROM fact_orders AS o
JOIN dim_date AS d ON d.date_key = o.order_date_key
WHERE o.status = 'delivered'
GROUP BY order_month
ORDER BY order_month;

-- --------------------------------------------------------------------------
-- Q7 [Medium] Weekend vs weekday
-- Compare weekends and weekdays (non-cancelled orders): day_type ('Weekend' or 'Weekday'), orders, revenue (2 decimals), avg_order_value (2 decimals, revenue divided by orders).
-- --------------------------------------------------------------------------
SELECT CASE WHEN d.is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS day_type,
       COUNT(DISTINCT o.order_id) AS orders,
       ROUND(SUM(l.net_revenue), 2) AS revenue,
       ROUND(SUM(l.net_revenue) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM fact_orders AS o
JOIN fact_order_lines AS l ON l.order_id = o.order_id
JOIN dim_date AS d ON d.date_key = o.order_date_key
WHERE o.status <> 'cancelled'
GROUP BY day_type
ORDER BY day_type DESC;
