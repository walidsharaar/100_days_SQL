/*
Find the review_text that received the highest number of  cool votes.
Output the business name along with the review text with the highest number of cool votes.
*/

WITH cte AS (
    SELECT 
        business_name,
        review_text,
        SUM(cool) AS cool_votes
    FROM yelp_reviews
    GROUP BY business_name, review_text
),
ranked AS (
    SELECT 
        business_name,
        review_text,
        cool_votes,
        RANK() OVER (ORDER BY cool_votes DESC) AS rn
    FROM cte
)
SELECT business_name, review_text, cool_votes
FROM ranked
WHERE rn = 1;
