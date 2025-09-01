/*
Find the number of employees working in the Admin department who joined in April or later, in any year.


*/

select count(*)
from worker
where department='Admin' and extract(month from joining_date) >= 4
