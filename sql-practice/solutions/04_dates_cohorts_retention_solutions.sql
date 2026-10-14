-- 04 - Dates, cohorts and retention - SOLUTIONS
-- Try each question yourself first. There is usually more than one correct way.

-- --------------------------------------------------------------------------
-- Q1 [Easy] Signups per month
-- --------------------------------------------------------------------------
SELECT strftime('%Y-%m', signup_date) AS signup_month, COUNT(*) AS customers
FROM dim_customer
GROUP BY signup_month
ORDER BY signup_month;

-- --------------------------------------------------------------------------
-- Q2 [Medium] Acquisition cohorts
-- --------------------------------------------------------------------------
WITH orders_ok AS (
  SELECT o.order_id, o.customer_key, d.full_date,
         strftime('%Y-%m', d.full_date) AS ym
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
-- --------------------------------------------------------------------------
WITH orders_ok AS (
  SELECT o.order_id, o.customer_key, d.full_date,
         strftime('%Y-%m', d.full_date) AS ym
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
-- --------------------------------------------------------------------------
WITH orders_ok AS (
  SELECT o.order_id, o.customer_key, d.full_date,
         strftime('%Y-%m', d.full_date) AS ym
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
-- --------------------------------------------------------------------------
WITH orders_ok AS (
  SELECT o.order_id, o.customer_key, d.full_date,
         strftime('%Y-%m', d.full_date) AS ym
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
      AND x.ym = strftime('%Y-%m', date(f.cohort_month || '-01', '+1 month'))
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
-- --------------------------------------------------------------------------
SELECT strftime('%Y-%m', d.full_date) AS order_month,
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
