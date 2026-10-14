-- 01 - Select, filter and join - SOLUTIONS
-- Try each question yourself first. There is usually more than one correct way.

-- --------------------------------------------------------------------------
-- Q1 [Easy] Customers in Stockholm
-- --------------------------------------------------------------------------
SELECT customer_name, signup_date
FROM dim_customer
WHERE city = 'Stockholm'
ORDER BY customer_name;

-- --------------------------------------------------------------------------
-- Q2 [Easy] Most expensive electronics
-- --------------------------------------------------------------------------
SELECT product_name, unit_price
FROM dim_product
WHERE category = 'Electronics'
ORDER BY unit_price DESC
LIMIT 5;

-- --------------------------------------------------------------------------
-- Q3 [Easy] Orders by status
-- --------------------------------------------------------------------------
SELECT status, COUNT(*) AS order_count
FROM fact_orders
GROUP BY status
ORDER BY order_count DESC;

-- --------------------------------------------------------------------------
-- Q4 [Easy] Order lines with product details
-- --------------------------------------------------------------------------
SELECT l.order_id, l.line_number, p.product_name, p.category, l.net_revenue
FROM fact_order_lines AS l
JOIN dim_product AS p ON p.product_key = l.product_key
WHERE l.order_id BETWEEN 1001 AND 1010
ORDER BY l.order_id, l.line_number;

-- --------------------------------------------------------------------------
-- Q5 [Medium] Customers who never ordered
-- --------------------------------------------------------------------------
SELECT c.customer_key, c.customer_name
FROM dim_customer AS c
LEFT JOIN fact_orders AS o ON o.customer_key = c.customer_key
WHERE o.order_id IS NULL
ORDER BY c.customer_key;

-- --------------------------------------------------------------------------
-- Q6 [Medium] Products that never sold
-- --------------------------------------------------------------------------
SELECT p.product_name, p.category
FROM dim_product AS p
LEFT JOIN fact_order_lines AS l ON l.product_key = p.product_key
WHERE l.order_id IS NULL
ORDER BY p.product_name;

-- --------------------------------------------------------------------------
-- Q7 [Medium] Delivered orders in March 2025
-- --------------------------------------------------------------------------
SELECT o.order_id, c.customer_name, c.city, d.full_date
FROM fact_orders AS o
JOIN dim_customer AS c ON c.customer_key = o.customer_key
JOIN dim_date AS d ON d.date_key = o.order_date_key
WHERE o.status = 'delivered'
  AND d.year = 2025
  AND d.month = 3
ORDER BY d.full_date, o.order_id;

-- --------------------------------------------------------------------------
-- Q8 [Easy] Corporate signups in 2024
-- --------------------------------------------------------------------------
SELECT customer_name, signup_date
FROM dim_customer
WHERE segment = 'Corporate'
  AND signup_date >= '2024-01-01'
  AND signup_date <  '2025-01-01'
ORDER BY signup_date;
