
/*
You work at an analytics company. Each user_id performs various event types logged in fact_events.
You want to identify client_ids whose active users are engaged (≥10 total events) but show a decline in call-related activity (≥30% decrease) between two consecutive months.
*/

WITH user_monthly AS (
    SELECT
        client_id,
        user_id,
        date_trunc('month', event_date) AS month,
        COUNT(*) AS total_events,
        COUNT(CASE 
                  WHEN event_type IN ('video call sent', 'video call received', 
                                      'voice call sent', 'voice call received') 
                  THEN 1 
             END) AS call_events
    FROM fact_events
    GROUP BY client_id, user_id, date_trunc('month', event_date)
),

qualified_users AS (
    SELECT * 
    FROM user_monthly
    WHERE total_events >= 10
),

user_trend AS (
    SELECT
        a.client_id,
        a.user_id,
        a.month AS prev_month,
        b.month AS current_month,
        a.call_events AS prev_calls,
        b.call_events AS curr_calls,
        (a.call_events - b.call_events) * 1.0 / NULLIF(a.call_events, 0) AS decline_rate
    FROM qualified_users a
    JOIN qualified_users b
      ON a.client_id = b.client_id
     AND a.user_id = b.user_id
     AND b.month = a.month + INTERVAL '1 month'
),

declining_clients AS (
    SELECT
        client_id,
        prev_month,
        current_month,
        AVG(decline_rate) AS avg_decline_rate
    FROM user_trend
    WHERE decline_rate >= 0.3
    GROUP BY client_id, prev_month, current_month
)

SELECT *
FROM declining_clients
ORDER BY avg_decline_rate DESC;
