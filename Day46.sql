/*
Identify customers who did not place an order between 2019-02-01 and 2019-03-01.


Include:


•    Customers who placed orders only outside this date range.
•    Customers who never placed any orders.


Output the customers' first names.
*/

SELECT DISTINCT c.first_name
FROM customers c
LEFT JOIN orders o
  ON o.cust_id = c.id 
  AND o.order_date BETWEEN '2019-02-01' AND '2019-03-01'
WHERE o.id IS NULL;
