-- ==========================================================
--
--              CHAPTER 4
--
-- ==========================================================


-- 1

SELECT
SalesDetailsID
,SalePrice
,(SELECT TotalSalePrice FROM Data.sales 
  WHERE SalesId = SD.SalesId) AS TotalSales
FROM Data.SalesDetails SD


-- 2

SELECT
 CS.CustomerName
,SA.INVOICENUMBER
,SD.SalePrice
,SD.SalePrice
/
(
SELECT     SUM(SDC.SalePrice)
FROM       Data.SalesDetails SDC
INNER JOIN Data.Sales SAC 
           ON SDC.SalesID = SAC.SalesID 
INNER JOIN Data.Customer CSC 
           ON SAC.CustomerID = CSC.CustomerID 
WHERE      SAC.CustomerID = CS.CustomerID
) * 100 AS PercentSalesPerCustomer

FROM       Data.SalesDetails SD 
INNER JOIN Data.Sales SA 
           ON SD.SalesID = SA.SalesID 
INNER JOIN Data.Customer CS 
           ON SA.CustomerID = CS.CustomerID 
ORDER BY   CS.CustomerName


-- 3

SELECT     MKX.MakeName, STX.RepairsCost, STX.StockCode
FROM       Data.Make AS MKX INNER JOIN Data.Model AS MDX 
           ON MKX.MakeID = MDX.MakeID
INNER JOIN Data.Stock AS STX ON STX.ModelID = MDX.ModelID
INNER JOIN Data.SalesDetails SDX ON STX.StockCode = SDX.StockID
WHERE      STX.RepairsCost >
                 (
                  SELECT     AVG(ST.RepairsCost) AS AvgRepairCost
                  FROM       Data.Make AS MK
                  INNER JOIN Data.Model AS MD 
                             ON MK.MakeID = MD.MakeID
                  INNER JOIN Data.Stock AS ST 
                             ON ST.ModelID = MD.ModelID
                   WHERE     MK.MakeName = MKX.MakeName
                  ) * 1.5



-- 4

SELECT     MKX.MakeName, STX.RepairsCost, STX.StockCode
,(
    SELECT     AVG(ST.RepairsCost) AS AvgRepairCost
    FROM       Data.Make AS MK
    INNER JOIN Data.Model AS MD 
               ON MK.MakeID = MD.MakeID
    INNER JOIN Data.Stock AS ST 
               ON ST.ModelID = MD.ModelID
    WHERE     MK.MakeName = MKX.MakeName
 ) AS MakeAvgRepairCost

FROM       Data.Make AS MKX 
INNER JOIN Data.Model AS MDX 
           ON MKX.MakeID = MDX.MakeID
INNER JOIN Data.Stock AS STX ON STX.ModelID = MDX.ModelID
INNER JOIN Data.SalesDetails SDX ON STX.StockCode = SDX.StockID
WHERE      STX.RepairsCost >
                 (
                  SELECT     AVG(ST.RepairsCost) AS AvgRepairCost
                  FROM       Data.Make AS MK
                  INNER JOIN Data.Model AS MD 
                             ON MK.MakeID = MD.MakeID
                  INNER JOIN Data.Stock AS ST 
                             ON ST.ModelID = MD.ModelID
                   WHERE     MK.MakeName = MKX.MakeName
                  ) * 1.5


-- 5

SELECT     CUX.CustomerName
          ,CUX.Town
          ,COX.CountryName
FROM       Data.Customer CUX
INNER JOIN Data.Country COX ON CUX.Country = COX.CountryISO2
WHERE      CUX.CustomerID IN
                (
                 SELECT     TOP (2) CU.CustomerID
                 FROM       Data.Make AS MK 
                 INNER JOIN Data.Model AS MD 
                            ON MK.MakeID = MD.MakeID
                 INNER JOIN Data.Stock AS ST 
                            ON ST.ModelID = MD.ModelID
                 INNER JOIN Data.SalesDetails SD 
                            ON ST.StockCode = SD.StockID
                 INNER JOIN Data.Sales AS SA
                            ON SA.SalesID = SD.SalesID
                 INNER JOIN Data.Customer CU 
                            ON SA.CustomerID = CU.CustomerID
                 INNER JOIN Data.Country CO 
                            ON CU.Country = CO.CountryISO2
                  WHERE      CUX.Country = CU.Country
                  GROUP BY   CU.CustomerID
                  ORDER BY   SUM(SD.SalePrice) DESC
                 )
ORDER BY   COX.CountryName, CUX.CustomerName 


-- 6

SELECT     MKX.MakeName, MDX.ModelName
FROM       Data.Make AS MKX 
           INNER JOIN Data.Model AS MDX ON MKX.MakeID = MDX.MakeID
           INNER JOIN Data.Stock AS STX ON STX.ModelID = MDX.ModelID
GROUP BY   MKX.MakeName, MDX.ModelName
HAVING     MAX(STX.Cost) >= 
                  (
                   SELECT     AVG(ST.Cost) * 1.5 
                              AS AvgCostPerModel
                   FROM       Data.Make AS MK 
                   INNER JOIN Data.Model AS MD 
                              ON MK.MakeID = MD.MakeID
                   INNER JOIN Data.Stock AS ST 
                              ON ST.ModelID = MD.ModelID
                   WHERE      MD.ModelName = MDX.ModelName
                              AND MK.MakeName = MKX. MakeName
                    )



-- 7

SELECT DISTINCT    CU.CustomerName
FROM               Data.Customer CU
WHERE              EXISTS
                   (
                    SELECT    *
                    FROM      Data.Sales SA
                    WHERE     SA.CustomerID = CU.CustomerID
                              AND YEAR(SA.SaleDate) = 2017
                   )
ORDER BY           CU.CustomerName


-- 8

SELECT     MakeName + ', ' + ModelName 
           AS VehicleInStock, ST.STOCKCODE
FROM       Data.Make AS MK 
INNER JOIN Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
WHERE      NOT EXISTS
                      (SELECT  *
                       FROM    Data.SalesDetails SD
                       WHERE   ST.StockCode = SD.StockID)



-- 9

SELECT     MKX.MakeName, YEAR(STX.DateBought) AS PurchaseYear
FROM       Data.Make AS MKX INNER JOIN Data.Model AS MDX 
           ON MKX.MakeID = MDX.MakeID
           INNER JOIN Data.Stock AS STX ON STX.ModelID 
                   = MDX.ModelID
WHERE      YEAR(STX.DateBought) IN (2015, 2016)
GROUP BY   MKX.MakeName, YEAR(STX.DateBought)
HAVING     MAX(STX.Cost) >= 
                          (
                           SELECT  AVG(ST.Cost) * 2 
                               AS AvgCostPerModel
                           FROM    Data.Make AS MK 
                                   INNER JOIN Data.Model AS MD 
                                   ON MK.MakeID = MD.MakeID
                                   INNER JOIN Data.Stock AS ST 
                                   ON ST.ModelID = MD.ModelID
                           WHERE     MK.MakeName = MKX.MakeName
                                     AND YEAR(ST.DateBought) 
                                         = YEAR(STX.DateBought)
                         )


-- 10

SELECT     SalesID
           ,TotalSalePrice
          ,CASE WHEN 
                     (
                       SELECT SUM(SalePrice)
                        FROM   Data.SalesDetails
                        WHERE  SalesID = Data.Sales.SalesID
                      ) = TotalSalePrice
                            THEN 'OK'
                            ELSE 'Error in Invoice'
                 END AS LineItemCheck
FROM       Data.Sales



