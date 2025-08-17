/*
Compare each employee's salary with the average salary of the corresponding department.
Output the department, first name, and salary of employees along with the average salary of that department.
*/
with cte as (
select department,avg(salary) as avg_salary
from employee
group by department)
select e.department,e.first_name,e.salary, avg_salary from cte c
join employee e on c.department = e.department
order by department asc

--alternative
SELECT 
    department,
    first_name,
    salary,
    AVG(salary) OVER (PARTITION BY department) AS avg_salary
FROM employee
ORDER BY department ASC;
