/*
Make a report showing the number of survivors and non-survivors by passenger class. Classes are categorized based on the pclass value as:


•	First class: pclass = 1
•	Second class: pclass = 2
•	Third class: pclass = 3


Output the number of survivors and non-survivors by each class.


*/



Select survived , 
sum(case when pclass = 1 then 1 else 0 end ) as first_class,
sum(case when pclass = 2 then 1 else 0 end ) as secong_class,
sum(case when pclass = 3 then 1 else 0 end ) as third_class

from titanic
group by survived
