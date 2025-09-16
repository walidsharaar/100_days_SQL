/*
Find the employee with the highest salary per department.
Output the department name, employee's first name along with the corresponding salary.
*/


SELECT
department,
first_name,
salary
FROM employee
WHERE (department, salary) IN(
SELECT 
department,
MAX(salary)
FROM employee
GROUP BY department
)


--Alternatives
--1.
SELECT department, first_name, salary
FROM employee e
WHERE salary = (
    SELECT MAX(salary)
    FROM employee
    WHERE department = e.department
);
