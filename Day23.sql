/*
Calculate each user's average session time, where a session is defined as the time difference between a page_load and a page_exit. Assume each user has only one session per day. 
If there are multiple page_load or page_exit events on the same day, use only the latest page_load and the earliest page_exit, 
ensuring the page_load occurs before the page_exit. Output the user_id and their average session time.
*/


WITH events AS (
    SELECT
        user_id,
        DATE(timestamp) AS session_date,
        action,
        timestamp
    FROM facebook_web_log
    WHERE action IN ('page_load', 'page_exit')
),
paired AS (
    SELECT
        user_id,
        session_date,
        MAX(CASE WHEN action = 'page_load' THEN timestamp END)  AS latest_load,
        MIN(CASE WHEN action = 'page_exit' THEN timestamp END)  AS earliest_exit
    FROM events
    GROUP BY user_id, session_date
),
valid_sessions AS (
    SELECT
        user_id,
        session_date,
        EXTRACT(EPOCH FROM (earliest_exit - latest_load)) AS session_seconds
    FROM paired
    WHERE latest_load IS NOT NULL
      AND earliest_exit IS NOT NULL
      AND latest_load < earliest_exit
)
SELECT
    user_id,
    AVG(session_seconds) AS avg_session_duration
FROM valid_sessions
GROUP BY user_id
ORDER BY user_id;


--Alternative
WITH flagged AS (
    SELECT
        user_id,
        DATE(timestamp) AS session_date,
        action,
        timestamp,
        MAX(CASE WHEN action = 'page_load' THEN timestamp END)
            OVER (PARTITION BY user_id, DATE(timestamp)) AS latest_load,
        MIN(CASE WHEN action = 'page_exit' THEN timestamp END)
            OVER (PARTITION BY user_id, DATE(timestamp)) AS earliest_exit
    FROM facebook_web_log
    WHERE action IN ('page_load', 'page_exit')
),
valid_sessions AS (
    SELECT DISTINCT
        user_id,
        session_date,
        EXTRACT(EPOCH FROM (earliest_exit - latest_load)) AS session_seconds
    FROM flagged
    WHERE latest_load IS NOT NULL
      AND earliest_exit IS NOT NULL
      AND latest_load < earliest_exit
)
SELECT
    user_id,
    AVG(session_seconds) AS avg_session_duration
FROM valid_sessions
GROUP BY user_id
ORDER BY user_id;
