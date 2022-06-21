-- ==========================================================
--
--              CHAPTER 6
--
-- ==========================================================



-- 1

SELECT   MakeName, ModelName
         ,Cost + RepairsCost + PartsCost + TransportInCost AS TotalCost
FROM     Data.SalesByCountry


-- 3

SELECT   MakeName, ModelName
         ,SalePrice - (Cost + RepairsCost + PartsCost + TransportInCost) 
         AS GrossMargin	
FROM     Data.SalesByCountry 


-- 4

SELECT   (SalePrice - (Cost + RepairsCost + PartsCost + TransportInCost)) 
         / SalePrice AS RatioOfCostsToSales
FROM     Data.SalesByCountry	


-- 5

SELECT (SalePrice * 1.05) 
       - (Cost + RepairsCost + PartsCost + TransportInCost) 
       AS ImprovedSalesMargins
FROM   Data.SalesByCountry	


-- 6

SELECT TOP 50 MakeName
          ,(SalePrice - (Cost + RepairsCost + PartsCost + TransportInCost)) 
          / SalePrice AS Profitability 
FROM      Data.SalesByCountry 	
ORDER BY  Profitability DESC


-- 7

SELECT   MakeName, ModelName
         ,Cost + RepairsCost + ISNULL(PartsCost, 0)  + TransportInCost 
         AS TotalCost	
FROM     Data.SalesByCountry


-- 8

SELECT     DISTINCT MK.MakeName, MD.ModelName, SD.SalePrice
FROM       Data.Make AS MK
INNER JOIN Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
WHERE      SD.SalePrice - 
             (ST.Cost + ST.RepairsCost + ST.PartsCost
              + ST.TransportInCost) > 5000



-- 9

SELECT     DISTINCT MK.MakeName, MD.ModelName
FROM       Data.Make AS MK
INNER JOIN Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
WHERE      (ST.Color = 'Red' AND SD.LineItemDiscount >= 1000 
           AND (SD.SalePrice - (ST.Cost + ST.RepairsCost 
                                + ST.PartsCost 
                                + ST.TransportInCost)) > 5000) 
		OR (ST.PartsCost > 500 AND ST.RepairsCost > 500)


