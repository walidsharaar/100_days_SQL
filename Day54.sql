/*
The election is conducted in a city and everyone can vote for one or more candidates, or choose not to vote at all. Each person has 1 vote so if they vote for multiple candidates, 
their vote gets equally split across these candidates. For example, if a person votes for 2 candidates, these candidates receive an equivalent of 0.5 vote each. Some voters have chosen not to vote, 
which explains the blank entries in the dataset.
Find out who got the most votes and won the election. Output the name of the candidate or multiple names in case of a tie.
To avoid issues with a floating-point error you can round the number of votes received by a candidate to 3 decimal places.

*/

WITH weighted_votes AS (
    SELECT
        candidate,
        ROUND(1.0 / COUNT(*) OVER (PARTITION BY voter), 3) AS vote_weight
    FROM voting_results
    WHERE candidate IS NOT NULL
),
candidate_totals AS (
    SELECT
        candidate,
        ROUND(SUM(vote_weight), 3) AS total_votes
    FROM weighted_votes
    GROUP BY candidate
),
ranked AS (
    SELECT
        candidate,
        RANK() OVER (ORDER BY total_votes DESC) AS rnk
    FROM candidate_totals
)
SELECT candidate
FROM ranked
WHERE rnk = 1;
