/*
8️⃣ Store-Level Daily Sales Analysis
Question: How does sales velocity and revenue contribution vary by day of week across different store locations?
*/

/*
=============================================================================
8. Staffing & Operational Efficiency Analysis
=============================================================================
Business Context:
    - Retail operations require precise daily forecasts to optimize labor costs (staffing) and inventory flow.
    - Global reporting standards require consistent week alignment (Monday-start) for cross-region comparability.

Analytical Approach:
    1. Granularity Adjustment (CTE): Aggregates transaction-level data into daily store-level metrics.
    2. Relative Contribution (Window Functions): Computes each day's share of total store revenue to identify revenue drivers.
    3. Standardization: Leverages ISO-8601 standard (Monday=1) for consistent temporal sorting.
=============================================================================
*/

CREATE OR REPLACE VIEW v_daily_sales_patterns_by_store AS
WITH daily_store_metrics AS (
    -- Pre-aggregates sales data to the required grain (Store x Day) for downstream analysis.
    SELECT
        st.store_id,
        st.store_name,
        c.day_name,
        c.day_of_week, -- Aligned to ISO-8601 standard via ETL process (1=Mon, 7=Sun).
        CASE 
            WHEN c.is_weekend IS TRUE THEN 'Weekend'
            ELSE 'Weekday' 
        END AS day_type,
        
        -- Primary aggregations
        SUM(p.product_price * s.units) AS daily_revenue,
        COUNT(DISTINCT s.sale_date) AS operating_days_count
    FROM
        stores_dim st
    INNER JOIN sales_fact s
        ON st.store_id = s.store_id
    INNER JOIN calendar_dim c
        ON s.sale_date = c.calendar_date
    INNER JOIN products_dim p
        ON s.product_id = p.product_id
    WHERE
        -- Restricts analysis to the most recent TTM period for relevant operational insights.
        c.calendar_date BETWEEN '2022-10-01' AND '2023-09-30'
    GROUP BY
        1, 2, 3, 4, 5
)

SELECT
    store_id,
    store_name,
    day_of_week,
    day_name,
    day_type,
    
    -- Operational KPI: Average Daily Revenue
    -- Acts as a proxy for store traffic volume to guide daily headcount planning.
    ROUND(
        daily_revenue / NULLIF(operating_days_count, 0), 
        2
    ) AS avg_daily_revenue,
    
    -- Strategic KPI: Revenue Contribution %
    -- Isolates high-value operating days to prioritize inventory availability and promotional focus.
    ROUND(
        daily_revenue / 
        SUM(daily_revenue) OVER (PARTITION BY store_id),
        4
    ) AS pct_of_store_revenue

FROM
    daily_store_metrics
ORDER BY
    store_id ASC,
    day_of_week ASC;