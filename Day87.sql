/*
You work as a Senior BI Analyst for a multinational company that wants to understand employee retention and pay fairness.
The HR Director suspects that salary growth and promotion opportunities are linked to employee churn, especially across departments and job levels.

Find out which departments have the highest weighted churn risk, where weight is based on both salary growth decline and performance drop.

A churned employee is defined as:

Left the company after Q4,

Was active in Q3,

And had a decrease in average salary growth or performance compared to Q2–Q3 period.
*/

WITH salary_change AS (
  SELECT
    employee_id,
    department,
    job_level,
    quarter,
    salary,
    LAG(salary) OVER (PARTITION BY employee_id ORDER BY quarter) AS prev_salary,
    performance_score,
    LAG(performance_score) OVER (PARTITION BY employee_id ORDER BY quarter) AS prev_perf,
    left_company
  FROM employee_performance
),
growth_calc AS (
  SELECT
    employee_id,
    department,
    job_level,
    quarter,
    ((salary - prev_salary) * 1.0 / NULLIF(prev_salary, 0)) AS salary_growth,
    (performance_score - prev_perf) AS performance_diff,
    left_company
  FROM salary_change
  WHERE prev_salary IS NOT NULL
),
q3_q4_churners AS (
  SELECT DISTINCT g.employee_id, g.department
  FROM growth_calc g
  WHERE g.quarter = 'Q4' AND g.left_company = 1
  AND EXISTS (
    SELECT 1 FROM growth_calc g2
    WHERE g2.employee_id = g.employee_id AND g2.quarter = 'Q3'
  )
),
declines AS (
  SELECT 
    g.department,
    g.employee_id,
    AVG(CASE WHEN quarter IN ('Q3', 'Q4') THEN performance_diff END) AS avg_perf_diff,
    AVG(CASE WHEN quarter IN ('Q3', 'Q4') THEN salary_growth END) AS avg_salary_growth
  FROM growth_calc g
  JOIN q3_q4_churners c ON g.employee_id = c.employee_id
  GROUP BY g.department, g.employee_id
  HAVING AVG(CASE WHEN quarter IN ('Q3', 'Q4') THEN performance_diff END) < 0
),
department_summary AS (
  SELECT 
    department,
    COUNT(DISTINCT employee_id) AS churned_employees,
    ABS(AVG(avg_perf_diff)) AS avg_performance_drop,
    ABS(AVG(avg_salary_growth)) AS avg_salary_growth_drop
  FROM declines
  GROUP BY department
)
SELECT 
  department,
  churned_employees,
  ROUND(avg_performance_drop, 2) AS avg_performance_drop,
  ROUND(avg_salary_growth_drop, 2) AS avg_salary_growth_drop,
  ROUND((avg_performance_drop * 0.6 + avg_salary_growth_drop * 0.4), 3) AS weighted_churn_score
FROM department_summary
ORDER BY weighted_churn_score DESC;


--ALTERNATIVE

WITH prev_quarter AS (
  SELECT 
    e1.employee_id,
    e1.department,
    e1.job_level,
    e1.quarter,
    e1.salary AS curr_salary,
    e2.salary AS prev_salary,
    e1.performance_score AS curr_perf,
    e2.performance_score AS prev_perf,
    e1.left_company
  FROM employee_performance e1
  JOIN employee_performance e2 
    ON e1.employee_id = e2.employee_id
   AND e1.quarter > e2.quarter
   AND (
        (e1.quarter = 'Q2' AND e2.quarter = 'Q1') OR
        (e1.quarter = 'Q3' AND e2.quarter = 'Q2') OR
        (e1.quarter = 'Q4' AND e2.quarter = 'Q3')
       )
),
growth_calc AS (
  SELECT 
    employee_id,
    department,
    ((curr_salary - prev_salary) * 1.0 / NULLIF(prev_salary, 0)) AS salary_growth,
    (curr_perf - prev_perf) AS performance_diff,
    quarter,
    left_company
  FROM prev_quarter
),
q3_q4_churners AS (
  SELECT DISTINCT g.employee_id, g.department
  FROM growth_calc g
  WHERE g.quarter = 'Q4' AND g.left_company = 1
  AND EXISTS (
    SELECT 1 FROM growth_calc g2
    WHERE g2.employee_id = g.employee_id AND g2.quarter = 'Q3'
  )
),
declines AS (
  SELECT 
    g.department,
    g.employee_id,
    AVG(CASE WHEN quarter IN ('Q3', 'Q4') THEN performance_diff END) AS avg_perf_diff,
    AVG(CASE WHEN quarter IN ('Q3', 'Q4') THEN salary_growth END) AS avg_salary_growth
  FROM growth_calc g
  JOIN q3_q4_churners c ON g.employee_id = c.employee_id
  GROUP BY g.department, g.employee_id
  HAVING AVG(CASE WHEN quarter IN ('Q3', 'Q4') THEN performance_diff END) < 0
),
department_summary AS (
  SELECT 
    department,
    COUNT(DISTINCT employee_id) AS churned_employees,
    ABS(AVG(avg_perf_diff)) AS avg_performance_drop,
    ABS(AVG(avg_salary_growth)) AS avg_salary_growth_drop
  FROM declines
  GROUP BY department
)
SELECT 
  department,
  churned_employees,
  ROUND(avg_performance_drop, 2) AS avg_performance_drop,
  ROUND(avg_salary_growth_drop, 2) AS avg_salary_growth_drop,
  ROUND((avg_performance_drop * 0.6 + avg_salary_growth_drop * 0.4), 3) AS weighted_churn_score
FROM department_summary
ORDER BY weighted_churn_score DESC;
