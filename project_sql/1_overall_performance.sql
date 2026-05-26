/*
1️⃣ Overall Performance (TTM Focus)
Question: What is the total revenue and units sold over the last 12 months?
How does this compare to the previous period?
*/

/*
=============================================================================
1. Executive Sales Scorecard (TTM & Growth Rates)
=============================================================================
Purpose:
    - Provide a high-level overview of the company's current performance magnitude.
    - Calculate growth rates to measure business momentum.

Methodology:
    1. TTM (Trailing 12 Months):
       - Analyzes the period [2022-10-01] to [2023-09-30].
       - Represents the most recent full annual cycle available in the dataset.
       
    2. Growth Rate Calculation (YTD Comparison):
       - Since historical data for Q4 2021 is missing, a direct TTM comparison is not possible.
       - Instead, we compare YTD performance (Jan - Sep) of 2023 vs. 2022.
       - This ensures an "apples-to-apples" comparison to avoid seasonality bias.

Key Metrics:
    - Revenue Growth %
    - Sales Volume (Units) Growth %
=============================================================================
*/

WITH revenue_snapshot AS (
    SELECT
        -- 1. Current Run Rate (Trailing 12 Months)
        SUM(CASE 
            WHEN c.calendar_date BETWEEN '2022-10-01' AND '2023-09-30' 
            THEN p.product_price * s.units 
            ELSE 0 
        END) AS ttm_revenue,
        
        SUM(CASE 
            WHEN c.calendar_date BETWEEN '2022-10-01' AND '2023-09-30' 
            THEN s.units 
            ELSE 0 
        END) AS ttm_units_sold,

        -- 2. YTD Current Year (Jan '23 - Sep '23)
        SUM(CASE 
            WHEN c.calendar_year = 2023 
            THEN p.product_price * s.units 
            ELSE 0 
        END) AS ytd_revenue_current,
        
        -- 3. YTD Previous Year (Jan '22 - Sep '22) - Normalized for comparison
        SUM(CASE 
            WHEN c.calendar_year = 2022 AND c.calendar_month <= 9 
            THEN p.product_price * s.units 
            ELSE 0 
        END) AS ytd_revenue_prev,
        
        -- 4. Units Volume YTD
        SUM(CASE 
            WHEN c.calendar_year = 2023 
            THEN s.units 
            ELSE 0 
        END) AS ytd_units_current,
        
        SUM(CASE 
            WHEN c.calendar_year = 2022 AND c.calendar_month <= 9 
            THEN s.units 
            ELSE 0 
        END) AS ytd_units_prev

    FROM
        products_dim p
    INNER JOIN sales_fact s
        ON p.product_id = s.product_id
    INNER JOIN calendar_dim c
        ON s.sale_date = c.calendar_date
)

SELECT
    ttm_revenue,
    ttm_units_sold,
    ytd_revenue_current,
    ytd_revenue_prev,
    ytd_units_current AS ytd_units_sold_2023,
    ytd_units_prev AS ytd_units_sold_2022,
    
    -- Growth Calculation: (Current - Prev) / Prev
    -- Uses NULLIF to prevent division by zero errors
        (ytd_revenue_current - ytd_revenue_prev) / NULLIF(ytd_revenue_prev, 0) AS revenue_growth_pct,
    
    -- Cast to NUMERIC to avoid integer division issues (e.g., 5/100 = 0)
        (ytd_units_current - ytd_units_prev)::NUMERIC / NULLIF(ytd_units_prev, 0) AS sales_growth_pct

FROM
    revenue_snapshot;