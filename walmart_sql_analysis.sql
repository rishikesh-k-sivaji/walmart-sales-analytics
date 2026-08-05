-- =============================================================
--   WALMART RETAIL SALES - SQL ANALYSIS
--   Dataset : Walmart Store Sales Forecasting (Kaggle)
--   Tool    : MySQL 8.0
--   Author  : Rishikesh K Sivaji
--
--   This file contains 14 business queries analyzing
--   421,570 weekly sales records across 45 stores
--   and 81 departments from Feb 2010 to Oct 2012.
-- =============================================================

USE walmartdb;


-- =============================================================
-- SECTION 1 : STORE PERFORMANCE
-- Which stores are driving the most revenue?
-- =============================================================

-- Q1. Top 10 stores by total revenue
-- Store 20 consistently comes out on top across all years
SELECT
    Store,
    ROUND(SUM(Weekly_Sales), 2)           AS Total_Sales,
    ROUND(SUM(Weekly_Sales) / 1000000, 2) AS Total_Sales_M
FROM train
GROUP BY Store
ORDER BY Total_Sales DESC
LIMIT 10;


-- Q2. Bottom 10 stores by total revenue
-- Useful for identifying underperforming locations
SELECT
    Store,
    ROUND(SUM(Weekly_Sales), 2)           AS Total_Sales,
    ROUND(SUM(Weekly_Sales) / 1000000, 2) AS Total_Sales_M
FROM train
GROUP BY Store
ORDER BY Total_Sales ASC
LIMIT 10;


-- Q3. Average weekly sales by store type (A, B, C)
-- Type A stores are the largest and generate significantly more revenue
SELECT
    s.Type                        AS Store_Type,
    COUNT(DISTINCT t.Store)       AS Num_Stores,
    ROUND(AVG(t.Weekly_Sales), 2) AS Avg_Weekly_Sales,
    ROUND(SUM(t.Weekly_Sales), 2) AS Total_Sales
FROM train t
JOIN stores s ON t.Store = s.Store
GROUP BY s.Type
ORDER BY Avg_Weekly_Sales DESC;


-- Q4. Store size vs total sales
-- Larger stores tend to generate more revenue
SELECT
    s.Store,
    s.Type,
    s.Size,
    ROUND(SUM(t.Weekly_Sales), 2) AS Total_Sales
FROM train t
JOIN stores s ON t.Store = s.Store
GROUP BY s.Store, s.Type, s.Size
ORDER BY Total_Sales DESC;


-- =============================================================
-- SECTION 2 : DEPARTMENT ANALYSIS
-- Which departments are the biggest revenue contributors?
-- =============================================================

-- Q5. Top 10 departments by total sales across all stores
-- Department 92 is the clear leader by a significant margin
SELECT
    Dept,
    ROUND(SUM(Weekly_Sales), 2)   AS Total_Sales,
    ROUND(AVG(Weekly_Sales), 2)   AS Avg_Weekly_Sales,
    COUNT(DISTINCT Store)         AS Stores_Present_In
FROM train
GROUP BY Dept
ORDER BY Total_Sales DESC
LIMIT 10;


-- Q6. Bottom 10 departments by total sales
-- These departments contribute very little revenue
SELECT
    Dept,
    ROUND(SUM(Weekly_Sales), 2) AS Total_Sales,
    ROUND(AVG(Weekly_Sales), 2) AS Avg_Weekly_Sales
FROM train
GROUP BY Dept
ORDER BY Total_Sales ASC
LIMIT 10;


-- Q7. Top 5 departments for each store
-- Shows which departments matter most at the store level
SELECT Store, Dept, ROUND(SUM(Weekly_Sales), 2) AS Total_Sales
FROM train
GROUP BY Store, Dept
ORDER BY Store ASC, Total_Sales DESC
LIMIT 50;


-- =============================================================
-- SECTION 3 : SEASONALITY AND TIME TRENDS
-- When does Walmart sell the most?
-- =============================================================

-- Q8. Yearly total sales
-- 2011 was the strongest full year - 2012 data ends in October
SELECT
    LEFT(`Date`, 4)             AS Year,
    ROUND(SUM(Weekly_Sales), 2) AS Total_Sales,
    COUNT(DISTINCT `Date`)      AS Num_Weeks
