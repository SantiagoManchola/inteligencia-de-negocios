-- TODO: This query will return a table with the top 10 revenue categories in 
-- English, the number of orders and their total revenue. The first column will 
-- be Category, that will contain the top 10 revenue categories; the second one 
-- will be Num_order, with the total amount of orders of each category; and the 
-- last one will be Revenue, with the total revenue of each catgory.
-- HINT: All orders should have a delivered status and the Category and actual 
-- delivery date should be not null.

SELECT
    pct.product_category_name_english AS Category,
    COUNT(DISTINCT o.order_id) AS Num_order,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS Revenue
FROM
    olist_order_items_dataset oi
    JOIN olist_orders_dataset o ON oi.order_id = o.order_id
    JOIN olist_products_dataset p ON oi.product_id = p.product_id
    JOIN product_category_name_translation pct ON p.product_category_name = pct.product_category_name
WHERE
    o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND pct.product_category_name_english IS NOT NULL
GROUP BY
    pct.product_category_name_english
ORDER BY
    Revenue DESC
LIMIT 10;