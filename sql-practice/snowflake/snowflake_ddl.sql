-- ============================================================
-- Retail practice database - Snowflake DDL
-- Same tables and data as the SQLite version, with Snowflake types.
-- Run this in a Snowsight worksheet after you have a database and
-- schema selected (see README_snowflake.md for the full walkthrough).
-- ============================================================

CREATE OR REPLACE TABLE dim_customer (
  customer_key   INTEGER,
  customer_name  VARCHAR,
  city           VARCHAR,
  segment        VARCHAR,
  signup_date    DATE
);

CREATE OR REPLACE TABLE dim_product (
  product_key    INTEGER,
  product_name   VARCHAR,
  category       VARCHAR,
  unit_price     NUMBER(10,2),
  unit_cost      NUMBER(10,2)
);

CREATE OR REPLACE TABLE dim_date (
  date_key       INTEGER,      -- YYYYMMDD
  full_date      DATE,
  year           INTEGER,
  quarter        INTEGER,
  month          INTEGER,
  month_name     VARCHAR,
  day_of_week    VARCHAR,
  is_weekend     INTEGER
);

CREATE OR REPLACE TABLE fact_orders (          -- grain: one row per order
  order_id       INTEGER,
  customer_key   INTEGER,
  order_date_key INTEGER,
  status         VARCHAR,       -- delivered / cancelled / returned / shipped
  delivery_days  INTEGER        -- NULL for cancelled and shipped orders
);

CREATE OR REPLACE TABLE fact_order_lines (     -- grain: one row per product on an order
  order_id       INTEGER,
  line_number    INTEGER,
  product_key    INTEGER,
  quantity       INTEGER,
  unit_price     NUMBER(10,2),
  discount_pct   INTEGER,
  net_revenue    NUMBER(10,2)
);

CREATE OR REPLACE TABLE sales_targets (        -- monthly revenue target per category, 2025
  category       VARCHAR,
  year           INTEGER,
  month          INTEGER,
  target_revenue NUMBER(10,2)
);

CREATE OR REPLACE TABLE raw_customers (        -- messy staging data for cleaning exercises
  customer_id    INTEGER,
  full_name      VARCHAR,
  email          VARCHAR,
  city           VARCHAR,
  updated_at     TIMESTAMP_NTZ
);
