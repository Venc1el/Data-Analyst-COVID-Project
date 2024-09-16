/*
	Cleaning data in SQL Queries
*/

SELECT SaleDateConverted
FROM NashvilleHousing

UPDATE NashvilleHousing SET SaleDate =  CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing SET SaleDateConverted = CONVERT(Date, SaleDate)

-- Populate property by address data

SELECT * 
FROM NashvilleHousing
ORDER BY ParcelID


SELECT nv1.ParcelID, nv1.PropertyAddress, nv2.ParcelID, nv2.PropertyAddress, ISNULL(nv1.PropertyAddress, nv2.PropertyAddress)
FROM NashvilleHousing nv1 
JOIN NashvilleHousing nv2 
	ON nv1.ParcelID = nv2.ParcelID
	AND nv1.[UniqueID ] <> nv2.[UniqueID ]

UPDATE nv1 
SET PropertyAddress = ISNULL(nv1.PropertyAddress, nv2.PropertyAddress)
FROM NashvilleHousing nv1 
JOIN NashvilleHousing nv2 
	ON nv1.ParcelID = nv2.ParcelID
	AND nv1.[UniqueID ] <> nv2.[UniqueID ]
WHERE nv1.PropertyAddress IS NULL

-- Breaking out Address into Individual Columns(Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS State
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT PropertySplitAddress, PropertySplitCity
FROM NashvilleHousing

SELECT * FROM NashvilleHousing


SELECT OwnerAddress
FROM NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
END


-- Remove Duplicates 

SELECT *, 
ROW_NUMBER() OVER(
	PARTITION BY ParcelID, 
				 PropertyAddress, 
				 SalePrice, 
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID) row_num
FROM NashvilleHousing
ORDER BY ParcelID

WITH CTE_RowNum AS (
	SELECT *, 
	ROW_NUMBER() OVER(
		PARTITION BY ParcelID, 
					 PropertyAddress, 
					 SalePrice, 
					 SaleDate,
					 LegalReference
					 ORDER BY
						UniqueID) row_num
	FROM NashvilleHousing
)
SELECT * FROM CTE_RowNum WHERE row_num > 1

-- Delete Unused Column

SELECT * 
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate