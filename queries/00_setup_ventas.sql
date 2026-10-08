-- 0. SETUP: adds the `order_date_formatted` column to the `ventas` table used by every other query.
-- Assumes the raw CSV (Sample_Superstore.csv) was imported into superstore.ventas
-- with `Order Date` stored as text (VARCHAR) in m/d/yyyy format.
-- In DBeaver: run each statement on its own (Ctrl+Enter), or the whole script with Alt+X.
USE superstore;

-- Needed only if MySQL Workbench / DBeaver blocks the UPDATE (error 1175, safe update mode)
SET SQL_SAFE_UPDATES = 0;

-- If this fails with "Duplicate column name", the column already exists: skip to the UPDATE.
ALTER TABLE ventas ADD COLUMN order_date_formatted DATE;

UPDATE ventas
SET order_date_formatted = STR_TO_DATE(`Order Date`, '%m/%d/%Y');

-- Sanity check. Expected: 9994 rows, first order 2014-01-03, last order 2017-12-30, 0 null dates
SELECT
    COUNT(*) AS total_rows,
    MIN(order_date_formatted) AS first_order,
    MAX(order_date_formatted) AS last_order,
    SUM(order_date_formatted IS NULL) AS null_dates
FROM ventas;
