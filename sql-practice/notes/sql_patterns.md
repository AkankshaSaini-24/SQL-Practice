# My SQL patterns

Starter snippets. Rewrite each one in your own words as you learn it, and add new ones.
Table and column names are placeholders.

## Top N per group
```sql
WITH ranked AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY group_col ORDER BY metric DESC) AS rn
  FROM t
)
SELECT * FROM ranked WHERE rn <= 3;
```

## Keep the latest row per key (de-duplicate)
```sql
WITH ranked AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY updated_at DESC) AS rn
  FROM raw_table
)
SELECT * FROM ranked WHERE rn = 1;
```

## Rows with no match (anti-join)
```sql
SELECT a.*
FROM a
LEFT JOIN b ON b.a_id = a.id
WHERE b.a_id IS NULL;
```

## Running total
```sql
SELECT month, revenue, SUM(revenue) OVER (ORDER BY month) AS running_total
FROM monthly;
```

## Previous value and % change (LAG)
```sql
SELECT month, revenue,
       LAG(revenue) OVER (ORDER BY month) AS prev,
       100.0 * (revenue - LAG(revenue) OVER (ORDER BY month)) / LAG(revenue) OVER (ORDER BY month) AS pct_change
FROM monthly;
```

## Pivot with conditional aggregation
```sql
SELECT segment,
       SUM(CASE WHEN category = 'A' THEN revenue ELSE 0 END) AS a,
       SUM(CASE WHEN category = 'B' THEN revenue ELSE 0 END) AS b
FROM sales
GROUP BY segment;
```

## First event per user (cohorts)
```sql
SELECT user_id, MIN(event_date) AS first_date
FROM events
GROUP BY user_id;
```

## Month bucket
```sql
SELECT strftime('%Y-%m', order_date) AS ym, COUNT(*) FROM orders GROUP BY ym;
```

## Data-quality test (returns failing rows)
```sql
SELECT * FROM orders WHERE total < 0 OR customer_id IS NULL;
```

## My own notes
- 
