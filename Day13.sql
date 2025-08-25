/*
Meta/Facebook has developed a new programming language called Hack. To measure the popularity of Hack, they ran a survey with their employees. The survey included data on previous programming familiarity as well as the number of years of experience, age, gender and most importantly satisfaction with Hack. Due to an error location data was not collected, but your supervisor demands a report showing average popularity of Hack by office location. Luckily the user IDs of employees completing the surveys were stored.
Based on the above, find the average popularity of the Hack per office location.
Output the location along with the average popularity.
*/

select * from facebook_employees;

select * from  facebook_hack_survey;

select fe.location, avg(fh.popularity) as popularity
from facebook_employees fe
left join facebook_hack_survey fh
on fh.employee_id = fe.id
group by fe.location

--Alternative

WITH survey_avg AS (
    SELECT employee_id,
           AVG(popularity) AS avg_popularity
    FROM facebook_hack_survey
    GROUP BY employee_id
)
SELECT fe.location,
       AVG(sa.avg_popularity) AS location_popularity
FROM facebook_employees fe
LEFT JOIN survey_avg sa
  ON sa.employee_id = fe.id
GROUP BY fe.location;
