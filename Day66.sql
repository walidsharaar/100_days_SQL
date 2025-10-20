/*
Find the top actors based on their average movie rating within the genre they appear in most frequently.
•  For each actor, determine their most frequent genre (i.e., the one they’ve appeared in the most).
•   If there is a tie in genre count, select the genre where the actor has the highest average rating.
•   If there is still a tie in both count and rating, include all tied genres for that actor.


Rank all resulting actor + genre pairs in descending order by their average movie rating.
•  Return all pairs that fall within the top 3 ranks (not simply the top 3 rows), including ties.
•  Do not skip rank numbers — for example, if two actors are tied at rank 1, the next rank is 2 (not 3).
*/

WITH genre_stats AS (
  -- Step 1: For each actor–genre pair, find total movies and average rating
  SELECT 
    actor_name,
    genre,
    COUNT(*) AS movie_count,
    AVG(movie_rating) AS avg_rating
  FROM top_actors_rating
  GROUP BY actor_name, genre
),
main_genre AS (
  -- Step 2: For each actor, pick their most frequent genre
  -- In case of a tie on count, pick the genre with the highest avg rating
  SELECT 
    actor_name,
    genre,
    avg_rating,
    DENSE_RANK() OVER (
      PARTITION BY actor_name 
      ORDER BY movie_count DESC, avg_rating DESC
    ) AS genre_rank
  FROM genre_stats
),
actor_main_genre AS (
  -- Step 3: Keep only the top genre(s) per actor (handle ties)
  SELECT actor_name, genre, avg_rating
  FROM main_genre
  WHERE genre_rank = 1
),
ranked AS (
  -- Step 4: Rank all resulting actor–genre pairs by average rating (descending)
  SELECT 
    actor_name,
    genre,
    avg_rating,
    DENSE_RANK() OVER (ORDER BY avg_rating DESC) AS rank
  FROM actor_main_genre
)
-- Step 5: Return only top 3 ranks (include ties)
SELECT actor_name, genre, avg_rating, rank
FROM ranked
WHERE rank <= 3
ORDER BY rank, avg_rating DESC;
