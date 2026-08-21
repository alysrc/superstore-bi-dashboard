CREATE TABLE customer_mapping AS
SELECT DISTINCT customer_id, customer_name,
       'Customer_' || LPAD(ROW_NUMBER() OVER (ORDER BY customer_id)::TEXT, 4, '0') AS anon_name
FROM sales;

UPDATE sales s
SET customer_name = m.anon_name
FROM customer_mapping m
WHERE s.customer_id = m.customer_id;

select * from sales;

