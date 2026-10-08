-- 1. Monthly sales with % change vs. previous month
WITH Monthly_Metrics AS (
    SELECT
        DATE_FORMAT(order_date_formatted, '%Y-%m') AS period,
        SUM(Sales) AS total_sales,
        SUM(Profit) AS total_profit,
        ROUND(SUM(Profit) / SUM(Sales) * 100, 2) AS profit_margin_pct
    FROM ventas
    GROUP BY period
)
SELECT
    period,
    total_sales,
    total_profit,
    profit_margin_pct,
    -- Sales growth vs. previous month (%)
    ROUND(
        ((total_sales - LAG(total_sales) OVER (ORDER BY period)) /
        LAG(total_sales) OVER (ORDER BY period)) * 100, 2
    ) AS sales_growth_pct,
    -- Margin difference in percentage points
    ROUND(profit_margin_pct - LAG(profit_margin_pct) OVER (ORDER BY period), 2) AS margin_diff_points
FROM Monthly_Metrics
ORDER BY period DESC;
