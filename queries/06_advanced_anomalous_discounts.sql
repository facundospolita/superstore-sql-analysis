-- 6. Products with anomalous discount rates (95th percentile+)

WITH Discount_By_Product AS (
    SELECT
        `Product ID` AS product_id,
        `Product Name` AS product_name,
        AVG(Discount) AS avg_discount,
        SUM(Profit) AS total_profit
    FROM ventas
    GROUP BY product_id, product_name
),
Anomaly_Ranking AS (
    SELECT *,
        PERCENT_RANK() OVER (ORDER BY avg_discount) AS discount_percentile
    FROM Discount_By_Product
)
SELECT
    *,
    CASE
        WHEN total_profit < 0 THEN 'CRITICAL LOSS'
        WHEN total_profit < 100 THEN 'Low Margin'
        ELSE 'Profitable despite discount'
    END AS profitability_status
FROM Anomaly_Ranking
WHERE discount_percentile >= 0.95
ORDER BY total_profit ASC;
