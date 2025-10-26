/*
You are given a dataset that tracks user activity. The dataset includes information about the date of user activity, the account_id associated with the activity, and the user_id of the user performing the activity. Each row in the dataset represents a user’s activity on a specific date for a particular account_id.


Your task is to calculate the monthly retention rate for users for each account_id for December 2020 and January 2021. The retention rate is defined as the percentage of users active in a given month who have activity in any future month.


For instance, a user is considered retained for December 2020 if they have activity in December 2020 and any subsequent month (e.g., January 2021 or later). Similarly, a user is retained for January 2021 if they have activity in January 2021 and any later month (e.g., February 2021 or later).


The final output should include the account_id and the ratio of the retention rate in January 2021 to the retention rate in December 2020 for each account_id. If there are no users retained in December 2020, the retention rate ratio should be set to 0.

*/

WITH user_month_activity AS (
    SELECT
        account_id,
        user_id,
        DATE_TRUNC('month', record_date) AS month,
        MAX(DATE_TRUNC('month', record_date)) OVER (PARTITION BY account_id, user_id) AS last_active
    FROM sf_events
),

monthly_retention AS (
    SELECT
        account_id,
        month,
        COUNT(DISTINCT user_id) AS total_users,
        COUNT(DISTINCT CASE WHEN last_active > month THEN user_id END) AS retained_users
    FROM user_month_activity
    WHERE month IN ('2020-12-01', '2021-01-01')  -- Only Dec 2020 and Jan 2021
    GROUP BY account_id, month
),

final AS (
    SELECT
        jan.account_id,
        CASE 
            WHEN dec.total_users = 0 THEN 0
            ELSE (jan.retained_users::float / jan.total_users) / (dec.retained_users::float / dec.total_users)
        END AS retention
    FROM monthly_retention jan
    LEFT JOIN monthly_retention dec
        ON jan.account_id = dec.account_id
       AND dec.month = '2020-12-01'
    WHERE jan.month = '2021-01-01'
)

SELECT *
FROM final
ORDER BY account_id;

