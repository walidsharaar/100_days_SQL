/*
You work as a BI Engineer for a large e-commerce platform. The platform tracks every user interaction with products: page views, cart additions, and purchases.

The company wants to identify emerging products — items that are trending up in user engagement month over month.
They want to focus on products that have at least 50% growth in engagement compared to the previous month.
*/

WITH monthly_engagement AS (
    SELECT
        product_id,
        DATE_TRUNC('month', event_date) AS month,
        COUNT(DISTINCT user_id) AS monthly_engagement
    FROM product_events
    WHERE event_type IN ('view','cart_add','purchase')
      AND event_date >= DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '6 months'
    GROUP BY product_id, month
),

monthly_with_prev AS (
    SELECT
        product_id,
        month,
        monthly_engagement,
        LAG(monthly_engagement) OVER (PARTITION BY product_id ORDER BY month) AS previous_month_engagement
    FROM monthly_engagement
),

growth_calc AS (
    SELECT
        product_id,
        month,
        monthly_engagement,
        previous_month_engagement,
        ROUND(
            CASE
                WHEN previous_month_engagement IS NULL OR previous_month_engagement = 0 THEN 0
                ELSE (monthly_engagement - previous_month_engagement)::float / previous_month_engagement * 100
            END
        , 2) AS growth_pct
    FROM monthly_with_prev
)

SELECT *
FROM growth_calc
WHERE growth_pct >= 50
ORDER BY month DESC, growth_pct DESC;
