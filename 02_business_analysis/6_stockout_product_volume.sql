/*
6️⃣ Inventory "Risks" Analysis (Snapshot)
Question: Which products are currently out of stock?
Among them, which ones are the biggest "missed opportunities"
based on their sales volume in the Last 12 Months?
*/

/*
=============================================================================
6. Part 1: Inventory Shortage Report (Stockouts Snapshot)
=============================================================================
Purpose:
    - Identify specific Store-Product combinations that are currently out of stock.
    - Serve as an immediate "Action List" for supply chain managers to restock.

Logic:
    - Filter `inventory_dim` where `stock_on_hand` is zero.
    - Join with Store and Product dimensions to provide context (Location & Category).
    - Ordered by Store and Category to facilitate logistical processing.
=============================================================================
*/

CREATE OR REPLACE VIEW v_stockout_product_volume AS
SELECT
    st.store_id,
    st.store_name,
    p.product_id AS out_of_stock_product_id,
    p.product_name AS out_of_stock_product_name,
    p.product_category AS category_name
FROM
    inventory_dim i 
INNER JOIN stores_dim st
    ON i.store_id = st.store_id
INNER JOIN products_dim p
    ON i.product_id = p.product_id
WHERE
    i.stock_on_hand = 0
ORDER BY
    i.store_id,
    category_name,
    out_of_stock_product_name;

/*
=============================================================================
6. Part 2: "Missed Opportunities" Analysis (Prioritization)
=============================================================================
Purpose:
    - Identify the "Top 3" critical out-of-stock products for each store.
    - Prioritize restocking based on "Opportunity Cost" (Historical Demand).
    
Methodology:
    - Focus on the Trailing 12 Months (TTM) [Oct '22 - Sep '23] to ensure 
      we rely on recent demand trends, not outdated history.
    - Use DENSE_RANK() to handle ties in sales volume gracefully.
    - Only considers items that have a sales history (Implicit filtering via Inner Join).

Business Impact:
    - Helps Supply Chain Managers allocate limited inventory to high-demand locations first.
=============================================================================
*/

WITH stockout_impact_analysis AS (
    -- Step 1: Calculate historical demand (TTM) for currently out-of-stock items
    SELECT
        i.store_id,
        st.store_name,
        i.product_id AS out_of_stock_product_id,
        p.product_name AS out_of_stock_product_name,
        p.product_category AS category_name,
        SUM(s.units) AS ttm_units_sold -- Renamed for clarity: TTM = Trailing 12 Months
    FROM
        inventory_dim i
    INNER JOIN stores_dim st
        ON i.store_id = st.store_id
    INNER JOIN products_dim p
        ON i.product_id = p.product_id
    INNER JOIN sales_fact s
        ON i.store_id = s.store_id AND i.product_id = s.product_id
    INNER JOIN calendar_dim c
        ON s.sale_date = c.calendar_date
    WHERE
        i.stock_on_hand = 0
        AND c.calendar_date BETWEEN '2022-10-01' AND '2023-09-30' -- Focus on recent performance
    GROUP BY
        1, 2, 3, 4, 5
),

prioritized_restock_list AS (
    -- Step 2: Rank items per store based on sales volume
    SELECT
        *,
        DENSE_RANK() OVER (PARTITION BY store_id ORDER BY ttm_units_sold DESC) AS demand_rank
    FROM
        stockout_impact_analysis
)

-- Step 3: Retrieve the Top 3 High-Priority items per store
SELECT
    store_id,
    store_name,
    out_of_stock_product_id,
    out_of_stock_product_name,
    category_name,
    demand_rank,
    ttm_units_sold
FROM
    prioritized_restock_list
WHERE
    demand_rank <= 3
ORDER BY
    store_id,
    demand_rank,
    category_name;