
/*
You work for a digital bank offering savings accounts, credit cards, and loans.
The marketing team suspects increased customer churn in recent months and wants to understand retention patterns — especially which customers remain active and which are at risk.

Find the 3 states with the highest customer retention rate between Q1 and Q2 of 2025.

A retained customer is one who made at least one transaction in both Q1 and Q2.

A churned customer is one who made transactions in Q1 but none in Q2.

The retention rate = retained_customers / total_customers_in_Q1

*/

WITH q1_customers AS (
  SELECT DISTINCT customer_id, state
  FROM bank_transactions
  WHERE txn_date BETWEEN '2025-01-01' AND '2025-03-31'
),
q2_customers AS (
  SELECT DISTINCT customer_id, state
  FROM bank_transactions
  WHERE txn_date BETWEEN '2025-04-01' AND '2025-06-30'
),
retention AS (
  SELECT 
    q1.state,
    COUNT(DISTINCT q1.customer_id) AS total_q1_customers,
    COUNT(DISTINCT q2.customer_id) AS retained_customers
  FROM q1_customers q1
  LEFT JOIN q2_customers q2
  ON q1.customer_id = q2.customer_id
  AND q1.state = q2.state
  GROUP BY q1.state
),
final AS (
  SELECT 
    state,
    retained_customers * 1.0 / total_q1_customers AS retention_rate,
    RANK() OVER (ORDER BY retained_customers * 1.0 / total_q1_customers DESC) AS rank_state
  FROM retention
)
SELECT state, ROUND(retention_rate, 3) AS retention_rate
FROM final
WHERE rank_state <= 3;

--Alternative

WITH q1_customers AS (
  SELECT DISTINCT customer_id, state
  FROM bank_transactions
  WHERE txn_date BETWEEN '2025-01-01' AND '2025-03-31'
),
q2_customers AS (
  SELECT DISTINCT customer_id, state
  FROM bank_transactions
  WHERE txn_date BETWEEN '2025-04-01' AND '2025-06-30'
),
retention AS (
  SELECT 
    q1.state,
    COUNT(DISTINCT q1.customer_id) AS total_q1_customers,
    COUNT(DISTINCT q2.customer_id) AS retained_customers
  FROM q1_customers q1
  LEFT JOIN q2_customers q2
  ON q1.customer_id = q2.customer_id
  AND q1.state = q2.state
  GROUP BY q1.state
),
ranked AS (
  SELECT 
    state,
    retained_customers * 1.0 / total_q1_customers AS retention_rate
  FROM retention
)
SELECT state, ROUND(retention_rate, 3) AS retention_rate
FROM ranked
ORDER BY retention_rate DESC
LIMIT 3;


