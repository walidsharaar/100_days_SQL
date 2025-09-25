/*
Calculate the percentage of spam posts in all viewed posts by day. A post is considered a spam if a string "spam" is inside keywords of the post. Note that the facebook_posts table stores all posts posted by users. 
The facebook_post_views table is an action table denoting if a user has viewed a post.
*/
SELECT 
    p.post_date, 
    COUNT(CASE WHEN p.post_keywords ILIKE '%spam%' THEN 1 ELSE NULL END) 
        / COUNT(v.post_id)::numeric * 100
FROM facebook_posts AS p
LEFT JOIN facebook_post_views AS v
    ON p.post_id = v.post_id
GROUP BY p.post_date;
