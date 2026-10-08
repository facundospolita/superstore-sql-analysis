-- 2. Top 3 products per category
WITH Sales_By_Product AS (
    SELECT
        Category AS category,
        `Product Name` AS product_name,
        SUM(Sales) AS total_sales
    FROM ventas
    GROUP BY Category, `Product Name`
),
Product_Ranking AS (
    SELECT
        category,
        product_name,
        total_sales,
        RANK() OVER (PARTITION BY category ORDER BY total_sales DESC) AS ranking
    FROM Sales_By_Product
)
SELECT * FROM Product_Ranking
WHERE ranking <= 3;
