/*
Find the percentage of shipable orders.
Consider an order is shipable if the customer's address is known.
*/


SELECT 
    100 * (AVG(CASE WHEN address IS NOT NULL THEN 1 ELSE 0 END)) AS percent_shipable
FROM orders AS o
LEFT JOIN customers AS c
ON o.cust_id = c.id
;
