/*
You have the marketing_campaign table, which records in-app purchases by users. Users making their first in-app purchase enter a marketing campaign, where they see call-to-actions for more purchases. Find how many users made additional purchases due to the campaign's success.


The campaign starts one day after the first purchase. Users with only one or multiple purchases on the first day do not count, nor do users who later buy only the same products from their first day.
*/


WITH first_day AS (
  SELECT user_id, MIN(created_at::date) AS first_day
  FROM marketing_campaign
  GROUP BY user_id
),
new_product_after AS (
  SELECT DISTINCT m.user_id
  FROM marketing_campaign m
  JOIN first_day f ON m.user_id = f.user_id
  WHERE m.created_at::date > f.first_day
    AND m.product_id NOT IN (
      SELECT product_id FROM marketing_campaign
      WHERE user_id = f.user_id AND created_at::date = f.first_day
    )
)
SELECT COUNT(*) AS successful_users
FROM new_product_after;

--Alternative

WITH ranked AS (
  SELECT
    user_id,
    product_id,
    created_at,
    DENSE_RANK() OVER (PARTITION BY user_id ORDER BY created_at::date) AS purchase_day_rank,
    DENSE_RANK() OVER (PARTITION BY user_id, product_id ORDER BY created_at::date) AS product_buy_rank
  FROM marketing_campaign
)
SELECT COUNT(DISTINCT user_id) AS successful_users
FROM ranked
WHERE purchase_day_rank > 1
  AND product_buy_rank = 1;
