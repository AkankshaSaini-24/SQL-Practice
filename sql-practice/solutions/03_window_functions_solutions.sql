-- 03 - Window functions - SOLUTIONS
-- Try each question yourself first. There is usually more than one correct way.

-- --------------------------------------------------------------------------
-- Q1 [Medium] Rank products within category
-- --------------------------------------------------------------------------
WITH product_rev AS (
  SELECT p.category, p.product_name, SUM(l.net_revenue) AS revenue
  FROM fact_order_lines AS l
  JOIN fact_orders AS o ON o.order_id = l.order_id
  JOIN dim_product AS p ON p.product_key = l.product_key
  WHERE o.status <> 'cancelled'
  GROUP BY p.product_key, p.category, p.product_name
)
SELECT category, product_name, ROUND(revenue, 2) AS revenue,
       RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rank_in_category
FROM product_rev
ORDER BY category, rank_in_category;

-- --------------------------------------------------------------------------
-- Q2 [Medium] Top 3 products per category
-- --------------------------------------------------------------------------
WITH product_rev AS (
  SELECT p.category, p.product_name, SUM(l.net_revenue) AS revenue
  FROM fact_order_lines AS l
  JOIN fact_orders AS o ON o.order_id = l.order_id
  JOIN dim_product AS p ON p.product_key = l.product_key
  WHERE o.status <> 'cancelled'
  GROUP BY p.product_key, p.category, p.product_name
),
ranked AS (
  SELECT category, product_name, ROUND(revenue, 2) AS revenue,
         RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rank_in_category
  FROM product_rev
)
SELECT *
FROM ranked
WHERE rank_in_category <= 3
ORDER BY category, rank_in_category;

-- --------------------------------------------------------------------------
-- Q3 [Medium] First order per customer
-- --------------------------------------------------------------------------
WITH numbered AS (
  SELECT o.customer_key, o.order_id, d.full_date,
         ROW_NUMBER() OVER (PARTITION BY o.customer_key ORDER BY d.full_date, o.order_id) AS rn
  FROM fact_orders AS o
  JOIN dim_date AS d ON d.date_key = o.order_date_key
)
SELECT customer_key, order_id, full_date
FROM numbered
WHERE rn = 1
ORDER BY customer_key;

-- --------------------------------------------------------------------------
-- Q4 [Medium] Running total of 2025 revenue
-- --------------------------------------------------------------------------
WITH monthly AS (
  SELECT d.year, d.month,
         d.year || '-' || printf('%02d', d.month) AS year_month,
         SUM(l.net_revenue) AS revenue
  FROM fact_order_lines AS l
  JOIN fact_orders AS o ON o.order_id = l.order_id
  JOIN dim_date AS d ON d.date_key = o.order_date_key
  WHERE o.status <> 'cancelled'
  GROUP BY d.year, d.month
)
SELECT year_month,
       ROUND(revenue, 2) AS revenue,
       ROUND(SUM(revenue) OVER (ORDER BY year, month), 2) AS running_total
FROM monthly
WHERE year = 2025
ORDER BY year, month;

-- --------------------------------------------------------------------------
-- Q5 [Hard] Month-over-month change
-- --------------------------------------------------------------------------
WITH monthly AS (
  SELECT d.year, d.month,
         d.year || '-' || printf('%02d', d.month) AS year_month,
         SUM(l.net_revenue) AS revenue
  FROM fact_order_lines AS l
  JOIN fact_orders AS o ON o.order_id = l.order_id
  JOIN dim_date AS d ON d.date_key = o.order_date_key
  WHERE o.status <> 'cancelled'
  GROUP BY d.year, d.month
),
with_prev AS (
  SELECT year_month, year, month, revenue,
         LAG(revenue) OVER (ORDER BY year, month) AS prev_month_revenue
  FROM monthly
)
SELECT year_month,
       ROUND(revenue, 2) AS revenue,
       ROUND(prev_month_revenue, 2) AS prev_month_revenue,
       ROUND(100.0 * (revenue - prev_month_revenue) / prev_month_revenue, 1) AS pct_change
FROM with_prev
ORDER BY year, month;

-- --------------------------------------------------------------------------
-- Q6 [Hard] 3-month moving average
-- --------------------------------------------------------------------------
WITH monthly AS (
  SELECT d.year, d.month,
         d.year || '-' || printf('%02d', d.month) AS year_month,
         SUM(l.net_revenue) AS revenue
  FROM fact_order_lines AS l
  JOIN fact_orders AS o ON o.order_id = l.order_id
  JOIN dim_date AS d ON d.date_key = o.order_date_key
  WHERE o.status <> 'cancelled'
  GROUP BY d.year, d.month
)
SELECT year_month,
       ROUND(revenue, 2) AS revenue,
       ROUND(AVG(revenue) OVER (ORDER BY year, month
                                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_3m
FROM monthly
ORDER BY year, month;

-- --------------------------------------------------------------------------
-- Q7 [Hard] Days between orders
-- --------------------------------------------------------------------------
WITH ordered AS (
  SELECT o.customer_key, o.order_id, d.full_date,
         LAG(d.full_date) OVER (PARTITION BY o.customer_key ORDER BY d.full_date, o.order_id) AS prev_date
  FROM fact_orders AS o
  JOIN dim_date AS d ON d.date_key = o.order_date_key
)
SELECT customer_key, order_id, full_date,
       CAST(julianday(full_date) - julianday(prev_date) AS INTEGER) AS days_since_previous_order
FROM ordered
WHERE prev_date IS NOT NULL
ORDER BY customer_key, full_date, order_id;

-- --------------------------------------------------------------------------
-- Q8 [Medium] Line share of order total
-- --------------------------------------------------------------------------
SELECT order_id, line_number, net_revenue,
       ROUND(SUM(net_revenue) OVER (PARTITION BY order_id), 2) AS order_total,
       ROUND(100.0 * net_revenue / SUM(net_revenue) OVER (PARTITION BY order_id), 1) AS pct_of_order
FROM fact_order_lines
WHERE order_id BETWEEN 1001 AND 1005
ORDER BY order_id, line_number;

-- --------------------------------------------------------------------------
-- Q9 [Hard] Customer revenue quartiles
-- --------------------------------------------------------------------------
WITH cust AS (
  SELECT o.customer_key, SUM(l.net_revenue) AS lifetime_revenue
  FROM fact_orders AS o
  JOIN fact_order_lines AS l ON l.order_id = o.order_id
  WHERE o.status <> 'cancelled'
  GROUP BY o.customer_key
),
bucketed AS (
  SELECT customer_key, lifetime_revenue,
         NTILE(4) OVER (ORDER BY lifetime_revenue DESC) AS quartile
  FROM cust
)
SELECT quartile, COUNT(*) AS customer_count, ROUND(SUM(lifetime_revenue), 2) AS total_revenue
FROM bucketed
GROUP BY quartile
ORDER BY quartile;
