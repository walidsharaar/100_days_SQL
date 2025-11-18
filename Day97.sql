/*
You work as a BI Engineer for a SaaS product offering monthly and annual subscriptions. Recently, the finance team noticed revenue loss from users who didn’t renew, not because they canceled — but because their payments failed or were never retried.
Your task is to identify potential involuntary churners and compute monthly churn risk trends per plan type.
Question:
Identify users who are at risk of involuntary churn — defined as:
Users whose last subscription ended within the last 60 days
Who have no successful payment after their end_date
But had at least one failed payment attempt after their end date
And their plan was auto-renew = TRUE
Then calculate:
The churn risk count per plan type
The total failed payment amount in that window
The percentage of at-risk users over total users per plan
Finally, list the top 3 plan types with the highest churn risk rate.
*/




WITH recent_subs AS (
  SELECT 
    user_id,
    plan_type,
    end_date,
    is_auto_renew
  FROM subscriptions
  WHERE end_date BETWEEN CURRENT_DATE - INTERVAL '60 day' AND CURRENT_DATE
    AND is_auto_renew = TRUE
),

payment_flags AS (
  SELECT 
    p.user_id,
    MAX(CASE WHEN p.payment_status = 'success' THEN 1 ELSE 0 END) AS has_success_after,
    MAX(CASE WHEN p.payment_status = 'failed' THEN 1 ELSE 0 END) AS has_failed_after,
    SUM(CASE WHEN p.payment_status = 'failed' THEN p.payment_amount ELSE 0 END) AS total_failed_amount
  FROM payments p
  JOIN recent_subs s ON p.user_id = s.user_id AND p.payment_date > s.end_date
  GROUP BY p.user_id
),

churn_risk AS (
  SELECT 
    s.plan_type,
    s.user_id,
    pf.total_failed_amount
  FROM recent_subs s
  JOIN payment_flags pf ON s.user_id = pf.user_id
  WHERE pf.has_success_after = 0 AND pf.has_failed_after = 1
),

total_per_plan AS (
  SELECT plan_type, COUNT(DISTINCT user_id) AS total_users
  FROM subscriptions
  GROUP BY plan_type
),

churn_summary AS (
  SELECT 
    cr.plan_type,
    COUNT(DISTINCT cr.user_id) AS at_risk_users,
    SUM(cr.total_failed_amount) AS failed_amount_total
  FROM churn_risk cr
  GROUP BY cr.plan_type
)

SELECT 
  cs.plan_type,
  cs.at_risk_users,
  cs.failed_amount_total,
  ROUND(cs.at_risk_users * 100.0 / tp.total_users, 2) AS churn_risk_percent
FROM churn_summary cs
JOIN total_per_plan tp ON cs.plan_type = tp.plan_type
ORDER BY churn_risk_percent DESC
LIMIT 3;


--Alternativew
WITH recent_subs AS (
  SELECT 
    user_id,
    plan_type,
    end_date,
    is_auto_renew
  FROM subscriptions
  WHERE end_date BETWEEN CURRENT_DATE - INTERVAL '60 day' AND CURRENT_DATE
    AND is_auto_renew = TRUE
),

failed_payments AS (
  SELECT 
    user_id,
    SUM(payment_amount) AS total_failed_amount
  FROM payments
  WHERE payment_status = 'failed'
  GROUP BY user_id
),

success_after AS (
  SELECT DISTINCT user_id
  FROM payments p
  JOIN recent_subs s ON p.user_id = s.user_id
  WHERE p.payment_status = 'success'
    AND p.payment_date > s.end_date
),

failed_after AS (
  SELECT DISTINCT p.user_id
  FROM payments p
  JOIN recent_subs s ON p.user_id = s.user_id
  WHERE p.payment_status = 'failed'
    AND p.payment_date > s.end_date
),

churn_risk AS (
  SELECT 
    s.plan_type,
    s.user_id,
    f.total_failed_amount
  FROM recent_subs s
  JOIN failed_after fa ON s.user_id = fa.user_id
  LEFT JOIN success_after sa ON s.user_id = sa.user_id
  LEFT JOIN failed_payments f ON s.user_id = f.user_id
  WHERE sa.user_id IS NULL
),

total_per_plan AS (
  SELECT plan_type, COUNT(DISTINCT user_id) AS total_users
  FROM subscriptions
  GROUP BY plan_type
),

churn_summary AS (
  SELECT 
    cr.plan_type,
    COUNT(DISTINCT cr.user_id) AS at_risk_users,
    SUM(cr.total_failed_amount) AS failed_amount_total
  FROM churn_risk cr
  GROUP BY cr.plan_type
)

SELECT 
  cs.plan_type,
  cs.at_risk_users,
  cs.failed_amount_total,
  ROUND(cs.at_risk_users * 100.0 / tp.total_users, 2) AS churn_risk_percent
FROM churn_summary cs
JOIN total_per_plan tp ON cs.plan_type = tp.plan_type
ORDER BY churn_risk_percent DESC
LIMIT 3;
