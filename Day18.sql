/*
Find the inspection date and risk category (pe_description) of facilities named 'STREET CHURROS' that received a score below 95.


*/

select * from los_angeles_restaurant_health_inspections;

select distinct activity_date,pe_description
from los_angeles_restaurant_health_inspections
where score < 95 and facility_name='STREET CHURROS'


--Alternatives

WITH churros_issues AS (
    SELECT 
        facility_name,
        activity_date,
        pe_description,
        score
    FROM los_angeles_restaurant_health_inspections
    WHERE facility_name = 'STREET CHURROS'
)
SELECT DISTINCT 
    activity_date,
    pe_description
FROM churros_issues
WHERE score < 95
ORDER BY activity_date;


SELECT activity_date, pe_description, score
FROM (
    SELECT 
        activity_date,
        pe_description,
        score,
        ROW_NUMBER() OVER (PARTITION BY activity_date ORDER BY score ASC) AS rn
    FROM los_angeles_restaurant_health_inspections
    WHERE facility_name = 'STREET CHURROS'
      AND score < 95
) t
WHERE rn = 1
ORDER BY activity_date;
