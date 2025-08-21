/*
Write a query that returns the number of unique users per client for each month. Assume all events occur within the same year, so only the month needs to be in the output as a number from 1 to 12.
*/

SELECT 
    client_id,
    EXTRACT(MONTH FROM time_id) AS month,
    COUNT(distinct user_id) AS users_num
FROM fact_events
GROUP BY client_id, month
ORDER BY client_id, month;

