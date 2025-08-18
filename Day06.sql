/*
Find the details of each customer regardless of whether the customer made an order. Output the customer's first name, last name, and the city along with the order details.
Sort records based on the customer's first name and the order details in ascending order.

*/

select first_name,last_name,city ,order_details
from customers c
left join orders o
on c.id= o.cust_id
order by first_name,order_details asc


--Alternative
WITH customer_orders AS (
    SELECT 
        c.first_name,
        c.last_name,
        c.city,
        o.order_details
    FROM customers c
    LEFT JOIN orders o
        ON c.id = o.cust_id
)
SELECT *
FROM customer_orders
ORDER BY first_name ASC, order_details ASC;
