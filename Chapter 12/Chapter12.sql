-- ==========================================================
--
--              CHAPTER 1
--
-- ==========================================================


-- 1

SELECT      CO.CountryName
           ,COUNT(SD.StockID) AS CarsSold
           ,(SELECT COUNT(SalesDetailsID)
             FROM Data.SalesDetails) AS SalesTotal
FROM       Data.SalesDetails SD 
INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
INNER JOIN Data.Customer CU ON SA.CustomerID = CU.CustomerID
INNER JOIN Data.Country CO ON CU.Country = CO.CountryISO2
GROUP BY   CO.CountryName	


-- 2

SELECT     MK.MakeName
           ,SUM(SD.SalePrice) AS SalePrice
           ,SUM(SD.SalePrice) / (SELECT SUM(SalePrice) 
                              FROM Data.SalesDetails) 
                              AS SalesRatio
FROM       Data.Make AS MK
INNER JOIN Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
GROUP BY   MK.MakeName	


-- 3

SELECT     ST.Color
FROM       Data.Stock AS ST 
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
WHERE      SD.SalePrice = 
                    (SELECT MAX(SalePrice) FROM Data.SalesDetails)
	


-- 4

SELECT     MK.MakeName, MD.ModelName, ST.RepairsCost
FROM       Data.Make AS MK
INNER JOIN Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
WHERE      ST.RepairsCost > 3 * 
                       (SELECT AVG(RepairsCost) FROM Data.Stock)


-- 5

SELECT     MK.MakeName, MD.ModelName, ST.Cost, ST.RepairsCost
FROM       Data.Make AS MK
INNER JOIN Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
WHERE      RepairsCost BETWEEN
                   (SELECT AVG(RepairsCost) FROM Data.Stock) * 0.9
                       AND
                   (SELECT AVG(RepairsCost) FROM Data.Stock) * 1.1


-- 6

SELECT     MK.MakeName, AVG(SD.SalePrice) AS AverageUpperSalePrice
FROM       Data.Make AS MK
INNER JOIN Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
GROUP BY   MK.MakeName
HAVING     AVG(SD.SalePrice) > 2 * (SELECT AVG(SalePrice)
                                    FROM   Data.SalesDetails)


-- 7

SELECT     MKX.MakeName, SDX.SalePrice
FROM       Data.Make AS MKX 
INNER JOIN Data.Model AS MDX ON MKX.MakeID = MDX.MakeID
INNER JOIN Data.Stock AS STX ON STX.ModelID = MDX.ModelID
INNER JOIN Data.SalesDetails SDX ON STX.StockCode = SDX.StockID
WHERE      MakeName IN (
                        SELECT     TOP (5) MK.MakeName
                        FROM       Data.Make AS MK 
                        INNER JOIN Data.Model AS MD 
                                   ON MK.MakeID = MD.MakeID
                        INNER JOIN Data.Stock AS ST 
                                   ON ST.ModelID = MD.ModelID
                        INNER JOIN Data.SalesDetails SD 
                                   ON ST.StockCode = SD.StockID
                        INNER JOIN Data.Sales SA
                                   ON SA.SalesID = SD.SalesID
                        GROUP BY   MK.MakeName
                        ORDER BY   SUM(SA.TotalSalePrice) DESC
                        )
ORDER BY   MKX.MakeName, SDX.SalePrice DESC


-- 8

SELECT      MK.MakeName
           ,COUNT(MK.MakeName) AS VehiclesSold
           ,SUM(SD.SalePrice) AS TotalSalesPerMake
FROM       Data.Make AS MK
INNER JOIN Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
WHERE      MakeName IN (
                        SELECT     TOP (3) MK.MakeName
                        FROM       Data.Make AS MK 
                        INNER JOIN Data.Model AS MD 
                                   ON MK.MakeID = MD.MakeID
                        INNER JOIN Data.Stock AS ST 
                                   ON ST.ModelID = MD.ModelID
                        INNER JOIN Data.SalesDetails SD 
                                   ON ST.StockCode = SD.StockID
                        INNER JOIN Data.Sales AS SA 
                                   ON SA.SalesID = SD.SalesID
                        GROUP BY    MK.MakeName
                        ORDER BY   COUNT(MK.MakeName) DESC
                       )
