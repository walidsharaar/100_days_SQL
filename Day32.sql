/*
Make a report showing the number of survivors and non-survivors by passenger class. Classes are categorized based on the pclass value as:


•	First class: pclass = 1
•	Second class: pclass = 2
•	Third class: pclass = 3


Output the number of survivors and non-survivors by each class.


*/



SELECT survived , 
sum(CASE WHEN pclass = 1 THEN 1 ELSE 0 END ) AS first_class,
sum(CASE WHEN pclass = 2 THEN 1 ELSE 0 END ) AS secong_class,
sum(CASE WHEN pclass = 3 THEN 1 ELSE 0 END ) AS third_class

FROM titanic
GROUP BY survived



-- Alternative

SELECT 
    survived,
    COUNT(*) FILTER (WHERE pclass = 1) AS first_class,
    COUNT(*) FILTER (WHERE pclass = 2) AS second_class,
    COUNT(*) FILTER (WHERE pclass = 3) AS third_class
FROM titanic
GROUP BY survived
ORDER BY survived;
