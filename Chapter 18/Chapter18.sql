-- ==========================================================
--
--              CHAPTER 7
--
-- ==========================================================


-- 1

SELECT       CustomerName
            ,MakeName + ', ' + ModelName AS MakeAndModel
            ,SalePrice
            ,RANK() OVER (ORDER BY SalePrice DESC) 
                   AS SalesImportance
FROM        Data.SalesByCountry
WHERE       YEAR(SaleDate) = 2018


-- 2

SELECT       MK.MakeName + ', ' + MD.ModelName AS MakeAndModel
            ,SD.SalePrice
            ,RANK() OVER (PARTITION BY MakeName 
                          ORDER BY SD.SalePrice DESC) AS SalesImportance
FROM        Data.Make AS MK 
INNER JOIN  Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN  Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN  Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN  Data.Sales AS SA ON SA.SalesID = SD.SalesID
WHERE       YEAR(SA.SaleDate) = 2017
ORDER BY    MK.MakeName	


-- 3

;
WITH
AllSalesProfit_CTE (CustomerName, MakeName, ModelName, SalePrice, ProfitPerModel)
AS
(
SELECT       CustomerName, MakeName, ModelName
             ,SalePrice
             ,((SalePrice - 
                 (Cost + ISNULL(RepairsCost,0) 
                  + PartsCost + TransportInCost))
                / SalePrice) * 100
FROM        Data.SalesByCountry
)
  
SELECT       CustomerName, MakeName, ModelName, ProfitPerModel, SalePrice
             ,RANK() OVER 
                      (PARTITION BY CustomerName, MakeName 
                       ORDER BY ProfitPerModel DESC) AS SalesImportance
FROM        AllSalesProfit_CTE
ORDER BY    CustomerName, MakeName, SalesImportance



-- 4

SELECT      Color, MakeName
FROM
             (
             SELECT       DISTINCT MK.MakeName, Color
                         ,RANK() OVER (PARTITION BY MakeName
                                      ORDER BY SD.SalePrice DESC) 
                                           AS ColorRank
             FROM        Data.Make AS MK 
             INNER JOIN  Data.Model AS MD 
                         ON MK.MakeID = MD.MakeID
             INNER JOIN  Data.Stock AS ST 
                         ON ST.ModelID = MD.ModelID
             INNER JOIN  Data.SalesDetails SD 
                         ON ST.StockCode = SD.StockID
             ) SQ
WHERE       ColorRank = 1
ORDER BY MakeName




-- 5

SELECT      Color, MakeAndModel, SalesImportance
FROM
(
SELECT       ST.Color, MK.MakeName + ', ' + MD.ModelName AS MakeAndModel
             ,SD.SalePrice
             ,DENSE_RANK() OVER (ORDER BY SD.SalePrice DESC) 
                           AS SalesImportance
FROM        Data.Make AS MK 
INNER JOIN  Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN  Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN  Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN 
           (
            SELECT TOP (5)   ST.Color, COUNT(*) AS NumberOfSales
            FROM             Data.Stock AS ST
            INNER JOIN       Data.SalesDetails SD 
                             ON ST.StockCode = SD.StockID
            GROUP BY         ST.Color
            ORDER BY         NumberOfSales
            ) CL
            ON CL.Color = ST.Color
) RK
WHERE       SalesImportance <= 10
ORDER BY    SalesImportance


-- 6

SELECT       ST.Color, MK.MakeName + ', ' + MD.ModelName AS MakeAndModel
             ,SD.SalePrice
             ,NTILE(10) OVER (ORDER BY SD.SalePrice DESC) AS SalesDecile
FROM        Data.Make AS MK 
INNER JOIN  Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN  Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN  Data.SalesDetails SD ON ST.StockCode = SD.StockID
ORDER BY    SalesDecile, ST.Color, MakeAndModel


-- 7

;
WITH PercentileList_CTE
AS
(
SELECT     RepairsCost
          ,Cost
          ,NTILE(100) OVER (ORDER BY Cost DESC) AS Percentile
FROM      Data.Stock
)

SELECT    Percentile
          ,SUM(Cost) AS TotalCostPerPercentile
          ,SUM(RepairsCost) AS RepairsCostPerPercentile
              ,SUM(RepairsCost) / SUM(Cost) AS RepairCostRatio
FROM      PercentileList_CTE
GROUP BY  Percentile
ORDER BY  RepairCostRatio DESC



-- 8

;
WITH Top20PercentSales_CTE
AS
(
SELECT       SalesDetailsID, MK.MakeName, MD.ModelName, SD.SalePrice
             ,NTILE(5) OVER (ORDER BY SD.SalePrice DESC) 
                  AS SalesQuintile
FROM        Data.Make AS MK 
INNER JOIN  Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN  Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN  Data.SalesDetails SD ON ST.StockCode = SD.StockID
)

SELECT      MakeName, ModelName, SalePrice
FROM        Top20PercentSales_CTE CTE
WHERE       MakeName IN (
                         SELECT   TOP 3 MakeName
                         FROM     Top20PercentSales_CTE
                         WHERE    SalesQuintile = 2
                         GROUP BY MakeName
                         ORDER BY SUM(SalePrice) DESC
                        )   
ORDER BY   SalePrice DESC 

-- 9

SELECT     DISTINCT  CU.CustomerName
           ,SA.TotalSalePrice
           ,SA.TotalSalePrice - PERCENTILE_CONT(0.5) 
           WITHIN GROUP(ORDER BY SA.TotalSalePrice) 
                        OVER(PARTITION BY CU.CustomerName) 
               AS SaleToMedianDelta
FROM       Data.Sales AS SA 
INNER JOIN Data.Customer CU ON SA.CustomerID = CU.CustomerID


