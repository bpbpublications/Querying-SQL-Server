-- ==========================================================
--
--              CHAPTER 11
--
-- ==========================================================


-- 1

SELECT      Cost, RepairsCost, PartsCost
           ,IIF(PartsCost > RepairsCost, 'Cost Alert!', NULL) 
           AS CostAnalysis
FROM       Data.Stock



-- 2

SELECT     Cost, RepairsCost, PartsCost 
           ,IIF(
                LEN(BuyerComments) < 25
                ,BuyerComments
                ,LEFT(BuyerComments, 20) + ' ...'
               ) AS Comments
FROM       Data.Stock


-- 3


SELECT      ST.Cost, ST.RepairsCost, ST.PartsCost 
           ,IIF(
                (SD.SalePrice - 
                  (ST.Cost + SD.LineItemDiscount
                           + ST.PartsCost
                           + ISNULL(ST.RepairsCost, 0) 
                           + ST.TransportInCost
                   )
                 ) 
                 < (SD.SalePrice * 0.1) 
                 AND (ST.RepairsCost * 2) > ST.PartsCost
              ,'Warning!!'
              ,'OK'
               ) AS CostAlert
FROM       Data.Stock ST
           INNER JOIN Data.SalesDetails SD ON ST.StockCode 
             = SD.StockID

-- 4

SELECT      ST.Cost, ST.RepairsCost, ST.PartsCost 
           ,IIF(
                 (SD.SalePrice - 
                       (ST.Cost + SD.LineItemDiscount - ST.PartsCost 
                        + ST.RepairsCost + ST.TransportInCost) 
                  ) < SD.SalePrice * 0.1 
                   ,'Warning!!'
               ,IIF(
                     (SD.SalePrice - 
                         (ST.Cost + SD.LineItemDiscount - ST.PartsCost 
                          + ST.RepairsCost + ST.TransportInCost) 
                      ) < SD.SalePrice * 0.5, 'Acceptable', 'OK'
                    )
                ) AS CostAlert
FROM       Data.Stock ST
           INNER JOIN Data.SalesDetails SD ON ST.StockCode 
              = SD.StockID


-- 5

SELECT     CountryName
           ,CASE CountryName
              WHEN 'Belgium' THEN 'Eurozone'
              WHEN 'France' THEN 'Eurozone'
              WHEN 'Italy' THEN 'Eurozone'
              WHEN 'Spain' THEN 'Eurozone'
              WHEN 'United Kingdom' THEN 'Pound Sterling'
              WHEN 'United States' THEN 'Dollar'
              ELSE 'Other'
           END AS CurrencyRegion
FROM       Data.Country	


-- 6

SELECT    CASE 
            WHEN MK.MakeCountry IN ('ITA', 'GER', 'FRA') 
                 THEN 'European'
            WHEN MK.MakeCountry = 'GBR' THEN 'British'
            WHEN MK.MakeCountry = 'USA' THEN 'American'
            ELSE 'Other'
          END AS SalesRegion
          ,COUNT(SD.SalesDetailsID) AS NumberOfSales
FROM       Data.Make AS MK INNER JOIN Data.Model 
           AS MD ON MK.MakeID = MD.MakeID
           INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
           INNER JOIN Data.SalesDetails SD ON ST.StockCode 
                      = SD.StockID
GROUP BY   CASE 
            WHEN MK.MakeCountry IN ('ITA', 'GER', 'FRA') 
                 THEN 'European'
            WHEN MK.MakeCountry = 'GBR' THEN 'British'
            WHEN MK.MakeCountry = 'USA' THEN 'American'
            ELSE 'Other'
          END	

-- 7

SELECT    CustomerName
          ,CASE
          WHEN IsReseller = 0 AND Country 
                               IN ('IT', 'DE', 'FR', 'ES', 'BE') 
                  THEN 'Eurozone Retail Client'
          WHEN IsReseller = 0 AND Country IN ('GB') 
                  THEN 'British Retail Client'
          WHEN IsReseller = 0 AND Country IN ('US') 
                  THEN 'American Retail Client'
          WHEN IsReseller = 0 AND Country IN ('CH') 
                  THEN 'Swiss Retail Client'
          WHEN IsReseller = 1 AND Country
                                IN ('IT', 'DE', 'FR', 'ES', 'BE') 
                  THEN 'Eurozone Reseller'
          WHEN IsReseller = 1 AND Country IN ('GB') 
                  THEN 'British Reseller'
          WHEN IsReseller = 1 AND Country IN ('US') 
                  THEN 'American Reseller'
          WHEN IsReseller = 1 AND Country IN ('CH') 
                  THEN 'Swiss Reseller'
         END AS CustomerType
FROM       Data.Customer


-- 8

SELECT     CustomerName
           ,CASE
               WHEN IsCreditRisk = 0 THEN
                        CASE 
                            WHEN Country IN ('IT', 'DE', 'FR'
                                             ,'ES', 'BE') 
                                THEN 'Eurozone No Risk'
                            WHEN Country IN ('GB') 
                                THEN 'British No Risk'
                            WHEN Country IN ('US') 
                                THEN 'American No Risk'
                            WHEN Country IN ('CH') 
                                THEN 'swiss No Risk'
                        END
               WHEN IsCreditRisk = 1 THEN
                        CASE
                            WHEN Country IN ('IT', 'DE', 'FR'
                                             ,'ES', 'BE') 
                               THEN 'Eurozone Credit Risk'
                            WHEN Country IN ('GB') 
                               THEN 'British Credit Risk'
                            WHEN Country IN ('US') 
                               THEN 'American Credit Risk'
                            WHEN Country IN ('CH') 
                               THEN 'swiss Credit Risk'
                  END        
            END AS RiskType
FROM       Data.Customer


-- 9

SELECT      *
FROM        Data.SalesByCountry
ORDER BY    CASE WHEN LineItemDiscount IS NULL THEN 1 ELSE 0 END
            ,LineItemDiscount	


-- 10

SELECT     
MONTH(SaleDate) AS MonthNumber
,CHOOSE(MONTH(SaleDate), 'Winter', 'Winter', 'Spring', 'Spring', 'Summer', 'Summer','Summer','Summer','Autumn','Autumn', 'Winter','Winter') AS SalesSeason
FROM       Data.Sales

