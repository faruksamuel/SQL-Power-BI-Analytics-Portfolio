/*
***********************************************************************************************************************************
Project: Product Profitablity Analysis
Author: Faruk S.A
Tools: SQL Server
Purpose: Analyze Product profitability to identify what product to continue, discontinue or Review.
************************************************************************************************************************************
*/

/*------------------------------------------------------------------------------------------------------------------------------------ 
	1. DATA PROFILING
-------------------------------------------------------------------------------------------------------------------------------------*/

-- Row Counts 
SELECT COUNT(*) AS SalesRows FROM Sales;
SELECT COUNT(*) AS ProductRows FROM Products;

-- Duplicate Checks: Duplicates expected for SalesOrderNumber
-- not for ProductKey
SELECT ProductKey, COUNT(*) AS Dup_chk
FROM Products
GROUP BY ProductKey
HAVING COUNT(*) > 1;

-- Checking for Nulls in Key columns

SELECT 
SUM(CASE WHEN SalesOrderNumber IS NULL THEN 1
		ELSE 0 END) AS NullOrders, 
SUM(CASE WHEN ProductKey IS NULL THEN 1
		ELSE 0 END) AS NullProductKeys
FROM Sales;

/*------------------------------------------------------------------------------------------------------------------------------------ 
	2. PROFIT PER PRODUCT
-------------------------------------------------------------------------------------------------------------------------------------*/
SELECT
p.ProductKey,
p.Product AS ProductName,
P.Category,
SUM(s.Sales) AS Total_Revenue, 
SUM(s.Sales - s.Cost) AS ProfitPerProduct,
CAST(SUM(s.Sales - s.Cost) * 1.0/NULLIF(SUM(s.Sales),0) AS DECIMAL(10,2)) AS Profit_Margin
FROM Sales s
LEFT JOIN Products p
ON s.ProductKey = p.ProductKey
GROUP BY p.ProductKey,p.Product,P.Category
ORDER BY ProfitPerProduct DESC;

/*------------------------------------------------------------------------------------------------------------------------------------ 
	3. CATEGORY PROFITABILTY 
-------------------------------------------------------------------------------------------------------------------------------------*/
SELECT 
p.Category, 
SUM(s.Sales) AS Total_Revenue, 
SUM(s.Sales - s.Cost) AS ProfitPerProduct,
CAST(SUM(s.Sales - s.Cost) * 1.0/NULLIF(SUM(s.Sales),0) AS DECIMAL(10,2)) AS Profit_Margin
FROM Sales s
LEFT JOIN Products p
ON s.ProductKey = p.ProductKey
GROUP BY P.Category
ORDER BY ProfitPerProduct DESC;
/*------------------------------------------------------------------------------------------------------------------------------------ 
	4. Products to Continue or Discontinue or Review 
-------------------------------------------------------------------------------------------------------------------------------------*/
WITH ProductPerformance AS 
(
SELECT  
p.ProductKey,
p.Product AS ProductName,
SUM(s.Sales) AS Total_Revenue, 
SUM(s.Sales - s.Cost) AS ProfitPerProduct,
CAST(SUM(s.Sales - s.Cost) * 1.0/NULLIF(SUM(s.Sales),0) AS DECIMAL(10,2)) AS Profit_Margin
FROM Sales s
LEFT JOIN Products p
ON s.ProductKey = p.ProductKey
GROUP BY p.ProductKey,p.Product
),  
Benchmarks AS (
	SELECT 
		AVG(ProfitPerProduct) AS AvgProfit,
		AVG(Profit_Margin) AS AvgMargin
	FROM ProductPerformance
)
SELECT 
pp.ProductKey,
pp.ProductName,
pp.Total_Revenue,
pp.ProfitPerProduct,
pp.Profit_Margin, 
	CASE 
		WHEN pp.ProfitPerProduct >= b.AvgProfit 
	AND pp.Profit_Margin >= b.AvgMargin THEN 'Continue'
		WHEN pp.ProfitPerProduct < b.AvgProfit 
	AND pp.Profit_Margin < b.AvgMargin THEN 'DisContinue'
		ELSE 'Review'
	END AS Reccomendation
FROM ProductPerformance pp
CROSS JOIN Benchmarks b 
ORDER BY pp.ProfitPerProduct DESC;
/*------------------------------------------------------------------------------------------------------------------------------------ 
	5. HIGH VOLUME, LOW PROFIT PRODUCTS
-------------------------------------------------------------------------------------------------------------------------------------*/
WITH ProductMetrics AS 
(
SELECT 
p.ProductKey,
p.Product AS ProductName,
P.Category,
SUM(s.Quantity) AS UnitsSold,
SUM(s.Sales) AS Total_Revenue, 
SUM(s.Sales - s.Cost) AS ProfitPerProduct,
CAST(SUM(s.Sales - s.Cost) * 1.0/NULLIF(SUM(s.Sales),0) AS DECIMAL(10,2)) AS Profit_Margin
FROM Sales s
LEFT JOIN Products p
ON s.ProductKey = p.ProductKey
GROUP BY p.ProductKey,p.Product,P.Category
)
SELECT * FROM ProductMetrics
WHERE UnitsSold > (SELECT AVG(UnitsSold) FROM ProductMetrics)
	AND Profit_Margin < 0.10
ORDER BY UnitsSold;

