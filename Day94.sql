/*
You’re working as a Senior BI Engineer for an e-commerce platform running multiple ad campaigns across channels (Google, Meta, Email, etc.).
The CMO wants to evaluate which campaign drives the best ROI, funnel retention, and long-term conversions — not just click-throughs.
You need to:
Build a 3-step funnel per campaign:
Step 1: Clicks
Step 2: Signups
Step 3: Purchases
Calculate the conversion rate between each funnel stage.
Compute ROI = (Total Revenue - Total Spend) / Total Spend per campaign.
Identify top 3 campaigns that have:
ROI > 1 (profitable)
AND at least 50% signup-to-purchase conversion rate
Output: campaign_id, channel, click_to_signup_rate, signup_to_purchase_rate, ROI
*/


WITH user_stage AS (
  SELECT
    campaign_id,
    channel,
    user_id,
    MAX(CASE WHEN action_type = 'click' THEN 1 ELSE 0 END) AS clicked,
    MAX(CASE WHEN action_type = 'signup' THEN 1 ELSE 0 END) AS signed_up,
    MAX(CASE WHEN action_type = 'purchase' THEN 1 ELSE 0 END) AS purchased
  FROM campaign_performance
  GROUP BY campaign_id, channel, user_id
),
funnel_metrics AS (
  SELECT
    campaign_id,
    channel,
    COUNT(DISTINCT CASE WHEN clicked = 1 THEN user_id END) AS clicks,
    COUNT(DISTINCT CASE WHEN signed_up = 1 THEN user_id END) AS signups,
    COUNT(DISTINCT CASE WHEN purchased = 1 THEN user_id END) AS purchases
  FROM user_stage
  GROUP BY campaign_id, channel
),
conversion_rates AS (
  SELECT
    f.*,
    ROUND(signups * 1.0 / NULLIF(clicks, 0), 2) AS click_to_signup_rate,
    ROUND(purchases * 1.0 / NULLIF(signups, 0), 2) AS signup_to_purchase_rate
  FROM funnel_metrics f
),
roi_calc AS (
  SELECT
    campaign_id,
    channel,
    SUM(revenue) AS total_revenue,
    SUM(spend) AS total_spend,
    (SUM(revenue) - SUM(spend)) / NULLIF(SUM(spend), 0) AS ROI
  FROM campaign_performance
  GROUP BY campaign_id, channel
)
SELECT 
  c.campaign_id,
  c.channel,
  c.click_to_signup_rate,
  c.signup_to_purchase_rate,
  r.ROI
FROM conversion_rates c
JOIN roi_calc r
  ON c.campaign_id = r.campaign_id AND c.channel = r.channel
WHERE r.ROI > 1 
  AND c.signup_to_purchase_rate >= 0.5
ORDER BY r.ROI DESC, c.signup_to_purchase_rate DESC
LIMIT 3;


--Alternative

WITH clicks AS (
  SELECT campaign_id, channel, user_id
  FROM campaign_performance
  WHERE action_type = 'click'
  GROUP BY campaign_id, channel, user_id
),
signups AS (
  SELECT campaign_id, channel, user_id
  FROM campaign_performance
  WHERE action_type = 'signup'
  GROUP BY campaign_id, channel, user_id
),
purchases AS (
  SELECT campaign_id, channel, user_id
  FROM campaign_performance
  WHERE action_type = 'purchase'
  GROUP BY campaign_id, channel, user_id
),
funnel AS (
  SELECT 
    c.campaign_id,
    c.channel,
    COUNT(DISTINCT c.user_id) AS clicks,
    COUNT(DISTINCT s.user_id) AS signups,
    COUNT(DISTINCT p.user_id) AS purchases
  FROM clicks c
  LEFT JOIN signups s ON c.user_id = s.user_id AND c.campaign_id = s.campaign_id
  LEFT JOIN purchases p ON s.user_id = p.user_id AND s.campaign_id = p.campaign_id
  GROUP BY c.campaign_id, c.channel
),
conversion AS (
  SELECT 
    f.*,
    ROUND(signups * 1.0 / NULLIF(clicks, 0), 2) AS click_to_signup_rate,
    ROUND(purchases * 1.0 / NULLIF(signups, 0), 2) AS signup_to_purchase_rate
  FROM funnel f
),
roi_calc AS (
  SELECT
    campaign_id,
    channel,
    SUM(revenue) AS total_revenue,
    SUM(spend) AS total_spend,
    (SUM(revenue) - SUM(spend)) / NULLIF(SUM(spend), 0) AS ROI
  FROM campaign_performance
  GROUP BY campaign_id, channel
)
SELECT 
  c.campaign_id,
  c.channel,
  c.click_to_signup_rate,
  c.signup_to_purchase_rate,
  r.ROI
FROM conversion c
JOIN roi_calc r
  ON c.campaign_id = r.campaign_id AND c.channel = r.channel
WHERE r.ROI > 1
  AND c.signup_to_purchase_rate >= 0.5
ORDER BY r.ROI DESC
LIMIT 3;
