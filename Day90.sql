/*
Identify client segments (by country and account_type) with the highest churn risk over the last 6 months.

For each segment, calculate:

Total number of active and churned clients.

Average retention offer value for churned clients.

Churn Rate = churned_clients / total_clients.

Then rank segments by highest churn rate, and flag those where avg_retention_offer_value > 50 but churn rate still > 0.4, meaning retention spending is not effectively reducing churn.
*/

WITH client_status AS (
  SELECT 
    client_id,
    country,
    account_type,
    retention_offer_value,
    CASE 
      WHEN last_transaction_date < DATE_SUB(CURRENT_DATE(), INTERVAL 6 MONTH) THEN 'churned'
      ELSE 'active'
    END AS client_status
  FROM bank_clients
),
agg_cte AS (
  SELECT
    country,
    account_type,
    COUNT(*) AS total_clients,
    COUNT(*) FILTER (WHERE client_status = 'churned') AS churned_clients,
    ROUND(AVG(CASE WHEN client_status = 'churned' THEN retention_offer_value END),2) AS avg_retention_offer_value
  FROM client_status
  GROUP BY country, account_type
),
final_cte AS (
  SELECT 
    *,
    ROUND(churned_clients * 1.0 / total_clients, 2) AS churn_rate,
    CASE 
      WHEN churned_clients * 1.0 / total_clients > 0.4 
           AND avg_retention_offer_value > 50 THEN 'High Spend - Low Impact'
      ELSE 'OK'
    END AS retention_flag
  FROM agg_cte
)
SELECT *
FROM final_cte
ORDER BY churn_rate DESC;

--Alternative

WITH churned AS (
  SELECT country, account_type, 
         COUNT(client_id) AS churned_clients,
         AVG(retention_offer_value) AS avg_retention_offer_value
  FROM bank_clients
  WHERE last_transaction_date < DATE_SUB(CURRENT_DATE(), INTERVAL 6 MONTH)
  GROUP BY country, account_type
),
total AS (
  SELECT country, account_type, 
         COUNT(client_id) AS total_clients
  FROM bank_clients
  GROUP BY country, account_type
),
joined AS (
  SELECT 
    t.country,
    t.account_type,
    t.total_clients,
    COALESCE(c.churned_clients, 0) AS churned_clients,
    COALESCE(c.avg_retention_offer_value, 0) AS avg_retention_offer_value,
    ROUND(COALESCE(c.churned_clients, 0) * 1.0 / t.total_clients, 2) AS churn_rate
  FROM total t
  LEFT JOIN churned c
  ON t.country = c.country AND t.account_type = c.account_type
)
SELECT *,
  CASE 
    WHEN churn_rate > 0.4 AND avg_retention_offer_value > 50 THEN 'High Spend - Low Impact'
    ELSE 'OK'
  END AS retention_flag
FROM joined
ORDER BY churn_rate DESC;
