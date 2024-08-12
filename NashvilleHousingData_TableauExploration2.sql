Use PortfolioProject;

Select * From NashvilleData;

-- Histogram of TotalValue based on City in bins of 500,000

SELECT 
    PropertySplitCity,
    CASE 
        WHEN TotalValue <= 500000 THEN '500,000 or less'
        WHEN TotalValue > 500000 AND TotalValue <= 1000000 THEN '500,001 to 1,000,000'
        ELSE '1,000,001 and above'
    END AS ValueBin,
    COUNT(*) AS PropertiesInBin
FROM 
    NashvilleData
WHERE
    TotalValue > 0 -- Ensure no properties with a TotalValue of 0 are included
GROUP BY 
    PropertySplitCity, ValueBin
HAVING 
    COUNT(*) > 0 -- Exclude bins with 0 properties
ORDER BY 
    PropertySplitCity, 
    CASE 
        WHEN ValueBin = '500,000 or less' THEN 1
        WHEN ValueBin = '500,001 to 1,000,000' THEN 2
        ELSE 3
    END;
    
-- Now I want to look at the appreciation (or depreciation) amount ($) average per city since the sale price

Select PropertySplitCity, PropertySplitState, AVG(TotalValue - SalePrice) as AvgAppreciationAmount From NashvilleData
Where PropertySplitCity != " UNKNOWN" AND PropertySplitState is not null
Group By PropertySplitCity, PropertySplitState;

-- Find best citys to purchase in based on Appreciation value, bathrooms, acreage and bedrooms

UPDATE NashvilleData
SET 
    Acreage = NULLIF(Acreage, ''),
    Bedrooms = NULLIF(Bedrooms, ''),
    FullBath = NULLIF(FullBath, ''),
    HalfBath = NULLIF(HalfBath, ''),
    TotalValue = NULLIF(TotalValue, ''),
    SalePrice = NULLIF(SalePrice, '')
WHERE
    Acreage = '' OR
    Bedrooms = '' OR
    FullBath = '' OR
    HalfBath = '' OR
    TotalValue = '' OR
    SalePrice = '';


SELECT 
    PropertySplitCity,
    AVG(Acreage) AS AvgAcreage,
    AVG(Bedrooms) AS AvgBedrooms,
    AVG(FullBath) AS AvgFullBath,
    AVG(HalfBath) AS AvgHalfBath,
    AVG(TotalValue - SalePrice) AS AvgAppreciationAmount
FROM 
    NashvilleData
GROUP BY 
    PropertySplitCity
HAVING 
    AVG(Acreage) IS NOT NULL 
    AND AVG(Bedrooms) IS NOT NULL 
    AND AVG(FullBath) IS NOT NULL
ORDER BY 
    AvgAppreciationAmount DESC, 
    AvgAcreage, 
    AvgBedrooms, 
    AvgFullBath, 
    AvgHalfBath;
    
-- Data for predictive modeling of HomeValue based on Acreage, YearBuild, BedRooms, Bathrooms and City
CREATE VIEW HomeData AS
SELECT
    PropertySplitCity,
    Acreage,
    YearBuilt,
    Bedrooms,
    (FullBath + HalfBath) AS Bathrooms,
    TotalValue
FROM
    NashvilleData
WHERE
    TotalValue IS NOT NULL
    AND Acreage IS NOT NULL
    AND YearBuilt IS NOT NULL
    AND Bedrooms IS NOT NULL
    AND FullBath IS NOT NULL
    AND HalfBath IS NOT NULL;









