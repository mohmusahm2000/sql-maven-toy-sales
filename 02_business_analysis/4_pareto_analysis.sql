/*
4️⃣ Pareto Analysis (The 80/20 Rule)
Question: Which products generate 80% of the total revenue?
*/

/*
=============================================================================
4. Pareto Analysis (Revenue Concentration)
=============================================================================
Purpose:
    - Identify the "Vital Few" products that drive the majority (80%) of revenue.
    - Focus strategic efforts (inventory, marketing) on these high-impact items.

Methodology:
    1. Aggregation: Calculate Total Revenue (TTM) per product.
    2. Window Calculation: Compute a running total (cumulative sum) sorted by revenue descending.
    3. Benchmarking: Calculate the cumulative percentage contribution of each product.
    4. Segmentation: Filter for the top percentile (<= 80%) to isolate key drivers.
=============================================================================
*/

WITH revenue_aggregation AS (
    -- Step 1: Calculate Total Revenue (TTM) per Product
    SELECT
        p.product_id,
        p.product_name,
        p.product_category,
        SUM(p.product_price * s.units) AS ttm_revenue
    FROM
        products_dim p
    INNER JOIN sales_fact s
        ON p.product_id = s.product_id
    INNER JOIN calendar_dim c
        ON s.sale_date = c.calendar_date
    WHERE
        c.calendar_date BETWEEN '2022-10-01' AND '2023-09-30'
    GROUP BY
        1, 2, 3
),

pareto_calculations AS (
    -- Step 2: Compute Running Total and Global Total using Window Functions
    SELECT
        *,
        -- Cumulative Sum: Adds up revenue row-by-row from highest to lowest
        SUM(ttm_revenue) OVER (ORDER BY ttm_revenue DESC) AS running_total_revenue,
        
        -- Global Total: Total revenue across all products (constant denominator)
        SUM(ttm_revenue) OVER () AS global_total_revenue
    FROM
        revenue_aggregation
)

SELECT
    product_id,
    product_name,
    product_category,
    ttm_revenue,
    running_total_revenue,

    -- individual_contribution_pct: Quantifies the specific revenue weight of each SKU
    ROUND(
        (ttm_revenue / NULLIF(global_total_revenue, 0)) * 100, 
        3
    ) AS individual_contribution_pct,

    -- Step 3: Calculate Cumulative Revenue Percentage
    ROUND(
        (running_total_revenue / NULLIF(global_total_revenue, 0)) * 100, 
    2) AS cumulative_revenue_pct

FROM
    pareto_calculations
WHERE
    -- Step 4: Filter to keep only the products contributing to the first 80% of revenue
    (running_total_revenue / NULLIF(global_total_revenue, 0)) <= 0.80
ORDER BY
    ttm_revenue DESC;