-- ==========================================================
--
--              CHAPTER 6
--
-- ==========================================================


-- 1

SELECT       CU.CustomerName
            ,FORMAT(
                     CAST(COUNT(CU.CustomerName) AS NUMERIC)
                     / (SELECT CAST(COUNT(*) AS NUMERIC) 
                        FROM Data.Sales)
                     , '0.00 %')
             AS PercentageSalesPerCustomer
FROM        Data.Sales SA
INNER JOIN  Data.Customer CU
            ON CU.CustomerID = SA.CustomerID
GROUP BY    CU.CustomerName
ORDER BY    CU.CustomerName


-- 2

SELECT       MakeName, ModelName, SalePrice
             ,(SalePrice / CRX.TotalSales) * 100 AS PercentOfSales
             ,SalePrice - CRX.AverageSales AS DifferenceToAverage
FROM         Data.SalesByCountry
CROSS JOIN   (SELECT SUM(SalePrice) AS TotalSales
                     ,AVG(SalePrice) AS AverageSales 
              FROM   Data.SalesByCountry 
              WHERE  YEAR(SaleDate) = 2017) AS CRX
WHERE        YEAR(SaleDate) = 2017


-- 3

SELECT      MakeName
            ,Cost AS PurchaseCost
            ,TotalOtherCosts
            ,Cost + TotalOtherCosts AS VehicleCost
FROM        Data.SalesByCountry
CROSS APPLY	
     (		
      SELECT RepairsCost + PartsCost + TransportInCost AS TotalOtherCosts
     ) SQ
WHERE        TotalOtherCosts > 10000


-- 4

SELECT       MakeName
            ,ModelName
            ,CAST(Cost AS INT) AS Cost
            ,CAST(RepairsCost AS INT) AS RepairsCost
            ,CAST(PartsCost AS INT) AS PartsCost
            ,CAST(SalePrice AS INT) AS SalePrice
FROM        Data.SalesByCountry


-- 6

SELECT       CountryName
            ,MakeName	
            ,TRY_CAST(Cost AS NUMERIC(20,4)) AS Cost
            ,TRY_CAST(SalePrice AS NUMERIC(20,4)) AS SalePrice
FROM        SourceData.SalesText


-- 7

SELECT       MakeName
            ,ModelName	
            ,PARSE(VehicleCost AS money USING 'EN-GB') AS VehicleCost
FROM        SourceData.SalesInPounds


-- 8

SELECT      MD.ModelName 
            ,ST.Cost
            ,CASE
                WHEN ST.PartsCost != 0 THEN ST.Cost / ST.PartsCost
                ELSE 0
            END AS PartsCostMultiple 
FROM        Data.Stock ST
            INNER JOIN Data.Model MD
            ON ST.ModelID = MD.ModelID


-- 9

SELECT    CustomerID
FROM
     (
     SELECT      CustomerID
                 ,CustomerID % 3 AS ModuloOutput
                 ,CASE
                       WHEN CustomerID % 3 = 1 THEN 'Winner'
                           ELSE NULL
                   END AS LuckyWinner
     FROM        Data.Customer
     ) Rnd
WHERE       LuckyWinner IS NOT NULL


-- 10

SELECT
 InitialCost
,MonthsSincePurchase
,(InitialCost * POWER(1 + (0.75 / 100), MonthsSincePurchase)) 
- InitialCost AS InterestCharge
,InitialCost * POWER(1 + (0.75 / 100), MonthsSincePurchase) 
 AS TotalWithInterest
FROM
(
   SELECT
    DATEDIFF(mm, DateBought, SL.SaleDate) AS MonthsSincePurchase
   ,(Cost + PartsCost + RepairsCost) AS InitialCost

    FROM         Data.Stock SK
    INNER JOIN   Data.SalesDetails SD
                 ON SK.StockCode = SD.StockID
    INNER JOIN   Data.Sales SL
                 ON SL.SalesID = SD.SalesID
    WHERE        DATEDIFF(mm, DateBought, SL.SaleDate) > 2
) SRC



-- 11

SELECT                  RowNo AS PeriodNumber
                        ,Cost
                        ,Cost / 5 AS StraightLineDepreciation
                        ,Cost - ((Cost / 5) * RowNo) AS RemainingValue

FROM                  Data.Stock
CROSS APPLY
(
SELECT 1 AS RowNo
UNION ALL
SELECT 2
UNION ALL
SELECT 3
UNION ALL
SELECT 4
UNION ALL
SELECT 5
) Tally
WHERE                  StockCode = 
                           'A2C3B95E-3005-4840-8CE3-A7BC5F9CFB5F'



--12

SELECT       TOP 5 PERCENT *
FROM         Data.SalesByCountry
ORDER BY     NEWID()





