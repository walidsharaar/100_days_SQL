/*
You are working as a Data Analyst in a digital bank that provides personal loans.
Your goal is to analyze customer repayment behavior and detect early signs of cashflow risk.
Find the top 3 states where customers are most likely to default, defined as:
having 2 or more late payments within the last 90 days from the current date, and
belonging to “Medium” or “High” risk segments.
Also calculate for each state:
Total number of risky customers
Average loan amount of those customers
Late payment rate (late_payments / total_payments)
*/



WITH recent_payments AS (
  SELECT 
    r.loan_id,
    r.payment_date,
    r.due_date,
    CASE WHEN r.payment_date > r.due_date THEN 1 ELSE 0 END AS is_late
  FROM repayments r
  WHERE r.payment_date >= CURRENT_DATE - INTERVAL '90 day'
),

customer_risk AS (
  SELECT 
    la.customer_id,
    c.state,
    c.risk_segment,
    la.loan_amount,
    COUNT(*) FILTER (WHERE rp.is_late = 1) AS late_payments,
    COUNT(*) AS total_payments
  FROM recent_payments rp
  JOIN loan_accounts la ON rp.loan_id = la.loan_id
  JOIN customers c ON la.customer_id = c.customer_id
  GROUP BY la.customer_id, c.state, c.risk_segment, la.loan_amount
),

risky_customers AS (
  SELECT *,
         late_payments * 1.0 / NULLIF(total_payments, 0) AS late_ratio
  FROM customer_risk
  WHERE late_payments >= 2
    AND risk_segment IN ('Medium', 'High')
)

SELECT 
  state,
  COUNT(DISTINCT customer_id) AS risky_customers,
  ROUND(AVG(loan_amount), 2) AS avg_loan_amount,
  ROUND(SUM(late_payments)::float / SUM(total_payments), 2) AS late_payment_rate
FROM risky_customers
GROUP BY state
ORDER BY late_payment_rate DESC
LIMIT 3;

--Alternative

WITH recent_payments AS (
  SELECT 
    r.loan_id,
    r.payment_date,
    r.due_date,
    CASE WHEN r.payment_date > r.due_date THEN 1 ELSE 0 END AS is_late
  FROM repayments r
  WHERE r.payment_date >= CURRENT_DATE - INTERVAL '90 day'
),

customer_payment_summary AS (
  SELECT 
    la.customer_id,
    c.state,
    c.risk_segment,
    la.loan_amount,
    SUM(rp.is_late) AS late_payments,
    COUNT(*) AS total_payments
  FROM recent_payments rp
  JOIN loan_accounts la ON rp.loan_id = la.loan_id
  JOIN customers c ON la.customer_id = c.customer_id
  GROUP BY la.customer_id, c.state, c.risk_segment, la.loan_amount
),

filtered AS (
  SELECT *
  FROM customer_payment_summary
  WHERE late_payments >= 2
    AND risk_segment IN ('Medium', 'High')
)

SELECT 
  state,
  COUNT(DISTINCT customer_id) AS risky_customers,
  ROUND(AVG(loan_amount), 2) AS avg_loan_amount,
  ROUND(SUM(late_payments)::float / SUM(total_payments), 2) AS late_payment_rate
FROM filtered
GROUP BY state
ORDER BY late_payment_rate DESC
LIMIT 3;
