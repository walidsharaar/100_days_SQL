/*
Find the second highest salary of employees.
*/


select salary from employee
where salary < (select max(salary) from employee)
order by salary desc
limit 1
