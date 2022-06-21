-- ==========================================================
--
--              CHAPTER 7
--
-- ==========================================================


-- 1

SELECT       SUM(Cost) AS TotalCost 
FROM         Data.Stock	


-- 2

SELECT        SUM(ST.Cost) AS TotalCost
             ,SUM(SD.SalePrice) AS TotalSales 
             ,SUM(SD.SalePrice) - SUM(ST.Cost) AS GrossProfit
FROM         Data.Stock ST
INNER JOIN   Data.SalesDetails SD
             ON ST.StockCode = SD.StockID


-- 3

SELECT     MD.ModelName, SUM(ST.Cost) AS TotalCost
FROM       Data.Stock ST
INNER JOIN Data.Model MD ON MD.ModelID = ST.ModelID
GROUP BY   MD.ModelName


-- 4

SELECT     MK.MakeName, MD.ModelName, SUM(ST.Cost) AS TotalCost
FROM       Data.Stock ST
INNER JOIN Data.Model MD ON MD.ModelID = ST.ModelID
INNER JOIN Data.Make AS MK ON MK.MakeID = MD.MakeID
GROUP BY   MK.MakeName, MD.ModelName


-- 5

SELECT     MK.MakeName, MD.ModelName
           ,AVG(ST.Cost) AS AverageCost 
FROM       Data.Make AS MK 
INNER JOIN Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
GROUP BY   MK.MakeName, MD.ModelName


-- 6

SELECT       MK.MakeName, MD.ModelName 
            ,COUNT(SD.SalesDetailsID) AS NumberofCarsSold
FROM        Data.Make AS MK 
INNER JOIN  Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN  Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN  Data.SalesDetails SD ON ST.StockCode = SD.StockID
GROUP BY    MK.MakeName, MD.ModelName
ORDER BY    MK.MakeName, MD.ModelName


-- 7

SELECT  COUNT(DISTINCT CountryName) AS CountriesWithSales
FROM    Data.SalesByCountry	


-- 8

SELECT       MD.ModelName
            ,MAX(SD.SalePrice) AS TopSalePrice
            ,MIN(SD.SalePrice) AS BottomSalePrice
FROM        Data.Make AS MK 
INNER JOIN  Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN  Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN  Data.SalesDetails SD ON ST.StockCode = SD.StockID
GROUP BY    MD.ModelName


-- 9

SELECT      MK.MakeName, COUNT(SD.SalePrice) AS CarsSold
FROM        Data.Make AS MK 
INNER JOIN  Data.Model MD
            ON MK.MakeID = MD.MakeID
INNER JOIN  Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN  Data.SalesDetails SD ON ST.StockCode = SD.StockID
WHERE       ST.Color = 'Red'
GROUP BY    MK.MakeName	


-- 10

SELECT     CountryName, COUNT(SalesDetailsID) AS NumberofCarsSold
FROM       Data.SalesByCountry
GROUP BY   CountryName			
HAVING     COUNT(SalesDetailsID) > 50	


-- 11

SELECT     CU.CustomerName, COUNT(SD.SalesDetailsID) 
               AS NumberofCarsSold
FROM       Data.Make AS MK INNER JOIN Data.Model AS MD 
           ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
INNER JOIN Data.Customer CU ON SA.CustomerID = CU.CustomerID
WHERE      (SD.SalePrice 
            - (
                ST.Cost + ISNULL(ST.RepairsCost,0) + ST.PartsCost 
                + ST.TransportInCost)
               ) > 5000
GROUP BY   CU.CustomerName
HAVING     COUNT(SD.SalesDetailsID) >= 3


-- 12

SELECT      TOP (3) MK.MakeName
FROM        Data.Make AS MK 
INNER JOIN  Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN  Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN  Data.SalesDetails SD ON ST.StockCode = SD.StockID
GROUP BY    MK.MakeName
ORDER BY    SUM(SD.SalePrice) DESC
