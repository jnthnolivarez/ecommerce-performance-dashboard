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
