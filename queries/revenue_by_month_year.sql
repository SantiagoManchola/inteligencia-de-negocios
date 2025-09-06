-- TODO: This query will return a table with the revenue by month and year. It
-- will have different columns: month_no, with the month numbers going from 01
-- to 12; month, with the 3 first letters of each month (e.g. Jan, Feb);
-- Year2016, with the revenue per month of 2016 (0.00 if it doesn't exist);
-- Year2017, with the revenue per month of 2017 (0.00 if it doesn't exist) and
-- Year2018, with the revenue per month of 2018 (0.00 if it doesn't exist).

WITH orders_base AS (
  SELECT
    o.order_id,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_status
  FROM olist_orders AS o
),
payments_per_order AS (
  SELECT
    op.order_id,
    MIN(op.payment_value) AS payment_value
  FROM olist_order_payments AS op
  GROUP BY op.order_id
),
rev_by_month AS (
  SELECT
    STRFTIME('%m', ob.order_delivered_customer_date) AS month_no,
    STRFTIME('%Y', ob.order_delivered_customer_date) AS year_,
    SUM(pp.payment_value) AS revenue
  FROM orders_base AS ob
  JOIN payments_per_order AS pp
    ON pp.order_id = ob.order_id
  WHERE
    ob.order_delivered_customer_date IS NOT NULL
    AND STRFTIME('%Y', ob.order_delivered_customer_date) IN ('2016','2017','2018')
    AND ob.order_status IN ('delivered','shipped','invoiced','approved','created')
  GROUP BY month_no, year_
),
months AS (
  SELECT '01' AS month_no, 'Jan' AS month UNION ALL
  SELECT '02','Feb' UNION ALL
  SELECT '03','Mar' UNION ALL
  SELECT '04','Apr' UNION ALL
  SELECT '05','May' UNION ALL
  SELECT '06','Jun' UNION ALL
  SELECT '07','Jul' UNION ALL
  SELECT '08','Aug' UNION ALL
  SELECT '09','Sep' UNION ALL
  SELECT '10','Oct' UNION ALL
  SELECT '11','Nov' UNION ALL
  SELECT '12','Dec'
)
SELECT
  m.month_no,
  m.month,
  ROUND(COALESCE(SUM(CASE WHEN r.year_ = '2016' THEN r.revenue END), 0), 2) AS Year2016,
  ROUND(COALESCE(SUM(CASE WHEN r.year_ = '2017' THEN r.revenue END), 0), 2) AS Year2017,
  ROUND(COALESCE(SUM(CASE WHEN r.year_ = '2018' THEN r.revenue END), 0), 2) AS Year2018
FROM months AS m
LEFT JOIN rev_by_month AS r
  ON r.month_no = m.month_no
GROUP BY m.month_no, m.month
ORDER BY m.month_no;