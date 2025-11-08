/*
Identify the top 5 countries with the highest churn risk based on the following:

A customer is active if they have ≥10 transactions in a quarter.

A customer is considered churned in Q3 if they were active in Q2 but inactive in Q3.

Weight each churned customer by their average transaction amount in Q2 (to highlight loss of high-value users).

Compute churn_risk_score = SUM(weighted_churn_value) / total_active_users_in_Q2 per country.
*/

WITH q2_active AS (
  SELECT 
    customer_id,
    country,
    product_type,
    total_transactions,
    total_amount,
    total_amount * 1.0 / NULLIF(total_transactions, 0) AS avg_txn_value
  FROM customer_activity
  WHERE quarter = 'Q2'
    AND total_transactions >= 10
),
q3_active AS (
  SELECT DISTINCT customer_id
  FROM customer_activity
  WHERE quarter = 'Q3'
    AND total_transactions >= 10
),
churned AS (
  SELECT 
    q2.customer_id,
    q2.country,
    q2.avg_txn_value
  FROM q2_active q2
  LEFT JOIN q3_active q3
  ON q2.customer_id = q3.customer_id
  WHERE q3.customer_id IS NULL
),
weighted_country AS (
  SELECT 
    country,
    SUM(avg_txn_value) AS total_weighted_churn,
    COUNT(DISTINCT customer_id) AS churned_customers
  FROM churned
  GROUP BY country
),
country_base AS (
  SELECT 
    country,
    COUNT(DISTINCT customer_id) AS total_active_q2
  FROM q2_active
  GROUP BY country
),
final AS (
  SELECT 
    w.country,
    w.total_weighted_churn / b.total_active_q2 AS churn_risk_score,
    RANK() OVER (ORDER BY w.total_weighted_churn / b.total_active_q2 DESC) AS rnk
  FROM weighted_country w
  JOIN country_base b
  ON w.country = b.country
)
SELECT country, ROUND(churn_risk_score, 3) AS churn_risk_score
FROM final
WHERE rnk <= 5;

--Alternative

WITH q2_active AS (
  SELECT 
    customer_id,
    country,
    total_transactions,
    total_amount,
    total_amount * 1.0 / NULLIF(total_transactions, 0) AS avg_txn_value
  FROM customer_activity
  WHERE quarter = 'Q2'
    AND total_transactions >= 10
),
q3_active AS (
  SELECT DISTINCT customer_id
  FROM customer_activity
  WHERE quarter = 'Q3'
    AND total_transactions >= 10
),
churned AS (
  SELECT 
    q2.customer_id,
    q2.country,
    q2.avg_txn_value
  FROM q2_active q2
  LEFT JOIN q3_active q3
  ON q2.customer_id = q3.customer_id
  WHERE q3.customer_id IS NULL
),
weighted_country AS (
  SELECT 
    country,
    SUM(avg_txn_value) AS total_weighted_churn,
    COUNT(DISTINCT customer_id) AS churned_customers
  FROM churned
  GROUP BY country
),
country_base AS (
  SELECT 
    country,
    COUNT(DISTINCT customer_id) AS total_active_q2
  FROM q2_active
  GROUP BY country
),
churn_risk AS (
  SELECT 
    w.country,
    w.total_weighted_churn / b.total_active_q2 AS churn_risk_score
  FROM weighted_country w
  JOIN country_base b
  ON w.country = b.country
)
SELECT country, ROUND(churn_risk_score, 3) AS churn_risk_score
FROM churn_risk
ORDER BY churn_risk_score DESC
LIMIT 5;

