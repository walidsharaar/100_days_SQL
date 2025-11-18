/*
You work as a BI Engineer for a SaaS product offering monthly and annual subscriptions. Recently, the finance team noticed revenue loss from users who didn’t renew, not because they canceled — but because their payments failed or were never retried.
Your task is to identify potential involuntary churners and compute monthly churn risk trends per plan type.
Question:
Identify users who are at risk of involuntary churn — defined as:
Users whose last subscription ended within the last 60 days
Who have no successful payment after their end_date
But had at least one failed payment attempt after their end date
And their plan was auto-renew = TRUE
Then calculate:
The churn risk count per plan type
The total failed payment amount in that window
The percentage of at-risk users over total users per plan
Finally, list the top 3 plan types with the highest churn risk rate.
*/
