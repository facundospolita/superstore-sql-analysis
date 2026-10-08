-- 8. TOP 10 distinct Sub-Categories purchased together
-- Technique: Self-join on Order ID with alphabetical filtering to avoid duplicates
-- Note: COUNT(DISTINCT Order ID) counts orders, not rows. With COUNT(*), an order
-- with several lines of the same sub-category would be counted more than once.
SELECT
    v1.`Sub-Category` AS sub_category_a,
    v2.`Sub-Category` AS sub_category_b,
    COUNT(DISTINCT v1.`Order ID`) AS orders_together
FROM ventas v1
INNER JOIN ventas v2 ON v1.`Order ID` = v2.`Order ID`
WHERE v1.`Sub-Category` < v2.`Sub-Category` -- Prevents self-pairing and mirror duplicates
GROUP BY sub_category_a, sub_category_b
ORDER BY orders_together DESC
LIMIT 10;
