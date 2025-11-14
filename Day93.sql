/*
Your company manages a multi-warehouse distribution network for a retail chain.
The operations director has asked you to identify warehouses showing early signs of supply-chain inefficiency, particularly those with rising stockouts and increasing average delivery delays.
You need to base your analysis on operational data for the past year.

Goal:
 Find warehouses that show simultaneous negative trends in:
Delivery Delay — average days between delivered_date and expected_delivery_date, increasing for 3 consecutive months
Stockout Rate — percentage of orders where stockout_flag = TRUE, increasing for the same 3-month window
Then, for those warehouses:
Report the average delivery delay and average stockout rate in the latest month.
Output should include warehouse_id, city, avg_delay_days, avg_stockout_rate.
*/

