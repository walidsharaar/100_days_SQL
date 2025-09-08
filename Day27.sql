/*
You are given a set of projects and employee data. Each project has a name, a budget, and a specific duration, while each employee has an annual salary and may be assigned to one or more projects for particular periods. 
The task is to identify which projects are overbudget. A project is considered overbudget if the prorated cost of all employees assigned to it exceeds the project’s budget.

To solve this, you must prorate each employee's annual salary based on the exact period they work on a given project, relative to a full year.
For example, if an employee works on a six-month project, only half of their annual salary should be attributed to that project. Sum these prorated salary amounts for all employees assigned to
a project and compare the total with the project’s budget.

Your output should be a list of overbudget projects, where each entry includes the project’s name, its budget, and the total prorated employee expenses for that project. T
he total expenses should be rounded up to the nearest dollar. Assume all years have 365 days and disregard leap years.

*/
