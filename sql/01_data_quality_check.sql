--DATA QUALITY CHECK

-- Duplicate Row IDs 
SELECT "row_id", COUNT(*)
FROM sales
GROUP BY "row_id"
HAVING COUNT(*) > 1;

-- Duplicate order lines 
SELECT "order_id", "product_id", COUNT(*) AS occurrences
FROM sales
GROUP BY "order_id", "product_id"
HAVING COUNT(*) > 1;

-- Negative quantity/sales, discount out of range
SELECT *
FROM sales
WHERE "quantity" <= 0
   OR "sales_amount" < 0
   OR "discount" < 0
   OR "discount" > 1;

-- Missing critical fields
SELECT *
FROM sales
WHERE "region" IS NULL
   OR "state" IS NULL
   OR "postal_code" IS NULL
   OR "customer_id" IS NULL;

-- Logically impossible dates (shipped before ordered)
SELECT "order_id", "order_date", "ship_date"
FROM sales
WHERE "ship_date" < "order_date";

-- One consolidated data quality summary 
SELECT
    (SELECT COUNT(*) FROM sales) AS total_rows,
    (SELECT COUNT(*) FROM (SELECT "row_id" FROM sales GROUP BY "row_id" HAVING COUNT(*) > 1) d) AS duplicate_row_ids,
    (SELECT COUNT(*) FROM sales WHERE "quantity" <= 0) AS bad_quantity_rows,
    (SELECT COUNT(*) FROM sales WHERE "discount" < 0 OR "discount" > 1) AS bad_discount_rows,
    (SELECT COUNT(*) FROM sales WHERE "region" IS NULL OR "state" IS NULL) AS missing_region_state,
    (SELECT COUNT(*) FROM sales WHERE "ship_date" < "order_date") AS bad_date_order;


-- Rescaled order_date and ship_date from the dataset's original range to 2023–2026
SELECT MIN(order_date) AS earliest, MAX(order_date) AS latest
FROM sales;

WITH bounds AS (
    SELECT MIN(order_date) AS old_min, MAX(order_date) AS old_max
    FROM sales
)
UPDATE sales s
SET order_date = DATE '2023-01-01' +
        ROUND( (s.order_date - b.old_min)::numeric
               * (DATE '2026-08-19' - DATE '2023-01-01')
               / NULLIF(b.old_max - b.old_min, 0) )::int,
    ship_date = DATE '2023-01-01' +
        ROUND( (s.ship_date - b.old_min)::numeric
               * (DATE '2026-08-19' - DATE '2023-01-01')
               / NULLIF(b.old_max - b.old_min, 0) )::int
FROM bounds b;

SELECT COUNT(*)
FROM sales
WHERE ship_date < order_date;

