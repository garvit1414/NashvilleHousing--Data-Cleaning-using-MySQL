/*

Cleaning Data in SQL Queries

*/


SELECT 
    *
FROM
    PortfolioProject.NashvilleHousing;

ALTER TABLE portfolioproject.Nashvillehousing
CHANGE ï»¿UniqueID  UniqueID int;


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


UPDATE portfolioproject.NashvilleHousing
SET SaleDate = DATE_FORMAT(STR_TO_DATE(SaleDate, '%Y%m-%d'), '%Y-%m-%d');

SELECT saleDate, DATE(SaleDate) AS ConvertedDate
FROM PortfolioProject.NashvilleHousing;



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select propertyaddress
From PortfolioProject.NashvilleHousing
Where PropertyAddress is null
order by ParcelID;



SELECT 
    a.ParcelID,
    a.PropertyAddress,
    b.ParcelID,
    b.PropertyAddress,
    COALESCE(a.PropertyAddress, b.PropertyAddress)
FROM
    PortfolioProject.NashvilleHousing a
        JOIN
    PortfolioProject.NashvilleHousing b ON a.ParcelID = b.ParcelID
        AND a.UniqueID <> b.UniqueID
WHERE
    a.PropertyAddress IS NULL;



UPDATE PortfolioProject.NashvilleHousing a
        JOIN
    PortfolioProject.NashvilleHousing b ON a.ParcelID = b.ParcelID
        AND a.UniqueID != b.UniqueID 
SET 
    a.PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
WHERE
    a.PropertyAddress IS NULL;





--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)



SELECT SUBSTRING_INDEX(PropertyAddress, ',', 1) as Address 
FROM PortfolioProject.NashvilleHousing;

SELECT SUBSTRING_INDEX(PropertyAddress, ',', -1) as Address
From PortfolioProject.NashvilleHousing;


ALTER TABLE portfolioproject.nashvillehousing
Add PropertySplitAddress Nvarchar(255);

Update portfolioproject.nashvillehousing
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1);


ALTER TABLE portfolioproject.nashvillehousing
Add PropertySplitCity Nvarchar(255);

Update portfolioproject.nashvillehousing
SET PropertySplitCity = SUBSTRING_INDEX(PropertyAddress, ',', -1);

Select *
From PortfolioProject.NashvilleHousing;


---------------------------------------------------------------------------------------------------------------------------------------------------


Select OwnerAddress
From PortfolioProject.NashvilleHousing;


SELECT 
    SUBSTRING_INDEX(OwnerAddress, ',', 1) AS Address
FROM
    PortfolioProject.NashvilleHousing;

SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -2), '.', 1) AS Result
FROM PortfolioProject.NashvilleHousing;

SELECT SUBSTRING_INDEX(OwnerAddress, ',', -1) as Address
From PortfolioProject.NashvilleHousing;


ALTER TABLE portfolioproject.nashvillehousing
Add Ownersplitaddress Nvarchar(255);

Update portfolioproject.nashvillehousing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);


ALTER TABLE portfolioproject.nashvillehousing
Add OwnersplitCity Nvarchar(255);


UPDATE portfolioproject.nashvillehousing 
SET 
    OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'),
                    '.',
                    - 2),
            '.',
            1);


ALTER TABLE portfolioproject.nashvillehousing
Add OwnerSplitState Nvarchar(255);

Update portfolioproject.nashvillehousing
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);



SELECT 
    *
FROM
    PortfolioProject.NashvilleHousing;




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.NashvilleHousing
Group by SoldAsVacant
order by 2;




SELECT 
    SoldAsVacant,
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END
FROM
    PortfolioProject.NashvilleHousing;


UPDATE portfolioproject.nashvillehousing 
SET 
    SoldAsVacant = CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END;


SELECT 
    *
FROM
    PortfolioProject.NashvilleHousing;






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.NashvilleHousing
-- order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress;


DELETE FROM PortfolioProject.NashvilleHousing
WHERE UniqueID IN (
    SELECT UniqueID
    FROM (
        SELECT UniqueID,
               ROW_NUMBER() OVER (
                   PARTITION BY ParcelID,
                                PropertyAddress,
                                SalePrice,
                                SaleDate,
                                LegalReference
                   ORDER BY UniqueID
               ) AS row_num
        FROM PortfolioProject.NashvilleHousing
    ) AS RowNumCTE2
    WHERE row_num > 1
);







SELECT 
    *
FROM
    PortfolioProject.NashvilleHousing;




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From PortfolioProject.NashvilleHousing;


ALTER TABLE PortfolioProject.NashvilleHousing
DROP COLUMN OwnerAddress;

ALTER TABLE PortfolioProject.NashvilleHousing
DROP COLUMN TaxDistrict;

ALTER TABLE PortfolioProject.NashvilleHousing
DROP COLUMN PropertyAddress;

SELECT 
    *
FROM
    PortfolioProject.NashvilleHousing;

-----------------------------------------------------------------------------------------------
