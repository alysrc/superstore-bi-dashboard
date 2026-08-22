# Superstore Sales & Profitability Analysis

A SQL and Power BI project built to answer a simple but expensive question: *where is this business actually making money, and where is it quietly losing it?*

Using the [Kaggle Superstore dataset](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final), this project traces sales performance from raw transaction data through to an interactive dashboard — with a specific focus on regional profitability, customer value concentration, and the point at which discounting stops paying off.

📌 See Live Dashboard [here](http://app.powerbi.com/reportEmbed?reportId=ff309ae2-11f0-4998-8877-41e1986b54a9&autoAuth=true&ctid=e8e1fa0b-7d9d-4187-83a2-8a8010ef06b4)  
---

## What's Inside

**Regional performance** — monthly sales and profit trends broken down to the region, state, and city level, with drill-down built into the dashboard.

**Discount impact analysis** —  analysis of profit margin against discount rate shows a clear downward relationship across the dataset, with Furniture and Office Supplies absorbing the steepest losses at high discount levels, while Technology holds up comparatively well. 

**Data quality & governance** — before any of the above was trusted, the dataset went through a validation pass, and customer identifiers were pseudonymized to reflect how this kind of data would need to be handled in a real production environment.

## Key Business Questions Answered

1. What is the total sales, profit, and order count overall?  
2. What are total sales and profit by region, month, and year?  
3. Which regions/states show declining profit despite stable or growing sales?  
4. Who are the top 10 customers by revenue, and are they also the most profitable?  
5. Which customers are high-revenue but low-margin — a retention risk worth flagging?  
6. At what discount level does profit margin turn negative, and does this vary by category?  
7. Which product categories are most exposed to discount-driven losses?  
8. What is the month-over-month and year-over-year sales growth trend?  
9. Which segment (Consumer, Corporate, Home Office) generates the most profit, not just revenue?  
10. What is the profit-per-order efficiency by segment and by state?  
11. Are there data quality issues (duplicates, invalid values, missing fields) that could distort analysis?  
12. How were customer identifiers handled to align with data privacy practices?

Query: [`sql/02_business_queries.sql`](http://sql/01_data_quality_checks.sql).

📁 All SQL queries are saved in `/sql`

---

## Built With

| Database | PostgreSQL |
| :---- | :---- |
| Query Tool | pgAdmin |
| Visualization | Power BI — DAX measures, drill-down hierarchies, field parameters, small multiples |
| Source Data | [Kaggle: Superstore Dataset](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final) |

---

## How the Data Was Prepared

Raw data is never analysis-ready, and this project treats that step as part of the deliverable, not a footnote:

- Verified `row_id` uniqueness and investigated any duplicate order/product combinations rather than assuming they were errors  
- Checked for invalid values — negative quantities, discounts outside a valid 0–100% range  
- Confirmed no missing values in fields the analysis depends on (region, state, postal code, customer ID)  
- Verified every `ship_date` logically follows its `order_date`  
- Renamed all columns to `snake_case` for query readability and consistency  
- Rescaled `order_date` and `ship_date` from the dataset's original range to 2023–2026, proportionally preserving the relative spacing and order between dates, so the analysis reflects a current, recognizable timeframe 

Query: [`sql/01_data_quality_check.sql`](http://sql/01_data_quality_checks.sql).  
Cleaned data: data/superstore\_sales\_clean.csv

---

## Handling Customer Data Responsibly

Customer names in this dataset were replaced with sequential identifiers (`Customer_0001`, `Customer_0002`, etc.) via a mapping table kept separate from the published data — a pseudonymization pattern consistent with GDPR's definition of the term. The mapping itself is never published; only the anonymized dataset and dashboard are.

Query: [`sql/03_pseudonymize_customers.sql`](http://sql/99_pseudonymize_customers.sql)

---

## **Visual Insights** 

The insights and answers to the business questions above are presented in an interactive Power BI dashboard, which includes:

* Monthly and yearly sales/profit trends with YoY comparison  
* Region → State → City drill-down for geographic performance  
* Discount vs. profit margin analysis, split by category, showing exactly where discounting turns unprofitable ![Discount vs Profit Margin Analysis]()

Check out: dashboard/dashboard\_superstore\_sales.pbix

---

## What This Project Demonstrates

- Translating a business question into SQL, not just running pre-built queries  
- Treating data validation and privacy handling as part of the analysis, not an afterthought  
- Building a dashboard meant to be explored (drill-downs, field parameters), not just viewed  
- Distinguishing between what the data actually shows and what still needs verifying — and being upfront about the difference

