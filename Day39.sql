/*
Calculate number of reviews for every business category. Output the category along with the total number of reviews. Order by total reviews in descending order.
*/

WITH cte AS (
    SELECT 
        unnest(string_to_array(categories, ';')) AS category,
        review_count
    FROM yelp_business
)
SELECT 
    category, 
    SUM(review_count) AS total_reviews
FROM cte
GROUP BY category
ORDER BY total_reviews DESC;
