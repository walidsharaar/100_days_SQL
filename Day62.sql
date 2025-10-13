/*
Compare the total number of comments made by users in each country between December 2019 and January 2020. For each month, rank countries by total comments using dense ranking (i.e., avoid gaps between ranks) in descending order.
Then, return the names of the countries whose rank improved from December to January.
*/

WITH dec_ranks AS (
  SELECT 
    u.country,
    DENSE_RANK() OVER (ORDER BY SUM(c.number_of_comments) DESC) AS rnk_dec
  FROM fb_comments_count c
  JOIN fb_active_users u ON c.user_id = u.user_id
  WHERE c.created_at BETWEEN '2019-12-01' AND '2019-12-31'
  GROUP BY u.country
),
jan_ranks AS (
  SELECT 
    u.country,
    DENSE_RANK() OVER (ORDER BY SUM(c.number_of_comments) DESC) AS rnk_jan
  FROM fb_comments_count c
  JOIN fb_active_users u ON c.user_id = u.user_id
  WHERE c.created_at BETWEEN '2020-01-01' AND '2020-01-31'
  GROUP BY u.country
)
SELECT 
  COALESCE(j.country, d.country) AS country
FROM dec_ranks d
FULL JOIN jan_ranks j ON d.country = j.country
WHERE j.rnk_jan < d.rnk_dec;