GROUP BY  MK.MakeName
ORDER BY  VehiclesSold DESC



-- 9

SELECT      DISTINCT STX.Color
FROM        Data.Stock STX
INNER JOIN  Data.SalesDetails SDX 
            ON STX.StockCode = SDX.StockID
WHERE       SDX.SalesID IN (
                        SELECT     TOP 5 PERCENT SalesID
                        FROM       Data.Stock AS ST
                        INNER JOIN Data.SalesDetails SD 
                                   ON ST.StockCode = SD.StockID
                        ORDER BY   (SD.SalePrice - 
                                    (Cost + ISNULL(RepairsCost, 0)
                                    + PartsCost + TransportInCost)
                                    ) ASC
                        )

-- 10

SELECT     TOP 5 MK.MakeName, MD.ModelName, SD.SalePrice 
FROM       Data.Make AS MK
INNER JOIN Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID 
WHERE      Color IN (SELECT     ST.Color
                     FROM       Data.Model AS MD
                     INNER JOIN Data.Stock AS ST 
                                ON ST.ModelID = MD.ModelID
                     INNER JOIN Data.SalesDetails SD 
                                ON ST.StockCode = SD.StockID
                     WHERE      SD.SalePrice = 
                                 (
                                  SELECT      MAX(SD.SalePrice) 
                                  FROM        Data.SalesDetails SD
                                  INNER JOIN  Data.Sales SA
                                  ON SA.SalesID = SD.SalesID 
		                      )
                     )
ORDER BY   SD.SalePrice DESC


-- 11

SELECT     MK.MakeName, SUM(SA.TotalSalePrice) AS TotalSales
FROM       Data.Make AS MK INNER JOIN Data.Model AS MD 
           ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
INNER JOIN Data.Customer CU ON SA.CustomerID = CU.CustomerID
INNER JOIN Data.Country CO ON CU.Country = CO.CountryISO2
WHERE      CountryName NOT IN (
                            SELECT     TOP 4 CO.CountryName
                            FROM       Data.Sales AS SA 
                            INNER JOIN Data.Customer CU 
                            ON SA.CustomerID = CU.CustomerID
                            INNER JOIN Data.Country CO 
                            ON CU.Country = CO.CountryISO2
                            GROUP BY   CountryName
                            ORDER BY   SUM(SA.TotalSalePrice) ASC
                               )
GROUP BY   MK.MakeName


-- 12

SELECT     MK.MakeName
           ,SUM(SD.SalePrice) AS SalePrice
           ,SUM(SD.SalePrice) / 
                        (SELECT     SUM(SD.SalePrice) 
                         FROM       Data.SalesDetails SD 
                         INNER JOIN Data.Sales AS SA
                                    ON SA.SalesID = SD.SalesID
                         WHERE      YEAR(SaleDate) = 2015
                        ) AS SalesRatio
FROM       Data.Make AS MK
INNER JOIN Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
WHERE      YEAR(SA.SaleDate) = 2015
GROUP BY   MK.MakeName


-- 13

SELECT      MK.MakeName
           ,MD.ModelName
           ,SD.SalePrice AS ThisYearsSalePrice
           ,SD.SalePrice
             - (SELECT  AVG(SD.SalePrice) 
                FROM       Data.Stock ST
                INNER JOIN Data.SalesDetails SD 
                           ON ST.StockCode = SD.StockID
                INNER JOIN Data.Sales AS SA 
                           ON SA.SalesID = SD.SalesID
                WHERE      YEAR(SA.SaleDate) = 2015) 
                                  AS DeltaToLastYearAverage
FROM       Data.Make AS MK INNER JOIN Data.Model AS MD 
           ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
WHERE      YEAR(SA.SaleDate) = 2016