/*
Given the users' sessions logs on a particular day, calculate how many hours each user was active that day.


Note: The session starts when state=1 and ends when state=0.
*/


WITH cte AS (
  SELECT
    cust_id,
    state,
    "timestamp" AS ses_start,
    LEAD("timestamp") OVER (PARTITION BY cust_id ORDER BY "timestamp") AS ses_end
  FROM cust_tracking
),
cte2 AS (
  SELECT 
    cust_id,
    ses_start,
    ses_end
  FROM cte
  WHERE state = 1
)
SELECT 
  cust_id,
  ROUND(SUM(EXTRACT(EPOCH FROM (ses_end - ses_start)) / 3600), 2) AS active_hours
FROM cte2
GROUP BY cust_id
ORDER BY cust_id;
