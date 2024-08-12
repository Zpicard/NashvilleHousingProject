SELECT 
    LandValue,
    BuildingValue,
    YearBuilt,
    SaleDateFormatted,
    YEAR(SaleDateFormatted) AS SaleYear,
    SalePrice
    LandValue
FROM 
    NashvilleData;

SELECT 
    YEAR(SaleDateFormatted) AS SaleYear,
    COUNT(*) AS YearCount
FROM 
    NashvilleData
GROUP BY 
    SaleYear
ORDER BY 
    SaleYear;
    
    
-- Look at the pricing trends of houses based on different bins of 'Land Value'

SELECT 
    YEAR(SaleDateFormatted) AS SaleYear,
    CASE 
        WHEN LandValue < 50000 THEN '0 - 50,000'
        WHEN LandValue BETWEEN 50000 AND 99999 THEN '50,000 - 100,000'
        WHEN LandValue BETWEEN 100000 AND 149999 THEN '100,000 - 150,000'
        WHEN LandValue BETWEEN 150000 AND 199999 THEN '150,000 - 200,000'
        WHEN LandValue BETWEEN 200000 AND 249999 THEN '200,000 - 250,000'
        WHEN LandValue BETWEEN 250000 AND 299999 THEN '250,000 - 300,000'
        WHEN LandValue BETWEEN 300000 AND 349999 THEN '300,000 - 350,000'
        WHEN LandValue BETWEEN 350000 AND 399999 THEN '350,000 - 400,000'
        ELSE '400,000+'
    END AS LandValueBin,
    AVG(SalePrice) AS AvgSalePrice
FROM 
    NashvilleData
GROUP BY 
    SaleYear, LandValueBin
ORDER BY 
    SaleYear, LandValueBin;
    
    
-- Look at Property Value Appreciation Since Sale

Select 
YEAR(SaleDateFormatted) as SaleYear,
TotalValue,
SalePrice,
(TotalValue - SalePrice) as AppreciationValue
From NashvilleData;

-- Compare Appreciation Across Different Property Types

SELECT 
    LANDUSE,
    YEAR(SaleDateFormatted) as SaleYear,
    AVG(TotalValue - SalePrice) as AvgAppreciationValue
FROM 
    NashvilleData
WHERE 
    LANDUSE IS NOT NULL AND LANDUSE != ''
    AND TotalValue IS NOT NULL AND TotalValue != ''
    AND SalePrice IS NOT NULL AND SalePrice != ''
GROUP BY 
    LANDUSE, SaleYear
ORDER BY 
    LANDUSE, SaleYear;
    
-- Calculate Compound Anual Growth Rate of Appreciation

SELECT 
    YEAR(SaleDateFormatted) as SaleYear,
    EXP(AVG(LN(COALESCE(NULLIF(TotalValue, ''), 1) / COALESCE(NULLIF(SalePrice, ''), 1)))) - 1 as CAGR
FROM 
    NashvilleData
WHERE 
    COALESCE(NULLIF(TotalValue, ''), 0) != 0
    AND COALESCE(NULLIF(SalePrice, ''), 0) != 0
GROUP BY 
    SaleYear
ORDER BY 
    SaleYear;
    
-- Map of Compound Annual Growth Rate

SELECT 
    PropertySplitAddress,
    PropertySplitCity,
    PropertySplitState,
    YEAR(SaleDateFormatted) as SaleYear,
    EXP(AVG(LN(COALESCE(NULLIF(TotalValue, ''), 1) / COALESCE(NULLIF(SalePrice, ''), 1)))) - 1 as CAGR
FROM 
    NashvilleData
WHERE 
    COALESCE(NULLIF(TotalValue, ''), 0) != 0
    AND COALESCE(NULLIF(SalePrice, ''), 0) != 0
GROUP BY 
    PropertySplitAddress,
    PropertySplitCity,
    PropertySplitState,
    SaleYear
ORDER BY 
    PropertySplitAddress, 
    PropertySplitCity, 
    PropertySplitState, 
    SaleYear;
    
-- Compare CAGR Across City
SELECT 
    PropertySplitCity,
    YEAR(SaleDateFormatted) as SaleYear,
    EXP(AVG(LN(COALESCE(NULLIF(TotalValue, ''), 1) / COALESCE(NULLIF(SalePrice, ''), 1)))) - 1 as AvgCAGR
FROM 
    NashvilleData
WHERE 
    COALESCE(NULLIF(TotalValue, ''), 0) != 0
    AND COALESCE(NULLIF(SalePrice, ''), 0) != 0
GROUP BY 
    PropertySplitCity,
    SaleYear
ORDER BY 
    PropertySplitCity,
    SaleYear;
    
    
    



    














