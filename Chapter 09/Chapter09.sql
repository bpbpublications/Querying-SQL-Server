-- ==========================================================
--
--              CHAPTER 9
--
-- ==========================================================


-- 1

SELECT 'Customer: ' + CustomerName AS Customer
FROM   Data.Customer	


-- 2

SELECT 'Sold For:' + STR(SalePrice) 
FROM    Data.SalesDetails	


-- 3

SELECT CustomerName, Address1 + ' ' + Town + ' ' + PostCode AS FullAddress FROM   Data.Customer

-- 4

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


-- 5

SELECT CustomerName, ISNULL(Address1, '') + ' ' + ISNULL(Town, '') + ' ' 
                     + ISNULL(PostCode, '') AS FullAddress 
FROM   Data.Customer


-- 6

SELECT     CONCAT('Sales: ', TotalSalePrice ,' GBP') AS SalePriceInPounds
FROM       Data.Sales	


-- 7

SELECT     UPPER(CustomerName) AS Customer
FROM       Data.Customer	


-- 8

SELECT     LOWER(ModelName) AS Model
FROM       Data.Model	


-- 9

SELECT     ModelName + ' (' + LEFT(MakeName, 3) + ')' 
           AS MakeAndModel
FROM       Data.Make
INNER JOIN Data.Model
ON         Make.MakeID = Model.MakeID


-- 10

SELECT     RIGHT(InvoiceNumber, 3) AS InvoiceSequenceNumber 
FROM       Data.Sales
ORDER BY   InvoiceSequenceNumber


-- 11

SELECT     SUBSTRING(InvoiceNumber, 4, 2) AS DestinationCountry 
FROM       Data.Sales


-- 12

SELECT     InvoiceNumber, TotalSalePrice
FROM       Data.Sales		
WHERE      LEFT(InvoiceNumber, 3) = 'EUR'


-- 13

SELECT     SA.InvoiceNumber, SA.TotalSalePrice
FROM       Data.Make AS MK INNER JOIN Data.Model AS MD 
           ON MK.MakeID = MD.MakeID
           INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
           INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
           INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
WHERE      SUBSTRING(SA.InvoiceNumber, 4, 2)  = 'FR'
           AND MK.MakeCountry = 'ITA'



