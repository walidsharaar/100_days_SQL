/*
Find the most profitable company from the financial sector. Output the result along with the continent.
*/




select company,continent from forbes_global_2010_2014 
where sector='Financials' and profits = (select max(profits) from forbes_global_2010_2014  )




--Alternative
--1.
select company,continent,sum(profits) as total_profits from forbes_global_2010_2014 
where sector='Financials'
group by company,continent
order by sum(profits) desc
limit 1

--2.
WITH max_financials AS (
    SELECT MAX(profits) AS max_profit
    FROM forbes_global_2010_2014
    WHERE sector = 'Financials'
)
SELECT company, continent
FROM forbes_global_2010_2014 f
JOIN max_financials m
  ON f.profits = m.max_profit
WHERE f.sector = 'Financials';

--3.
