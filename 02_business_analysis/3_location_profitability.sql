/*
3️⃣ Store Performance by Location (Normalized by Operational Efficiency)
Question: Which store locations yield the best performance?
Method: Calculating "Average Monthly Revenue" per store, adjusted for each store's 
        specific opening date within the analysis period.
*/

/*
=============================================================================
3. Location Segmentation Analysis (Time-Weighted)
=============================================================================
Purpose:
    - Determine the most profitable location types (Downtown, Commercial, etc.).
    - Normalize performance by calculating monthly averages per store to account 
      for different store opening dates (avoiding bias against newer stores).

Logic:
    1. Define a strict analysis window (Jan '22 - Sep '23).
    2. For each store, calculate "Operational Months" within this window:
       - If a store opened BEFORE the window, count from Start Date.
       - If a store opened DURING the window, count from Opening Date.
    3. Metric = Total Revenue / Operational Months.
=============================================================================
*/

CREATE OR REPLACE VIEW v_location_profitability AS
WITH analysis_timeframe AS (
    -- 🔧 CONFIGURATION: Define the scope of analysis
    SELECT 
        '2022-01-01'::DATE AS start_date,
        '2023-09-30'::DATE AS end_date
),

store_performance AS (
    SELECT
        st.store_location,
        st.store_id,
        
        -- 1. Calculate Revenue
        SUM(p.product_price * s.units) AS total_revenue,

        -- 2. Calculate "Effective" Operational Months
        -- Logic: We calculate the duration between the analysis END date and
        -- the LATER of (Analysis Start Date OR Store Open Date).
        EXTRACT(YEAR FROM AGE(
            tf.end_date, 
            CASE 
                WHEN st.store_open_date > tf.start_date 
                THEN st.store_open_date 
                ELSE tf.start_date 
            END
        )) * 12 
        + EXTRACT(MONTH FROM AGE(
            tf.end_date, 
            CASE 
                WHEN st.store_open_date > tf.start_date 
                THEN st.store_open_date 
                ELSE tf.start_date 
            END
        )) + 1 AS operational_months

    FROM
        stores_dim st
    INNER JOIN sales_fact s
        ON st.store_id = s.store_id
    INNER JOIN products_dim p
        ON s.product_id = p.product_id
    CROSS JOIN analysis_timeframe tf
    GROUP BY
        1, 2, 4, tf.end_date, tf.start_date, st.store_open_date
)

SELECT
    store_location,
    COUNT(store_id) AS num_of_stores,
    
    -- 3. Final Metric: Average Monthly Revenue per Store
    -- Averages the monthly run-rate of all stores in that location
    ROUND(
        AVG(total_revenue / NULLIF(operational_months, 0)), 
    2) AS avg_monthly_revenue_per_store

FROM
    store_performance
GROUP BY
    store_location
ORDER BY
    avg_monthly_revenue_per_store DESC;