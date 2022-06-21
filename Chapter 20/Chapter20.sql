-- ==========================================================
--
--              CHAPTER 9
--
-- ==========================================================


-- 1

SELECT     MK.MakeName, SUM(SD.SalePrice) AS CumulativeSalesYTD
FROM       Data.Make AS MK INNER JOIN Data.Model AS MD 
           ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
WHERE      SA.SaleDate BETWEEN DATEFROMPARTS(YEAR(GETDATE()),1,1)
           AND CONVERT(CHAR(8), GETDATE(), 112)
GROUP BY   MK.MakeName
ORDER BY   MK.MakeName ASC


-- 2

SELECT     MK.MakeName, SUM(SD.SalePrice) AS CumulativeSalesMTD
FROM       Data.Make AS MK INNER JOIN Data.Model AS MD 
           ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
WHERE      SA.SaleDate 
           BETWEEN 
           DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
           AND GETDATE() 
GROUP BY   MK.MakeName
ORDER BY   MK.MakeName ASC


-- 3

SELECT     MK.MakeName, SUM(SD.SalePrice) AS CumulativeSalesQTD
FROM       Data.Make AS MK INNER JOIN Data.Model AS MD 
           ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
WHERE      SA.SaleDate BETWEEN 
                       DATEADD(q, DATEDIFF(q, 0, GETDATE()), 0) 
                       AND CONVERT(CHAR(8), GETDATE(), 112)
GROUP BY   MK.MakeName
ORDER BY   MK.MakeName ASC


-- 4

SELECT     MK.MakeName, SUM(ST.Cost) AS TotalCost
FROM       Data.Make AS MK INNER JOIN Data.Model AS MD 
           ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
WHERE      DateBought BETWEEN 
           CAST(YEAR(DATEADD(m, -1, GETDATE())) AS CHAR(4)) 
           + RIGHT('0' + CAST(MONTH(DATEADD(m, -1, GETDATE())) 
           AS VARCHAR(2)),2) + '01'
           AND EOMONTH(DATEADD(m, -1, GETDATE()))
GROUP BY   MK.MakeName


-- 5

SELECT     ST.Color, AVG(SA.TotalSalePrice) AS AverageMonthSales
           ,MAX(AveragePreviousMonthSales) 
              AS AveragePreviousYearMonthSales
FROM       Data.Make AS MK 
INNER JOIN Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
           LEFT OUTER JOIN 
                  (
                    SELECT     Color, AVG(SA.TotalSalePrice) 
                               AS AveragePreviousMonthSales
                    FROM       Data.Make AS MK 
                    INNER JOIN Data.Model AS MD 
                               ON MK.MakeID = MD.MakeID
                    INNER JOIN Data.Stock AS ST 
                               ON ST.ModelID = MD.ModelID
                    INNER JOIN Data.SalesDetails SD 
                               ON ST.StockCode = SD.StockID
                    INNER JOIN Data.Sales AS SA 
                               ON SA.SalesID = SD.SalesID
                    WHERE      YEAR(SA.SaleDate) 
                                = YEAR(GETDATE())- 1
                               AND MONTH(SA.SaleDate) 
                                = MONTH(GETDATE())
                    GROUP BY   Color
                   ) SQ   
               ON SQ.Color = ST.Color
WHERE      YEAR(SA.SaleDate) = YEAR(GETDATE())
           AND MONTH(SA.SaleDate) = MONTH(GETDATE())
GROUP BY   St.Color


-- 6

;
WITH TallyTable_CTE
AS
(
SELECT     ROW_NUMBER() OVER (ORDER BY StockCode) - 1 AS ID
FROM       Data.Stock
)
,DateList_CTE
AS
(
SELECT       DATEADD(DD, ID, DATEFROMPARTS(2017, 1, 1))
             AS WeekdayDate
             ,DATENAME(DW, DATEADD(DD, ID, DATEFROMPARTS(2017, 1, 1))) 
             AS WeekdayName
FROM         TallyTable_CTE
WHERE        DATEPART(dw, 
                      DATEADD(DD, ID, DATEFROMPARTS(2017, 1, 1)))
             BETWEEN 2 AND 6
             AND 
             CAST(DATEADD(DD, ID, DATEFROMPARTS(2017, 1, 1)) 
               AS DATE) <= '20171231'
)
SELECT        CTE.WeekdayDate
             ,CTE.WeekdayName
             ,SUM(SLS.SalePrice) AS TotalDailySales
FROM         Data.SalesByCountry SLS
INNER JOIN   DateList_CTE CTE
             ON CTE.WeekdayDate = CAST(SLS.SaleDate AS DATE)
GROUP BY      CTE.WeekdayDate
             ,CTE.WeekdayName
ORDER BY     CTE.WeekdayDate



-- 7

;
WITH TallyTable_CTE
AS
(
SELECT     ROW_NUMBER() OVER (ORDER BY StockCode) - 1 AS ID
FROM       Data.Stock
)
SELECT       CAST(DATEADD(DD, ID, '20171201') AS DATE) 
               AS WeekdayDate
FROM         TallyTable_CTE
WHERE        ID <= DATEDIFF(DD, '20171201', '20171213')
             AND DATEPART(dw, DATEADD(DD, ID, '20171201')) 
             IN (1,7)


-- 8

