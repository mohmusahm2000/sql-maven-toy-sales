-- =========================================================
-- Load Data Script for Mexico Toy Sales Dataset
-- Purpose: Populate the data warehouse tables (dimension and fact tables)
-- =========================================================

-- ⚠️ IMPORTANT CONFIGURATION NOTE:
-- The file paths in the COPY commands below use a placeholder structure.
-- BEFORE RUNNING: Please update the paths to match the actual location 
-- of the CSV files on your local machine.
-- Example: 'C:/Users/YourName/Documents/sql-mexico-toy-sales/data/...'
-- Use forward slashes (/) to avoid path parsing errors.

BEGIN;  -- Start transaction to ensure all-or-nothing execution

-- =========================================================
-- 1️⃣ Load Stores Dimension
-- =========================================================
COPY stores_dim (
    store_id,
    store_name,
    store_city,
    store_location,
    store_open_date
)
FROM
    'C:/path/to/sql-mexico-toy-sales/data/stores.csv' -- <== UPDATE THIS PATH
    CSV HEADER;

-- =========================================================
-- 2️⃣ Load Products Dimension using TEMP TABLE for cleaning
-- =========================================================
DROP TABLE IF EXISTS products_dim_temp;  -- Remove temp table if it exists
CREATE TABLE products_dim_temp (
    product_id TEXT,
    product_name TEXT,
    product_category TEXT,
    product_cost TEXT,
    product_price TEXT
);

-- Copy raw data into temp table
COPY products_dim_temp (
    product_id,
    product_name,
    product_category,
    product_cost,
    product_price
)
FROM
    'C:/path/to/sql-mexico-toy-sales/data/products.csv' -- <== UPDATE THIS PATH
    CSV HEADER;

-- Transform and insert into final products_dim table
INSERT INTO products_dim (
    product_id,
    product_name,
    product_category,
    product_cost,
    product_price
)
SELECT
    product_id::INT,                       -- Convert ID from TEXT to INT
    product_name,
    product_category,
    REPLACE(product_cost,'$','')::NUMERIC, -- Remove $ sign and cast to NUMERIC
    REPLACE(product_price,'$','')::NUMERIC
FROM
    products_dim_temp;

DROP TABLE IF EXISTS products_dim_temp;  -- Clean up temp table

-- =========================================================
-- 3️⃣ Load Sales Fact Table
-- =========================================================
COPY sales_fact (
    sale_id,
    sale_date,
    store_id,
    product_id,
    units
)
FROM
    'C:/path/to/sql-mexico-toy-sales/data/sales.csv' -- <== UPDATE THIS PATH
    CSV HEADER;

-- =========================================================
-- 4️⃣ Load Inventory Dimension
-- =========================================================
COPY inventory_dim (
    store_id,
    product_id,
    stock_on_hand
)
FROM
    'C:/path/to/sql-mexico-toy-sales/data/inventory.csv' -- <== UPDATE THIS PATH
    CSV HEADER;

-- =========================================================
-- 5️⃣ Load Calendar Dimension using TEMP TABLE
-- =========================================================
DROP TABLE IF EXISTS calendar_dim_temp;
CREATE TABLE calendar_dim_temp (
    calendar_date TEXT  -- Load raw date as TEXT initially
);

COPY calendar_dim_temp (calendar_date)
FROM
    'C:/path/to/sql-mexico-toy-sales/data/calendar.csv' -- <== UPDATE THIS PATH
    CSV HEADER;

-- Transform calendar_date into full dimension with derived columns
-- Update: Using TO_DATE for explicit format parsing (Best Practice)
INSERT INTO calendar_dim (
    calendar_date,
    calendar_year,
    calendar_month,
    calendar_day,
    calendar_quarter,
    calendar_week,
    day_of_week,
    day_name,
    is_weekend
)
SELECT
    TO_DATE(calendar_date, 'MM/DD/YYYY'), -- Explicitly parse 'MM/DD/YYYY' format
    EXTRACT(YEAR FROM TO_DATE(calendar_date, 'MM/DD/YYYY'))::INT,
    EXTRACT(MONTH FROM TO_DATE(calendar_date, 'MM/DD/YYYY'))::INT,
    EXTRACT(DAY FROM TO_DATE(calendar_date, 'MM/DD/YYYY'))::INT,
    EXTRACT(QUARTER FROM TO_DATE(calendar_date, 'MM/DD/YYYY'))::INT,
    EXTRACT(WEEK FROM TO_DATE(calendar_date, 'MM/DD/YYYY'))::INT,
    EXTRACT(ISODOW FROM TO_DATE(calendar_date, 'MM/DD/YYYY'))::INT,
    TO_CHAR(TO_DATE(calendar_date, 'MM/DD/YYYY'),'FMDay')::VARCHAR,  -- Full day name without padding
    CASE
        WHEN EXTRACT(ISODOW FROM TO_DATE(calendar_date, 'MM/DD/YYYY')) IN (6,7) THEN TRUE
        ELSE FALSE
    END
FROM calendar_dim_temp;

DROP TABLE IF EXISTS calendar_dim_temp;  -- Clean up temp table

-- =========================================================
-- Commit transaction
-- =========================================================
COMMIT;  -- Apply all changes if no errors occurred

-- =========================================================
-- ✅ End of Load Script
-- =========================================================