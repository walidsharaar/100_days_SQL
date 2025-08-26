/*
Find order details made by Jill and Eva.
Consider Jill and Eva as the first names of customers.
Output the order date, details and cost along with the first name.
Order records based on the customer id in ascending order.

*/

select c.first_name, o.order_date, o.order_details, total_order_cost
from customers c
left join orders o 
on c.id = o.cust_id
where first_name in ('Jill','Eva')
