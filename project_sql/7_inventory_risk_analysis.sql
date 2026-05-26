/*
7️⃣ Inventory Risk Analysis (Stockouts & Critical Levels)
Question: How much daily revenue is being lost (or at risk) due to inventory shortages?
*/

/*
=============================================================================
7. Inventory Health & Opportunity Cost Analysis
=============================================================================
Purpose:
    - Identify SKU-Store combinations currently experiencing Stockouts (Immediate Revenue Loss).
    - Flag items with Critical Low Stock (< 3 Days) to preempt future outages.
    - Quantify financial impact (Daily Revenue at Risk) to drive replenishment prioritization.

Methodology:
    1. Sales Velocity: Compute Average Daily Sales using TTM data to normalize for seasonality.
    2. Coverage Ratio: Derive 'Days of Supply' metric (Current Stock / Daily Sales Velocity).
    3. Risk Assessment: Filter dataset to isolate only immediate threats (< 3 days coverage).
    4. Prioritization: Sort output by urgency (lowest coverage) and financial magnitude (highest revenue loss).
=============================================================================
*/

WITH product_sales_velocity AS (
    -- 1. Calculate Average Daily Sales (Run Rate)
    -- Aggregates TTM sales to establish a baseline for daily demand.
    SELECT
        s.store_id,
        s.product_id,
        -- Cast to NUMERIC preserves precision for low-volume, high-value items.
        ROUND(SUM(s.units)::NUMERIC / 365, 4) AS avg_daily_units_sold
    FROM
        sales_fact s
    INNER JOIN calendar_dim c
        ON s.sale_date = c.calendar_date
    WHERE
        c.calendar_date BETWEEN '2022-10-01' AND '2023-09-30'
    GROUP BY
        1, 2
),

inventory_risk_assessment AS (
    -- 2. Compare Current Inventory vs. Sales Velocity
    SELECT
        st.store_id,
        st.store_name,
        p.product_id,
        p.product_name,
        p.product_category,
        p.product_price,
        i.stock_on_hand AS current_stock,
        vel.avg_daily_units_sold,

        -- Metric: Days of Supply (Inventory Coverage)
        -- NULLIF handles potential division by zero errors for inactive products.
        (i.stock_on_hand / NULLIF(vel.avg_daily_units_sold, 0))::INT AS days_of_supply,

        -- Metric: Estimated Daily Revenue at Risk
        -- Quantifies the potential daily financial loss if stock remains depleted.
        ROUND(vel.avg_daily_units_sold * p.product_price, 2) AS daily_revenue_at_risk

    FROM
        inventory_dim i
    INNER JOIN stores_dim st
        ON i.store_id = st.store_id
    INNER JOIN products_dim p
        ON i.product_id = p.product_id
    INNER JOIN product_sales_velocity vel
        ON i.store_id = vel.store_id AND i.product_id = vel.product_id
)

SELECT
    -- Identifiers for operational execution
    store_id,
    store_name,
    product_id,
    product_name,
    store_name || ' - ' || product_name AS store_product,
    product_category,
    
    -- Metrics for Decision Making
    current_stock,
    avg_daily_units_sold, -- Included to assist in calculating reorder quantities
    days_of_supply,
    daily_revenue_at_risk,
    
    -- 3. Risk Classification Status
    CASE 
        WHEN current_stock = 0 THEN '❌ Out of Stock (Losing Sales)'
        ELSE '⚠️ Critical Low (Action Needed)'
    END AS risk_status

FROM
    inventory_risk_assessment
WHERE
    -- Filter strictly for immediate stockouts (0 days) and critical risks (< 3 days).
    days_of_supply < 3
ORDER BY
    days_of_supply ASC,          -- Priority 1: Address empty shelves (Immediate Stockouts).
    daily_revenue_at_risk DESC;  -- Priority 2: Address highest financial impact items.