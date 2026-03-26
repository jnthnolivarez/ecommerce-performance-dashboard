--- Data Cleaning

SELECT *
FROM orders
WHERE amount IS NULL;

-- Replace NULL amount with 0 
UPDATE orders
SET amount = 0
WHERE amount IS NULL;

-- Check for NULL price or cost
SELECT *
FROM order_items
WHERE price IS NULL OR cost IS NULL;

-- Replace NULL values with 0
UPDATE order_items
SET price = 0
WHERE price IS NULL;

UPDATE order_items
SET cost = 0
WHERE cost IS NULL;

SELECT order_id, product_id, COUNT(*)
FROM order_items
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;

-- Keep only one record
DELETE FROM order_items
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM order_items
    GROUP BY order_id, product_id
);



SELECT *
FROM marketing_spend
--- Analyze P&L
SELECT 
    SUM(oi.price * oi.quantity) AS total_revenue,
    SUM(oi.cost * oi.quantity) AS total_cost,
    SUM(oi.price * oi.quantity) - SUM(oi.cost * oi.quantity) AS profit
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id;

--- Customer Acquisition Cost (CAC) how much it costs to get 1 customer.

SELECT channel, SUM(ad_spend) / SUM(new_customers) AS CAC
FROM marketing_spend
GROUP BY channel

--- CAC Vs Revenue

WITH revenue_data AS (
	SELECT 
		o.channel,
    	SUM(oi.price * oi.quantity) AS total_revenue,
    	SUM(oi.cost * oi.quantity) AS total_cost,
    	SUM(oi.price * oi.quantity) - SUM(oi.cost * oi.quantity) AS profit
	FROM orders o
	JOIN order_items oi
	ON o.order_id = oi.order_id
	GROUP BY o.channel
),
cac_data AS (
	SELECT 
		channel, 
		SUM(ad_spend) / SUM(new_customers) AS CAC
	FROM marketing_spend
	GROUP BY channel
)
SELECT
	r.channel,
	r.total_revenue,
	r.profit,
	c.CAC
FROM revenue_data r
JOIN cac_data c
ON r.channel = c.channel


--- LTV
SELECT customer_id, SUM(amount)
FROM orders
GROUP BY customer_id

--- LTV Vs CAC

WITH ltv_data AS (
    SELECT 
        channel,
        AVG(customer_ltv) AS ltv
    FROM (
        SELECT 
            customer_id,
            channel,
            SUM(o.amount) AS customer_ltv
        FROM orders o
        GROUP BY o.customer_id, o.channel
    ) t
    GROUP BY channel
),
cac_data AS (
    SELECT 
        channel,
        SUM(ad_spend) / SUM(new_customers) AS cac
    FROM marketing_spend
    GROUP BY channel
)
SELECT 
    l.channel,
    l.ltv,
    c.cac,
    l.ltv / c.cac AS ltv_cac_ratio
FROM ltv_data l
JOIN cac_data c
    ON l.channel = c.channel;


-- Month Over Month Query

WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS month,
        SUM(amount) AS revenue
    FROM orders
    GROUP BY 1
)
SELECT 
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
    (revenue - LAG(revenue) OVER (ORDER BY BY month)) 
        / LAG(revenue) OVER (ORDER BY month) AS mom_channel
FROM monthly_revenue
ORDER BY month;

--- Month Over Month Per Channel
WITH monthly_revenue AS (
    SELECT 
        channel,
        DATE_TRUNC('month', order_date) AS month,
        SUM(amount) AS revenue
    FROM orders
    GROUP BY channel, month
)
SELECT 
    channel,
    month,
    revenue,
    LAG(revenue) OVER (PARTITION BY channel ORDER BY month) AS prev_month_revenue,
    (revenue - LAG(revenue) OVER (PARTITION BY channel ORDER BY month))
        / NULLIF(LAG(revenue) OVER (PARTITION BY channel ORDER BY month), 0) AS mom_growth
FROM monthly_revenue
ORDER BY channel, month;


SELECT amount FROM orders
