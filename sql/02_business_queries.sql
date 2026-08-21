
-- BUSINESS ANALYSIS QUERIES

-- Monthly sales & profit trend per region

select 
 "region",
 DATE_TRUNC('month', "order_date") as order_month,
 SUM("profit") as total_profit,
 SUM("sales_amount") as total_sales,
 ROUND(SUM("profit") / NULLIF(SUM("sales_amount"), 0) * 100, 2) AS profit_margin_pct
from sales
group by "region",  DATE_TRUNC('month', "order_date")
order by "region", DATE_TRUNC('month', "order_date");


  

-- Month-over-month % change in sales per region (using window functions)

WITH monthly_sales (
  SELECT 
  "region",
 date_trunc('month', "order_date") as order_month,
  SUM("sales_amount") as total_sales
from sales
group by "region",  date_trunc('month', "order_date")
)

select 
  "region",
  order_month,
  total_sales,
  LAG(total_sales) OVER (PARTITION BY "Region" ORDER BY order_month) AS prev_month_sales,
    ROUND(
        (total_sales - LAG(total_sales) OVER (PARTITION BY "region" ORDER BY order_month))
        / NULLIF(LAG(total_sales) OVER (PARTITION BY "region" ORDER BY order_month), 0) * 100
    , 2) AS mom_growth_pct
FROM monthly
ORDER BY "region", order_month;



-- Top 10 customers overall

SELECT
    "customer_name",
    "region",
    round(SUM("sales_amount"), 0) AS total_revenue,
    SUM("profit") AS total_profit,
    COUNT(DISTINCT "order_id") AS order_count
FROM sales
GROUP BY "customer_name", "region"
ORDER BY total_revenue DESC
LIMIT 10;



-- Top 10 customers WITHIN EACH region 
WITH ranked AS (
    SELECT
        "region",
        "customer_name",
        SUM("sales_amount") AS total_revenue,
        SUM("profit") AS total_profit,
        RANK() OVER (PARTITION BY "region" ORDER BY SUM("sales_amount") DESC) AS rev_rank
    FROM sales
    GROUP BY "region", "customer_name"
)
SELECT *
FROM ranked
WHERE rev_rank <= 10
ORDER BY "region", rev_rank; 


  
-- Profit by discount bucket, per category 
SELECT
    "category",
    CASE
        WHEN "discount" = 0 THEN '0%'
        WHEN "discount" <= 0.1 THEN '1-10%'
        WHEN "discount" <= 0.2 THEN '11-20%'
        WHEN "discount" <= 0.3 THEN '21-30%'
        ELSE '30%+'
    END AS discount_bucket,
    COUNT(*) AS order_lines,
    ROUND(AVG("profit"), 2) AS avg_profit,
    ROUND(SUM("profit"), 2) AS total_profit
FROM sales
GROUP BY "category", discount_bucket
ORDER BY "category", discount_bucket;  



-- Sub-categories that are net-negative on profit 
SELECT
    "category",
    "sub_category",
    ROUND(SUM("profit"), 2) AS total_profit,
    ROUND(AVG("discount"), 2) AS avg_discount
FROM sales
GROUP BY "category", "sub_category"
HAVING SUM("profit") < 0
ORDER BY total_profit ASC;



-- Segment performance ranking
SELECT
    "segment",
    COUNT(DISTINCT "order_id") AS total_orders,
    ROUND(SUM("sales_amount"), 2) AS total_revenue,
    ROUND(SUM("profit"), 2) AS total_profit,
    ROUND(SUM("profit") / COUNT(DISTINCT "order_id"), 2) AS profit_per_order
FROM sales
GROUP BY "segment"
ORDER BY total_profit DESC;



-- State performance ranking, as a Sales Rep proxy
SELECT
    "state",
    "region",
    ROUND(SUM("sales_amount"), 2) AS total_revenue,
    ROUND(SUM("profit"), 2) AS total_profit,
    RANK() OVER (ORDER BY SUM("profit") DESC) AS profit_rank
FROM sales
GROUP BY "state", "region"
ORDER BY profit_rank
LIMIT 15;

--- discount threshold
SELECT category, sub_category,
       CASE
           WHEN discount = 0 THEN '0%'
           WHEN discount <= 0.1 THEN '1-10%'
           WHEN discount <= 0.2 THEN '11-20%'
           WHEN discount <= 0.3 THEN '21-30%'
           WHEN discount <= 0.5 THEN '31-50%'
           ELSE '50%+'
       END AS discount_bucket,
       ROUND(AVG(profit), 2) AS avg_profit,
       ROUND(AVG(profit / NULLIF(sales_amount, 0)) * 100, 2) AS avg_profit_margin_pct
FROM sales
GROUP BY category, sub_category, discount_bucket
ORDER BY category, sub_category, discount_bucket;







