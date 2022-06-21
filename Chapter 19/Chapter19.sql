-- ==========================================================
--
--              CHAPTER 8
--
-- ==========================================================


-- 1

SELECT       InvoiceNumber 
            ,FORMAT(SA.SaleDate, 'd', 'en-gb') AS DateOfSale
            ,SD.SalePrice
            ,SUM(SD.SalePrice) 
            OVER (ORDER BY SaleDate ASC) AS AccumulatedSales
            ,AVG(SD.SalePrice) 
            OVER (ORDER BY SA.SaleDate ASC) 
                 AS AverageSalesValueToDate
FROM        Data.SalesDetails SD
INNER JOIN  Data.Sales AS SA ON SA.SalesID = SD.SalesID
WHERE       YEAR(SA.SaleDate) = 2017
ORDER BY    SA.SaleDate

-- 2

SELECT      DateBought
            ,SUM(Cost) AS PurchaseCost
            ,SUM(SUM(Cost)) 
               OVER (ORDER BY DateBought ASC) AS CostForTheYear
FROM        Data.Stock
WHERE       YEAR(DateBought) = 2016
GROUP BY    DateBought
ORDER BY    DateBought


-- 3

SELECT       FORMAT(SaleDate, 'd', 'en-gb') AS DateOfSale
            ,CU.CustomerName, CU.Town
            ,SD.SalePrice
            ,COUNT(SD.SalesDetailsID) 
             OVER (PARTITION BY YEAR(SaleDate) ORDER BY SalesDetailsID ASC) 
                 AS AnnualNumberOfSalesToDate
FROM        Data.SalesDetails SD
INNER JOIN  Data.Sales AS SA ON SA.SalesID = SD.SalesID
INNER JOIN  Data.Customer CU ON SA.CustomerID = CU.CustomerID
ORDER BY    SaleDate


-- 4

SELECT       FORMAT(SaleDate, 'd', 'en-us') AS DateOfSale
            ,DailyCount AS NumberOfSales
            ,SUM(DailyCount) OVER 
                   (PARTITION BY YEAR(SaleDate) 
                    ORDER BY SaleDate ASC) 
                   AS AnnualNumberOfSalesToDate
            ,SUM(DailySalePrice) OVER 
                   (PARTITION BY YEAR(SaleDate) 
                    ORDER BY SaleDate ASC) 
                   AS AnnualSalePriceToDate
FROM        (
             SELECT       SA.SaleDate
                         ,COUNT(SD.SalesDetailsID) AS DailyCount
                         ,SUM(SD.SalePrice) AS DailySalePrice
             FROM        Data.SalesDetails SD
             INNER JOIN  Data.Sales AS SA 
                         ON SA.SalesID = SD.SalesID
             GROUP BY    SA.SaleDate
            ) DT
ORDER BY    SaleDate


-- 5

SELECT       FORMAT(SA.SaleDate, 'd', 'en-gb') AS DateOfSale
            ,SD.SalePrice, CU.CustomerName, CU.Town, MK.MakeName
            ,COUNT(SD.SalesDetailsID) 
              OVER (PARTITION BY YEAR(SaleDate) 
              ORDER BY SA.SaleDate ASC) 
                 AS AnnualNumberOfSalesToDate
            ,ROW_NUMBER() OVER (ORDER BY SA.SaleDate ASC) 
                 AS SalesCounter        
FROM        Data.Make AS MK 
INNER JOIN  Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN  Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN  Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN  Data.Sales AS SA ON SA.SalesID = SD.SalesID
INNER JOIN  Data.Customer CU ON SA.CustomerID = CU.CustomerID
ORDER BY    SA.SaleDate


-- 6

;
WITH Tally_CTE
AS
(
SELECT     TOP 52 ROW_NUMBER() OVER (ORDER BY StockCode) AS Num
FROM       Data.Stock
)

SELECT           Num, SalesForTheWeek
FROM             Tally_CTE CTE
LEFT OUTER JOIN  
                 (
                 SELECT         SUM(TotalSalePrice) 
                                   AS SalesForTheWeek
                               ,DatePart(wk, SaleDate) AS WeekNo
                 FROM          Data.Sales
                 WHERE         YEAR(SaleDate) = 2016
                 GROUP BY      DatePart(wk, SaleDate)
                 ) SLS
                 ON CTE.Num = SLS.WeekNo


-- 7

;
WITH Tally_CTE
AS
(
SELECT     TOP 10000 ROW_NUMBER() OVER (ORDER BY ST1.StockCode) -1
               AS Num
FROM       Data.Stock ST1
CROSS JOIN Data.Stock ST2
)
,DateRange_CTE
AS
(
SELECT     DATEADD(DD, Num,'20170101') AS DateList FROM Tally_CTE 
WHERE      Num <= DATEDIFF(DD, '20170101', '20170630')
)

