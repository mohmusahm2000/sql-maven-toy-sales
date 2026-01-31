-- =========================================================
-- Data Validation Script — Mexico Toy Sales SQL Portfolio
-- Purpose: Validate data integrity after loading
-- =========================================================

-- ===============================================================
-- 1️⃣ Check row counts
-- Returns total number of rows in each table.
-- This check is informational; row counts are expected to be > 0.
-- ===============================================================
SELECT 'stores_dim' AS table_name, COUNT(*) FROM stores_dim
UNION ALL
SELECT 'products_dim', COUNT(*) FROM products_dim
UNION ALL
SELECT 'sales_fact', COUNT(*) FROM sales_fact
UNION ALL
SELECT 'inventory_dim', COUNT(*) FROM inventory_dim
UNION ALL
SELECT 'calendar_dim', COUNT(*) FROM calendar_dim;

-- =========================================================
-- 2️⃣ NOT NULL checks
-- Ensure no mandatory columns contain NULL values.
-- =========================================================

-- stores_dim
SELECT * FROM stores_dim
WHERE store_id IS NULL
   OR store_name IS NULL
   OR store_city IS NULL;

-- products_dim
SELECT * FROM products_dim
WHERE product_id IS NULL
   OR product_name IS NULL
   OR product_category IS NULL
   OR product_cost IS NULL
   OR product_price IS NULL;

-- sales_fact
SELECT * FROM sales_fact
WHERE sale_id IS NULL
   OR sale_date IS NULL
   OR store_id IS NULL
   OR product_id IS NULL
   OR units IS NULL;

-- inventory_dim
SELECT * FROM inventory_dim
WHERE store_id IS NULL
   OR product_id IS NULL
   OR stock_on_hand IS NULL;

-- calendar_dim
SELECT * FROM calendar_dim
WHERE calendar_date IS NULL
   OR calendar_year IS NULL
   OR calendar_month IS NULL
   OR calendar_day IS NULL
   OR calendar_quarter IS NULL
   OR calendar_week IS NULL
   OR day_of_week IS NULL
   OR day_name IS NULL
   OR is_weekend IS NULL;

-- =========================================================
-- 3️⃣ Primary Key uniqueness checks
-- Ensure no duplicate primary key values exist
-- =========================================================
SELECT sale_id, COUNT(*) FROM sales_fact
GROUP BY sale_id
HAVING COUNT(*) > 1;

SELECT store_id, COUNT(*) FROM stores_dim
GROUP BY store_id
HAVING COUNT(*) > 1;

SELECT product_id, COUNT(*) FROM products_dim
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT calendar_date, COUNT(*) FROM calendar_dim
GROUP BY calendar_date
HAVING COUNT(*) > 1;

SELECT store_id, product_id, COUNT(*) FROM inventory_dim
GROUP BY store_id, product_id
HAVING COUNT(*) > 1;

-- =========================================================
-- 4️⃣ Foreign Key integrity checks
-- Detect orphaned references in fact and inventory tables
-- =========================================================

-- sales_fact FKs
SELECT *
FROM sales_fact s
LEFT JOIN stores_dim st ON s.store_id = st.store_id
WHERE st.store_id IS NULL;

SELECT *
FROM sales_fact s
LEFT JOIN products_dim p ON s.product_id = p.product_id
WHERE p.product_id IS NULL;

-- inventory_dim FKs
SELECT *
FROM inventory_dim i
LEFT JOIN stores_dim st ON i.store_id = st.store_id
WHERE st.store_id IS NULL;

SELECT *
FROM inventory_dim i
LEFT JOIN products_dim p ON i.product_id = p.product_id
WHERE p.product_id IS NULL;

-- ===========================================================
-- 5️⃣ CHECK constraints / range validations
-- Ensure numeric and calendar columns are within valid ranges
-- ===========================================================

-- Numeric / units / prices
SELECT * FROM sales_fact WHERE units <= 0;
SELECT * FROM products_dim WHERE product_cost < 0 OR product_price < 0;
SELECT * FROM inventory_dim WHERE stock_on_hand < 0;

-- Calendar sanity checks
SELECT *
FROM calendar_dim
WHERE calendar_month NOT BETWEEN 1 AND 12
   OR calendar_day NOT BETWEEN 1 AND 31
   OR calendar_quarter NOT BETWEEN 1 AND 4
   OR calendar_week NOT BETWEEN 1 AND 53
   OR day_of_week NOT BETWEEN 1 AND 7;

-- ====================================================================================
-- ✅ End of Validation
-- All checks above - except the first (row counts) - return zero rows if data is clean
-- ====================================================================================
