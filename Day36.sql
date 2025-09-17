/*

Identify the employee(s) working under manager manager_id=13 who have achieved the highest target. Return each such employee’s first name alongside the target value.
The goal is to display the maximum target among all employees under manager_id=13 and show which employee(s) reached that top value.
*/

select * from salesforce_employees;


select  first_name, target
from salesforce_employees
where manager_id=13 and 
target=(select max(target) from salesforce_employees where manager_id=13)


--Alternative
--1.
SELECT first_name, target
FROM (
    SELECT 
        first_name,
        target,
        RANK() OVER (PARTITION BY manager_id ORDER BY target DESC) AS rnk
    FROM salesforce_employees
    WHERE manager_id = 13
) t
WHERE rnk = 1;


--2.
SELECT first_name, target
FROM salesforce_employees
WHERE manager_id = 13
  AND target = (
      SELECT MAX(target)
      FROM salesforce_employees
      WHERE manager_id = 13
  );