FROM train
GROUP BY LEFT(`Date`, 4)
ORDER BY LEFT(`Date`, 4);


-- Q9. Top 10 highest sales weeks ever
-- Thanksgiving and Christmas weeks dominate this list
SELECT
    `Date`,
    ROUND(SUM(Weekly_Sales), 2) AS Total_Sales,
    IsHoliday
FROM train
GROUP BY `Date`, IsHoliday
ORDER BY Total_Sales DESC
LIMIT 10;


-- Q10. Lowest 10 sales weeks
-- Post-holiday weeks in January tend to be the weakest
SELECT
    `Date`,
    ROUND(SUM(Weekly_Sales), 2) AS Total_Sales,
    IsHoliday
FROM train
GROUP BY `Date`, IsHoliday
ORDER BY Total_Sales ASC
LIMIT 10;


-- =============================================================
-- SECTION 4 : HOLIDAY IMPACT
-- Do holiday weeks actually drive more sales?
-- =============================================================

-- Q11. Holiday vs normal week - overall comparison
-- Holiday weeks show a clear uplift in average sales
SELECT
    IsHoliday,
    ROUND(AVG(Weekly_Sales), 2) AS Avg_Weekly_Sales,
    ROUND(SUM(Weekly_Sales), 2) AS Total_Sales,
    COUNT(*)                    AS Total_Records
FROM train
GROUP BY IsHoliday;


-- Q12. Holiday impact broken down by store type
-- Type A stores benefit the most from holiday weeks
-- Type C stores show almost no holiday effect
SELECT
    s.Type                        AS Store_Type,
    t.IsHoliday,
    ROUND(AVG(t.Weekly_Sales), 2) AS Avg_Weekly_Sales,
    COUNT(*)                      AS Records
FROM train t
JOIN stores s ON t.Store = s.Store
GROUP BY s.Type, t.IsHoliday
ORDER BY s.Type, t.IsHoliday;


-- =============================================================
-- SECTION 5 : MARKDOWN ANALYSIS
-- Do promotional markdowns actually boost sales?
-- =============================================================

-- Q13. Markdown active vs no markdown
-- Weeks with any markdown vs weeks with no markdown
SELECT
    CASE
        WHEN MarkDown1 != 'NA' OR MarkDown2 != 'NA'
          OR MarkDown3 != 'NA' OR MarkDown4 != 'NA'
          OR MarkDown5 != 'NA'
        THEN 'Markdown Active'
        ELSE 'No Markdown'
    END      AS Markdown_Status,
    COUNT(*) AS Records
FROM features
GROUP BY Markdown_Status;


-- Q14. Average CPI and unemployment by store
-- Helps understand the economic environment each store operates in
SELECT
    f.Store,
    ROUND(AVG(CAST(f.CPI AS DECIMAL(12,6))), 4)        AS Avg_CPI,
    ROUND(AVG(CAST(f.Unemployment AS DECIMAL(6,3))), 3) AS Avg_Unemployment
FROM features f
WHERE f.CPI != 'NA'
  AND f.Unemployment != 'NA'
GROUP BY f.Store
ORDER BY Avg_Unemployment DESC
LIMIT 10;


-- =============================================================
-- END OF FILE
-- All results from these queries were used to validate
-- findings from the Python Pandas Insights notebook.
-- =============================================================


-- NOTE: Q14 above combines CPI and Unemployment.
-- Below are the same as two separate queries for clarity.

-- Q14b. Stores with highest average CPI
SELECT
    Store,
    ROUND(AVG(CAST(CPI AS DECIMAL(12,6))), 4) AS Avg_CPI
FROM features
WHERE CPI != 'NA'
GROUP BY Store
ORDER BY Avg_CPI DESC
LIMIT 10;


-- Q15. Stores with highest average unemployment
SELECT
    Store,
    ROUND(AVG(CAST(Unemployment AS DECIMAL(6,3))), 3) AS Avg_Unemployment
FROM features
WHERE Unemployment != 'NA'
GROUP BY Store
ORDER BY Avg_Unemployment DESC
LIMIT 10;
