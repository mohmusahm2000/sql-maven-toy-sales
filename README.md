# Maven Toys Mexico: Sales & Operational Performance Analysis

# Project Background
Maven Toys is a growing retail chain operating 50 store locations across Mexico. The company offers a catalog of 35 distinct toy products and operates across four main real estate categories: Downtown, Commercial, Residential, and Airports. As a Data Analyst at Maven Toys, I was tasked with conducting a diagnostic analysis of the company's operational performance. Despite experiencing strong top-line organic growth, executive leadership suspected hidden inefficiencies regarding inventory management, real estate investments, and product portfolio profitability.

Insights and recommendations are provided on the following key areas:
- **Sales Trends & Seasonality:** Evaluating overall YoY growth and monthly cyclical patterns.
- **Location & Footprint Efficiency:** Assessing the actual financial yield of different store locations.
- **Product Portfolio Optimization:** Identifying the core drivers of revenue vs. dead stock.
- **Supply Chain & Operational Risk:** Quantifying the daily financial impact of inventory stockouts.

The SQL queries used to inspect and clean the data for this analysis can be found here [Link to SQL file].

Targeted SQL queries regarding various business questions can be found here [Link to SQL file].

An interactive Power BI dashboard used to report and explore sales and inventory trends can be found here [Link to Dashboard].

# Data Structure & Initial Checks
The company's main database structure consists of four interconnected tables containing extensive historical transactional data. A description of each table is as follows:
- **sales_fact:** Contains daily transactional records including store ID, product ID, date, and units sold.
- **products_dim:** Contains product-level details including product name, category, cost, and retail price.
- **stores_dim:** Contains geographical and categorical data for the 50 branches, including location type and city.
- **inventory_dim:** Contains daily stock-on-hand snapshots for every product at every store location.

[Entity Relationship Diagram here]

# Executive Summary
### Overview of Findings
Maven Toys is experiencing robust market penetration, with Year-to-Date (YTD) volume growing by 40.8% and revenue increasing by 30.9% to reach a Trailing Twelve Months (TTM) total of $9.12M. However, this aggressive growth masks severe operational bottlenecks: the company has over-expanded into low-yielding Downtown real estate, and systemic supply chain failures (frequent stockouts of high-demand items) are bleeding daily revenue. Focusing on protecting the top 15 products and shifting CapEx to transit hubs will significantly improve margin efficiency.

[Overall Executive Dashboard Screenshot here]

# Insights Deep Dive
### Sales Trends & Seasonality:
* **Organic growth is strong but volume-driven.** YTD 2023 revenue reached $6.96M compared to $5.32M in the previous year (+30.9%). Notably, units sold outpaced revenue growth (+40.8%), indicating heavier discounting or a shift toward lower-priced items to capture market share.
* **Extreme seasonal reliance on Q4.** December 2022 generated a massive, disproportionate revenue spike (the holiday peak), followed by a steep contraction in January 2023. This post-holiday mean reversion drives Month-over-Month (MoM) growth deeply into negative territory in Q1.

[Line Chart Visualization: Monthly Revenue & MoM Growth]

### Location & Footprint Efficiency:
* **Downtown stores are over-saturated.** Maven Toys has heavily invested in Downtown areas (29 stores), but these locations yield the lowest average monthly revenue per store (under $14,000). 
* **Airport locations are highly lucrative.** Despite having only 3 stores globally, Airport locations dominate unit economics, generating an exceptional average of >$20,000 per store monthly. They capture a high-intent, captive audience.

[Bar Chart Visualization: Store Count vs. Avg Monthly Revenue by Location]

### Product Portfolio Optimization:
* **Revenue is heavily concentrated (Pareto Principle).** Out of a 35-item catalog, just 15 products generate exactly 80% of total corporate revenue. 
* **The "Vital Few" dominate.** `Lego Bricks` is the undisputed leader, generating ~$1.5M TTM revenue independently, followed closely by `Magic Sand` ($1.0M). 
* **The Tail-End is draining resources.** Products like `Classic Dominoes` ($5k total TTM profit) and `Teddy Bear` (which moves high volume but yields only $8k total profit, indicating a ~$2 margin) are occupying valuable shelf space with minimal ROI.

[Pareto Chart Visualization: Cumulative Revenue by Product]

### Supply Chain & Operational Risk:
* **Weekends dictate operational flow.** A daily sales heatmap reveals that Saturdays contribute 20% to 29% of weekly sales across almost all branches, followed by Fridays. Tuesdays and Wednesdays drop to 8%-10%.
* **Stockouts are costing tangible daily revenue.** Out-of-stock instances for top-tier products are inducing severe financial penalties. For example, stockouts of `Lego Bricks` at high-performing stores like Ciudad de Mexico 2 and Guanajuato 1 cost the company >$130 in lost revenue *every single day* the item is missing.

[Bar Chart Visualization: Daily Revenue at Risk by Store-Product]

# Recommendations:
Based on the insights and findings above, we recommend the Executive and Operations teams consider the following:

* Downtown locations show diminishing returns while transit hubs excel. **Freeze retail expansion in Downtown markets and re-route Capital Expenditure (CapEx) to scale small-footprint kiosks in Airports and commercial transit centers.**
* 15 products drive 80% of revenue, yet frequently suffer from stockouts. **Implement an Automated Re-order Point (ROP) system with high safety stock buffers specifically for these 15 items. Treat out-of-stock alerts for Lego Bricks and Magic Sand as operational emergencies.**
* The bottom 5 products generate negligible profit but consume warehousing space. **Discontinue procurement for items like Classic Dominoes and Uno, and launch a clearance sale to free up capacity for high-margin SKU lines.**
* Customer foot traffic heavily skews toward the weekend. **Dynamically optimize store staffing schedules by maximizing front-line workforce during the Friday-Saturday surge, and scaling down shifts during the Tuesday-Wednesday lull to reduce payroll overhead.**

# Assumptions and Caveats:
Throughout the analysis, multiple assumptions were made to manage challenges with the data:
* It is assumed that days with zero `stock_on_hand` in the inventory table correspond directly to missed sales opportunities, calculated against the historical daily average sales of that specific store-product combination.
* Cost and retail pricing for the 35 products are assumed to be static across the analyzed period, as historical price-change logs were not provided in the dataset.