SELECT           CAST(DateList AS DATE) AS SaleDate, SalesPerDay
FROM             DateRange_CTE CTE
LEFT OUTER JOIN  
                 (
                 SELECT         CAST(SaleDate AS DATE) 
                                   AS DateOfSale
                               ,SUM(TotalSalePrice) AS SalesPerDay
                 FROM          Data.Sales
                 GROUP BY      CAST(SaleDate AS DATE)
                 ) SLS
                 ON CTE.DateList = SLS.DateOfSale



-- 8

SELECT      CU.CustomerName
           ,SA.SaleDate
           ,SA.TotalSalePrice
           ,SA.TotalSalePrice - LAG(SA.TotalSalePrice,1) 
                                OVER (PARTITION BY CU.CustomerName 
                                      ORDER BY SA.SaleDate)
                                 AS DifferenceToPreviousSalePrice
FROM       Data.Sales SA
INNER JOIN Data.Customer CU
           ON SA.CustomerID = CU.CustomerID
ORDER BY   SaleDate


-- 9

SELECT      CU.CustomerName
           ,SA.SaleDate
           ,SA.TotalSalePrice AS CurrentSale
           ,FIRST_VALUE(SA.TotalSalePrice) 
            OVER (PARTITION BY CU.CustomerName 
                  ORDER BY SA.SaleDate, SalesID)
                      AS InitialOrder
           ,LAST_VALUE(TotalSalePrice) 
            OVER (PARTITION BY CU.CustomerName
                  ORDER BY SaleDate, SA.SalesID 
                  ROWS BETWEEN CURRENT ROW 
                       AND UNBOUNDED FOLLOWING) 
                      AS FinalOrder
FROM       Data.Sales SA
           INNER JOIN Data.Customer CU
               ON SA.CustomerID = CU.CustomerID



-- 10

SELECT      CU.CustomerName
           ,SA.SaleDate
           ,SA.TotalSalePrice
           ,AVG(SA.TotalSalePrice) 
            OVER (PARTITION BY CU.CustomerName ORDER BY SA.SaleDate 
            ROWS BETWEEN 3 PRECEDING AND CURRENT ROW)
               AS AverageSalePrice
FROM       Data.Sales AS SA 
INNER JOIN Data.Customer CU ON SA.CustomerID = CU.CustomerID
ORDER BY   CU.CustomerName, SA.SaleDate


-- 11

SELECT   
 CU.CustomerName
,SA.SaleDate
,SA.TotalSalePrice
,FIRST_VALUE(SA.TotalSalePrice) OVER (PARTITION BY CU.CustomerName
                                    ORDER BY SA.SaleDate) 
                                   AS FirstOrder
,LAG(TotalSalePrice, 3) OVER (PARTITION BY CU.CustomerName
                              ORDER BY SA.SaleDate) 
                                   AS LastButThreeOrder
,LAG(TotalSalePrice, 2) OVER (PARTITION BY CU.CustomerName
                              ORDER BY SA.SaleDate) 
                                   AS LastButTwoOrder
,LAG(TotalSalePrice, 1) OVER (PARTITION BY CU.CustomerName
                              ORDER BY SA.SaleDate) 
                                    AS LastButOneOrder
,LAST_VALUE(TotalSalePrice) OVER (PARTITION BY CU.CustomerName
                                  ORDER BY SA.SaleDate) 
                                     AS LatestOrder
FROM     Data.Sales AS SA 
         INNER JOIN Data.Customer CU ON SA.CustomerID 
                                        = CU.CustomerID

-- 12

SELECT      MK.MakeName, MD.ModelName, SA.InvoiceNumber
           , SD.SalePrice
           ,ROUND(CUME_DIST() 
            OVER (PARTITION BY MK.MakeName 
                  ORDER BY SD.SalePrice),2) 
                      AS RelativeStanding
FROM        Data.Make AS MK 
INNER JOIN  Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN  Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN  Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN  Data.Sales AS SA ON SA.SalesID = SD.SalesID	
ORDER BY    MK.MakeName, SD.SalePrice, RelativeStanding


-- 13

SELECT      CO.CountryName, SA.SaleDate, SA.InvoiceNumber
           ,FORMAT(PERCENT_RANK() 
            OVER (PARTITION BY CO.CountryName 
            ORDER BY SA.TotalSalePrice), '0.00 %') 
               AS PercentageRanking
FROM       Data.Sales AS SA 
INNER JOIN Data.Customer CU ON SA.CustomerID = CU.CustomerID
INNER JOIN Data.Country CO ON CU.Country = CO.CountryISO2
ORDER BY   CO.CountryName, SA.TotalSalePrice DESC

