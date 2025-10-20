/*
You are given a table of tennis players and their matches that they could either win (W) or lose (L). Find the longest streak of wins. A streak is a set of consecutive won matches of one player. The streak ends once a player 
loses their next match. Output the ID of the player or players and the length of the streak.
*/



WITH base_tbl AS (
    SELECT 
        player_id,
        match_result,
        ROW_NUMBER() OVER(PARTITION BY player_id ORDER BY match_date) AS game_number,
        ROW_NUMBER() OVER(PARTITION BY player_id ORDER BY match_date) 
          - ROW_NUMBER() OVER(PARTITION BY player_id, match_result ORDER BY match_date) AS grp_id
    FROM players_results
),
streak_tbl AS (
    SELECT 
        player_id,
        grp_id,
        COUNT(*) AS streak_len
    FROM base_tbl
    WHERE match_result = 'W'
    GROUP BY player_id, grp_id
),
max_streak AS (
    SELECT MAX(streak_len) AS max_len
    FROM streak_tbl
)
SELECT 
    player_id,
    streak_len
FROM streak_tbl
WHERE streak_len = (SELECT max_len FROM max_streak);
