/*
Find the best-selling item for each month (no need to separate months by year). The best-selling item is determined by the highest total sales amount, calculated as: total_paid = unitprice * quantity. Output the month, description of the item, and the total amount paid.

*/

WITH monthly_sales AS (
  SELECT
    DATE_PART('month', invoicedate) AS month,
    description,
    SUM(unitprice * quantity) AS total_paid,
    RANK() OVER (
      PARTITION BY DATE_PART('month', invoicedate)
      ORDER BY SUM(unitprice * quantity) DESC
    ) AS rnk
  FROM online_retail
  GROUP BY 1, 2
)
SELECT 
  month,
  description,
  total_paid
FROM monthly_sales
WHERE rnk = 1
ORDER BY month;



--Alternative

WITH monthly_sales AS (
  SELECT
    DATE_PART('month', invoicedate) AS month,
    description,
    SUM(unitprice * quantity) AS total_paid,
    ROW_NUMBER() OVER (
      PARTITION BY DATE_PART('month', invoicedate)
      ORDER BY SUM(unitprice * quantity) DESC
    ) AS rn
  FROM online_retail
  GROUP BY 1, 2
)
SELECT
  month,
  description,
  total_paid
FROM monthly_sales
WHERE rn = 1
ORDER BY month;


