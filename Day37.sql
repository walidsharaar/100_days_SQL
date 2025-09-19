/*
Find the Olympics with the highest number of unique athletes. The Olympics game is a combination of the year and the season, and is found in the games column. Output the Olympics along with the corresponding number of athletes. 
The id column uniquely identifies an athlete.
*/


SELECT 
    games, 
    COUNT(DISTINCT id) AS athlete_count
FROM olympics_athletes_events
GROUP BY games
ORDER BY athlete_count DESC
LIMIT 1;


--Alternativve

SELECT games, athlete_count
FROM (
    SELECT 
        games,
        COUNT(DISTINCT id) AS athlete_count,
        RANK() OVER (ORDER BY COUNT(DISTINCT id) DESC) AS rnk
    FROM olympics_athletes_events
    GROUP BY games
) t
WHERE rnk = 1;

