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

--Alternative

WITH launches AS (
    SELECT 
        company_name,
        year,
        COUNT(DISTINCT product_name) AS launches_per_year
    FROM car_launches
    WHERE year IN (2019, 2020)
    GROUP BY company_name, year
),
ranked AS (
    SELECT
        company_name,
        year,
        launches_per_year,
        SUM(
            CASE WHEN year = 2020 THEN launches_per_year
                 WHEN year = 2019 THEN -launches_per_year
                 ELSE 0 END
        ) OVER (PARTITION BY company_name) AS net_difference
    FROM launches
)
SELECT DISTINCT
    company_name,
    net_difference
FROM ranked
ORDER BY net_difference DESC, company_name;
