/*
Find the average number of bathrooms and bedrooms for each city’s property types. Output the result along with the city name and the property type.
*/
SELECT
  city,
  property_type,
  ROUND(AVG(bathrooms), 2) AS avg_bathrooms,
  ROUND(AVG(bedrooms), 2) AS avg_bedrooms
FROM airbnb_search_details
GROUP BY city, property_type;
