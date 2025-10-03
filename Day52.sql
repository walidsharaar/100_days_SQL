/*
Identify returning active users by finding users who made a second purchase within 7 days or less of any previous transaction, excluding same-day purchases. Output a list of these user_id.
*/

SELECT DISTINCT a.user_id
FROM amazon_transactions AS a
JOIN amazon_transactions AS b
ON a.user_id = b.user_id
    AND a.created_at +7 > b.created_at
    AND a.created_at < b.created_at
    AND a.created_at <> b.created_at
ORDER BY a.user_id
