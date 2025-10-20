/*
You are given a dataset of actors and the films they have been involved in, including each film's release date and rating. For each actor, calculate the difference between the rating of their most recent film and their average rating across all previous films (the average rating excludes the most recent one).


Return a list of actors along with their average lifetime rating, the rating of their most recent film, and the difference between the two ratings. Round the difference calculation to 2 decimal places. If an actor has only one film, return 0 for the difference and their only film’s rating for both the average and latest rating fields.


*/

WITH recent AS (
    SELECT
        actor_name,
        film_title,
        release_date,
        film_rating,
        ROW_NUMBER() OVER (
            PARTITION BY actor_name
            ORDER BY release_date DESC
        ) AS r
    FROM actor_rating_shift
),
lifetime AS (
    SELECT
        actor_name,
        AVG(film_rating) AS lifetime_avg
    FROM recent
    WHERE r != 1
    GROUP BY actor_name
)
SELECT
    r.actor_name,
    COALESCE(l.lifetime_avg, r.film_rating) AS lifetime_avg,
    r.film_rating AS recent_rating,
    ROUND((r.film_rating - COALESCE(l.lifetime_avg, r.film_rating))::numeric, 2) AS difference
FROM recent AS r 
LEFT JOIN lifetime AS l 
    ON r.actor_name = l.actor_name
WHERE r = 1
ORDER BY r.actor_name;
