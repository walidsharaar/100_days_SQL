/*
Find all the users who were active for 3 consecutive days or more.
*/

WITH distinct_days AS (
  SELECT DISTINCT user_id,
                  record_date AS date_h
  FROM sf_events
  ORDER BY user_id ASC, date_h ASC
),
consecutive_days AS (
  SELECT user_id,
         date_h - ROW_NUMBER() OVER (
             PARTITION BY user_id
             ORDER BY date_h
         )::int AS grp
  FROM distinct_days
)
SELECT user_id
FROM consecutive_days
GROUP BY user_id, grp
HAVING COUNT(*) >= 3;

--Alternative
WITH user_activity AS (
  SELECT DISTINCT user_id, record_date
  FROM sf_events
),
lagged AS (
  SELECT user_id,
         record_date,
         LAG(record_date) OVER (PARTITION BY user_id ORDER BY record_date) AS prev_date
  FROM user_activity
),
streaks AS (
  SELECT user_id,
         record_date,
         CASE 
           WHEN record_date - prev_date = 1 THEN 0
           ELSE 1
         END AS is_new_streak
  FROM lagged
),
streak_groups AS (
  SELECT user_id,
         record_date,
         SUM(is_new_streak) OVER (PARTITION BY user_id ORDER BY record_date ROWS UNBOUNDED PRECEDING) AS streak_group
  FROM streaks
)
SELECT user_id
FROM streak_groups
GROUP BY user_id, streak_group
HAVING COUNT(*) >= 3;


