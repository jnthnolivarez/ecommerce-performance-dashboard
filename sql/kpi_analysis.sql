-- Analyze P&L
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