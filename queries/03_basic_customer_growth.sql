-- 3. Customers with >20% growth vs. previous month
WITH Customer_Metrics AS (
	SELECT
        `Customer ID` AS customer_id,
        `Customer Name` AS customer_name,
        DATE_FORMAT(order_date_formatted, '%Y-%m') AS period,
        SUM(Sales) AS total_sales
    FROM ventas
    GROUP BY customer_id, customer_name, period
),
Growth_Calculation AS (
    SELECT *,
    ROUND((total_sales - LAG(total_sales) OVER (PARTITION BY customer_id ORDER BY period)) / (LAG(total_sales) OVER (PARTITION BY customer_id ORDER BY period)), 2) AS sales_growth
    FROM Customer_Metrics
)
SELECT
    customer_id,
    customer_name,
    period,
    total_sales,
    sales_growth,
    CASE
        WHEN sales_growth > 0.2 THEN 'Over 20% Growth'
        WHEN sales_growth IS NULL THEN 'No Prior History'
        ELSE 'Under 20% Growth'
    END AS growth_category
FROM Growth_Calculation
ORDER BY period DESC;
