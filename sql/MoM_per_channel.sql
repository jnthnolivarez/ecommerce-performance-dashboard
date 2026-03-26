- Month Over Month Query

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
