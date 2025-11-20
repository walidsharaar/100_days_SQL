/*
The hospital wants to improve vendor performance, budget adherence, and inventory management. They track:
Orders per department with an array of items (item_id, quantity, unit_price, emergency_flag)
Order dates, delivery dates, and payment dates
Budgets per department per month
Vendors associated with each order
Goal / Business Questions:
Compute per-item delivery delays and flag high-risk items (frequent delays or emergency items).
Compute vendor reliability scores combining delivery speed and emergency fulfillment.
Calculate budget vs spend ratio per department per month.
Detect payment delays (difference between delivery date and payment date).
Produce rolling metrics for the last 3 months for each department and vendor.
Identify emergency procurement trends.
*/
