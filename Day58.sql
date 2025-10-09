/*
You are given a table named airbnb_host_searches that contains data for rental property searches made by users. Determine the minimum, average, and maximum rental prices for each popularity-rating bucket. 
A popularity rating bucket should be assigned to every record based on its number of reviews (see rules below).


The host’s popularity rating is defined as below:
•   0 reviews: "New"
•   1 to 5 reviews: "Rising"
•   6 to 15 reviews: "Trending Up"
•   16 to 40 reviews: "Popular"
•   More than 40 reviews: "Hot"


Tip: The id column in the table refers to the search ID.


Output host popularity rating and their minimum, average and maximum rental prices. Order the solution by the minimum cost.
*/

WITH host_data AS (
  SELECT
    price,
    number_of_reviews
  FROM airbnb_host_searches
),
pop_ratings AS (
  SELECT
    CASE
      WHEN number_of_reviews = 0 THEN 'New'
      WHEN number_of_reviews BETWEEN 1 AND 5 THEN 'Rising'
      WHEN number_of_reviews BETWEEN 6 AND 15 THEN 'Trending Up'
      WHEN number_of_reviews BETWEEN 16 AND 40 THEN 'Popular'
      WHEN number_of_reviews > 40 THEN 'Hot'
    END AS host_popularity,
    price
  FROM host_data
)
SELECT
  host_popularity,
  MIN(price) AS min_price,
  AVG(price) AS avg_price,
  MAX(price) AS max_price
FROM pop_ratings
GROUP BY host_popularity
ORDER BY MIN(price);