;
WITH TallyTable_CTE
AS
(
SELECT     ROW_NUMBER() OVER (ORDER BY StockCode) - 1 AS ID
FROM       Data.Stock
)
,WeekendList_CTE
AS
(
SELECT        CAST(DATEADD(DD, ID, '20180301') AS DATE) 
                 AS WeekdayDate
FROM         TallyTable_CTE
WHERE        DATEPART(dw, DATEADD(DD, ID, '20180301')) IN (1,7)
             AND ID <= DATEDIFF(DD, '20180301', '20180430')
)
SELECT    COUNT(*) AS WeekendDays FROM WeekendList_CTE


-- 9

;
WITH TallyTable_CTE
AS
(
SELECT     ROW_NUMBER() OVER (ORDER BY StockCode) AS ID
FROM       Data.Stock
)
,LastDayOfMonth_CTE
AS
(
SELECT        EOMONTH(DATEFROMPARTS(2016, ID, 1)) AS LastDayDate
FROM         TallyTable_CTE
WHERE        ID <= 12
)
SELECT        CTE.LastDayDate
             ,SUM(SLS.SalePrice) AS TotalDailySales
FROM         Data.SalesByCountry SLS
INNER JOIN   LastDayOfMonth_CTE CTE
             ON CTE.LastDayDate = CAST(SLS.SaleDate AS DATE)
GROUP BY     CTE.LastDayDate
ORDER BY     CTE.LastDayDate


-- 10

;
WITH TallyTable_CTE
AS
(
SELECT     ROW_NUMBER() OVER (ORDER BY StockCode) AS ID
FROM       Data.Stock
)
,LastDayOfMonth_CTE
AS
(
SELECT        EOMONTH(DATEFROMPARTS(2017, ID, 1)) AS MonthEndDate
             ,DATEPART(DW, EOMONTH(DATEFROMPARTS(2017, ID, 1))) 
             AS MonthEndDay
FROM         TallyTable_CTE
WHERE        ID <= 12
)
SELECT       MonthEndDate
                   ,DATEADD(dd
                              ,CASE
                                 WHEN MonthEndDay >= 6 THEN 6 
                                                        - MonthEndDay
                                 ELSE (6 - MonthEndDay) - 7
                               END
                              ,MonthEndDate) AS LastFridayOfMonth
FROM         LastDayOfMonth_CTE




-- 11

SELECT       ST.StockCode
            ,DATEDIFF(dd, ST.DateBought, SA.SaleDate) / 365 
                   AS Years
            ,(DATEDIFF(dd, ST.DateBought, SA.SaleDate) % 365) / 30 
                   AS Months
            ,(DATEDIFF(dd, ST.DateBought, SA.SaleDate)  % 365) % 30
                   AS Days
            ,DATEDIFF(dd, ST.DateBought, SA.SaleDate) / 30
                   AS TotalMonths
            ,DATEDIFF(dd, ST.DateBought, SA.SaleDate) % 365
                   AS DaysInYear
FROM        Data.Stock ST
INNER JOIN   Data.SalesDetails SD
             ON ST.StockCode = SD.StockID 
INNER JOIN   Data.Sales SA
             ON SD.SalesID = SA.SalesID 
ORDER BY      DATEDIFF(dd, ST.DateBought, SA.SaleDate) / 365 DESC
             ,DATEDIFF(dd, ST.DateBought, SA.SaleDate) % 365 DESC


-- 12

SELECT       ST.DateBought
            ,SA.SaleDate
            ,MK.MakeName + '-' + MD.ModelName AS MakeAndModel
            ,(DATEDIFF(second, ST.DateBought, SA.SaleDate) 
               % (24*60*60)) 
              / 3600   AS Hours
            ,((DATEDIFF(second, ST.DateBought, SA.SaleDate) 
               % (24*60*60)) % 3600) / 60   AS Minutes
            ,(((DATEDIFF(second, ST.DateBought, SA.SaleDate)  
               % 365) 
              % (24*60*60)) % 3600) % 60   AS Seconds
FROM         Data.Stock ST
             INNER JOIN Data.Model MD
             ON ST.ModelID = MD.ModelID 
INNER JOIN   Data.Make MK
             ON MD.MakeID = MK.MakeID 
INNER JOIN   Data.SalesDetails SD
             ON ST.StockCode = SD.StockID 
INNER JOIN   Data.Sales SA
             ON SD.SalesID = SA.SalesID 
WHERE       (DATEDIFF(dd, ST.DateBought, SA.SaleDate) % 365) = 1
            AND YEAR(SA.SaleDate) = 2017



-- 13

SELECT     MakeName, ModelName, SalePrice
          ,FORMAT(SaleDate, 't') AS TimeOfDaySold
FROM      Data.SalesByCountry
WHERE     YEAR(SaleDate) = 2017
ORDER BY  CONVERT(TIME, SaleDate)



-- 14

SELECT      CAST(HourOfDay AS VARCHAR(2)) + '-' 
            + CAST(HourOfDay + 1 
            AS VARCHAR(2)) AS HourBand
            ,SUM(SalePrice) AS SalesByHourBand
FROM
    (
     SELECT     SalePrice
               ,DATEPART(hh, SaleDate) AS HourOfDay
     FROM      Data.SalesByCountry
     WHERE     YEAR(SaleDate) = 2017
    ) A
GROUP BY   HourOfDay
ORDER BY   HourOfDay



-- 15

SELECT      QuarterOfHour 
           ,SUM(SalePrice) AS SalesByQuarterHourBand
FROM
    (
     SELECT     SalePrice
               ,(DATEPART(mi, SaleDate) / 15) + 1 AS QuarterOfHour
     FROM      Data.SalesByCountry
     WHERE     YEAR(SaleDate) = 2017
    ) A
GROUP BY   QuarterOfHour
ORDER BY   QuarterOfHour
