-- ==================================================================
-- Dimension table: Stores
-- Contains information about store locations, city, and opening date
-- ==================================================================
CREATE TABLE IF NOT EXISTS stores_dim (
    store_id INT PRIMARY KEY,
    store_name TEXT NOT NULL,
    store_city TEXT NOT NULL,
    store_location TEXT,
    store_open_date DATE
);

-- ============================================================
-- Dimension table: Products
-- Contains product details including category, cost, and price
-- ============================================================
CREATE TABLE IF NOT EXISTS products_dim (
    product_id INT PRIMARY KEY,
    product_name TEXT NOT NULL,
    product_category TEXT NOT NULL,
    product_cost NUMERIC(12,2) NOT NULL CHECK (product_cost >= 0),
    product_price NUMERIC(12,2) NOT NULL CHECK (product_price >= 0)
);

-- ===============================================
-- Fact table: Sales
-- Stores sales transactions per store and product
-- ===============================================
CREATE TABLE IF NOT EXISTS sales_fact (
    sale_id INT PRIMARY KEY,
    sale_date DATE NOT NULL,
    store_id INT NOT NULL,
    product_id INT NOT NULL,
    units INT NOT NULL CHECK (units > 0),
    FOREIGN KEY (store_id)
        REFERENCES stores_dim(store_id)
        ON DELETE RESTRICT,
    FOREIGN KEY (product_id)
        REFERENCES products_dim(product_id)
        ON DELETE RESTRICT
);

-- ===================================
-- Dimension table: Inventory
-- Current stock per store and product
-- ===================================
CREATE TABLE IF NOT EXISTS inventory_dim (
    store_id INT,
    product_id INT,
    stock_on_hand INT NOT NULL CHECK (stock_on_hand >= 0),
    PRIMARY KEY (store_id, product_id),
    FOREIGN KEY (store_id)
        REFERENCES stores_dim(store_id)
        ON DELETE RESTRICT,
    FOREIGN KEY (product_id)
        REFERENCES products_dim(product_id)
        ON DELETE RESTRICT
);

-- ===============================================================
-- Dimension table: Calendar
-- Each row represents a date with derived attributes for analysis
-- ===============================================================
CREATE TABLE IF NOT EXISTS calendar_dim (
    calendar_date DATE PRIMARY KEY,
    calendar_year INT NOT NULL,
    calendar_month INT NOT NULL CHECK (calendar_month BETWEEN 1 AND 12),
    calendar_day INT NOT NULL CHECK (calendar_day BETWEEN 1 AND 31),
    calendar_quarter INT NOT NULL CHECK (calendar_quarter BETWEEN 1 AND 4),
    calendar_week INT NOT NULL CHECK (calendar_week BETWEEN 1 AND 53),
    day_of_week INT NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),
    day_name VARCHAR(10) NOT NULL,
    is_weekend BOOLEAN NOT NULL
); 

-- ==================================================
-- Indexes for performance optimization on sales_fact
-- ==================================================
CREATE INDEX idx_sales_date ON sales_fact(sale_date);
CREATE INDEX idx_sales_store ON sales_fact(store_id);
CREATE INDEX idx_sales_product ON sales_fact(product_id);