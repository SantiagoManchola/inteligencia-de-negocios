-- TODO: This query will return a table with two columns; customer_state, and 
-- Revenue. The first one will have the letters that identify the top 10 states 
-- with most revenue and the second one the total revenue of each.
-- HINT: All orders should have a delivered status and the actual delivery date 
-- should be not null. 

SELECT
    c.customer_state,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS Revenue
FROM
    olist_order_items_dataset oi
    JOIN olist_orders_dataset o ON oi.order_id = o.order_id
    JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
WHERE
    o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
GROUP BY
    c.customer_state
ORDER BY
    Revenue DESC
LIMIT 10;