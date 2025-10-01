/*
Of all accounts with status records on January 10th, 2020, calculate the ratio of those with 'closed' status.
*/

SELECT 
    AVG(CASE WHEN status = 'closed' THEN 1.0 ELSE 0 END) AS closed_ratio
FROM fb_account_status
WHERE status_date = '2020-01-10';
