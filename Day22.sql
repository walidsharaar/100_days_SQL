/*
Calculate the net change in the number of products launched by companies in 2020 compared to 2019. Your output should include the company names and the net difference.
(Net difference = Number of products launched in 2020 - The number launched in 2019.)
*/


SELECT 
    company_name,
    COUNT(CASE WHEN year = '2020' THEN product_name END) - 
    COUNT(CASE WHEN year = '2019' THEN product_name END) AS net_difference
FROM car_launches
GROUP BY company_name
ORDER BY 2 DESC;
