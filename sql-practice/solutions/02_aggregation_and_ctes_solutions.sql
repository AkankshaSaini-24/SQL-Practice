-- 02 - Aggregation and CTEs - SOLUTIONS
-- Try each question yourself first. There is usually more than one correct way.

-- --------------------------------------------------------------------------
-- Q1 [Easy] Revenue by category
-- --------------------------------------------------------------------------
SELECT p.category, ROUND(SUM(l.net_revenue), 2) AS revenue
FROM fact_order_lines AS l
JOIN fact_orders AS o ON o.order_id = l.order_id
JOIN dim_product AS p ON p.product_key = l.product_key
WHERE o.status <> 'cancelled'
GROUP BY p.category
ORDER BY revenue DESC;

-- --------------------------------------------------------------------------
-- Q2 [Easy] Cities with more than 10 customers
-- --------------------------------------------------------------------------
SELECT city, COUNT(*) AS customer_count
FROM dim_customer
GROUP BY city
HAVING COUNT(*) > 10
ORDER BY customer_count DESC;

-- --------------------------------------------------------------------------
-- Q3 [Medium] Average delivery time by city
-- --------------------------------------------------------------------------
SELECT c.city, ROUND(AVG(o.delivery_days), 1) AS avg_delivery_days
FROM fact_orders AS o
JOIN dim_customer AS c ON c.customer_key = o.customer_key
WHERE o.status = 'delivered'
GROUP BY c.city
ORDER BY avg_delivery_days;

-- --------------------------------------------------------------------------
-- Q4 [Medium] Monthly revenue 2025
-- --------------------------------------------------------------------------
SELECT d.year, d.month, ROUND(SUM(l.net_revenue), 2) AS revenue
FROM fact_order_lines AS l
JOIN fact_orders AS o ON o.order_id = l.order_id
JOIN dim_date AS d ON d.date_key = o.order_date_key
WHERE o.status <> 'cancelled'
  AND d.year = 2025
GROUP BY d.year, d.month
ORDER BY d.month;

-- --------------------------------------------------------------------------
-- Q5 [Medium] Top 5 products by gross margin
-- --------------------------------------------------------------------------
SELECT p.product_name,
       ROUND(SUM(l.net_revenue), 2) AS revenue,
       ROUND(SUM(l.net_revenue) - SUM(l.quantity * p.unit_cost), 2) AS margin
FROM fact_order_lines AS l
JOIN fact_orders AS o ON o.order_id = l.order_id
JOIN dim_product AS p ON p.product_key = l.product_key
WHERE o.status <> 'cancelled'
GROUP BY p.product_key, p.product_name
ORDER BY margin DESC
LIMIT 5;

-- --------------------------------------------------------------------------
-- Q6 [Medium] Above-average customers (CTE)
-- --------------------------------------------------------------------------
WITH cust AS (
  SELECT c.customer_key, c.customer_name, SUM(l.net_revenue) AS lifetime_revenue
  FROM dim_customer AS c
  JOIN fact_orders AS o ON o.customer_key = c.customer_key
  JOIN fact_order_lines AS l ON l.order_id = o.order_id
  WHERE o.status <> 'cancelled'
  GROUP BY c.customer_key, c.customer_name
)
SELECT customer_name, ROUND(lifetime_revenue, 2) AS lifetime_revenue
FROM cust
WHERE lifetime_revenue > (SELECT AVG(lifetime_revenue) FROM cust)
ORDER BY lifetime_revenue DESC;

-- --------------------------------------------------------------------------
-- Q7 [Medium] Order value buckets
-- --------------------------------------------------------------------------
WITH order_totals AS (
  SELECT o.order_id, SUM(l.net_revenue) AS total
  FROM fact_orders AS o
  JOIN fact_order_lines AS l ON l.order_id = o.order_id
  WHERE o.status <> 'cancelled'
  GROUP BY o.order_id
)
SELECT CASE
         WHEN total < 500  THEN '<500'
         WHEN total < 1500 THEN '500-1499'
         ELSE '1500+'
       END AS bucket,
       COUNT(*) AS order_count
FROM order_totals
GROUP BY bucket
ORDER BY MIN(total);

-- --------------------------------------------------------------------------
-- Q8 [Hard] Pivot: segment x category
-- --------------------------------------------------------------------------
SELECT c.segment,
       ROUND(SUM(CASE WHEN p.category = 'Electronics' THEN l.net_revenue ELSE 0 END), 2) AS electronics,
       ROUND(SUM(CASE WHEN p.category = 'Home'        THEN l.net_revenue ELSE 0 END), 2) AS home,
       ROUND(SUM(CASE WHEN p.category = 'Sports'      THEN l.net_revenue ELSE 0 END), 2) AS sports,
       ROUND(SUM(CASE WHEN p.category = 'Books'       THEN l.net_revenue ELSE 0 END), 2) AS books,
       ROUND(SUM(CASE WHEN p.category = 'Clothing'    THEN l.net_revenue ELSE 0 END), 2) AS clothing
FROM fact_order_lines AS l
JOIN fact_orders AS o ON o.order_id = l.order_id
JOIN dim_customer AS c ON c.customer_key = o.customer_key
JOIN dim_product AS p ON p.product_key = l.product_key
WHERE o.status <> 'cancelled'
GROUP BY c.segment
ORDER BY c.segment;
