/*
Find the job titles of the employees with the highest salary. If multiple employees have the same highest salary, include the job titles for all such employees.
*/

select t.worker_title as best_paid_title from worker w
join title t on w.worker_id = t.worker_ref_id
where  w. salary = (select max(salary) from worker) 
