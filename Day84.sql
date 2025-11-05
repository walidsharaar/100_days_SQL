/*
You work for FinEdge Bank, which offers personal and business accounts.
The BI team wants to understand how effective relationship managers (RMs) are at retaining and growing client engagement — measured by transaction volume and activity consistency.
Identify top 3 relationship managers (RMs) per account_type who achieved the highest growth in client engagement between Q1 2024 and Q2 2024
A client is active in a quarter if they made ≥2 transactions.
*/


WITH quarterly_base AS (
  SELECT
    account_type,
    manager_id,
    client_id,
    DATE_TRUNC('quarter', transaction_date) AS quarter,
    COUNT(transaction_id) AS txn_count,
    SUM(transaction_amount) AS total_amount
  FROM transactions
  WHERE transaction_date BETWEEN '2024-01-01' AND '2024-06-30'
  GROUP BY 1, 2, 3, 4
),
active_clients AS (
  SELECT
    account_type,
    manager_id,
    quarter,
    COUNT(DISTINCT client_id) FILTER (WHERE txn_count >= 2) AS active_clients,
    SUM(total_amount) AS total_volume,
    SUM(txn_count) AS total_txns
  FROM quarterly_base
  GROUP BY 1, 2, 3
),
ces_calc AS (
  SELECT
    account_type,
    manager_id,
    quarter,
    (active_clients * total_volume * 1.0 / total_txns) AS ces
  FROM active_clients
),
ces_growth AS (
  SELECT
    a.account_type,
    a.manager_id,
    (b.ces - a.ces) AS ces_growth
  FROM ces_calc a
  JOIN ces_calc b
    ON a.account_type = b.account_type
   AND a.manager_id = b.manager_id
   AND a.quarter = '2024-01-01'
   AND b.quarter = '2024-04-01'
),
ranked AS (
  SELECT
    account_type,
    manager_id,
    ces_growth,
    RANK() OVER (PARTITION BY account_type ORDER BY ces_growth DESC) AS rnk
  FROM ces_growth
)
SELECT account_type, manager_id, ces_growth, rnk
FROM ranked
WHERE rnk <= 3
ORDER BY account_type, rnk;


--Alternative
WITH quarterly_base AS (
  SELECT
    account_type,
    manager_id,
    client_id,
    DATE_TRUNC('quarter', transaction_date) AS quarter,
    COUNT(transaction_id) AS txn_count,
    SUM(transaction_amount) AS total_amount
  FROM transactions
  WHERE transaction_date BETWEEN '2024-01-01' AND '2024-06-30'
  GROUP BY 1, 2, 3, 4
),
active_clients AS (
  SELECT
    account_type,
    manager_id,
    quarter,
    COUNT(DISTINCT CASE WHEN txn_count >= 2 THEN client_id END) AS active_clients,
    SUM(total_amount) AS total_volume,
    SUM(txn_count) AS total_txns
  FROM quarterly_base
  GROUP BY 1, 2, 3
),
ces_calc AS (
  SELECT
    account_type,
    manager_id,
    quarter,
    (active_clients * total_volume * 1.0 / total_txns) AS ces
  FROM active_clients
),
ces_growth AS (
  SELECT
    a.account_type,
    a.manager_id,
    (b.ces - a.ces) AS ces_growth
  FROM ces_calc a
  JOIN ces_calc b
    ON a.account_type = b.account_type
   AND a.manager_id = b.manager_id
   AND a.quarter = '2024-01-01'
   AND b.quarter = '2024-04-01'
),
ranked AS (
  SELECT g1.account_type, g1.manager_id, g1.ces_growth,
         (SELECT COUNT(*) + 1
          FROM ces_growth g2
          WHERE g2.account_type = g1.account_type
            AND g2.ces_growth > g1.ces_growth) AS rnk
  FROM ces_growth g1
)
SELECT account_type, manager_id, ces_growth, rnk
FROM ranked
WHERE rnk <= 3
ORDER BY account_type, rnk;
