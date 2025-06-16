---segment products into cost range & how many products fall into each segment
WITH segment_count AS (
SELECT 
product_key,
product_name,
cost,
CASE WHEN cost >= (SELECT MAX(cost) FROM dbo.[gold.dim_products]) THEN 'High Cost'
     WHEN cost <= (SELECT MIN(cost) FROM dbo.[gold.dim_products]) THEN 'Low Cost'
	 ELSE 'Average'
END cost_range
FROM dbo.[gold.dim_products]
GROUP BY product_key,product_name,cost
)
SELECT cost_range,
count(product_key) AS 'segment_num'
FROM segment_count
GROUP BY cost_range
ORDER BY segment_num DESC
;


---group customers into 3 segments based on their spending behavior
---vip:at least 12 months & spend more than $5000
---regular:at least 12 months & spend less than or equal $5000
---new:lifespan less than 12 months
WITH customer_status AS (
SELECT
c.customer_key,
SUM(f.sales_amount) AS 'sales_amount',
DATEDIFF(MONTH, MIN(f.order_date),MAX(f.order_date)) AS 'lifespan'
FROM dbo.[gold.fact_sales] f
LEFT JOIN dbo.[gold.dim_customers] c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
)
SELECT 
customer_segment,
COUNT(customer_key) AS 'total_customers'
FROM (
SELECT 
customer_key,
sales_amount,
lifespan,
CASE WHEN lifespan >= 12 AND sales_amount > 5000 THEN 'VIP'
     WHEN lifespan >= 12 AND sales_amount <= 5000 THEN 'Regular'
	 ELSE 'New'
END AS customer_segment
FROM customer_status ) T
GROUP BY customer_segment
ORDER BY total_customers DESC
;









