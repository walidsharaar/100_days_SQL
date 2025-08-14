/*
We have a table with employees and their salaries, however, some of the records are old and contain outdated salary information. Find the current salary of each employee
assuming that salaries increase each year. Output their id, first name, 
last name, department ID, and current salary. Order your list by employee ID in ascending order.
*/

WITH cte AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY id
            ORDER BY salary DESC
        ) AS rk
    FROM ms_employee_salary
)
SELECT *
FROM cte
WHERE rk = 1;

--Below version that consider date 
WITH cte AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY id
            ORDER BY effective_date DESC
        ) AS rk
    FROM ms_employee_salary
)
SELECT *
FROM cte
WHERE rk = 1
ORDER BY id;
