-- ==========================================================
--
--              CHAPTER 5
--
-- ==========================================================


-- 1

SELECT     DISTINCT MK.MakeName, ST.Color
FROM       Data.Make AS MK
INNER JOIN Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
WHERE      ST.Color = 'Red' OR MakeName = 'Ferrari'



-- 2

SELECT DISTINCT  MK.MakeName, ST.Color
FROM             Data.Make AS MK
INNER JOIN       Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN       Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN       Data.SalesDetails SD ON ST.StockCode = SD.StockID
WHERE            ST.Color = 'Red' AND MK.MakeName = 'Ferrari'


-- 3

SELECT     DISTINCT MK.MakeName, ST.Color
FROM       Data.Make AS MK
INNER JOIN Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
WHERE      ST.Color IN ('Red', 'Green', 'Blue')
           AND MK.MakeName != 'Bentley'

-- 4

SELECT     DISTINCT MD.ModelName, ST.Color, ST.PartsCost
           ,ST.RepairsCost
FROM       Data.Stock AS ST 
INNER JOIN Data.Model AS MD
           ON ST.ModelID = MD.ModelID
WHERE      ST.Color = 'Red' AND (ST.PartsCost > 1000 
           OR ST.RepairsCost > 1000)


-- 5

SELECT DISTINCT  MD.ModelName, ST.Color, ST.PartsCost
                 ,ST.RepairsCost
FROM             Data.Stock AS ST 
INNER JOIN Data.Model AS MD
                 ON ST.ModelID = MD.ModelID
WHERE            (ST.Color IN ('Red', 'Green', 'Blue') 
                   AND 
                   MD.ModelName = 'Phantom') 
                 OR 
                (ST.PartsCost > 5500 AND ST.RepairsCost > 5500)

-- 6

SELECT     CustomerName 
FROM       Data.Customer
WHERE      CustomerName LIKE '%pete%'


-- 7

SELECT     CustomerName 
FROM       Data.Customer		
WHERE      CustomerName NOT LIKE '%pete%'


-- 8

SELECT DISTINCT   MD.ModelName, SA. InvoiceNumber
FROM              Data.Make AS MK 
INNER JOIN        Data.Model AS MD 
                  ON MK.MakeID = MD.MakeID
INNER JOIN        Data.Stock ST
                  ON ST.ModelID = MD.ModelID
INNER JOIN        Data.SalesDetails AS SD 
                  ON SD.StockID = ST.StockCode
INNER JOIN        Data.Sales AS SA
                  ON SA.SalesID = SD.SalesID
WHERE             SA.InvoiceNumber LIKE '___FR%'



-- 9

SELECT   CustomerName
FROM     Data.Customer	
WHERE    PostCode IS NULL

