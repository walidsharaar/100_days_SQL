/*
Calculate the percentage of users who are both from the US and have an 'open' status, as indicated in the fb_active_users table.
*/


SELECT (COUNT(user_id) FILTER (WHERE status = 'open' AND country = 'USA') * 100.0) / COUNT(user_id)
FROM fb_active_users
