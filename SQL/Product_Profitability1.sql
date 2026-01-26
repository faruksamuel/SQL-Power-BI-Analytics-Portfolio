/*
**********************************************************************************************************************************
Project: Product Profitablity Analysis
Author: Faruk S.A
Tools: SQL Server
Purpose: Analyze Product profitability to identify and discontinue candidates.
************************************************************************************************************************************
*/

/*------------------------------------------------------------------------------------------------------------------------------------ 
     Drop existing views so script can rerun
-------------------------------------------------------------------------------------------------------------------------------------*/

IF OBJECT_ID('dbo.vw_ProductProfitability_Base', 'V') IS NOT NULL
    DROP VIEW dbo.vw_ProductProfitability_Base;
GO

IF OBJECT_ID('dbo.vw_CategoryProfitability', 'V') IS NOT NULL
    DROP VIEW dbo.vw_CategoryProfitability;
GO

IF OBJECT_ID('dbo.vw_ProductRecommendation', 'V') IS NOT NULL
    DROP VIEW dbo.vw_ProductRecommendation;
GO

IF OBJECT_ID('dbo.vw_HighVolumeLowMarginProducts', 'V') IS NOT NULL
    DROP VIEW dbo.vw_HighVolumeLowMarginProducts;
GO
/*------------------------------------------------------------------------------------------------------------------------------------ 
	1. Base View - using one join and one clean row for each product.
-------------------------------------------------------------------------------------------------------------------------------------*/
CREATE VIEW dbo.vw_ProductProfitability_Base
AS
SELECT
    -- Product identifiers
    p.ProductKey,
    p.Product AS ProductName,
    p.Category,
    p.Subcategory,

    -- Volume metrics
    SUM(s.Quantity) AS UnitsSold,
    COUNT(DISTINCT s.SalesOrderNumber) AS OrderCount,

    -- Financial metrics
    SUM(s.Sales) AS TotalRevenue,
    SUM(s.Cost) AS TotalCost,
    SUM(s.Sales - s.Cost) AS TotalProfit,

    -- Profit margin
    CAST(
        SUM(s.Sales - s.Cost) * 1.0 /
        NULLIF(SUM(s.Sales), 0)
        AS DECIMAL(10,4)
    ) AS ProfitMargin

FROM dbo.Sales s
LEFT JOIN dbo.Products p
    ON s.ProductKey = p.ProductKey

GROUP BY
    p.ProductKey,
    p.Product,
    p.Category,
    p.Subcategory;
GO
/*------------------------------------------------------------------------------------------------------------------------------------ 
    2. Category view.
    This builds directly on the base view, so there’s no need to rejoin the raw tables again.
-------------------------------------------------------------------------------------------------------------------------------------*/
CREATE VIEW dbo.vw_CategoryProfitability
AS
SELECT
    Category,
    SUM(TotalRevenue) AS TotalRevenue,
    SUM(TotalCost) AS TotalCost,
    SUM(TotalProfit) AS TotalProfit,
    CAST(
        SUM(TotalProfit) * 1.0 /
        NULLIF(SUM(TotalRevenue), 0)
        AS DECIMAL(10,4)
    ) AS ProfitMargin
FROM dbo.vw_ProductProfitability_Base
GROUP BY Category;
GO

/*------------------------------------------------------------------------------------------------------------------------------------ 
      3. Recommendation view — Continue, review or discontinue.
         We compare each product against key benchmarks, 
        like average profit and average margin, to decide what action makes the most sense. 
-------------------------------------------------------------------------------------------------------------------------------------*/
CREATE VIEW dbo.vw_ProductRecommendation
AS
WITH Benchmarks AS (
    SELECT
        AVG(CAST(TotalProfit AS FLOAT)) AS AvgProfit,
        AVG(CAST(ProfitMargin AS FLOAT)) AS AvgMargin
    FROM dbo.vw_ProductProfitability_Base
)
SELECT
    b.ProductKey,
    b.ProductName,
    b.Category,
    b.Subcategory,
    b.UnitsSold,
    b.OrderCount,
    b.TotalRevenue,
    b.TotalCost,
    b.TotalProfit,
    b.ProfitMargin,

    CASE
        WHEN b.TotalRevenue IS NULL OR b.TotalRevenue = 0 THEN 'Review'
        WHEN b.TotalProfit >= bm.AvgProfit AND b.ProfitMargin >= bm.AvgMargin THEN 'Continue'
        WHEN b.TotalProfit <  bm.AvgProfit AND b.ProfitMargin <  bm.AvgMargin THEN 'Discontinue'
        ELSE 'Review'
    END AS Recommendation
FROM dbo.vw_ProductProfitability_Base b
CROSS JOIN Benchmarks bm;
GO
/*------------------------------------------------------------------------------------------------------------------------------------ 
	4. High-volume, low-margin view — the margin killers.
       This highlights products that sell a lot but don’t make much. 
       In this view, “high volume” means above-average units sold, 
       while “low margin” is anything under our average profit margin, 8.68%.
-------------------------------------------------------------------------------------------------------------------------------------*/
CREATE VIEW dbo.vw_HighVolumeLowMarginProducts
AS
WITH Benchmarks AS (
    SELECT
        AVG(CAST(UnitsSold AS FLOAT)) AS AvgUnitsSold
    FROM dbo.vw_ProductProfitability_Base
)
SELECT
    r.*,
    CASE
        WHEN r.UnitsSold > b.AvgUnitsSold AND r.ProfitMargin < 0.0867 THEN 1
        ELSE 0
    END AS HighVolumeLowMarginFlag
FROM dbo.vw_ProductRecommendation r
CROSS JOIN Benchmarks b
WHERE r.UnitsSold > b.AvgUnitsSold
  AND r.ProfitMargin < 0.0867;
GO

/*------------------------------------------------------------------------------------------------------------------------------------ 
5. Final output queries.
-------------------------------------------------------------------------------------------------------------------------------------*/

-- Profit per product (Top 20)
    SELECT TOP 20
    ProductKey, ProductName, Category,
    UnitsSold, TotalRevenue, TotalCost, TotalProfit, ProfitMargin
FROM dbo.vw_ProductProfitability_Base
ORDER BY TotalProfit DESC;

-- Categories that generate the most profit
SELECT
    Category, TotalRevenue, TotalCost, TotalProfit, ProfitMargin
FROM dbo.vw_CategoryProfitability
ORDER BY TotalProfit DESC;

-- Products that should continue
SELECT *
FROM dbo.vw_ProductRecommendation
WHERE Recommendation = 'Continue'
ORDER BY TotalProfit DESC;

-- Products to be discontinued
SELECT *
FROM dbo.vw_ProductRecommendation
WHERE Recommendation = 'Discontinue'
ORDER BY TotalProfit ASC;

-- Products that sell a lot but make little money 
SELECT *
FROM dbo.vw_HighVolumeLowMarginProducts
ORDER BY UnitsSold DESC;

-- Summary count - a quick snapshot of the portfolio.
SELECT Recommendation, COUNT(*) AS ProductCount
FROM dbo.vw_ProductRecommendation
GROUP BY Recommendation
ORDER BY ProductCount DESC;