/*
Find the processed rate of tickets for each type. The processed rate is defined as the number of processed tickets divided by the total number of tickets for that type. Round this result to two decimal places.


*/


SELECT 
    type,
    ROUND(
        SUM(CASE WHEN processed = 'TRUE' THEN 1 ELSE 0 END) * 1.0 
        / COUNT(*), 
        2
    ) AS processed_rate
FROM facebook_complaints
GROUP BY type;

