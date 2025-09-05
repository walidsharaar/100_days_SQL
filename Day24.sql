/*
Calculate the friend acceptance rate for each date when friend requests were sent. A request is sent if action = 'sent', and accepted if action = 'accepted'. If a request is not accepted, it will not be recorded in the table as accepted. 
The output will only include dates where requests were sent and at least one of them was accepted, 
as the acceptance rate can only be calculated for those dates. Show the results ordered from the earliest to the latest date.
*/
SELECT * FROM fb_friend_requests;

WITH cteSent AS (
    SELECT user_id_sender, user_id_receiver, date
    FROM fb_friend_requests
    WHERE action = 'sent'
),
cteAccepted AS (
    SELECT user_id_sender, user_id_receiver, date
    FROM fb_friend_requests
    WHERE action = 'accepted'
)
SELECT 
    cteSent.date,
   COUNT(DISTINCT cteSent.user_id_sender) AS sent_count,
    COUNT(DISTINCT cteAccepted.user_id_receiver) AS accepted_count,
    COUNT(DISTINCT cteAccepted.user_id_receiver)::float 
      / NULLIF(COUNT(DISTINCT cteSent.user_id_sender), 0) AS acceptance_rate
FROM cteSent
LEFT JOIN cteAccepted 
    ON cteSent.user_id_sender = cteAccepted.user_id_sender
   AND cteSent.user_id_receiver = cteAccepted.user_id_receiver
GROUP BY cteSent.date
ORDER BY cteSent.date;
