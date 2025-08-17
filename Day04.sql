/*
Find the last time each bike was in use. Output both the bike number and the date-timestamp of the bike's last use (i.e., the date-time the bike was returned). Order the results by bikes that were most recently used.
*/

select bike_number, max(end_time) as last_used from dc_bikeshare_q1_2012
group by bike_number
order by max(end_time) desc


--Alternatives
--1.
SELECT
    bike_number,
    start_time,
    end_time,
    start_station,
    end_station,
    duration
FROM (
    SELECT
        bike_number,
        start_time,
        end_time,
        start_station,
        end_station,
        duration,
        ROW_NUMBER() OVER (
            PARTITION BY bike_number
            ORDER BY end_time DESC
        ) AS rn
    FROM dc_bikeshare_q1_2012
) t
WHERE rn = 1
ORDER BY end_time DESC;

--2.
WITH ranked_trips AS (
    SELECT
        bike_number,
        start_time,
        end_time,
        start_station,
        end_station,
        duration,
        ROW_NUMBER() OVER (
            PARTITION BY bike_number
            ORDER BY end_time DESC
        ) AS rn
    FROM dc_bikeshare_q1_2012
)
SELECT
    bike_number,
    start_time,
    end_time,
    start_station,
    end_station,
    duration
FROM ranked_trips
WHERE rn = 1
ORDER BY end_time DESC;

