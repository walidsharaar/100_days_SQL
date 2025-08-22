/*
Find songs that have ranked in the top position. Output the track name and the number of times it ranked at the top. Sort your records by the number of times the song was in the top position in descending order.
*/




select trackname, count(position) as times_top1 from spotify_worldwide_daily_song_ranking
where position = 1
group by trackname
order by times_top1 desc


--Alternative
--1.
WITH top1_songs AS (
    SELECT 
        trackname
    FROM spotify_worldwide_daily_song_ranking
    WHERE position = 1
)
SELECT 
    trackname,
    COUNT(*) AS times_top1
FROM top1_songs
GROUP BY trackname
ORDER BY times_top1 DESC;

--2.
SELECT DISTINCT
    trackname,
    COUNT(*) OVER (PARTITION BY trackname) AS times_top1
FROM spotify_worldwide_daily_song_ranking
WHERE position = 1
ORDER BY times_top1 DESC;

--3.
WITH top1_songs AS (
    SELECT 
        trackname
    FROM spotify_worldwide_daily_song_ranking
    WHERE position = 1
)
SELECT DISTINCT
    trackname,
    COUNT(*) OVER (PARTITION BY trackname) AS times_top1
FROM top1_songs
ORDER BY times_top1 DESC;

