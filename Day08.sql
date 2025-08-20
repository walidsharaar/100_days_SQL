/*
Find the number of workers by department who joined on or after April 1, 2014.
Output the department name along with the corresponding number of workers.
Sort the results based on the number of workers in descending order.
*/



select department, count(worker_id)
from worker
where joining_date>'2014-04-01'
group by department
