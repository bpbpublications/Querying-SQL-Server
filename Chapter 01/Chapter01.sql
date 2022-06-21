-- ==========================================================
--
--              CHAPTER 1
--
-- ==========================================================


-- 7

SELECT  *	
FROM    Data.Make


-- 8

SELECT   TOP 10 *
FROM     Data.Make


-- 9

SELECT CustomerName
FROM   Data.Customer


-- 11

SELECT CountryName, SalesRegion
FROM   Data.Country


-- 12

SELECT CountryName, CountryISO3 AS IsoCode FROM Data.Country


-- 13

SELECT    * 
FROM      Data.SalesByCountry 
ORDER BY  SalePrice 


-- 14

SELECT    CountryISO3 AS IsoCode, CountryName  
FROM      Data.Country 
ORDER BY  IsoCode DESC


-- 15

SELECT    CountryName, MakeName, ModelName
FROM      Data.SalesByCountry		
ORDER BY  CountryName, MakeName, ModelName

