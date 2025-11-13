/*
You are a BI Analyst for StaySmart Hotels, a chain operating in multiple cities. The company wants to analyze guest stay behavior, room utilization efficiency, and revenue leakage over time.
Find the monthly room utilization rate for each hotel and identify the top 3 hotels with the highest improvement in utilization from one month to the next (based on consecutive months).

Room Utilization Rate = Total Nights Occupied / Total Room Nights Available in the Month 
Assume:
Each hotel has 100 rooms available daily.
A booking contributes nights from check-in to check-out - 1.
Cancelled bookings should be excluded.
Compare consecutive months to find the top improvers in utilization rate.

*/


WITH expanded AS (
    SELECT 
        hotel_id,
        generate_series(check_in, check_out - INTERVAL '1 day', INTERVAL '1 day')::date AS stay_date
    FROM hotel_bookings
    WHERE cancelled = FALSE
),
monthly_util AS (
    SELECT 
        hotel_id,
        date_trunc('month', stay_date) AS month,
        COUNT(*) AS occupied_nights
    FROM expanded
    GROUP BY hotel_id, date_trunc('month', stay_date)
),
monthly_final AS (
    SELECT 
        hotel_id,
        month,
        occupied_nights,
        EXTRACT(DAY FROM (date_trunc('month', month) + INTERVAL '1 month - 1 day')) * 100 AS total_nights_available,
        (occupied_nights * 1.0) / (EXTRACT(DAY FROM (date_trunc('month', month) + INTERVAL '1 month - 1 day')) * 100) AS utilization_rate
    FROM monthly_util
),
month_compare AS (
    SELECT 
        hotel_id,
        month,
        utilization_rate,
        utilization_rate - LAG(utilization_rate) OVER (PARTITION BY hotel_id ORDER BY month) AS change_rate
    FROM monthly_final
)
SELECT 
    hotel_id,
    month,
    change_rate
FROM month_compare
WHERE change_rate IS NOT NULL
ORDER BY change_rate DESC
LIMIT 3;


--Alternative
WITH expanded AS (
    SELECT 
        hotel_id,
        generate_series(check_in, check_out - INTERVAL '1 day', INTERVAL '1 day')::date AS stay_date
    FROM hotel_bookings
    WHERE cancelled = FALSE
),
monthly_util AS (
    SELECT 
        hotel_id,
        date_trunc('month', stay_date) AS month,
        COUNT(*) AS occupied_nights
    FROM expanded
    GROUP BY hotel_id, date_trunc('month', stay_date)
),
monthly_final AS (
    SELECT 
        hotel_id,
        month,
        (COUNT(*) * 1.0) / (EXTRACT(DAY FROM (date_trunc('month', month) + INTERVAL '1 month - 1 day')) * 100) AS utilization_rate
    FROM expanded
    GROUP BY hotel_id, month
),
month_compare AS (
    SELECT 
        a.hotel_id,
        a.month,
        a.utilization_rate - b.utilization_rate AS change_rate
    FROM monthly_final a
    JOIN monthly_final b 
      ON a.hotel_id = b.hotel_id
     AND a.month = b.month + INTERVAL '1 month'
)
SELECT 
    hotel_id,
    month,
    change_rate
FROM month_compare
ORDER BY change_rate DESC
LIMIT 3;
