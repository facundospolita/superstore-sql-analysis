-- 7. Customer Risk Scoring (RFM Based)
WITH RFM_Metrics AS (
	SELECT
		`Customer ID` AS customer_id,
		`Customer Name` AS customer_name,
		MAX(order_date_formatted) AS last_purchase,
		COUNT(DISTINCT `Order ID`) AS frequency,
		AVG(Sales) AS avg_sales
	FROM ventas
	GROUP BY customer_id, customer_name
),
Days_Calculation AS (
    SELECT *,
        DATEDIFF((SELECT MAX(order_date_formatted) FROM ventas), last_purchase) AS days_since_last_purchase
    FROM RFM_Metrics
),
Points_Assignment AS (
	SELECT *,
        -- Recency Points
		CASE
			WHEN days_since_last_purchase > 90 THEN 50
			WHEN days_since_last_purchase > 30 THEN 20
			ELSE 0
		END AS r_points,
        -- Frequency Points
		CASE
			WHEN frequency = 1 THEN 30
			WHEN frequency < 3 THEN 10
			ELSE 0
		END AS f_points,
        -- Monetary Points
		CASE
			WHEN avg_sales < 50 THEN 20
			ELSE 0
		END AS m_points
    FROM Days_Calculation
),
Final_Score AS (
	SELECT *,
		(r_points + f_points + m_points) AS total_score
	FROM Points_Assignment
)
SELECT *,
    CASE
        WHEN total_score > 60 THEN 'HIGH RISK'
        WHEN total_score >= 30 THEN 'MEDIUM RISK'
        ELSE 'LOW RISK'
    END AS risk_classification
FROM Final_Score
ORDER BY total_score DESC;
