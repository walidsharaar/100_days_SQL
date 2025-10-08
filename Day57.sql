/*
Identify the IDs of students who scored exactly at the median for the SAT writing section.
*/
WITH cte AS (
    SELECT
        AVG(sat_writing) AS meadian_sat_writing
    FROM (
        SELECT
            student_id,
            sat_writing,
            ROW_NUMBER() OVER (ORDER BY sat_writing ASC, student_id ASC) AS rnk1,
            ROW_NUMBER() OVER (ORDER BY sat_writing DESC, student_id DESC) AS rnk2
        FROM
            sat_scores) AS t1
    WHERE
        ABS(rnk1 - rnk2) <= 1
)

SELECT
    student_id
FROM
    sat_scores
WHERE
    sat_writing = (SELECT meadian_sat_writing FROM cte)
