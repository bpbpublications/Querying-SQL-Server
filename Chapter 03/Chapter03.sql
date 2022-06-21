-- ==========================================================
--
--              CHAPTER 3
--
-- ==========================================================

-- 1

SELECT DISTINCT    MK.MakeName, MD.ModelName
FROM               Data.Make MK LEFT OUTER JOIN Data.Model MD
                   ON MK.MakeID = MD.MakeID


-- 2

SELECT DISTINCT    MK.MakeName, MD.ModelName
FROM               Data.Model MD 
RIGHT OUTER JOIN   Data.Make MK
                   ON MK.MakeID = MD.MakeID


-- 3

SELECT            CT.CountryName, CT.SalesRegion, CS.*
FROM              Data.Country CT
FULL OUTER JOIN   Data.Customer CS
                  ON CS.Country = CT.CountryISO2
ORDER BY          CT.SalesRegion


-- 4

SELECT     CO.CountryName, SA.TotalSalePrice
FROM       Data.Sales SA
INNER JOIN Data.Customer CS	
           ON SA.CustomerID = CS.CustomerID
INNER JOIN Data.Country CO	
           ON CS.Country = CO.CountryISO2

-- 5

SELECT      CS.CustomerName, MI.SpendCapacity
FROM        Data.Customer CS	
INNER JOIN  Reference.MarketingInformation MI
            ON CS.CustomerName = MI.Cust
            AND CS.Country = MI.Country

-- 6

SELECT       ST1.StaffName, ST1.Department, ST2.StaffName AS ManagerName
FROM         Reference.Staff ST1
INNER JOIN   Reference.Staff ST2	
             ON ST1.ManagerID = ST2.StaffID

-- 7

SELECT
 MK.MakeName
,MD.ModelName
,SD.SalePrice
,CAT.CategoryDescription
	
FROM        Data.Stock ST 
INNER JOIN  Data.Model MD 
            ON ST.ModelID = MD.ModelID 
INNER JOIN  Data.Make MK 
            ON MD.MakeID = MK.MakeID 
INNER JOIN  Data.SalesDetails SD 
            ON ST.StockCode = SD.StockID 
INNER JOIN  Reference.SalesCategory CAT
            ON SD.SalePrice BETWEEN 
                            CAT.LowerThreshold AND CAT.UpperThreshold

-- 8

SELECT        CountryName, MakeName
FROM          Data.Country    
CROSS JOIN    Data.Make

