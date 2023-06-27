
--Cleaning the data in SQL QUERIES

Select *
From PortfolioProject.dbo.NashvilleHousing


--standardizing the saledate ( There is a time in the end that serves no purpose ) data format is a datetime

Select saledateconverted, Convert(date,saledate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
set SaleDateConverted = Convert(date,saledate)

Alter table NashvilleHousing
add SaleDateConverted Date;


--Populate the property Address Data

Select *
from NashvilleHousing
where PropertyAddress is null

Select * 
from NashvilleHousing
order by ParcelID

--doing a self join on the table so that  we can compare a and b values to populate the Propertyaddresses where they are null
select a.ParcelID , a.PropertyAddress, b.ParcelID, b.PropertyAddress,isnull( a.propertyaddress,b.propertyaddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull( a.propertyaddress,b.propertyaddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--going to break down the Property address into address, city - using substring


Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing


SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1 , len(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

--adding new columns to add these separated values and adding the values with the statements created above

alter table nashvillehousing
add PropertySplitAddress nvarchar(255)

update nashvillehousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table nashvillehousing
add PropertySplitCity nvarchar(255)

update nashvillehousing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1 , len(PropertyAddress))


-- now looking at owner address and splitting them up with the use of parse, then adding them into the table as separate values

select
parsename(replace(owneraddress, ',','.'),3),
parsename(replace(owneraddress, ',','.'),2),
parsename(replace(owneraddress, ',','.'),1)
from NashvilleHousing
where owneraddress is not null

alter table nashvillehousing
add OwnerSplitAddress nvarchar(255)

update nashvillehousing
set OwnerSplitAddress = parsename(replace(owneraddress,',','.'),3)

alter table nashvillehousing
add OwnerSplitCity nvarchar(255)

update nashvillehousing
set OwnerSplitCity = parsename(replace(owneraddress, ',','.'),2)

alter table nashvillehousing
add OwnerSplitState nvarchar(255)

update nashvillehousing
set OwnerSplitState = parsename(replace(owneraddress, ',','.'),1)


-- Changing Y and N to Yes and no in "Sold As Vacant Field"

select distinct ( SoldAsVacant ) , count ( soldasvacant )
from NashvilleHousing
group by SoldAsVacant
order by 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant ='N' Then 'No'
ELSE SoldAsVacant
End
from NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant ='N' Then 'No'
	ELSE SoldAsVacant
	End



-- removing duplicates
--going to create a cte and find duplicates

WITH RowNumCTE as (
SELECT * , ROW_NUMBER () OVER ( PARTITION BY ParcelID, PropertyAddress, SalePrice,SaleDate, LegalReference Order by UniqueID) row_num
FROM NashvilleHousing

)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

--removing unused columns
Select * from NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SaleDate