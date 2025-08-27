-- TODO: This query will return a table with two columns; order_status, and
-- Ammount. The first one will have the different order status classes and the
-- second one the total ammount of each.

SELECT
    order_status,
    COUNT(*) AS Ammount
FROM
    olist_orders_dataset
GROUP BY
    order_status
ORDER BY
    Ammount DESC;