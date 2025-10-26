
/*
Find the top 5 states with the most 5 star businesses. Output the state name along with the number of 5-star businesses and order records by the number of 5-star businesses in descending order. In case there are ties in the number of businesses, return all the unique states. If two states have the same result, sort them in alphabetical order.


*/



WITH state_counts AS (
  SELECT 
    state,
    COUNT(*) AS five_star_count
  FROM yelp_business
  WHERE stars = 5
  GROUP BY state
)

SELECT 
  s1.state,
  s1.five_star_count
FROM state_counts s1
WHERE (
  SELECT COUNT(DISTINCT s2.five_star_count)
  FROM state_counts s2
  WHERE s2.five_star_count > s1.five_star_count
) < 5
ORDER BY s1.five_star_count DESC, s1.state;


--Alternative

WITH state_counts AS (
  SELECT 
    state,
    COUNT(*) AS five_star_count
  FROM yelp_business
  WHERE stars = 5
  GROUP BY state
),
ranked_states AS (
  SELECT
    state,
    five_star_count,
    DENSE_RANK() OVER (ORDER BY five_star_count DESC) AS rnk
  FROM state_counts
)
SELECT 
  state,
  five_star_count
FROM ranked_states
WHERE rnk <= 5
ORDER BY five_star_count DESC, state;

