/*
We’re analyzing user data to understand how popular Apple devices are among users who have performed at least one event on the platform. Specifically, we want to measure this popularity across different languages. 
Count the number of distinct users using Apple devices —limited to "macbook pro", "iphone 5s", and "ipad air" — and compare it to the total number of users per language.


Present the results with the language, the number of Apple users, and the total number of users for each language. Finally, sort the results so that languages with the highest total user count appear first.
*/


WITH event_agg AS (
    SELECT 
        user_id,
        COUNT(DISTINCT CASE WHEN device IN ('macbook pro','iphone 5s','ipad air') THEN user_id END) AS apple_flag,
        1 AS total_flag
    FROM playbook_events
    GROUP BY user_id
)
SELECT 
    b.language,
    SUM(apple_flag) AS apple,
    SUM(total_flag) AS total
FROM event_agg e
JOIN playbook_users b USING(user_id)
GROUP BY b.language
ORDER BY total DESC;
