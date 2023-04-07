/* 

--Cleaning Data in SQL Queries------------------------

*/

SELECT * 
FROM portfolioproject.dbo.Nashvellhousing

--Standardize Date format------------------------


SELECT SaleDate,CONVERT(Date,Saledate)
FROM portfolioproject.dbo.Nashvellhousing

ALTER TABLE Nashvellhousing
Add SaledateConverted Date

Update Nashvellhousing
SET SaledateConverted = CONVERT(Date,Saledate)

SELECT SaledateConverted
FROM portfolioproject.dbo.Nashvellhousing


--Populate Property Address Data-------------------------

SELECT ParcelID, PropertyAddress
FROM portfolioproject.dbo.Nashvellhousing
ORDER BY ParcelID

/* We have similar id with similar address too 
we are joining the inside tables  */-------------------------


SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
FROM portfolioproject.dbo.Nashvellhousing a
JOIN portfolioproject.dbo.Nashvellhousing b 
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--- Filling the a.propertyaddress which is null with b.propertyaddress ------------------

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM portfolioproject.dbo.Nashvellhousing a
JOIN portfolioproject.dbo.Nashvellhousing b 
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM portfolioproject.dbo.Nashvellhousing a
JOIN portfolioproject.dbo.Nashvellhousing b 
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM portfolioproject.dbo.Nashvellhousing a
JOIN portfolioproject.dbo.Nashvellhousing b 
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]


----------Breaking the address into column (Address,city, State)----------------------------------------------------

SELECT PropertyAddress
FROM portfolioproject.dbo.Nashvellhousing

SELECT 
SUBSTRING(PropertyAddress,1, CHARINDEX(',' , PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM portfolioproject.dbo.Nashvellhousing 


ALTER TABLE Nashvellhousing
ADD Address Nvarchar(255)

UPDATE Nashvellhousing
SET Address = SUBSTRING(PropertyAddress,1, CHARINDEX(',' , PropertyAddress)-1)

ALTER TABLE Nashvellhousing
ADD City Nvarchar(255)

UPDATE Nashvellhousing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress))

SELECT PropertyAddress,Address,City
FROM portfolioproject.dbo.Nashvellhousing


SELECT OwnerAddress
FROM portfolioproject.dbo.Nashvellhousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM portfolioproject.dbo.Nashvellhousing


ALTER TABLE Nashvellhousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE Nashvellhousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE Nashvellhousing
ADD OwnerCity Nvarchar(255)

UPDATE Nashvellhousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Nashvellhousing
ADD OwnerState Nvarchar(255)

UPDATE Nashvellhousing
SET OwnerState= PARSENAME(REPLACE(OwnerAddress,',','.'),1)


SELECT OwnerAddress, OwnersplitAddress, Ownercity, OwnerState
FROM portfolioproject.dbo.Nashvellhousing


--Change Y and N into Yes and No in SoldASVacant ---

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM portfolioproject.dbo.Nashvellhousing
Group by SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM portfolioproject.dbo.Nashvellhousing


UPDATE Nashvellhousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM portfolioproject.dbo.Nashvellhousing
Group by SoldAsVacant
ORDER BY 2
 



---REMOVE Duplicates ------


SELECT * 
FROM portfolioproject.dbo.Nashvellhousing

WITH RowNumCTE AS(
SELECT *,
     ROW_NUMBER() OVER (
	 PARTITION BY ParcelID,
	              PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY
				     UniqueID
				     ) row_num
FROM portfolioproject.dbo.Nashvellhousing
)

SELECT * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



WITH RowNumCTE AS(
SELECT *,
     ROW_NUMBER() OVER (
	 PARTITION BY ParcelID,
	              PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY
				     UniqueID
				     ) row_num
FROM portfolioproject.dbo.Nashvellhousing
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1


--DELETE Unused Columns--

SELECT * 
FROM portfolioproject.dbo.Nashvellhousing

ALTER TABLE portfolioproject.dbo.Nashvellhousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate