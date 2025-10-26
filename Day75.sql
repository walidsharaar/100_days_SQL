/*
Select the most popular client_id based on the number of users who individually have at least 50% of their events from the following list: 'video call received', 'video call sent', 'voice call received', 'voice call sent'.
*/


WITH user_events AS (
    SELECT
        client_id,
        user_id,
        COUNT(*) AS total_events,
        COUNT(CASE 
                  WHEN event_type IN ('video call received', 'video call sent', 
                                     'voice call received', 'voice call sent') 
                  THEN 1 
             END) AS call_events
    FROM fact_events
    GROUP BY client_id, user_id
),

qualified_users AS (
    SELECT client_id, user_id
    FROM user_events
    WHERE call_events::float / total_events >= 0.5
),

client_popularity AS (
    SELECT client_id, COUNT(*) AS qualified_users_count
    FROM qualified_users
    GROUP BY client_id
)

SELECT client_id
FROM client_popularity
WHERE qualified_users_count = (
    SELECT MAX(qualified_users_count)
    FROM client_popularity
);
