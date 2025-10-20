
/*
Find the genre of the person with the most number of oscar winnings.
If there are more than one person with the same number of oscar wins, return the first one in alphabetic order based on their name. Use the names as keys when joining the tables.
*/

SELECT top_genre
FROM nominee_information ni
JOIN oscar_nominees om
  ON ni.name = om.nominee
WHERE om.winner = TRUE
GROUP BY top_genre
ORDER BY COUNT(*) DESC, top_genre ASC
LIMIT 1;
