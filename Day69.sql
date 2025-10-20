/*
Provided a table with user id and the dates they visited the platform, find the top 3 users with the longest continuous streak of visiting the platform as of August 10, 2022. Output the user ID and the length of the streak.


In case of a tie, display all users with the top three longest streaks.

*/

WITH distinct_days AS (
  -- one row per user per day (dedupe same-day visits)
  SELECT DISTINCT user_id, date_visited::date AS dt
  FROM user_streaks
  WHERE date_visited::date <= '2022-08-10'
),
lagged AS (
  SELECT
    user_id,
    dt,
    CASE
      WHEN dt - LAG(dt) OVER (PARTITION BY user_id ORDER BY dt) = 1 THEN 0
      ELSE 1
    END AS new_streak_flag
  FROM distinct_days
),
streak_groups AS (
  SELECT
    user_id,
    dt,
    SUM(new_streak_flag) OVER (PARTITION BY user_id ORDER BY dt ROWS UNBOUNDED PRECEDING) AS grp
  FROM lagged
),
streak_counts AS (
  -- each row = one streak (user_id, grp) with its length
  SELECT user_id, grp, COUNT(*) AS streak_length
  FROM streak_groups
  GROUP BY user_id, grp
),
user_max AS (
  -- longest streak per user
  SELECT user_id, MAX(streak_length) AS max_streak
  FROM streak_counts
  GROUP BY user_id
),
ranked AS (
  -- dense rank users by their longest streak
  SELECT user_id, max_streak,
         DENSE_RANK() OVER (ORDER BY max_streak DESC) AS rnk
  FROM user_max
)
SELECT user_id,
       max_streak AS streak_length
FROM ranked
WHERE rnk <= 3
ORDER BY streak_length DESC, user_id;
