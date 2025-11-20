/*
The hospital wants to improve vendor performance, budget adherence, and inventory management. They track:
Orders per department with an array of items (item_id, quantity, unit_price, emergency_flag)
Order dates, delivery dates, and payment dates
Budgets per department per month
Vendors associated with each order
Goal / Business Questions:
Compute per-item delivery delays and flag high-risk items (frequent delays or emergency items).
Compute vendor reliability scores combining delivery speed and emergency fulfillment.
Calculate the budget-to-spend ratio per department per month.
Detect payment delays (the difference between the delivery date and the payment date).
Produce rolling metrics for the last 3 months for each department and vendor.
Identify emergency procurement trends.
*/

WITH hospital_analysis AS (
  SELECT
    order_id,
    department,
    vendor_id,
    item.item_id,
    item.item_category,
    item.quantity,
    item.unit_price,
    item.emergency_flag,
    order_date,
    delivery_date,
    payment_date,
    
    -- Total cost per item
    (item.quantity * item.unit_price) AS total_cost,
    
    -- Delivery & Payment delays
    DATE_DIFF(delivery_date, order_date) AS delivery_delay_days,
    DATE_DIFF(payment_date, delivery_date) AS payment_delay_days,
    
    -- High risk items
    CASE 
      WHEN DATE_DIFF(delivery_date, order_date) > 7 OR item.emergency_flag = TRUE THEN 1
      ELSE 0
    END AS is_high_risk,
    
    -- Vendor reliability rolling metrics
    AVG(DATE_DIFF(delivery_date, order_date)) OVER (PARTITION BY vendor_id ORDER BY order_date
       ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) AS rolling_avg_delivery,
       
    SUM(CASE WHEN DATE_DIFF(delivery_date, order_date) > 7 THEN 1 ELSE 0 END) OVER (PARTITION BY vendor_id ORDER BY order_date
       ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) AS rolling_late_count,
       
    -- Department budget rolling metrics
    SUM(item.quantity * item.unit_price) OVER (PARTITION BY department, DATE_TRUNC('month', order_date)
       ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS dept_monthly_spend
       
  FROM hospital_orders,
       UNNEST(items) AS item
  WHERE order_status = 'Completed'
)
SELECT 
  department,
  vendor_id,
  item_category,
  COUNT(DISTINCT item_id) AS distinct_items,
  SUM(total_cost) AS total_spend,
  AVG(delivery_delay_days) AS avg_delivery_delay,
  AVG(payment_delay_days) AS avg_payment_delay,
  SUM(is_high_risk) AS high_risk_items_count,
  AVG(rolling_avg_delivery) AS avg_rolling_delivery_last3,
  SUM(rolling_late_count) AS rolling_late_total_last3,
  MAX(dept_monthly_spend) AS monthly_spend
FROM hospital_analysis
GROUP BY department, vendor_id, item_category
ORDER BY avg_rolling_delivery_last3 DESC, high_risk_items_count DESC;


--Alternative

WITH exploded AS (
  SELECT
    order_id,
    department,
    vendor_id,
    item.item_id,
    item.item_category,
    item.quantity,
    item.unit_price,
    item.emergency_flag,
    order_date,
    delivery_date,
    payment_date,
    (item.quantity * item.unit_price) AS total_cost,
    DATE_DIFF(delivery_date, order_date) AS delivery_delay_days,
    DATE_DIFF(payment_date, delivery_date) AS payment_delay_days,
    CASE 
      WHEN DATE_DIFF(delivery_date, order_date) > 7 OR item.emergency_flag = TRUE THEN 1
      ELSE 0
    END AS is_high_risk
  FROM hospital_orders,
       UNNEST(items) AS item
  WHERE order_status = 'Completed'
),
vendor_metrics AS (
  SELECT
    vendor_id,
    AVG(delivery_delay_days) AS avg_delivery_delay,
    SUM(is_high_risk) AS high_risk_items_count
  FROM exploded
  GROUP BY vendor_id
),
department_metrics AS (
  SELECT
    department,
    item_category,
    SUM(total_cost) AS total_spend,
    AVG(delivery_delay_days) AS avg_delivery_delay,
    AVG(payment_delay_days) AS avg_payment_delay,
    SUM(is_high_risk) AS high_risk_items_count
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
  d.high_risk_items_count,
  v.avg_delivery_delay AS vendor_avg_delivery,
  v.high_risk_items_count AS vendor_high_risk_total
FROM department_metrics d
JOIN vendor_metrics v ON d.department = v.vendor_id -- or other mapping if needed
ORDER BY vendor_avg_delivery DESC, high_risk_items_count DESC;

