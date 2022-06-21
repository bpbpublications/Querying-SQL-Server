-- ==========================================================
--
--              CHAPTER 3
--
-- ==========================================================


-- 1

WITH Sales2015_CTE 
AS
(
SELECT     MK.MakeName, MD.ModelName, ST.Color
FROM       Data.Make AS MK
INNER JOIN Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
WHERE      YEAR(SA.SaleDate) = 2015	
)
SELECT     MakeName, ModelName, Color
FROM       Sales2015_CTE
GROUP BY   MakeName, ModelName, Color


-- 2

;
WITH Sales_CTE
AS
(
SELECT     MK.MakeName
           ,SalePrice - (
                         ST.Cost 
                         + ST.RepairsCost 
                         + ST.PartsCost 
                         + ST.TransportINCost
                        ) AS Profit
FROM       Data.Make AS MK 
INNER JOIN Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
)

SELECT     MakeName, AVG(Profit) AS AverageProfit
FROM       Sales_CTE
GROUP BY   MakeName


-- 3

;
WITH Discount2015_CTE (Make, Model, Color, SalePrice, LineItemDiscount)
AS
(
SELECT     MK.MakeName, MD.ModelName, ST.Color
           ,SD.SalePrice, SD.LineItemDiscount
FROM       Data.Make AS MK
INNER JOIN Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
WHERE      YEAR(SaleDate) = 2015
)
SELECT     Make, Model, Color, LineItemDiscount, SalePrice
           ,(SELECT AVG(LineItemDiscount) * 2 FROM Discount2015_CTE) 
           AS AverageDiscount
FROM       Discount2015_CTE
WHERE      LineItemDiscount > (SELECT AVG(LineItemDiscount) * 2 
                               FROM Discount2015_CTE)



-- 4

;
WITH ExpensiveCar_CTE (
                        MakeName, ModelName, SalePrice
                       ,Color, TransportInCost, SaleDate
                       ,InvoiceNumber, CustomerName
)
AS
(
SELECT     MK.MakeName, MD.ModelName, SD.SalePrice, ST.Color
           ,ST.TransportInCost, SA.SaleDate, SA.InvoiceNumber
           ,CU.CustomerName
FROM       Data.Make AS MK
INNER JOIN Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
INNER JOIN Data.Customer CU ON SA.CustomerID = CU.CustomerID
WHERE      YEAR(SaleDate) = 2015
)
SELECT     SLS.MakeName, SLS.ModelName, SLS.Color, CustomerName
           ,SLS.TransportInCost, SLS.SaleDate, SLS.InvoiceNumber
FROM       ExpensiveCar_CTE SLS
           INNER JOIN (
                       SELECT    MakeName
                                ,MAX(SalePrice) AS MaxSalePrice
                       FROM     ExpensiveCar_CTE
                       GROUP BY MakeName
                      ) MX
           ON SLS.MakeName = MX.MakeName
           AND SLS.SalePrice = MX.MaxSalePrice


-- 5

;
WITH SalesBudget_CTE
AS
(
SELECT     BudgetValue, BudgetDetail, Year, Month
FROM       Reference.Budget
WHERE      BudgetElement = 'Country'
)

SELECT     CO.CountryName, YEAR(SA.SaleDate) AS YearOfSale
           ,MONTH(SA.SaleDate) AS MonthOfSale
           ,SUM(SD.SalePrice) AS SalePrice
           ,SUM(CTE.BudgetValue) AS BudgetValue
           ,SUM(CTE.BudgetValue) 
           - SUM(SD.SalePrice) AS DifferenceBudgetToSales
FROM       Data.Make AS MK
INNER JOIN Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
INNER JOIN Data.Customer CU ON SA.CustomerID = CU.CustomerID
INNER JOIN Data.Country CO ON CU.Country = CO.CountryISO2
INNER JOIN SalesBudget_CTE CTE
           ON CTE.BudgetDetail = CO.CountryName
           AND CTE.Year = YEAR(SA.SaleDate)
           AND CTE.Month = MONTH(SA.SaleDate)
GROUP BY   CO.CountryName, YEAR(SA.SaleDate), MONTH(SaleDate)



-- 6
;
WITH
ColorSales_CTE
AS
(
SELECT     Color
           ,SUM(SD.SalePrice) AS TotalSalesValue
FROM       Data.Stock ST 
INNER JOIN Data.SalesDetails SD 
           ON ST.StockCode = SD.StockID 
INNER JOIN Data.Sales SA 
           ON SD.SalesID = SA.SalesID 
WHERE      YEAR(SA.SaleDate) = 2016
GROUP BY   Color
)
,
ColorBudget_CTE
AS
(
SELECT  BudgetDetail AS Color, BudgetValue
FROM    Reference.Budget
WHERE   BudgetElement = 'Color'
            AND YEAR = 2016
)

SELECT      BDG.Color, SLS.TotalSalesValue, BDG.BudgetValue
            ,(SLS.TotalSalesValue - BDG.BudgetValue) AS BudgetDelta

FROM        ColorSales_CTE SLS
INNER JOIN  ColorBudget_CTE BDG
            ON SLS.Color = BDG.Color



-- 7

;
WITH Outer2015Sales_CTE
AS
(
SELECT     MK.MakeName
FROM       Data.Make AS MK
INNER JOIN Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
WHERE      YEAR(SA.SaleDate) = 2015
)
,
CoreSales_CTE (MakeName, NumberOfSales)
AS
(
SELECT     MakeName
           ,COUNT(*)
FROM       Outer2015Sales_CTE
GROUP BY   MakeName
HAVING     COUNT(*) >= 2
)

SELECT      CTE.MakeName, MK2.MakeCountry AS CountryCode
           ,CTE.NumberOfSales 
FROM       CoreSales_CTE CTE
INNER JOIN Data.Make MK2
           ON CTE.MakeName = MK2.MakeName



-- 8

;
WITH Initial2017Sales_CTE
AS
(
SELECT     SD.SalePrice, CU.CustomerName, SA.SaleDate
FROM       Data.Make AS MK
INNER JOIN Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
INNER JOIN Data.Customer CU ON SA.CustomerID = CU.CustomerID
WHERE      YEAR(SaleDate) = 2017
)
,
AggregateSales_CTE (CustomerName, SalesForCustomer)
AS
(
SELECT     CustomerName, SUM(SalePrice)
FROM       Initial2017Sales_CTE
GROUP BY   CustomerName
)
,
TotalSales_CTE (TotalSalePrice)
AS
(
SELECT     SUM(SalePrice)
FROM       Initial2017Sales_CTE
)

SELECT
 IT.CustomerName
,IT.SalePrice
, IT.SaleDate
,FORMAT(IT.SalePrice / AG.SalesForCustomer, '0.00%')
           AS SaleAsPercentageForCustomer
,FORMAT(IT.SalePrice / TT.TotalSalePrice, '0.00%')
           AS SalePercentOverall
FROM       Initial2017Sales_CTE IT
           INNER JOIN AggregateSales_CTE AG
           ON IT.CustomerName = AG.CustomerName
           CROSS APPLY TotalSales_CTE TT
 ORDER BY  IT.SaleDate, IT.CustomerName


