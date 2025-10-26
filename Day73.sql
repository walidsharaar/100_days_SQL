/*

You're given a dataset of searches for properties on Airbnb. For simplicity, let's say that each search result (i.e., each row) represents a unique host. Find the city with the most
amenities across all their host's properties. Output the name of the city.


*/


WITH cte AS (
  SELECT 
    city,
    TRIM(BOTH '{, ", }' FROM amenity) AS split_amenity
  FROM airbnb_search_details,
       UNNEST(STRING_TO_ARRAY(amenities, ',')) AS amenity
)
SELECT 
  city
FROM cte
GROUP BY city
ORDER BY COUNT(DISTINCT split_amenity) DESC
LIMIT 1;


--Alternative

WITH cte AS (
  SELECT 
    city,
    TRIM(BOTH '{, ", }' FROM regexp_split_to_table(amenities, ',')) AS amenity
  FROM airbnb_search_details
)
SELECT 
  city,
  COUNT(DISTINCT amenity) AS unique_amenities
FROM cte
GROUP BY city
ORDER BY unique_amenities DESC
LIMIT 1;
