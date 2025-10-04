/*
You have a dataset that records daily active users for each premium account. A premium account appears in the data every day as long as it remains premium. However, some premium accounts may be temporarily discounted,
meaning they are not actively paying — this is indicated by a final_price of 0.


For each of the first 7 available dates in the dataset, count the number of premium accounts that were actively paying on that day. Then, track how many of those same accounts are still premium and actively paying exactly 7 days later, 
based solely on their status on that 7th day (i.e., both dates must exist in the dataset). Accounts are only counted if they appear in the data on both dates.


Output three columns:
•   The date of initial calculation.
•   The number of premium accounts that were actively paying on that day.
•   The number of those accounts that remain premium and are still paying after 7 days.
*/

SELECT 
    a.entry_date,
    COUNT(a.final_price) AS count_a,
    COUNT(b.final_price) AS count_b
FROM premium_accounts_by_day a
LEFT JOIN premium_accounts_by_day b
    ON a.account_id = b.account_id
   AND (b.entry_date - a.entry_date) = 7
   AND b.final_price > 0
WHERE a.final_price > 0
GROUP BY a.entry_date
ORDER BY a.entry_date
LIMIT 7;
