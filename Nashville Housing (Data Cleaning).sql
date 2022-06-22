rm -rf .git
/*
Cleaning Data in SQL Queries
*/
-- Standardize Date Format
ALTER TABLE	Nashvillehousing
ADD			DateofSale DATE

UPDATE	NashvilleHousing
SET		DateofSale = CONVERT(Date,SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
SELECT	a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM	PortfolioProjects.dbo.NashvilleHousing a
JOIN	PortfolioProjects.dbo.NashvilleHousing b
	ON	a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE	a.PropertyAddress IS NULL


UPDATE	a
SET		PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM	PortfolioProjects.dbo.NashvilleHousing a
JOIN	PortfolioProjects.dbo.NashvilleHousing b
	ON	a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE	a.PropertyAddress IS NULL

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
ALTER TABLE	NashvilleHousing
ADD			PropertySplitAddress Nvarchar(255);

ALTER TABLE	NashvilleHousing
ADD			PropertySplitCity NVARCHAR(255);

UPDATE	NashvilleHousing
SET		PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

UPDATE	NashvilleHousing
SET		PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


SELECT	OwnerAddress
FROM	PortfolioProject.dbo.NashvilleHousing


SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PortfolioProjects.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD			OwnerSplitAddress NVARCHAR(255);

ALTER TABLE	NashvilleHousing
ADD			OwnerSplitCity NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD			OwnerSplitState NVARCHAR(255);

UPDATE	NashvilleHousing
SET		OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

UPDATE	NashvilleHousing
SET		OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

UPDATE	NashvilleHousing
SET		OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field
UPDATE	NashvilleHousing
SET		SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH	RowNumCTE AS(
SELECT	*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM PortfolioProjects.dbo.NashvilleHousing
)
DELETE
FROM	RowNumCTE
WHERE	row_num > 1

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

---------------------------------------------------------------------------------------------------------

--Checking on the Table
SELECT	*
FROM	PortfolioProjects.dbo.NashvilleHousing
