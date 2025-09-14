/*
Find the second highest salary of employees.
*/


select salary from employee
where salary < (select max(salary) from employee)
order by salary desc
limit 1


--Alternatives

select distinct salary
from employee
order by salary desc
offset 1 limit 1;
---
select salary
from (
    select salary, dense_rank() over (order by salary desc) as rnk
    from employee
) t
where rnk = 2;
