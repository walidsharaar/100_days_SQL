/*
Calculate the total revenue from each customer in March 2019. Include only customers who were active in March 2019. An active user is a customer who made at least one transaction in March 2019.
Output the revenue along with the customer id and sort the results based on the revenue in descending order.
*/

select * from orders;

select cust_id, 
sum(total_order_cost)
from orders
where extract(Month from order_date) = 3
group by cust_id



--Alternative

select 
    cust_id,
    SUM(total_order_cost) as total_revenue
from orders
where date_trunc('month', order_date) = date '2019-03-01'
group by cust_id
order by total_revenue desc;
