-- TODO: This query will return a table with the top 10 revenue categories in 
-- English, the number of orders and their total revenue. The first column will 
-- be Category, that will contain the top 10 revenue categories; the second one 
-- will be Num_order, with the total amount of orders of each category; and the 
-- last one will be Revenue, with the total revenue of each catgory.
-- HINT: All orders should have a delivered status and the Category and actual 
-- delivery date should be not null.

SELECT
  t.product_category_name_english AS Category,
  COUNT(DISTINCT oi.order_id)     AS Num_order,
  ROUND(SUM(pay.payment_value), 2) AS Revenue
FROM product_category_name_translation AS t
JOIN olist_products         AS p  ON t.product_category_name = p.product_category_name
JOIN olist_order_items      AS oi ON oi.product_id = p.product_id
JOIN olist_orders           AS o  ON o.order_id = oi.order_id
JOIN olist_order_payments   AS pay ON pay.order_id = o.order_id
WHERE
  o.order_status = 'delivered'
  AND t.product_category_name_english IS NOT NULL
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY Category
ORDER BY Revenue DESC
LIMIT 10;