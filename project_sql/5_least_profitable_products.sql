/*
5️⃣ Profitability Analysis (Bottom Performers)
Question: Which products are generating the lowest profit (or financial losses)?
*/

/*
=============================================================================
5. Least Profitable Products (TTM Analysis)
=============================================================================
Purpose:
    - Identify the bottom 5 products in terms of Total Profit generation over the Last 12 Months (TTM).
    - Highlight products that may be operating at a loss or yielding negligible returns, 
      serving as candidates for discontinuation or pricing strategy reviews.

Logic:
    - Profit Calculation: Derived dynamically as (Product Price - Product Cost) * Units Sold.
    - Timeframe: Restricted to the TTM period [2022-10-01 to 2023-09-30] to reflect current market conditions.
    - Sorting: Ascending order is used to surface negative values (losses) or the smallest positive profits first.
=============================================================================
*/

SELECT
    p.product_id,
    p.product_name,
    p.product_category, -- Included to identify if specific categories are underperforming
    
    SUM(s.units) AS total_units_sold,
    -- Calculate Total Gross Profit
    SUM((p.product_price - p.product_cost) * s.units) AS ttm_total_profit

FROM
    products_dim p
INNER JOIN sales_fact s
    ON p.product_id = s.product_id
INNER JOIN calendar_dim c
    ON s.sale_date = c.calendar_date
WHERE
    -- Filter for Trailing 12 Months (TTM)
    c.calendar_date BETWEEN '2022-10-01' AND '2023-09-30'
GROUP BY
    1, 2, 3
ORDER BY
    ttm_total_profit ASC -- Sorts from lowest (potentially negative) to highest
LIMIT 5;