/*Write a query that will calculate the number of shipments per month. The unique key for one shipment is a combination of shipment_id and sub_id. Output the year_month in format YYYY-MM and the number of shipments in that month.*/

SELECT 
    TO_CHAR(shipment_date, 'YYYY-MM') AS year_month,
    COUNT(DISTINCT shipment_id || '-' || sub_id) AS shipments_count
FROM amazon_shipment
GROUP BY TO_CHAR(shipment_date, 'YYYY-MM')
ORDER BY year_month;
