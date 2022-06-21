-- ==========================================================
--
--              CHAPTER 2
--
-- ==========================================================


-- 2

SELECT     ModelName, Cost
FROM       Data.Model
INNER JOIN Data.Stock
           ON Model.ModelID = Stock.ModelID
ORDER BY   ModelName


-- 3

SELECT DISTINCT  CountryName
FROM             Data.Customer
INNER JOIN       Data.Country			
                 ON Customer.Country = Country.CountryISO2


-- 4

SELECT     Make.MakeName, Model.ModelName, Stock.Cost
FROM       Data.Stock 	
INNER JOIN Data.Model	
           ON Model.ModelID = Stock.ModelID
INNER JOIN Data.Make
           ON Make.MakeID = Model.MakeID


-- 5

SELECT     S.InvoiceNumber, D.LineItemNumber, D.SalePrice
           ,D.LineItemDiscount
FROM       Data.Sales AS S
INNER JOIN Data.SalesDetails AS D
           ON S.SalesID = D.SalesID	
ORDER BY   S.InvoiceNumber, D.LineItemNumber


-- 6

SELECT      CY.CountryName
           ,MK.MakeName
           ,MD.ModelName
           ,ST.Cost
           ,ST.RepairsCost
           ,ST.PartsCost
           ,ST.TransportInCost
           ,ST.Color
           ,SD.SalePrice
           ,SD.LineItemDiscount
           ,SA.InvoiceNumber
           ,SA.SaleDate
           ,CS.CustomerName
FROM       Data.Stock ST 
INNER JOIN Data.Model MD 
           ON ST.ModelID = MD.ModelID 
INNER JOIN Data.Make MK 
           ON MD.MakeID = MK.MakeID 
INNER JOIN Data.SalesDetails SD 
           ON ST.StockCode = SD.StockID 
INNER JOIN Data.Sales SA 
           ON SD.SalesID = SA.SalesID 
INNER JOIN Data.Customer CS 
           ON SA.CustomerID = CS.CustomerID 
INNER JOIN Data.Country CY 
           ON CS.Country = CY.CountryISO2
ORDER BY    CY.CountryName
           ,MK.MakeName
           ,MD.ModelName

