/*
A hospital tracks:
Orders: Each order has items (array of item_id, quantity, unit_price, emergency_flag)
Departments: Each department has monthly budgets
Vendors: Each vendor has delivery times and reliability scores
Patients / Subscriptions: Some departments have recurring patient visits (billing records)
Payments: Payment date, payment method, delayed or on-time
Historical Demand: For each item per department per month
Objectives:
Detect items with risk of stockout using historical demand, delivery delays, and emergency orders.
Compute budget vs spend ratios per department and flag overspending trends.
Identify vendors at risk: frequent delays + emergency fulfillment.
Predict patient churn for recurring billing patients using:
Missed visits in last 3 months
Delayed payments
Emergency service usage
Compute rolling 3-month average spend, delivery delays, and churn risk scores.
Generate department + vendor + item-level KPIs ready for dashboard visualization.

*/
