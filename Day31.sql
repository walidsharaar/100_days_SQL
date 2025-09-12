/*
Find the number of times each word appears in the contents column across all rows in the google_file_store dataset. Output two columns: word and occurrences.
*/

select * from google_file_store;

WITH tokens AS (
    SELECT 
        LOWER(word) AS word
    FROM google_file_store,
         regexp_split_to_table(contents, '\s+') AS word
)
SELECT 
    word,
    COUNT(*) AS occurrences
FROM tokens
WHERE word <> ''
GROUP BY word
ORDER BY occurrences DESC, word;
