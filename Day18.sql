/*
Find the inspection date and risk category (pe_description) of facilities named 'STREET CHURROS' that received a score below 95.


*/

select * from los_angeles_restaurant_health_inspections;

select distinct activity_date,pe_description
from los_angeles_restaurant_health_inspections
where score < 95 and facility_name='STREET CHURROS'
