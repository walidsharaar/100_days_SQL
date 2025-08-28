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


--Altenatives
--1.
WITH macbook_events AS (
    SELECT event_name, user_id
    FROM playbook_events
    WHERE device = 'macbook pro'
)
SELECT 
    event_name,
    COUNT(user_id) AS event_count
FROM macbook_events
GROUP BY event_name
ORDER BY event_count DESC;


--2.
SELECT DISTINCT
    event_name,
    COUNT(user_id) OVER (PARTITION BY event_name) AS event_count
FROM playbook_events
WHERE device = 'macbook pro'
ORDER BY event_count DESC;

