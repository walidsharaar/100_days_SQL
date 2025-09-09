/*
Find the email activity rank for each user. Email activity rank is defined by the total number of emails sent. The user with the highest number of emails sent will have a rank of 1, and so on. Output the user, total emails,
and their activity rank.


•	Order records first by the total emails in descending order.
•	Then, sort users with the same number of emails in alphabetical order by their username.
•	In your rankings, return a unique value (i.e., a unique rank) even if multiple users have the same number of emails.
*/

SELECT
    user_id,
    total_emails,
    ROW_NUMBER() OVER (
        ORDER BY total_emails DESC, user_id ASC
    ) AS activity_rank
FROM (
    SELECT 
        from_user AS user_id,
        COUNT(*) AS total_emails
    FROM google_gmail_emails
    GROUP BY from_user
) AS t
ORDER BY activity_rank;


---Alternative



SELECT 
    from_user,
    COUNT(*) AS email_sent,
    ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC, from_user ASC) AS rk
FROM google_gmail_emails
GROUP BY from_user;
