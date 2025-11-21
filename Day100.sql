/*
A hospital tracks:
Orders: Each order has items (array of item_id, quantity, unit_price, emergency_flag)
Departments: Each department has monthly budgets
Vendors: Each vendor has delivery times and reliability scores
Patients / Subscriptions: Some departments have recurring patient visits (billing records)
Payments: Payment date, payment method, delayed or on-time
Historical Demand: For each item per department per month
Objectives:
Detect items with risk of stockout using historical demand, delivery delays, and emergency orders.
Compute budget vs spend ratios per department and flag overspending trends.
Identify vendors at risk: frequent delays + emergency fulfillment.
Predict patient churn for recurring billing patients using:
Missed visits in last 3 months
Delayed payments
Emergency service usage
Compute rolling 3-month average spend, delivery delays, and churn risk scores.
Generate department + vendor + item-level KPIs ready for dashboard visualization.

*/

WITH hospital_capstone AS (
  SELECT
    o.order_id,
    o.department,
    o.vendor_id,
    item.item_id,
    item.item_category,
    item.quantity,
    item.unit_price,
    item.emergency_flag,
    o.order_date,
    o.delivery_date,
    o.payment_date,
    p.patient_id,
    p.last_visit_date,
    
    -- Financial & procurement metrics
    (item.quantity * item.unit_price) AS total_cost,
    DATE_DIFF(delivery_date, order_date) AS delivery_delay,
    DATE_DIFF(payment_date, delivery_date) AS payment_delay,
    CASE WHEN DATE_DIFF(delivery_date, order_date) > 7 OR item.emergency_flag THEN 1 ELSE 0 END AS high_risk_item,
    
    -- Rolling vendor reliability (3 months)
    AVG(DATE_DIFF(delivery_date, order_date)) OVER (PARTITION BY vendor_id ORDER BY order_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_avg_delivery,
    SUM(CASE WHEN DATE_DIFF(delivery_date, order_date) > 7 THEN 1 ELSE 0 END) OVER (PARTITION BY vendor_id ORDER BY order_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_late_count,
    
    -- Department monthly spend & budget ratio
    SUM(item.quantity * item.unit_price) OVER (PARTITION BY department, DATE_TRUNC('month', order_date)) AS monthly_spend,
    d.monthly_budget,
    (SUM(item.quantity * item.unit_price) OVER (PARTITION BY department, DATE_TRUNC('month', order_date)) / d.monthly_budget) AS budget_ratio,
    
    -- Patient churn risk scoring
    CASE WHEN DATE_DIFF(CURRENT_DATE, p.last_visit_date) > 90 THEN 1 ELSE 0 END +
    CASE WHEN DATE_DIFF(p.payment_date, p.last_visit_date) > 15 THEN 1 ELSE 0 END +
    CASE WHEN p.emergency_visit_flag = TRUE THEN 0.5 ELSE 0 END AS churn_risk_score
  FROM hospital_orders o
       UNNEST(o.items) AS item
       LEFT JOIN departments d ON o.department = d.department
       LEFT JOIN patient_visits p ON o.department = p.department
  WHERE o.order_status = 'Completed'
)
SELECT
  department,
  vendor_id,
  item_category,
  COUNT(DISTINCT item_id) AS distinct_items,
  SUM(total_cost) AS total_spend,
  AVG(delivery_delay) AS avg_delivery_delay,
  AVG(payment_delay) AS avg_payment_delay,
  SUM(high_risk_item) AS high_risk_count,
  AVG(rolling_avg_delivery) AS rolling_avg_delivery_3mo,
  SUM(rolling_late_count) AS rolling_late_count_3mo,
  MAX(budget_ratio) AS max_budget_ratio,
  AVG(churn_risk_score) AS avg_churn_risk
FROM hospital_capstone
GROUP BY department, vendor_id, item_category
ORDER BY avg_churn_risk DESC, rolling_avg_delivery_3mo DESC;


--Alternative

WITH exploded AS (
  SELECT
    o.order_id,
    o.department,
    o.vendor_id,
    item.item_id,
    item.item_category,
    item.quantity,
    item.unit_price,
    item.emergency_flag,
    o.order_date,
    o.delivery_date,
    o.payment_date,
    (item.quantity * item.unit_price) AS total_cost,
    DATE_DIFF(delivery_date, order_date) AS delivery_delay,
    DATE_DIFF(payment_date, delivery_date) AS payment_delay,
    CASE WHEN DATE_DIFF(delivery_date, order_date) > 7 OR item.emergency_flag THEN 1 ELSE 0 END AS high_risk_item
  FROM hospital_orders o
       UNNEST(o.items) AS item
  WHERE o.order_status = 'Completed'
),
vendor_metrics AS (
  SELECT
    vendor_id,
    AVG(delivery_delay) AS avg_delivery_delay,
    SUM(high_risk_item) AS high_risk_count
  FROM exploded
  GROUP BY vendor_id
),
department_metrics AS (
  SELECT
    department,
    item_category,
    SUM(total_cost) AS total_spend,
    AVG(delivery_delay) AS avg_delivery_delay,
    AVG(payment_delay) AS avg_payment_delay,
    SUM(high_risk_item) AS high_risk_count
  FROM exploded
  GROUP BY department, item_category
)
SELECT
  d.department,
  v.vendor_id,
  d.item_category,
  d.total_spend,
  d.avg_delivery_delay,
  d.avg_payment_delay,
  d.high_risk_count,
  v.avg_delivery_delay AS vendor_avg_delivery,
  v.high_risk_count AS vendor_high_risk
FROM department_metrics d
JOIN vendor_metrics v ON d.department = v.vendor_id -- adjust mapping if needed
ORDER BY vendor_avg_delivery DESC, high_risk_count DESC;
