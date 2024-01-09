--Covid 19 Cleaning Data


SELECT*
FROM Nashville_Housing


--Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM Nashville_Housing

ALTER TABLE Nashville_Housing 
ALTER COLUMN SaleDate DATE


--Populate Property Address Data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville_Housing AS a
JOIN Nashville_Housing AS b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville_Housing AS a
JOIN Nashville_Housing AS b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL


--Breaking Out Property Address Into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM Nashville_Housing

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress, -1)) AS Address
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress, 1), LEN(PropertyAddress)) AS City
FROM Nashville_Housing

ALTER TABLE Nashville_Housing
ADD PropertySplitAddress nvarchar(100)

UPDATE Nashville_Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress, -1))

ALTER TABLE Nashville_Housing
ADD PropertySplitCity nvarchar(100)

UPDATE Nashville_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress, 1), LEN(PropertyAddress))


--Breaking out Owner Address into Individual Columns (Address, City, State)

SELECT OwnerAddress
FROM Nashville_Housing

SELECT
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerSplitAddress,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerSplitCity,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerSplitState
FROM Nashville_Housing

ALTER TABLE Nashville_Housing
ADD OwnerSplitAddress nvarchar(100)

UPDATE Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Nashville_Housing
ADD OwnerSplitCity nvarchar(100)

UPDATE Nashville_Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Nashville_Housing
ADD OwnerSplitState nvarchar(100)

UPDATE Nashville_Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


--Change 'Y, N' to 'Yes, No' in Sold as Vacant

Select
	SoldAsVacant,
	CASE 
		When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
From Nashville_Housing

Update Nashville_Housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


--Remove Duplicate

WITH CTE_RowNum AS
(
Select*, 
	ROW_NUMBER() OVER 
	(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID
	) AS RowNum
From Nashville_Housing
)
DELETE From CTE_RowNum
Where RowNum > 1


--Delete Unused Columns

ALTER TABLE Nashville_Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

SELECT*
FROM Nashville_Housing
