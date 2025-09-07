/*

Find the total number of downloads for paying and non-paying users by date. Include only records where non-paying customers have more downloads than paying customers. The output should be sorted by earliest
date first and contain 3 columns date, non-paying downloads,
paying downloads. Hint: In Oracle you should use "date" when referring to date column (reserved keyword).
*/

WITH cte AS (
    SELECT 
        d.date,
        a.paying_customer,
        SUM(d.downloads) AS download_count
    FROM ms_user_dimension u
    JOIN ms_acc_dimension a 
        ON u.acc_id = a.acc_id
    JOIN ms_download_facts d 
        ON u.user_id = d.user_id
    GROUP BY d.date, a.paying_customer
),
cte2 AS (
    SELECT 
        date,
        SUM(CASE WHEN paying_customer = 'no'  THEN download_count ELSE 0 END) AS non_paying,
        SUM(CASE WHEN paying_customer = 'yes' THEN download_count ELSE 0 END) AS paying
    FROM cte
    GROUP BY date
)
SELECT *
FROM cte2
WHERE non_paying > paying
ORDER BY date;
