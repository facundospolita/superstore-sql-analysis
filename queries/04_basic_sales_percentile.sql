-- 4. 90th Percentile of sales by category
-- Uses: PERCENT_RANK() to identify the top 10% of products

WITH Sales_By_Product AS (
    SELECT
        Category AS category,
        `Product Name` AS product_name,
        SUM(Sales) AS total_sales
    FROM ventas
    GROUP BY category, product_name
),
Percentile_Calculation AS (
    SELECT *,
        PERCENT_RANK() OVER (PARTITION BY category ORDER BY total_sales) AS percentile
    FROM Sales_By_Product
)
SELECT * FROM Percentile_Calculation
WHERE percentile >= 0.9
ORDER BY category, percentile DESC;
