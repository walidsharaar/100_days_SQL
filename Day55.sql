/*
For each video, find how many unique users flagged it. A unique user can be identified using the combination of their first name and last name. Do not consider rows in which there is no flag ID.


*/

SELECT 
    video_id,
    COUNT(DISTINCT (user_firstname, user_lastname)) AS unique_user_flags
FROM user_flags
WHERE flag_id IS NOT NULL
GROUP BY video_id;
