-- ==========================================================
--
--              CHAPTER 4
--
-- ==========================================================


-- 2

SELECT DISTINCT     MK.MakeName, MD.ModelName
FROM                Data.Stock ST
INNER JOIN          Data.Model MD
                    ON MD.ModelID = ST.ModelID
INNER JOIN          Data.Make MK
                    ON MK.MakeID = MD.MakeID
ORDER BY            MK.MakeName, MD.ModelName


-- 3

SELECT     MD.ModelName, SA.SaleDate, SA.InvoiceNumber 
FROM       Data.Model AS MD 
INNER JOIN Data.Stock ST
           ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD 
           ON ST.StockCode = SD.StockID
INNER JOIN Data.Sales SA
           ON SA.SalesID = SD.SalesID
ORDER BY   MD.ModelName


-- 4

SELECT DISTINCT ModelName, Color 
FROM            Data.Stock ST
INNER JOIN      Data.Model MD
                ON ST.ModelID = MD.ModelID
WHERE           Color = 'Red'



-- 5

SELECT     MD.ModelName, ST.Color 
FROM       Data.Stock ST
INNER JOIN Data.Model MD
           ON ST.ModelID = MD.ModelID
WHERE      ST.Color IN ('Red', 'Green', 'Blue')


-- 6

SELECT     DISTINCT MK.MakeName
           FROM Data.Make AS MK 
INNER JOIN Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
WHERE      MK.MakeName <> 'Ferrari'
ORDER BY   MK.MakeName




-- 7

SELECT     DISTINCT MK.MakeName
FROM       Data.Make AS MK 
           INNER JOIN Data.Model AS MD ON MK.MakeID = MD.MakeID
           INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
           INNER JOIN Data.SalesDetails SD 
           ON ST.StockCode = SD.StockID
WHERE      MK.MakeName 
           NOT IN ('Porsche', 'Aston Martin', 'Bentley')
ORDER BY   MK.MakeName


-- 8

SELECT     ModelName, Cost
FROM       Data.Model
INNER JOIN Data.Stock
           ON Model.ModelID = Stock.ModelID
WHERE      Cost > 50000	


-- 9

SELECT     ModelName, Cost, PartsCost
FROM       Data.Model
INNER JOIN Data.Stock
           ON Model.ModelID = Stock.ModelID
WHERE      PartsCost < 1000	


-- 10

SELECT     ModelName, RepairsCost
FROM       Data.Model
INNER JOIN Data.Stock
           ON Model.ModelID = Stock.ModelID
WHERE      RepairsCost <= 500	


-- 11

SELECT     DISTINCT MK.MakeName
FROM       Data.Make AS MK INNER JOIN Data.Model AS MD 
           ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
WHERE      ST.PartsCost BETWEEN 1000 AND 2000
ORDER BY   MK.MakeName	


-- 12

SELECT     DISTINCT MK.MakeName, MD.ModelName
FROM       Data.Make AS MK 
INNER JOIN Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
WHERE      ST.IsRHD = 1
ORDER BY   MK.MakeName, MD.ModelName


