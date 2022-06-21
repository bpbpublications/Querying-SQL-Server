-- ==========================================================
--
--              CHAPTER 5
--
-- ==========================================================



-- 1

SELECT  MakeName, ModelName, CustomerName, CountryName
        ,Cost, RepairsCost, PartsCost, TransportInCost
        ,SalePrice, SaleDate
FROM    DataTransfer.Sales2015
UNION 
SELECT  MakeName, ModelName, CustomerName, CountryName
        ,Cost, RepairsCost, PartsCost, TransportInCost
        ,SalePrice, SaleDate
FROM    DataTransfer.Sales2016
UNION
SELECT  MakeName, ModelName, CustomerName, CountryName
        ,Cost, RepairsCost, PartsCost, TransportInCost
        ,SalePrice, SaleDate
FROM    DataTransfer.Sales2017


-- 2

SELECT     MK.MakeName
FROM       Data.Make AS MK 
INNER JOIN Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
WHERE      YEAR(DateBought) = 2015
INTERSECT
SELECT     MK.MakeName
FROM       Data.Make AS MK 
INNER JOIN Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
WHERE      YEAR(DateBought) = 2016


-- 3

SELECT     MK.MakeName + ' ' + MD.ModelName AS MakeModel
FROM       Data.Make AS MK 
INNER JOIN Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
WHERE      YEAR(SaleDate) = 2015
EXCEPT
SELECT     MK.MakeName + ' ' + MD.ModelName
FROM       Data.Make AS MK 
INNER JOIN Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
WHERE      YEAR(SaleDate) = 2016


-- 4

SELECT  MakeName, ModelName
FROM
(
   SELECT  MakeName, ModelName, CustomerName, CountryName, Cost
   ,RepairsCost, PartsCost, TransportInCost, SalePrice, SaleDate
   FROM    DataTransfer.Sales2015
   UNION 
   SELECT  MakeName, ModelName, CustomerName, CountryName, Cost
   ,RepairsCost, PartsCost, TransportInCost, SalePrice, SaleDate
   FROM    DataTransfer.Sales2016
   UNION
   SELECT  MakeName, ModelName, CustomerName, CountryName, Cost
   ,RepairsCost, PartsCost, TransportInCost, SalePrice, SaleDate
   FROM    DataTransfer.Sales2017
) SQ
WHERE   CountryName = 'Germany'


