/*
You’re analyzing HR data for a multinational company with offices in multiple countries, departments, and job roles. The company wants to identify departments with potential salary imbalance and high attrition risk.
For each department and country, calculate the average salary of retained employees vs. employees who left during the last 12 months.
Then, compute a Retention–to–Attrition Salary Ratio (avg_retained_salary / avg_left_salary) to detect imbalances.

Finally, rank departments by the highest imbalance (ratio < 0.8 or > 1.2) — showing possible over/underpayment risk areas.
*/

WITH status_cte AS (
  SELECT 
    employee_id,
    department,
    country,
    salary,
    CASE 
      WHEN termination_date IS NULL THEN 'retained'
      WHEN termination_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH) THEN 'churned'
      ELSE 'inactive_old'
    END AS emp_status
  FROM employee_data
),
agg_cte AS (
  SELECT 
    department,
    country,
    AVG(CASE WHEN emp_status = 'retained' THEN salary END) AS avg_retained_salary,
    AVG(CASE WHEN emp_status = 'churned' THEN salary END) AS avg_left_salary
  FROM status_cte
  GROUP BY department, country
),
ratio_cte AS (
  SELECT 
    department,
    country,
    avg_retained_salary,
    avg_left_salary,
    ROUND(avg_retained_salary / NULLIF(avg_left_salary, 0), 2) AS retention_salary_ratio
  FROM agg_cte
)
SELECT *
FROM ratio_cte
WHERE retention_salary_ratio < 0.8 OR retention_salary_ratio > 1.2
ORDER BY retention_salary_ratio DESC;

--Alternative
WITH retained AS (
  SELECT department, country, AVG(salary) AS avg_retained_salary
  FROM employee_data
  WHERE termination_date IS NULL
  GROUP BY department, country
),
churned AS (
  SELECT department, country, AVG(salary) AS avg_left_salary
  FROM employee_data
  WHERE termination_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
  GROUP BY department, country
),
joined AS (
  SELECT 
    r.department,
    r.country,
    r.avg_retained_salary,
    c.avg_left_salary,
    ROUND(r.avg_retained_salary / NULLIF(c.avg_left_salary, 0), 2) AS retention_salary_ratio
  FROM retained r
  JOIN churned c
  ON r.department = c.department AND r.country = c.country
)
SELECT *
FROM joined
WHERE retention_salary_ratio < 0.8 OR retention_salary_ratio > 1.2
ORDER BY retention_salary_ratio DESC;



