/*
You are given a dataset of health inspections that includes details about violations. Each row represents an inspection, and if an inspection resulted in a violation, the violation_id column will contain a value.


Count the total number of violations that occurred at 'Roxanne Cafe' for each year, based on the inspection date. Output the year and the corresponding number of violations in ascending order of the year.
*/


select extract(year from inspection_date) as inspection_year , count(violation_id) as n_violations from sf_restaurant_health_violations
where business_name='Roxanne Cafe'
group by inspection_year
