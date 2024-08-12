-- Change Date Format

ALTER TABLE PortfolioProject.NashvilleData 
ADD COLUMN SaleDateFormatted DATE;

UPDATE PortfolioProject.NashvilleData 
SET SaleDateFormatted = STR_TO_DATE(SaleDate, '%M %d, %Y');

UPDATE PortfolioProject.NashvilleHousingData 
SET SaleDate = SaleDateFormatted;

ALTER TABLE PortfolioProject.NashvilleData 
DROP COLUMN SaleDateFormatted;

-- Populate Property Address Data

Select *
From NashvilleData
-- Where PropertyAddress is null
order by ParcelID;

UPDATE PortfolioProject.NashvilleData
SET PropertyAddress = NULL
WHERE PropertyAddress = '';

SELECT a.ParcelID, 
       IFNULL(a.PropertyAddress, b.PropertyAddress) AS PropertyAddress, 
       b.ParcelID, 
       b.PropertyAddress
FROM PortfolioProject.NashvilleData a
JOIN PortfolioProject.NashvilleData b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE PortfolioProject.NashvilleData a
JOIN PortfolioProject.NashvilleData b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;


-- Breaking out Address Into Individual Columns (Address, City, State)

Select *
From NashvilleData;
-- Where PropertyAddress is null
-- order by ParcelID;

SELECT
    SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS AddressPart1,
    SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1) AS AddressPart2
FROM PortfolioProject.NashvilleData;

ALTER TABLE PortfolioProject.NashvilleData 
ADD COLUMN PropertySplitAddress varchar(255);

Update NashvilleData
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1);

ALTER TABLE PortfolioProject.NashvilleData 
ADD COLUMN PropertySplitCity varchar(255);

Update NashvilleData
Set PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1);

-- Clean up Owner Address

Select OwnerAddress from NashvilleData;

SELECT
    SUBSTRING_INDEX(OwnerAddress, ',', 1) AS Part1,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)) AS Part2,
    TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1)) AS Part3
FROM NashvilleData;

ALTER TABLE PortfolioProject.NashvilleData 
ADD COLUMN OwnerSplitAddress varchar(255);

Update NashvilleData
Set OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

ALTER TABLE PortfolioProject.NashvilleData 
ADD COLUMN OwnerSplitCity varchar(255);

Update NashvilleData
Set OwnerSplitCity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1));

ALTER TABLE PortfolioProject.NashvilleData 
ADD COLUMN PropertySplitState varchar(255);

Update NashvilleData
Set PropertySplitState = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1));

-- Change Y and N to Yes/No in SoldAsVacant

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleData
Group by SoldAsVacant
Order by 2;

Select SoldAsVacant
, Case When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END 
From NashvilleData;

Update NashvilleData
SET SoldAsVacant = Case When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END;

-- Remove Duplicates



WITH RowNumCTE AS(
Select * ,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID) row_num

From NashvilleData
-- Order By ParcelID
)

DELETE
From RowNumCTE
Where row_num > 1;


-- Preview rows that will be deleted
SELECT UniqueID
FROM (
    SELECT UniqueID,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM NashvilleData
) AS RowNumCTE
WHERE row_num > 1;

-- Select rows that would be deleted
SELECT *
FROM NashvilleData
WHERE UniqueID IN (
    SELECT UniqueID
    FROM (
        SELECT UniqueID,
               ROW_NUMBER() OVER (
                   PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
                   ORDER BY UniqueID
               ) AS row_num
        FROM NashvilleData
    ) AS RowNumCTE
    WHERE row_num > 1
);

DELETE FROM NashvilleData
WHERE UniqueID IN (
    SELECT UniqueID
    FROM (
        SELECT UniqueID,
               ROW_NUMBER() OVER (
                   PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
                   ORDER BY UniqueID
               ) AS row_num
        FROM NashvilleData
    ) AS RowNumCTE
    WHERE row_num > 1
);

-- Verify remaining rows
SELECT COUNT(*) AS RemainingRows FROM NashvilleData;

-- Delete Unused Columns

ALTER TABLE NashvilleData
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress;

ALTER TABLE NashvilleData
Drop Column SaleDate









