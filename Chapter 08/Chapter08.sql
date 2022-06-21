-- ==========================================================
--
--              CHAPTER 8
--
-- ==========================================================


-- 1

SELECT     MK.MakeName, MD.ModelName, ST.DateBought
FROM       Data.Make AS MK 
INNER JOIN Data.Model AS MD 
           ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST 
           ON ST.ModelID = MD.ModelID
WHERE      ST.DateBought = '20150725'



-- 2

SELECT     MK.MakeName, MD.ModelName
FROM       Data.Make AS MK INNER JOIN Data.Model AS MD 
           ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
WHERE      ST.DateBought BETWEEN '2018-08-30' AND '2018-08-31'


-- 3

SELECT    
            MK.MakeName
           ,MD.ModelName 
           ,ST.DateBought
           ,SA.SaleDate
           ,DATEDIFF(d, ST.DateBought, SA.SaleDate) AS DaysInStock
FROM       Data.Make AS MK 
INNER JOIN Data.Model AS MD 
           ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN Data.Sales SA ON SA.SalesID = SD.SalesID


-- 4

SELECT     SUM(Cost) 
           / DATEDIFF(m, '20150701', '20161231') 
             AS AverageDailyPurchase
FROM       Data.Make AS MK INNER JOIN Data.Model AS MD 
           ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
WHERE      ST.DateBought BETWEEN '20150701' AND '20161231'


-- 5

SELECT     MK.MakeName, MD.ModelName
FROM       Data.Make AS MK INNER JOIN Data.Model AS MD 
           ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
WHERE      CAST(SA.SaleDate AS DATE) = '20160228'


-- 6

SELECT     MK.MakeName, MD.ModelName
           ,YEAR(SA.SaleDate) AS YearOfSale 
FROM       Data.Make AS MK INNER JOIN Data.Model AS MD 
           ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
WHERE      YEAR(SA.SaleDate) = 2015
ORDER BY   MK.MakeName, MD.ModelName


-- 7

SELECT DISTINCT MK.MakeName, MD.ModelName, YEAR(SA.SaleDate)
                AS YearOfSale
FROM            Data.Make AS MK INNER JOIN Data.Model AS MD 
                ON MK.MakeID = MD.MakeID
INNER JOIN      Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN      Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN      Data.Sales AS SA ON SA.SalesID = SD.SalesID
WHERE           YEAR(SA.SaleDate) IN (2015, 2016)
ORDER BY        YEAR(SA.SaleDate), MakeName, ModelName


-- 8

SELECT     MK.MakeName, MD.ModelName, SA.SaleDate
FROM       Data.Make AS MK INNER JOIN Data.Model AS MD 
           ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
WHERE      YEAR(SA.SaleDate) = 2015 
           AND MONTH(SA.SaleDate) = 7


-- 9

SELECT     MK.MakeName, MD.ModelName
FROM       Data.Make AS MK INNER JOIN Data.Model AS MD 
           ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
WHERE      DATEPART(q, SA.SaleDate) = 3
           AND YEAR(SA.SaleDate) = 2015

-- 10

SELECT     MK.MakeName, MD.ModelName
FROM       Data.Make AS MK INNER JOIN Data.Model AS MD 
           ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
WHERE      DATEPART(dw, SA.SaleDate) = 6
           AND YEAR(SA.SaleDate) = 2016


-- 11

SELECT     MK.MakeName, MD.ModelName
FROM       Data.Make AS MK INNER JOIN Data.Model AS MD 
           ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
WHERE      DATEPART(wk, SA.SaleDate) = 26
           AND YEAR(SA.SaleDate) = 2017


-- 12

SELECT      DATEPART(dw, SA.SaleDate) AS DayOfWeek
           ,SUM(SD.SalePrice) AS Sales
FROM       Data.Make AS MK INNER JOIN Data.Model AS MD 
           ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
WHERE      YEAR(SA.SaleDate) = 2015
GROUP BY   DATEPART(dw, SA.SaleDate)
ORDER BY   SUM(SD.SalePrice) DESC



-- 13

SELECT      DATENAME(dw, SA.SaleDate) AS DayOfWeek
           ,SUM(SD.SalePrice) AS Sales
FROM       Data.Make AS MK INNER JOIN Data.Model AS MD 
           ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
WHERE      YEAR(SA.SaleDate) = 2015
GROUP BY   DATENAME(dw, SA.SaleDate)
           ,DATEPART(dw, SA.SaleDate)
ORDER BY   DATEPART(dw, SA.SaleDate)



-- 14

SELECT     SUM(SD.SalePrice) AS CumulativeJaguarSales
FROM       Data.Make AS MK INNER JOIN Data.Model AS MD 
           ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
WHERE      SA.SaleDate BETWEEN DATEADD(d, -90, '20170725') 
           AND '20170725'
           AND MK.MakeName = 'Jaguar'



-- 15

SELECT     MK.MakeName, SUM(SD.SalePrice) AS CumulativeSales
FROM       Data.Make AS MK INNER JOIN Data.Model AS MD 
           ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
WHERE      CAST(SA.SaleDate AS DATE)  
           BETWEEN DATEADD(m, -3, CAST(GETDATE() AS DATE))
           AND CAST(GETDATE() AS DATE) 
GROUP BY   MK.MakeName
ORDER BY   MK.MakeName ASC

-- 16

SELECT GETDATE()

