/*
Find the customers with the highest daily total order cost between 2019-02-01 and 2019-05-01. If a customer had more than one order on a certain day, sum the order costs daily. Output each customer's first name, the total cost of their items, and the date.


For simplicity, you can assume that every first name in the dataset is unique.
*/

SELECT * FROM customers;
SELECT * FROM orders

SELECT 
    c.first_name,
    o.order_date,
    SUM(o.total_order_cost) AS total_cost
FROM customers c
JOIN orders o 
  ON c.id = o.cust_id
WHERE o.order_date BETWEEN '2019-02-01' AND '2019-05-01'
GROUP BY c.first_name, o.order_date
ORDER BY total_cost DESC
LIMIT 1;

--Alternative

WITH daily_totals AS (
    SELECT 
        c.first_name,
        o.order_date,
        SUM(o.total_order_cost) AS total_cost
    FROM customers c
    JOIN orders o 
      ON c.id = o.cust_id
    WHERE o.order_date BETWEEN '2019-02-01' AND '2019-05-01'
    GROUP BY c.first_name, o.order_date
),
ranked AS (
    SELECT 
        first_name,
        order_date,
        total_cost,
        RANK() OVER (PARTITION BY order_date ORDER BY total_cost DESC) AS rnk
    FROM daily_totals
)
SELECT 
    first_name,
    order_date,
    total_cost
FROM ranked
WHERE rnk = 1
ORDER BY order_date, first_name;
