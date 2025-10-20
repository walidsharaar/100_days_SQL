/*
Given a table of purchases by date, calculate the month-over-month percentage change in revenue. The output should include the year-month date (YYYY-MM) and percentage change, rounded to the 2nd decimal point, and sorted from the beginning of the year to the end of the year.
The percentage change column will be populated from the 2nd month forward and can be calculated as ((this month's revenue - last month's revenue) / last month's revenue)*100.
*/
WITH monthly_revenue AS (
  SELECT 
    TO_CHAR(created_at, 'YYYY-MM') AS year_month,
    SUM(value) AS total_revenue
  FROM sf_transactions
  GROUP BY 1
)
SELECT 
  year_month,
  ROUND(
    CASE 
      WHEN LAG(total_revenue) OVER (ORDER BY year_month) = 0 THEN NULL
      ELSE ((total_revenue - LAG(total_revenue) OVER (ORDER BY year_month))
            / LAG(total_revenue) OVER (ORDER BY year_month) * 100)
    END
  , 2) AS revenue_diff_pct
FROM monthly_revenue
ORDER BY year_month;
