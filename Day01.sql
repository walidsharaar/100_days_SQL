/*
Calculates the difference between the highest salaries in the marketing and engineering departments. Output just the absolute difference in salaries.
*/

select
abs(max(case when d.department = 'marketing' then e.salary end )  -
max(case when d.department = 'engineering' then e.salary end)) as salary_difference
from db_employee e
left join db_dept d
on e.department_id=d.id


-- Other possible solutions
--solution 1
*SELECT 
    m.max_salary - e.max_salary AS salary_difference
FROM (
    SELECT MAX(salary) AS max_salary
    FROM db_employee
    WHERE department_id = (
        SELECT id FROM db_dept WHERE department = 'marketing'
    )
) m
CROSS JOIN (
    SELECT MAX(salary) AS max_salary
    FROM db_employee
    WHERE department_id = (
        SELECT id FROM db_dept WHERE department = 'engineering'
    )
) e

--solution 2
SELECT 
    MAX(salary) FILTER (WHERE d.department = 'marketing')
    - MAX(salary) FILTER (WHERE d.department = 'engineering') AS salary_difference
FROM db_employee e
JOIN db_dept d
    ON e.department_id = d.id
WHERE d.department IN ('marketing', 'engineering');
