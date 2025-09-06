-- TODO: This query will return a table with two columns; customer_state, and 
-- Revenue. The first one will have the letters that identify the top 10 states 
-- with most revenue and the second one the total revenue of each.
-- HINT: All orders should have a delivered status and the actual delivery date 
-- should be not null. 

SELECT
  c.customer_state,
  ROUND(SUM(p.payment_value), 3) AS Revenue
FROM olist_orders          AS o
JOIN olist_order_payments  AS p ON p.order_id = o.order_id
JOIN olist_customers       AS c ON c.customer_id = o.customer_id
WHERE
  o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY Revenue DESC
LIMIT 10;