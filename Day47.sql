/*
We have data on rental properties and their owners. Write a query that figures out how many different apartments (use unit_id) are owned by people under 30, broken down by their nationality. 
We want to see which nationality owns the most apartments, 
so make sure to sort the results accordingly.
*/

SELECT 
    h.nationality,
    COUNT(DISTINCT u.unit_id) AS num_apt
FROM airbnb_units u
JOIN airbnb_hosts h
  ON u.host_id = h.host_id
WHERE u.unit_type = 'Apartment'
  AND h.age < 30
GROUP BY h.nationality
ORDER BY num_apt DESC;

