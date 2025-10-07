/*
Which user flagged the most distinct videos that ended up approved by YouTube? Output, in one column, their full name or names in case of a tie. In the user's full name, include a space between the first and the last name.
*/

WITH approved_flags AS (
    SELECT 
        f.user_firstname,
        f.user_lastname,
        COUNT(DISTINCT f.video_id) AS distinct_approved_videos
    FROM user_flags f
    JOIN flag_review r
      ON f.flag_id = r.flag_id
    WHERE r.reviewed_outcome = 'APPROVED'
    GROUP BY f.user_firstname, f.user_lastname
)
SELECT 
    CONCAT(user_firstname, ' ', user_lastname) AS full_name
FROM (
    SELECT 
        user_firstname,
        user_lastname,
        distinct_approved_videos,
        DENSE_RANK() OVER (ORDER BY distinct_approved_videos DESC) AS rnk
    FROM approved_flags
) ranked
WHERE rnk = 1;

--Alternative

WITH user_votes AS (
    SELECT 
        CONCAT(user_firstname, ' ', user_lastname) AS full_name,
        COUNT(DISTINCT f.video_id) AS approved_videos
    FROM user_flags f
    JOIN flag_review r
        ON f.flag_id = r.flag_id
    WHERE r.reviewed_outcome = 'APPROVED'
    GROUP BY full_name
)
SELECT full_name
FROM user_votes
WHERE approved_videos = (
    SELECT MAX(approved_videos) FROM user_votes
);
