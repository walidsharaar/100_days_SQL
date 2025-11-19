/*
A large hospital system manages its medical equipment, drug supplies, and consumables through a centralized procurement system. 
Hospital management suspects delays in delivery and payment are increasing total procurement costs and affecting department efficiency.
They want to analyze:
Delivery efficiency — average delivery delay (in days) per department and vendor.
Payment lag impact — how late payments correlate with higher unit prices.
Emergency procurement costs — average % markup compared to non-emergency purchases.
Monthly procurement cycle — identify which months have the longest delivery delays and highest costs.
*/

--Q1. Calculate the average delivery delay (in days) for each department and vendor.
SELECT 
    department,
    vendor_id,
    ROUND(AVG(DATEDIFF(delivery_date, order_date)),2) AS avg_delivery_delay
FROM hospital_procurement
WHERE delivery_date IS NOT NULL
GROUP BY department, vendor_id
ORDER BY avg_delivery_delay DESC;

--Q2. Find correlation indicators between payment delay and unit price — i.e., does longer payment delay lead to higher cost items?
/*We’ll compute the average unit_price for payment delays grouped in buckets:
0–7 days

8–15 days

16–30 days

30 days
*/


WITH payment_delay AS (
    SELECT 
        item_category,
        DATEDIFF(payment_date, delivery_date) AS delay_days,
        unit_price
    FROM hospital_procurement
    WHERE payment_date IS NOT NULL AND delivery_date IS NOT NULL
)
SELECT 
    item_category,
    CASE 
        WHEN delay_days <= 7 THEN '0-7 days'
        WHEN delay_days <= 15 THEN '8-15 days'
        WHEN delay_days <= 30 THEN '16-30 days'
        ELSE '>30 days'
    END AS delay_bucket,
    ROUND(AVG(unit_price),2) AS avg_unit_price
FROM payment_delay
GROUP BY item_category, delay_bucket
ORDER BY item_category, delay_bucket;

Q3. Compare the average % markup on emergency vs non-emergency procurements.
Let’s assume item_base_cost (standard cost reference) is in another table.
SELECT 
    item_category,
    ROUND(
        100 * (AVG(unit_price) FILTER (WHERE is_emergency) 
        - AVG(unit_price) FILTER (WHERE NOT is_emergency))
        / AVG(unit_price) FILTER (WHERE NOT is_emergency), 2
    ) AS emergency_markup_percent
FROM hospital_procurement
GROUP BY item_category
ORDER BY emergency_markup_percent DESC;

--Q4. Identify months with the longest average delivery delay and highest total procurement cost, using EXTRACT() and DATE_TRUNC().

SELECT
    DATE_TRUNC('month', order_date) AS month,
    ROUND(AVG(DATEDIFF(delivery_date, order_date)),2) AS avg_delivery_delay,
    ROUND(SUM(quantity * unit_price),2) AS total_monthly_cost
FROM hospital_procurement
WHERE delivery_date IS NOT NULL
GROUP BY month
ORDER BY total_monthly_cost DESC, avg_delivery_delay DESC;
