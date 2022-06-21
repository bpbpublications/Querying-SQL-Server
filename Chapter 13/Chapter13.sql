-- ==========================================================
--
--              CHAPTER 2
--
-- ==========================================================



-- 1

SELECT
 MakeName
,ModelName
,SaleDate
,SalePrice
,Cost
,SalePrice - DirectCosts AS GrossProfit
,SalePrice - DirectCosts - LineItemDiscount AS NetProfit
FROM
(
  SELECT     
   MK.MakeName
  ,MD.ModelName
  ,SA.SaleDate
  ,SD.SalePrice
  ,ST.Cost
  ,LineItemDiscount
  ,(ISNULL(ST.RepairsCost, 0) + ST.PartsCost 
  + ST.TransportInCost) AS DirectCosts
  FROM       Data.Make AS MK INNER JOIN Data.Model 
             AS MD ON MK.MakeID = MD.MakeID
             INNER JOIN Data.Stock AS ST ON ST.ModelID =
                        MD.ModelID
             INNER JOIN Data.SalesDetails SD ON ST.StockCode =
                        SD.StockID
             INNER JOIN Data.Sales AS SA ON SA.SalesID =
                        SD.SalesID
  ) DT



-- 2

SELECT     DT.CustomerClassification
           ,COUNT(DT.CustomerSpend) AS CustomerSpend
FROM
          (
            SELECT     SUM(SD.SalePrice) AS CustomerSpend
            ,SA.CustomerID
            ,CASE
             WHEN SUM(SD.SalePrice) <= 100000 THEN 'Tiny'
             WHEN SUM(SD.SalePrice) BETWEEN 100001 AND 200000 
                  THEN 'Small'
             WHEN SUM(SD.SalePrice) BETWEEN 200001 AND 300000 
                  THEN 'Medium'
             WHEN SUM(SD.SalePrice) BETWEEN 300001 AND 400000 
                  THEN 'Large'
             WHEN SUM(SD.SalePrice) > 400000 THEN 'Mega Rich'
            END AS CustomerClassification
            FROM       Data.SalesDetails SD 
                       INNER JOIN Data.Sales AS SA 
                       ON SA.SalesID = SD.SalesID
            GROUP BY   SA.CustomerID
         ) AS DT
GROUP BY   DT.CustomerClassification
ORDER BY   CustomerSpend DESC


-- 3

SELECT    ST.DateBought, MK.MakeName, MD.ModelName, ST.Color
          ,ST.Cost, SD.SalePrice, DT.AveragePurchasePrice
          ,DT.AverageSalePrice
FROM
     (
      SELECT     MakeName 
                 ,ModelName 
                 ,AVG(Cost) AS AveragePurchasePrice
                 ,AVG(SalePrice) AS AverageSalePrice
      FROM       Data.Make AS MK1
                 INNER JOIN Data.Model AS MD1 
                            ON MK1.MakeID = MD1.MakeID
	            INNER JOIN Data.Stock AS ST1 
                            ON ST1.ModelID = MD1.ModelID 
                 INNER JOIN Data.SalesDetails SD1 
                            ON ST1.StockCode = SD1.StockID
      GROUP BY   MakeName, ModelName
     ) AS DT
     INNER JOIN Data.Make AS MK
     INNER JOIN Data.Model AS MD ON MK.MakeID = MD.MakeID
     INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
     INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
     ON MK.MakeName = DT.MakeName
     AND MD.ModelName = DT.ModelName
ORDER BY   ST.DateBought, MK.MakeName, MD.ModelName


-- 4

SELECT 
TOT.PurchaseYear
,AGG.Color
,(AGG.CostPerYear / TOT.TotalPurchasePrice) * 100 
                         AS PercentPerColorPerYear
FROM
   (
    SELECT       STX.Color
                ,SUM(STX.Cost) AS CostPerYear
                ,YEAR(STX.DateBought) AS YearBought
    FROM        Data.Make AS MKX 
    INNER JOIN  Data.Model AS MDX ON MKX.MakeID = MDX.MakeID
    INNER JOIN  Data.Stock AS STX ON STX.ModelID = MDX.ModelID
    GROUP BY    STX.Color
                ,YEAR(STX.DateBought)
   ) AGG
INNER JOIN
   (
    SELECT      YEAR(DateBought) AS PurchaseYear, SUM(Cost) 
                AS TotalPurchasePrice
    FROM        Data.Stock
    GROUP BY    YEAR(DateBought)
   ) TOT
ON TOT.PurchaseYear = AGG.YearBought
ORDER BY PurchaseYear, PercentPerColorPerYear DESC


-- 5

SELECT 
 DT2.CountryName
