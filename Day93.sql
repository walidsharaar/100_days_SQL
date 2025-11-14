/*
Your company manages a multi-warehouse distribution network for a retail chain.
The operations director has asked you to identify warehouses showing early signs of supply-chain inefficiency, particularly those with rising stockouts and increasing average delivery delays.
You need to base your analysis on operational data for the past year.

Goal:
 Find warehouses that show simultaneous negative trends in:
Delivery Delay — average days between delivered_date and expected_delivery_date, increasing for 3 consecutive months
Stockout Rate — percentage of orders where stockout_flag = TRUE, increasing for the same 3-month window
Then, for those warehouses:
Report the average delivery delay and average stockout rate in the latest month.
Output should include warehouse_id, city, avg_delay_days, avg_stockout_rate.
*/

WITH monthly_metrics AS (
    SELECT 
        warehouse_id,
        city,
        DATE_TRUNC('month', order_date) AS month,
        AVG(EXTRACT(DAY FROM delivered_date - expected_delivery_date)) AS avg_delay_days,
        SUM(CASE WHEN stockout_flag THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS stockout_rate
    FROM warehouse_operations
    WHERE delivered_date IS NOT NULL
    GROUP BY warehouse_id, city, DATE_TRUNC('month', order_date)
),
with_trends AS (
    SELECT 
        warehouse_id,
        city,
        month,
        avg_delay_days,
        stockout_rate,
        LAG(avg_delay_days, 1) OVER (PARTITION BY warehouse_id ORDER BY month) AS prev_delay,
        LAG(avg_delay_days, 2) OVER (PARTITION BY warehouse_id ORDER BY month) AS prev2_delay,
        LAG(stockout_rate, 1) OVER (PARTITION BY warehouse_id ORDER BY month) AS prev_stockout,
        LAG(stockout_rate, 2) OVER (PARTITION BY warehouse_id ORDER BY month) AS prev2_stockout
    FROM monthly_metrics
),
problematic AS (
    SELECT 
        warehouse_id,
        city
    FROM with_trends
    WHERE avg_delay_days > prev_delay 
      AND prev_delay > prev2_delay
      AND stockout_rate > prev_stockout 
      AND prev_stockout > prev2_stockout
)
SELECT 
    w.warehouse_id,
    w.city,
    m.avg_delay_days,
    m.stockout_rate
FROM monthly_metrics m
JOIN problematic w ON m.warehouse_id = w.warehouse_id
WHERE m.month = (SELECT MAX(DATE_TRUNC('month', order_date)) FROM warehouse_operations)
ORDER BY m.avg_delay_days DESC;


---Alternative


WITH monthly_metrics AS (
    SELECT 
        warehouse_id,
        city,
        DATE_TRUNC('month', order_date) AS month,
        AVG(EXTRACT(DAY FROM delivered_date - expected_delivery_date)) AS avg_delay_days,
        SUM(CASE WHEN stockout_flag THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS stockout_rate
    FROM warehouse_operations
    WHERE delivered_date IS NOT NULL
    GROUP BY warehouse_id, city, DATE_TRUNC('month', order_date)
),
join1 AS (
    SELECT 
        a.warehouse_id,
        a.city,
        a.month AS m3,
        a.avg_delay_days AS delay3,
        a.stockout_rate AS stockout3,
        b.avg_delay_days AS delay2,
        b.stockout_rate AS stockout2,
        c.avg_delay_days AS delay1,
        c.stockout_rate AS stockout1
    FROM monthly_metrics a
    JOIN monthly_metrics b ON a.warehouse_id = b.warehouse_id 
         AND a.month = b.month + INTERVAL '1 month'
    JOIN monthly_metrics c ON b.warehouse_id = c.warehouse_id 
         AND b.month = c.month + INTERVAL '1 month'
),
problematic AS (
    SELECT DISTINCT warehouse_id, city
    FROM join1
    WHERE delay3 > delay2 AND delay2 > delay1
      AND stockout3 > stockout2 AND stockout2 > stockout1
)
SELECT 
    w.warehouse_id,
    w.city,
    m.avg_delay_days,
    m.stockout_rate
FROM monthly_metrics m
JOIN problematic w ON m.warehouse_id = w.warehouse_id
WHERE m.month = (SELECT MAX(DATE_TRUNC('month', order_date)) FROM warehouse_operations)
ORDER BY m.avg_delay_days DESC;
