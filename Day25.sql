/*Identify returning active users by finding users who made a second purchase within 1 to 7 days after their first purchase. Ignore same-day purchases. 
Output a list of these user_ids.
*/

WITH cte AS (
    SELECT 
        user_id,
        created_at,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY created_at ASC
        ) AS row_num
    FROM amazon_transactions
),
cte2 AS (
    SELECT  
        t1.user_id,
        t1.created_at AS first_purchase,
        t2.created_at AS next_purchase,
        (t2.created_at::date - t1.created_at::date) AS days_between
    FROM cte t1
    INNER JOIN cte t2
        ON t1.user_id = t2.user_id
       AND t2.row_num = t1.row_num + 1
    WHERE t1.row_num = 1
      AND (t2.created_at::date - t1.created_at::date) BETWEEN 1 AND 7
)
SELECT user_id
FROM cte2
ORDER BY user_id;
