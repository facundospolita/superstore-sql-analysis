---------------------------------------------------------------------------------
-- BONUS: INTEGRAL REPORT (Master Query for Power BI)
---------------------------------------------------------------------------------
WITH Sales_Metrics AS (
    SELECT
        DATE_FORMAT(order_date_formatted, '%Y-%m') AS period,
        Category AS category,
        SUM(Sales) AS monthly_sales,
        SUM(Profit) AS monthly_profit,
        COUNT(DISTINCT `Order ID`) AS order_count -- orders per category (an order can appear in several categories)
    FROM ventas
    GROUP BY period, category
),
Monthly_Customers AS (
    SELECT DISTINCT
        DATE_FORMAT(order_date_formatted, '%Y-%m') AS period,
        `Customer ID` AS customer_id
    FROM ventas
),
Churn_Calculation AS (
    SELECT
        t1.period AS reference_period,
        COUNT(*) AS active_customers,                          -- customers who bought in the month
        SUM(t2.customer_id IS NULL) AS churn_count,            -- of those, who did not buy the next month
        ROUND(SUM(t2.customer_id IS NULL) / COUNT(*), 4) AS churn_rate
    FROM Monthly_Customers t1
    LEFT JOIN Monthly_Customers t2
        ON t1.customer_id = t2.customer_id
        AND t2.period = DATE_FORMAT(STR_TO_DATE(CONCAT(t1.period, '-01'), '%Y-%m-%d') + INTERVAL 1 MONTH, '%Y-%m')
    -- The last month of the dataset has no "next month", so it would count as 100% churn
    WHERE t1.period < (SELECT MAX(period) FROM Monthly_Customers)
    GROUP BY t1.period
),
Orders_Global AS (
    -- Distinct orders per month across all categories (use this for total orders KPIs)
    SELECT
        DATE_FORMAT(order_date_formatted, '%Y-%m') AS period,
        COUNT(DISTINCT `Order ID`) AS global_order_count
    FROM ventas
    GROUP BY period
),
Alert_Products AS (
    SELECT
        category,
        COUNT(*) AS risk_product_count
    FROM (
        SELECT
            Category AS category,
            PERCENT_RANK() OVER (PARTITION BY Category ORDER BY AVG(Discount)) AS p_rank
        FROM ventas
        GROUP BY Category, `Product Name`
    ) AS sub
    WHERE p_rank >= 0.95
    GROUP BY category
)
SELECT
    v.period,
    v.category,
    v.monthly_sales,
    v.monthly_profit,
    v.order_count,
    o.global_order_count,
    c.active_customers,
    c.churn_count AS global_monthly_churn,
    c.churn_rate AS global_monthly_churn_rate,
    r.risk_product_count
FROM Sales_Metrics v
LEFT JOIN Churn_Calculation c ON v.period = c.reference_period
LEFT JOIN Orders_Global o ON v.period = o.period
LEFT JOIN Alert_Products r ON v.category = r.category
ORDER BY v.period DESC, v.category;
