/*
You’re a BI Analyst at a digital bank.
Your team is investigating client churn and transaction risk signals.
The management suspects that clients showing erratic spending behavior (sharp drops in activity followed by inactivity) are more likely to churn or become inactive in the next quarter.

Business Question: Find which account types have the highest churn risk based on transaction volatility and activity decline.
*/

WITH quarterly_stats AS (
  SELECT
    client_id,
    account_type,
    DATE_TRUNC('quarter', transaction_date) AS quarter,
    COUNT(*) AS txn_count,
    SUM(transaction_amount) AS total_spend,
    STDDEV(transaction_amount) AS spend_volatility,
    MAX(churn_flag) AS churn_flag
  FROM transactions
  GROUP BY client_id, account_type, DATE_TRUNC('quarter', transaction_date)
),
quarterly_change AS (
  SELECT
    client_id,
    account_type,
    quarter,
    txn_count,
    spend_volatility,
    LAG(txn_count) OVER (PARTITION BY client_id, account_type ORDER BY quarter) AS prev_txn_count,
    churn_flag
  FROM quarterly_stats
),
q3_q4_churners AS (
  SELECT DISTINCT client_id, account_type
  FROM quarterly_change
  WHERE churn_flag = 1 AND quarter = '2020-10-01'
  AND EXISTS (
    SELECT 1 FROM quarterly_change q
    WHERE q.client_id = quarterly_change.client_id
      AND q.quarter = '2020-07-01'
  )
),
decline_metrics AS (
  SELECT 
    q.account_type,
    q.client_id,
    (COALESCE(prev_txn_count,0) - txn_count)*1.0 / NULLIF(prev_txn_count,0) AS activity_drop,
    spend_volatility
  FROM quarterly_change q
  JOIN q3_q4_churners c ON q.client_id = c.client_id
  WHERE q.quarter = '2020-10-01'
)
SELECT
  account_type,
  COUNT(DISTINCT client_id) AS churned_clients,
  ROUND(AVG(activity_drop), 3) AS avg_activity_drop,
  ROUND(AVG(spend_volatility), 3) AS avg_spend_volatility,
  ROUND((AVG(activity_drop)*0.4 + AVG(spend_volatility)*0.6), 3) AS weighted_churn_risk
FROM decline_metrics
GROUP BY account_type
ORDER BY weighted_churn_risk DESC;

--Alternative

WITH quarterly_stats AS (
  SELECT
    client_id,
    account_type,
    DATE_TRUNC('quarter', transaction_date) AS quarter,
    COUNT(*) AS txn_count,
    SUM(transaction_amount) AS total_spend,
    STDDEV(transaction_amount) AS spend_volatility,
    MAX(churn_flag) AS churn_flag
  FROM transactions
  GROUP BY client_id, account_type, DATE_TRUNC('quarter', transaction_date)
),
qoq_change AS (
  SELECT 
    q1.client_id,
    q1.account_type,
    q1.quarter AS current_quarter,
    q1.txn_count AS curr_txn,
    q1.spend_volatility,
    q1.churn_flag,
    q2.txn_count AS prev_txn
  FROM quarterly_stats q1
  LEFT JOIN quarterly_stats q2
    ON q1.client_id = q2.client_id 
    AND q1.account_type = q2.account_type
    AND q1.quarter = q2.quarter + INTERVAL '3 months'
),
q3_q4_churners AS (
  SELECT DISTINCT client_id, account_type
  FROM qoq_change
  WHERE churn_flag = 1 AND current_quarter = '2020-10-01'
  AND EXISTS (
    SELECT 1 FROM qoq_change q
    WHERE q.client_id = qoq_change.client_id AND q.current_quarter = '2020-07-01'
  )
),
decline_metrics AS (
  SELECT 
    q.account_type,
    q.client_id,
    (COALESCE(prev_txn,0) - curr_txn)*1.0 / NULLIF(prev_txn,0) AS activity_drop,
    spend_volatility
  FROM qoq_change q
  JOIN q3_q4_churners c ON q.client_id = c.client_id
  WHERE q.current_quarter = '2020-10-01'
)
SELECT
  account_type,
  COUNT(DISTINCT client_id) AS churned_clients,
  ROUND(AVG(activity_drop), 3) AS avg_activity_drop,
  ROUND(AVG(spend_volatility), 3) AS avg_spend_volatility,
  ROUND((AVG(activity_drop)*0.4 + AVG(spend_volatility)*0.6), 3) AS weighted_churn_risk
FROM decline_metrics
GROUP BY account_type
ORDER BY weighted_churn_risk DESC;


