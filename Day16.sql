/*
Count the number of user events performed by MacBookPro users.
Output the result along with the event name.
Sort the result based on the event count in the descending order.
*/

select distinct device from playbook_events;

select event_name , count(user_id) as event_count
from playbook_events
where device='macbook pro'
group by event_name
order by count(user_id) desc
