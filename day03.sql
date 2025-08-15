/*
Find the job titles of the employees with the highest salary. If multiple employees have the same highest salary, include the job titles for all such employees.
*/

select t.worker_title as best_paid_title from worker w
join title t on w.worker_id = t.worker_ref_id
where  w. salary = (select max(salary) from worker) 


--Alternative
--1.
WITH max_salary AS (
    SELECT MAX(salary) AS salary
    FROM worker
)
SELECT t.worker_title AS best_paid_title
FROM worker w
JOIN title t 
  ON w.worker_id = t.worker_ref_id
JOIN max_salary m
  ON w.salary = m.salary;

--2.
SELECT worker_title AS best_paid_title
FROM (
    SELECT
        t.worker_title,
        RANK() OVER (ORDER BY w.salary DESC) AS rnk
    FROM worker w
    JOIN title t
      ON w.worker_id = t.worker_ref_id
) ranked
WHERE rnk = 1;
