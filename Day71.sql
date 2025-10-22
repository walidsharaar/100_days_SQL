/*
For the video (or videos) that received the most user flags, how many of these flags were reviewed by YouTube? Output the video ID and the corresponding number of reviewed flags.  Ignore flags that do not have a corresponding flag_id.
*/



WITH top_flags AS (
  SELECT 
    u.video_id,
    COUNT(*) AS cnt
  FROM user_flags u
  WHERE u.flag_id IS NOT NULL
  GROUP BY u.video_id
),
video_info AS (
  SELECT 
    video_id
  FROM top_flags
  WHERE cnt = (SELECT MAX(cnt) FROM top_flags)
)
SELECT 
  u.video_id,
  COUNT(CASE WHEN f.reviewed_by_yt = TRUE THEN 1 END) AS reviewed_flags
FROM user_flags u
JOIN flag_review f 
  ON u.flag_id = f.flag_id
WHERE u.video_id IN (SELECT video_id FROM video_info)
  AND u.flag_id IS NOT NULL
GROUP BY u.video_id;
