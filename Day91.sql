/*
You’re working for a digital bank. Management wants to understand how client engagement, account activity, and retention spending evolve month by month,
to predict when clients are at the highest churn risk and whether retention spending is working.
For each country and account_type, calculate:
Monthly churn rate over the last 12 months.
Average monthly retention spend per churned client.
Rolling 3-month moving average churn rate to show trends.
Identify the month and segment (country + account_type) where churn peaked.
*/

WITH monthly_activity AS (
  SELECT 
    client_id,
    country,
    account_type,
    activity_month,
    transactions_count,
    retention_offer_value,
    LEAD(activity_month) OVER (PARTITION BY client_id ORDER BY activity_month) AS next_activity_month
  FROM bank_client_activity
),
churn_flag AS (
  SELECT 
    country,
    account_type,
    activity_month,
    COUNT(DISTINCT client_id) AS total_clients,
    COUNT(DISTINCT CASE 
      WHEN next_activity_month IS NULL 
        OR next_activity_month > activity_month + INTERVAL '1 month' 
      THEN client_id END) AS churned_clients,
    ROUND(AVG(retention_offer_value),2) AS avg_retention_offer
  FROM monthly_activity
  GROUP BY country, account_type, activity_month
),
churn_rate_cte AS (
  SELECT *,
    ROUND(churned_clients * 1.0 / total_clients, 3) AS churn_rate,
    ROUND(AVG(churned_clients * 1.0 / total_clients) OVER (
      PARTITION BY country, account_type 
      ORDER BY activity_month 
      ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 3) AS moving_avg_churn
  FROM churn_flag
)
SELECT 
  *,
  CASE WHEN churn_rate = MAX(churn_rate) OVER (PARTITION BY country, account_type)
       THEN 'Peak Churn Month'
       ELSE ''
  END AS churn_peak_flag
FROM churn_rate_cte
ORDER BY country, account_type, activity_month;

--Alternative

WITH base AS (
  SELECT 
    a.client_id,
    a.country,
    a.account_type,
    a.activity_month,
    a.retention_offer_value,
    MIN(b.activity_month) AS next_month
  FROM bank_client_activity a
  LEFT JOIN bank_client_activity b
    ON a.client_id = b.client_id
   AND b.activity_month > a.activity_month
   AND b.activity_month <= a.activity_month + INTERVAL '1 month'
  GROUP BY a.client_id, a.country, a.account_type, a.activity_month, a.retention_offer_value
),
churn_flag AS (
  SELECT 
    country,
    account_type,
    activity_month,
    COUNT(DISTINCT client_id) AS total_clients,
    COUNT(DISTINCT CASE WHEN next_month IS NULL THEN client_id END) AS churned_clients,
    ROUND(AVG(retention_offer_value),2) AS avg_retention_offer
  FROM base
  GROUP BY country, account_type, activity_month
),
rolling_avg AS (
  SELECT c1.country, c1.account_type, c1.activity_month, 
         c1.churned_clients, c1.total_clients, c1.avg_retention_offer,
         ROUND(c1.churned_clients*1.0/c1.total_clients,3) AS churn_rate,
         (
           SELECT ROUND(AVG(c2.churned_clients*1.0/c2.total_clients),3)
           FROM churn_flag c2
           WHERE c2.country = c1.country 
             AND c2.account_type = c1.account_type
             AND c2.activity_month BETWEEN c1.activity_month - INTERVAL '2 month' AND c1.activity_month
         ) AS moving_avg_churn
  FROM churn_flag c1
)
SELECT *,
  CASE WHEN churn_rate = (
    SELECT MAX(churn_rate) 
    FROM rolling_avg r2 
    WHERE r2.country = r1.country AND r2.account_type = r1.account_type
  )
  THEN 'Peak Churn Month' ELSE '' END AS churn_peak_flag
FROM rolling_avg r1
ORDER BY country, account_type, activity_month;

