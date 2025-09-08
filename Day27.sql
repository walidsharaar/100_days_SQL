/*
You are given a set of projects and employee data. Each project has a name, a budget, and a specific duration, while each employee has an annual salary and may be assigned to one or more projects for particular periods. 
The task is to identify which projects are overbudget. A project is considered overbudget if the prorated cost of all employees assigned to it exceeds the project’s budget.

To solve this, you must prorate each employee's annual salary based on the exact period they work on a given project, relative to a full year.
For example, if an employee works on a six-month project, only half of their annual salary should be attributed to that project. Sum these prorated salary amounts for all employees assigned to
a project and compare the total with the project’s budget.

Your output should be a list of overbudget projects, where each entry includes the project’s name, its budget, and the total prorated employee expenses for that project. T
he total expenses should be rounded up to the nearest dollar. Assume all years have 365 days and disregard leap years.

*/


SELECT 
    p.title,
    p.budget,
    CEILING(SUM((DATEDIFF(empp.end_date, empp.start_date) * emp.salary) / 365)) AS prorated_employee_expense
FROM linkedin_projects p
INNER JOIN linkedin_emp_projects empp
    ON p.id = empp.project_id
INNER JOIN linkedin_employees emp
    ON emp.id = empp.emp_id
GROUP BY p.title, p.budget
HAVING CEILING(SUM((DATEDIFF(empp.end_date, empp.start_date) * emp.salary) / 365)) > p.budget
ORDER BY p.title;



---Alternative

WITH employee_fraction AS (
  SELECT
    p.id   AS project_id,
    p.title,
    p.budget,
    ((DATE(p.end_date) - DATE(p.start_date)) * emp.salary) / 365.0 AS employee_fraction_cost
  FROM linkedin_projects      p
  JOIN linkedin_emp_projects empp ON p.id   = empp.project_id
  JOIN linkedin_employees    emp  ON emp.id = empp.emp_id
),
project_window AS (
  SELECT
    project_id,
    title,
    budget,
    SUM(employee_fraction_cost) OVER (PARTITION BY project_id) AS project_sum_raw,
    ROW_NUMBER() OVER (PARTITION BY project_id ORDER BY project_id)   AS rn
  FROM employee_fraction
)
SELECT
  title,
  budget,
  CEIL(project_sum_raw)::bigint AS prorated_employee_expense
FROM project_window
WHERE rn = 1
  AND CEIL(project_sum_raw) > budget
ORDER BY title;

