/*
Identify client segments (by country and account_type) with highest churn risk over the last 6 months.

For each segment, calculate:

Total number of active and churned clients.

Average retention offer value for churned clients.

Churn Rate = churned_clients / total_clients.

Then rank segments by highest churn rate, and flag those where avg_retention_offer_value > 50 but churn rate still > 0.4, meaning retention spending is not effectively reducing churn.
*/
