/*
Find the top 5 businesses with most reviews. Assume that each row has a unique business_id such that the total reviews for each business is listed on each row. Output the business name along with the total number of reviews
and order your results by the total reviews in descending order.


If there are ties in review counts, businesses with the same number of reviews receive the same rank, and subsequent ranks are skipped accordingly (e.g., if two businesses tie for rank 4, the next business receives rank 6, 
skipping rank 5).


*/


SELECT 
    name, 
    SUM(review_count) AS total_reviews
FROM yelp_business
GROUP BY name
ORDER BY total_reviews DESC
LIMIT 5;


--Alternative

SELECT name, total_reviews
FROM (
    SELECT 
        name, 
        SUM(review_count) AS total_reviews,
        RANK() OVER (ORDER BY SUM(review_count) DESC) AS rnk
    FROM yelp_business
    GROUP BY name
) t
WHERE rnk <= 5;
