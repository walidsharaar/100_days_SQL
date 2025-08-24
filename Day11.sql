/*
Find how many times each artist appeared on the Spotify ranking list.
Output the artist name along with the corresponding number of occurrences.
Order records by the number of occurrences in descending order.
*/
select artist,count(stream_date) as n_occurences
from spotify_worldwide_daily_song_ranking
group by artist
order by count(stream_date) desc;

--Atletnative
--1.  This will provide flexibility but not efficiency

WITH artist_counts AS (
    SELECT 
        artist,
        COUNT(*) AS n_occurrences
    FROM spotify_worldwide_daily_song_ranking
    GROUP BY artist
)

SELECT 
    artist,
    n_occurrences,
    RANK() OVER (ORDER BY n_occurrences DESC) AS artist_rank
FROM artist_counts
ORDER BY artist_rank;
