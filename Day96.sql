/*
Your company runs a digital banking app where users manage personal finances, apply for loans, and use services like bill payments, transfers, and investments.
Your manager wants to identify customers who are likely to churn — i.e., become inactive — in the upcoming 30 days.
Identify customers who show early churn risk signals — defined as users who:
Had no activity in the last 30 days
But had at least 4 active weeks in the previous 60–90 days before that inactivity window
Have an average session duration below the median of all users
Belong to the “Free” plan
Then calculate for each state:
total potential churn users
average session duration before inactivity
Ratio of potential churn users to total users in that state
Finally, list the top 5 states with the highest churn ratio
*/




WITH date_ranges AS (
  SELECT 
    CURRENT_DATE - INTERVAL '30 day' AS recent_start,
    CURRENT_DATE - INTERVAL '90 day' AS active_start
),

activity_summary AS (
  SELECT 
    ua.user_id,
    DATE_TRUNC('week', ua.activity_date) AS active_week,
    AVG(ua.session_duration) AS avg_session
  FROM user_activity ua
  WHERE ua.activity_date BETWEEN 
        (SELECT active_start FROM date_ranges)
        AND (SELECT recent_start FROM date_ranges)
  GROUP BY ua.user_id, DATE_TRUNC('week', ua.activity_date)
),

user_behavior AS (
  SELECT 
    user_id,
    COUNT(DISTINCT active_week) AS active_weeks,
    AVG(avg_session) AS mean_session_duration
  FROM activity_summary
  GROUP BY user_id
),

recent_inactive AS (
  SELECT 
    up.user_id,
    up.state,
    up.plan_type,
    up.risk_segment,
    ub.active_weeks,
    ub.mean_session_duration
  FROM user_profile up
  LEFT JOIN user_behavior ub ON up.user_id = ub.user_id
  WHERE up.plan_type = 'Free'
    AND up.user_id NOT IN (
      SELECT DISTINCT user_id
      FROM user_activity
      WHERE activity_date >= (SELECT recent_start FROM date_ranges)
    )
    AND ub.active_weeks >= 4
),

median_calc AS (
  SELECT 
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY mean_session_duration) AS median_session
  FROM user_behavior
),

potential_churn AS (
  SELECT ri.*, mc.median_session
  FROM recent_inactive ri CROSS JOIN median_calc mc
  WHERE ri.mean_session_duration < mc.median_session
)

SELECT 
  state,
  COUNT(DISTINCT user_id) AS churn_users,
  ROUND(AVG(mean_session_duration),2) AS avg_session_before_churn,
  ROUND(
    COUNT(DISTINCT user_id)::NUMERIC /
    (SELECT COUNT(*) FROM user_profile up WHERE up.state = ri.state), 2
  ) AS churn_ratio
FROM potential_churn ri
GROUP BY state
ORDER BY churn_ratio DESC
LIMIT 5;

---Alternative

WITH date_ranges AS (
  SELECT 
    CURRENT_DATE - INTERVAL '30 day' AS recent_start,
    CURRENT_DATE - INTERVAL '90 day' AS active_start
),

activity_summary AS (
  SELECT 
    ua.user_id,
    DATE_TRUNC('week', ua.activity_date) AS active_week,
    AVG(ua.session_duration) AS avg_session
  FROM user_activity ua
  WHERE ua.activity_date BETWEEN 
        (SELECT active_start FROM date_ranges)
        AND (SELECT recent_start FROM date_ranges)
  GROUP BY ua.user_id, DATE_TRUNC('week', ua.activity_date)
),

user_behavior AS (
  SELECT 
    user_id,
    COUNT(DISTINCT active_week) AS active_weeks,
    AVG(avg_session) AS mean_session_duration
  FROM activity_summary
  GROUP BY user_id
),

median_calc AS (
  SELECT 
    AVG(mean_session_duration) AS median_approx
  FROM (
    SELECT mean_session_duration
    FROM user_behavior
    ORDER BY mean_session_duration
    LIMIT (SELECT COUNT(*)/2 FROM user_behavior)
  ) t
),

inactive_users AS (
  SELECT up.*, ub.active_weeks, ub.mean_session_duration
  FROM user_profile up
  JOIN user_behavior ub ON up.user_id = ub.user_id
  WHERE up.plan_type = 'Free'
    AND ub.active_weeks >= 4
    AND up.user_id NOT IN (
      SELECT DISTINCT user_id
      FROM user_activity
      WHERE activity_date >= (SELECT recent_start FROM date_ranges)
    )
),

potential_churn AS (
  SELECT iu.*
  FROM inactive_users iu, median_calc mc
  WHERE iu.mean_session_duration < mc.median_approx
)

SELECT 
  iu.state,
  COUNT(DISTINCT iu.user_id) AS churn_users,
  ROUND(AVG(iu.mean_session_duration), 2) AS avg_session_before_churn,
  ROUND(
    COUNT(DISTINCT iu.user_id)::NUMERIC /
    (SELECT COUNT(*) FROM user_profile p WHERE p.state = iu.state), 2
  ) AS churn_ratio
FROM potential_churn iu
GROUP BY iu.state
ORDER BY churn_ratio DESC
LIMIT 5;
