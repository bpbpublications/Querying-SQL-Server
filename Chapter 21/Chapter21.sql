-- ==========================================================
--
--              CHAPTER 10
--
-- ==========================================================


-- 1

SELECT      Color, [2015], [2016], [2017], [2018]
FROM        
            (
             SELECT      Color, SD.SalePrice, YEAR(SaleDate)
                                  AS YearOfSale
             FROM        Data.Stock ST
             INNER JOIN  Data.SalesDetails SD 
                         ON ST.StockCode = SD.StockID
             INNER JOIN  Data.Sales SA 
                         ON SA.SalesID = SD.SalesID
            ) SQ
PIVOT       (
             SUM(SalePrice) FOR YearOfSale 
                            IN ([2015], [2016], [2017], [2018])
            ) AS PVT


-- 2

;
WITH MakeAndModelCostByYear_CTE (MakeName, ModelName, Color,
                                 CostPrice)
AS
(
SELECT      MakeName, ModelName, Color, Cost
FROM        Data.Make MK 
INNER JOIN  Data.Model MD ON MK.MakeID = MD.MakeID
INNER JOIN  Data.Stock ST ON ST.ModelID = MD.ModelID
)

SELECT      MakeName, ModelName, [Black], [Blue]
            ,[British Racing Green]
           ,[Canary Yellow], [Dark Purple], [Green], [Night Blue]
           ,[Pink], [Red], [Silver]
FROM        MakeAndModelCostByYear_CTE
PIVOT       (
                   COUNT(CostPrice) FOR Color IN 
                          (
                            [Black], [Blue]
                           ,[British Racing Green] 
                           ,[Canary Yellow], [Dark Purple]
                           ,[Green], [Night Blue], [Pink]
                           ,[Red], [Silver]
                           )
             ) PVT
ORDER BY    MakeName, ModelName


-- 3

SELECT    Color, UPT.SaleValue, UPT.SaleYear
FROM      Data.PivotTable
UNPIVOT  (SaleValue 
          FOR SaleYear IN ([2015], [2016], [2017],[2018])) 
              AS UPT



-- 4

SELECT      MakeName, Color, SUM(Cost) AS Cost
FROM        Data.Make MK 
INNER JOIN  Data.Model MD ON MK.MakeID = MD.MakeID
INNER JOIN  Data.Stock ST ON ST.ModelID = MD.ModelID
GROUP BY    GROUPING SETS ((MakeName, Color), ())
ORDER BY    MakeName, Color


-- 5

SELECT      MakeName, Color, SUM(Cost) AS Cost
FROM        Data.Make MK 
INNER JOIN  Data.Model MD ON MK.MakeID = MD.MakeID
INNER JOIN  Data.Stock ST ON ST.ModelID = MD.ModelID
GROUP BY    GROUPING SETS (
             (MakeName, Color), (MakeName), (Color), ()
                           )
ORDER BY    MakeName, Color



-- 6

;
;
WITH GroupedSource_CTE
AS
(
SELECT 
MakeName
,Color
,Count(*) AS NumberOfCarsBought

FROM        Data.Make MK 
            INNER JOIN Data.Model MD ON MK.MakeID = MD.MakeID
            INNER JOIN Data.Stock ST ON ST.ModelID = MD.ModelID
WHERE       MakeName IS NOT NULL OR Color IS NOT NULL
GROUP BY    GROUPING SETS ((MakeName), (Color), ())
)

SELECT AggregationType
,Category
,NumberOfCarsBought

FROM
(
SELECT   'GrandTotal' AS AggregationType, NULL AS Category
         ,NumberOfCarsBought, 1 AS SortOrder
FROM     GroupedSource_CTE
WHERE    MakeName IS NULL and Color IS NULL
UNION
SELECT   'Make Subtotals', MakeName, NumberOfCarsBought , 2
FROM     GroupedSource_CTE
WHERE    MakeName IS NOT NULL and Color IS NULL 
UNION
SELECT   'Color Subtotals', Color, NumberOfCarsBought , 3
FROM     GroupedSource_CTE
WHERE    MakeName IS NULL and Color IS NOT NULL
) SQ
ORDER BY SortOrder, NumberOfCarsBought DESC


-- 7

;
WITH HierarchyList_CTE
AS
(
SELECT        StaffID, StaffName, Department, ManagerID, 1 
                  AS StaffLevel
FROM          Reference.Staff
WHERE         ManagerID IS NULL
UNION ALL
SELECT         ST.StaffID, ST.StaffName 
              ,ST.Department, ST.ManagerID, StaffLevel + 1
FROM          Reference.Staff ST
INNER JOIN    HierarchyList_CTE CTE
              ON ST.ManagerID = CTE.StaffID
)

