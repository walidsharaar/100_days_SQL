/*
Count the number of unique street names for each postal code in the business dataset. Use only the first word of the street name, case insensitive (e.g., "FOLSOM" and "Folsom" are the same).
If the structure is reversed (e.g., "Pier 39" and "39 Pier"), count them as the same street. Output the results with postal codes, 
ordered by the number of streets (descending) and postal code (ascending).
*/

SELECT 
    COUNT(DISTINCT LOWER(SPLIT_PART(business_address, ' ', 2))) AS n_street, 
    business_postal_code
FROM sf_restaurant_health_violations 
GROUP BY business_postal_code 
ORDER BY n_street DESC, business_postal_code ASC;


--Alternative

WITH address_parts AS (
    SELECT 
        business_postal_code,
        LOWER(SPLIT_PART(business_address, ' ', 2)) AS street_name
    FROM sf_restaurant_health_violations
)
SELECT 
    business_postal_code,
    COUNT(DISTINCT street_name) AS n_street
FROM address_parts
GROUP BY business_postal_code
ORDER BY n_street DESC, business_postal_code ASC;
