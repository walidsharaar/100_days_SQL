/*
Calculates the difference between the highest salaries in the marketing and engineering departments. Output just the absolute difference in salaries.
*/

select
abs(max(case when d.department = 'marketing' then e.salary end )  -
max(case when d.department = 'engineering' then e.salary end)) as salary_difference
from db_employee e
left join db_dept d
on e.department_id=d.id