SELECT         STF.Department
              ,STF.StaffName
              ,CTE.StaffName AS ManagerName
              ,CTE.StaffLevel 
FROM          HierarchyList_CTE CTE
INNER JOIN    Reference.Staff STF
              ON STF.ManagerID = CTE.StaffID


-- 8

;
WITH HierarchyList_CTE
AS
(
SELECT    StaffID, StaffName, Department, ManagerID, 1 AS StaffLevel
FROM      Reference.Staff
WHERE     ManagerID IS NULL
UNION ALL
SELECT         ST.StaffID, ST.StaffName
              ,ST.Department, ST.ManagerID, StaffLevel + 1
FROM          Reference.Staff ST
INNER JOIN    HierarchyList_CTE CTE
              ON ST.ManagerID = CTE.StaffID
)
SELECT         STF.Department
              ,REPLICATE(' ', StaffLevel * 2) + STF.StaffName 
                   AS StaffMember
              ,CTE.StaffName AS ManagerName
              ,CTE.StaffLevel 
FROM          HierarchyList_CTE CTE
INNER JOIN    Reference.Staff STF
              ON STF.ManagerID = CTE.StaffID
ORDER BY      Department, StaffLevel, CTE.StaffName


-- 9

SELECT        CAST(STF.HierarchyReference AS VARCHAR(50)) 
                       AS StaffHierarchy
             ,CAST(MGR.HierarchyReference AS VARCHAR(50)) 
                       AS ManagerHierarchy
             ,STF.StaffName AS ManagerName
             ,MGR.StaffName
FROM         Reference.StaffHierarchy STF
INNER JOIN   Reference.StaffHierarchy MGR
             ON STF.ManagerID = MGR.StaffID
ORDER BY     MGR.HierarchyReference



-- 10

SELECT     REPLACE(CustomerName, 'Ltd', 'Limited') AS NoAcronymName
FROM       Data.Customer	
WHERE      LOWER(CustomerName) LIKE '%ltd%'


-- 11

SELECT 
STUFF(StockCode,1,23,'PrestigeCars-') AS NewStockCode
,Cost	
,RepairsCost
,PartsCost
,TransportInCost  
FROM Data.Stock


-- 12

;
WITH ConcatenateSource_CTE (MakeModel, Color)
AS
(
SELECT DISTINCT  MakeName + ' ' + ModelName, Color
FROM             Data.Make MK 
                 INNER JOIN Data.Model MD ON MK.MakeID = MD.MakeID
                 INNER JOIN Data.Stock ST ON ST.ModelID = MD.ModelID
)

SELECT   MakeModel, STRING_AGG(Color, ',') AS ColorList
FROM     ConcatenateSource_CTE
GROUP BY MakeModel



-- 13

SELECT          MakeName, Value AS VehicleType
FROM            Reference.MarketingCategories	
CROSS APPLY     STRING_SPLIT(MarketingType, ',')

-- 14

SELECT        MD.ModelName, ST.Color, ST.Cost
FROM          Data.Stock ST
INNER JOIN    Data.Model MD
              ON ST.ModelID = MD.ModelID
FOR XML PATH ('Stock'), ROOT ('PrestigeCars')


--15

SELECT         MD.ModelName AS "@Model"
              ,ST.Color
              ,ST.Cost AS "Costs/Purchase"
			  ,ST.PartsCost AS "Costs/Parts"
			  ,ST.RepairsCost AS "Costs/Repairs"
FROM          Data.Stock ST
INNER JOIN    Data.Model MD
              ON ST.ModelID = MD.ModelID
FOR XML PATH ('Stock')


-- 16

SELECT TOP 3   MD.ModelName
              ,ST.Color
              ,ST.Cost
			  ,ST.PartsCost
			  ,ST.RepairsCost
FROM          Data.Stock ST
INNER JOIN    Data.Model MD
              ON ST.ModelID = MD.ModelID
FOR JSON PATH, ROOT ('Stock')


-- 17

SELECT TOP 3   MD.ModelName
              ,ST.Color
              ,ST.Cost AS [Costs.Purchase]
			  ,ST.PartsCost AS [Costs.Parts]
			  ,ST.RepairsCost AS [Costs.Repairs]
FROM          Data.Stock ST
INNER JOIN    Data.Model MD
              ON ST.ModelID = MD.ModelID
FOR JSON PATH, ROOT ('Stock')

