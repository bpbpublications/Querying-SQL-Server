-- ==========================================================
--
--              CHAPTER 10
--
-- ==========================================================





-- 1

SELECT     TotalSalePrice, FLOOR(TotalSalePrice) 
           AS SalePriceRoundedDown
FROM       Data.Sales

-- 2

SELECT     TotalSalePrice, CEILING(TotalSalePrice) 
           AS SalePriceRoundedUp
FROM       Data.Sales


-- 3

SELECT     TotalSalePrice, ROUND(TotalSalePrice, 0) 
           AS SalePriceRounded
FROM       Data.Sales	


-- 4

SELECT     TotalSalePrice, ROUND(TotalSalePrice, -3) 
           AS SalePriceRoundedUp
FROM       Data.Sales


-- 5

SELECT     FORMAT(TotalSalePrice, 'C', 'en-gb') 
           AS SterlingSalePrice
FROM       Data.Sales	


-- 6

SELECT     FORMAT(SalePrice, '#,#0.00') AS FormattedSalePrice
FROM       Data.SalesDetails


-- 7

SELECT     InvoiceNumber
           ,CONVERT(DATE, SaleDate, 113) AS SaleDate
FROM       Data.Sales	


-- 8

SELECT     FORMAT(SaleDate, 'D', 'en-us') AS SaleDate
FROM       Data.Sales


-- 9

SELECT     FORMAT(SaleDate, 'ddd d MMM-yyyy', 'en-us')
           AS SaleDate
FROM       Data.Sales	

