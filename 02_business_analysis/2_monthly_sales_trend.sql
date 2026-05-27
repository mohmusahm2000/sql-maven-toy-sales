/*
2️⃣ Monthly Sales Trend (Seasonality)
Question: How have sales evolved month-over-month?
Are there specific seasonal peaks?
*/

/*
=============================================================================
2. Monthly Sales Trend Analysis (Time Series & Seasonality)
=============================================================================
Purpose:
    - Visualize historical sales performance across the full timeline (Jan 2022 - Sep 2023).
    - Detect seasonal patterns, specifically validating the Q4 holiday spike in 2022.
    - Measure business momentum using Month-over-Month (MoM) revenue growth.

Key Techniques:
    - Window Functions (LAG): To compare current performance vs. previous periods without self-joins.
    - Error Handling (NULLIF): To ensure robust calculations by preventing division-by-zero errors.
=============================================================================
*/

CREATE OR REPLACE VIEW v_monthly_sales_trend AS
WITH monthly_sales AS (
    -- 1. Aggregating transaction-level data into monthly snapshots
    SELECT
        DATE_TRUNC('month', c.calendar_date)::DATE AS month_date, -- Normalize dates to 1st of month
        c.calendar_year,
        c.calendar_month,
        SUM(s.units) AS total_units,
        SUM(s.units * p.product_price) AS total_revenue
    FROM
        sales_fact s
    INNER JOIN products_dim p
        ON s.product_id = p.product_id
    INNER JOIN calendar_dim c
        ON s.sale_date = c.calendar_date
    GROUP BY
        1, 2, 3
)

SELECT
    month_date,
    calendar_year,
    calendar_month,
    total_revenue,
    total_units,
    
    -- 2. Calculating Month-over-Month (MoM) Growth
    -- Formula: (Current Revenue - Previous Revenue) / Previous Revenue
    (total_revenue - LAG(total_revenue) OVER (ORDER BY month_date))
    / NULLIF(LAG(total_revenue) OVER (ORDER BY month_date), 0) AS mom_revenue_growth_pct

FROM
    monthly_sales
ORDER BY
    month_date; -- Chronological order is essential for trend visualization