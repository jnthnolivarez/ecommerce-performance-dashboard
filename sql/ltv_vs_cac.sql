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