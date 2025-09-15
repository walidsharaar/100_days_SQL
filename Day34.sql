/*
Find employees who are earning more than their managers. Output the employee's first name along with the corresponding salary.
*/

SELECT 
    e.first_name AS employee_name,
    e.salary     AS employee_salary,
    m.first_name AS manager_name,
    m.salary     AS manager_salary
FROM employee e
INNER JOIN employee m 
    ON e.manager_id = m.id
WHERE e.salary > m.salary;


--Alternative

SELECT first_name, salary
FROM employee e
WHERE salary > (
    SELECT m.salary
    FROM employee m
    WHERE m.id = e.manager_id
);
