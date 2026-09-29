-- Replace student_01 with your assigned schema.
USE CATALOG training_lab;
USE SCHEMA student_01;

SELECT o.order_id, o.amount, p.payment_id, p.paid
FROM day18_orders o
LEFT JOIN day18_payments p ON o.order_id = p.order_id
ORDER BY o.order_id, p.payment_id;

WITH payment_totals AS (
 SELECT order_id, SUM(paid) AS paid
 FROM day18_payments GROUP BY order_id
)
SELECT o.order_id, c.name, o.amount,
       COALESCE(p.paid, 0) AS paid,
       o.amount - COALESCE(p.paid, 0) AS outstanding
FROM day18_orders o
JOIN day18_customers c ON c.customer_id = o.customer_id
LEFT JOIN payment_totals p ON p.order_id = o.order_id
ORDER BY o.order_id;

SELECT order_id, amount FROM day18_orders
WHERE amount > (SELECT AVG(amount) FROM day18_orders)
ORDER BY order_id;

SELECT c.customer_id, c.name FROM day18_customers c
WHERE NOT EXISTS (
 SELECT 1 FROM day18_orders o
 WHERE o.customer_id = c.customer_id
);

WITH customer_totals AS (
 SELECT customer_id, SUM(amount) AS revenue
 FROM day18_orders GROUP BY customer_id
), ranked AS (
 SELECT *, DENSE_RANK() OVER (ORDER BY revenue DESC) AS rnk
 FROM customer_totals
)
SELECT c.name, r.revenue, r.rnk
FROM ranked r JOIN day18_customers c
ON r.customer_id = c.customer_id
WHERE r.rnk <= 2 ORDER BY r.rnk;

SELECT order_id, customer_id, amount,
 ROW_NUMBER() OVER (
  PARTITION BY customer_id ORDER BY amount DESC, order_id) AS rn,
 LAG(amount) OVER (
  PARTITION BY customer_id ORDER BY order_date, order_id) AS previous,
 SUM(amount) OVER (
  ORDER BY order_date, order_id
  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running
FROM day18_orders
ORDER BY order_date, order_id;

WITH daily AS (
 SELECT order_date, SUM(amount) AS revenue
 FROM day18_orders GROUP BY order_date
)
SELECT order_date, revenue,
 AVG(revenue) OVER (ORDER BY order_date
  ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) AS moving_2_rows
FROM daily ORDER BY order_date;
