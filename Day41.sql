/*
Find the average total compensation based on employee titles and gender. Total compensation is calculated by adding both the salary and bonus of each employee. However, not every employee receives a bonus so disregard employees without bonuses in your calculation. Employee can receive more than one bonus.
Output the employee title, gender (i.e., sex), along with the average total compensation.
*/

WITH total_bonus AS (
    SELECT worker_ref_id, SUM(bonus) AS bonus
    FROM sf_bonus
    GROUP BY worker_ref_id
)
SELECT 
    e.employee_title, 
    e.sex,
    AVG(e.salary + COALESCE(tb.bonus, 0)) AS avg_compensation
FROM sf_employee e
 JOIN total_bonus tb
    ON e.id = tb.worker_ref_id
GROUP BY e.employee_title, e.sex
ORDER BY e.employee_title, e.sex;