,DT2.CustomerName
,DT2.NumberOfCustomerSales
,DT2.TotalCustomerSales
,CAST(DT2.NumberOfCustomerSales AS NUMERIC) 
  / CAST(DT1.NumberOfCountrySales AS NUMERIC) 
      AS PercentageOfCountryCarsSold
,DT2.TotalCustomerSales / DT1.TotalCountrySales 
      AS PercentageOfCountryCarsSoldByValue
FROM
(
    SELECT      CO.CountryName
               ,COUNT(*) AS NumberOfCountrySales
               ,SUM(SD.SalePrice) AS TotalCountrySales
    FROM       Data.Stock AS ST 
    INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
    INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
    INNER JOIN Data.Customer CU ON SA.CustomerID = CU.CustomerID
    INNER JOIN Data.Country CO ON CU.Country = CO.CountryISO2
    GROUP BY   CO.CountryName
) AS DT1
INNER JOIN
(
    SELECT      CO.CountryName
               ,CU.CustomerName
               ,COUNT(*) AS NumberOfCustomerSales
               ,SUM(SD.SalePrice) AS TotalCustomerSales
    FROM       Data.Stock AS ST 
    INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
    INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
    INNER JOIN Data.Customer CU ON SA.CustomerID = CU.CustomerID
    INNER JOIN Data.Country CO ON CU.Country = CO.CountryISO2
    GROUP BY   CO.CountryName, CU.CustomerName
) AS DT2
ON DT1.CountryName = DT2.CountryName
ORDER BY DT2.CountryName, NumberOfCustomerSales DESC



-- 6

SELECT      CO.CountryName
           ,SUM(SD.SalePrice) AS Sales
           ,SUM(CSQ.BudgetValue) AS BudgetValue
           ,YEAR(SaleDate) AS YearOfSale
           ,MONTH(SaleDate) AS MonthOfSale
           ,SUM(CSQ.BudgetValue) 
           - SUM(SD.SalePrice) AS DifferenceBudgetToSales
 FROM      Data.SalesDetails SD
INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
INNER JOIN Data.Customer CU ON SA.CustomerID = CU.CustomerID
INNER JOIN Data.Country CO ON CU.Country = CO.CountryISO2
INNER JOIN           (
                        SELECT     BudgetValue, BudgetDetail,
                                   Year, Month
                        FROM       Reference.Budget
                        WHERE      BudgetElement = 'Country'
                      ) CSQ
		   ON CSQ.BudgetDetail = CO.CountryName
		   AND CSQ.Year = YEAR(SaleDate)
		   AND CSQ.Month = MONTH(SaleDate)
GROUP BY CO.CountryName, YEAR(SaleDate), MONTH(SaleDate)
ORDER BY CO.CountryName, YEAR(SaleDate), MONTH(SaleDate)


-- 7

SELECT      MK.MakeName
           ,MD.ModelName
           ,SD.SalePrice
           ,CSQ.MaxSalePrice - SD.SalePrice 
                          AS PriceDifferenceToMaxPrevYear
FROM       Data.Make AS MK 
INNER JOIN Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
INNER JOIN  (
                    SELECT     MAX(SDX.SalePrice) AS MaxSalePrice
                              ,YEAR(SAX.SaleDate) AS SaleYear
                              ,MKX.MakeName
                    FROM       Data.Make AS MKX 
                    INNER JOIN Data.Model AS MDX 
                               ON MKX.MakeID = MDX.MakeID
                    INNER JOIN Data.Stock AS STX 
                               ON STX.ModelID = MDX.ModelID
                    INNER JOIN Data.SalesDetails SDX 
                               ON STX.StockCode = SDX.StockID
                    INNER JOIN Data.Sales AS SAX 
                               ON SAX.SalesID = SDX.SalesID
                    WHERE      YEAR(SAX.SaleDate) = 2015
                    GROUP BY   YEAR(SAX.SaleDate)
                               ,MKX.MakeName
               ) CSQ
            ON CSQ.MakeName = MK.MakeName
WHERE       YEAR(SA.SaleDate) = 2016



-- 8

SELECT     ST.Color, ST.DateBought, ST.Cost, CSQ.MinPurchaseCost
FROM       Data.Stock ST
INNER JOIN 
           (
           SELECT     Color, MIN(Cost) AS MinPurchaseCost
                      ,YEAR(DateBought) AS PurchaseYear
           FROM       Data.Stock
           WHERE      YEAR(DateBought) = 2016
           GROUP BY   Color, YEAR(DateBought)     
           ) CSQ
           ON ST.Color = CSQ.Color        
           AND YEAR(ST.DateBought) = CSQ.PurchaseYear - 1


