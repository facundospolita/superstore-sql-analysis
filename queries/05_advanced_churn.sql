-- 5. CHURN Analysis (Customers who bought last month but NOT this month)
WITH March_CTE AS (
	SELECT DISTINCT
        `Customer ID` AS customer_id,
        `Customer Name` AS customer_name
	FROM ventas
	WHERE DATE_FORMAT(order_date_formatted, '%Y-%m') = '2017-03'),
April_CTE AS (
	SELECT DISTINCT
        `Customer ID` AS customer_id
	FROM ventas
	WHERE DATE_FORMAT(order_date_formatted, '%Y-%m') = '2017-04')
SELECT
	m.customer_id,
	m.customer_name,
	'2017-04' AS churn_period
FROM March_CTE m
LEFT JOIN April_CTE a ON m.customer_id = a.customer_id
WHERE a.customer_id IS NULL;
