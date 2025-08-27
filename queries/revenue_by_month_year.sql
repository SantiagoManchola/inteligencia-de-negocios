-- TODO: This query will return a table with the revenue by month and year. It
-- will have different columns: month_no, with the month numbers going from 01
-- to 12; month, with the 3 first letters of each month (e.g. Jan, Feb);
-- Year2016, with the revenue per month of 2016 (0.00 if it doesn't exist);
-- Year2017, with the revenue per month of 2017 (0.00 if it doesn't exist) and
-- Year2018, with the revenue per month of 2018 (0.00 if it doesn't exist).

SELECT
    strftime('%m', o.order_delivered_customer_date) AS month_no,
    strftime('%b', o.order_delivered_customer_date) AS month,
    SUM(CASE WHEN strftime('%Y', o.order_delivered_customer_date) = '2016' THEN oi.price + oi.freight_value ELSE 0 END) AS Year2016,
    SUM(CASE WHEN strftime('%Y', o.order_delivered_customer_date) = '2017' THEN oi.price + oi.freight_value ELSE 0 END) AS Year2017,
    SUM(CASE WHEN strftime('%Y', o.order_delivered_customer_date) = '2018' THEN oi.price + oi.freight_value ELSE 0 END) AS Year2018
FROM
    olist_order_items_dataset oi
    JOIN olist_orders_dataset o ON oi.order_id = o.order_id
WHERE
    o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
GROUP BY
    month_no, month
ORDER BY
    month_no;