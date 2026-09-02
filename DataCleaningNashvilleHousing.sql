/*
	Cleaning Data in SQL queries
*/


-- стандартилизация формата даты

alter table NashvilleHousing
add SaleDateConverted date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)


-- избавиться от NULL в Property Address с помощью ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProj.dbo.NashvilleHousing a
JOIN PortfolioProj.dbo.NashvilleHousing b on a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
where a.PropertyAddress IS NULL

update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProj.dbo.NashvilleHousing a
JOIN PortfolioProj.dbo.NashvilleHousing b on a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
where a.PropertyAddress IS NULL


-- Address по колонкам: адрес, город, штат

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

alter table PortfolioProj..NashvilleHousing
add OwnerSplitAddress nvarchar(255)

UPDATE PortfolioProj..NashvilleHousing
SET OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3)

alter table PortfolioProj..NashvilleHousing
add OwnerSplitCity nvarchar(255)

UPDATE PortfolioProj..NashvilleHousing
SET OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'), 2)

alter table PortfolioProj..NashvilleHousing
add OwnerSplitState nvarchar(255)

UPDATE PortfolioProj..NashvilleHousing
SET OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'), 1)


-- в колонке SoldAsVacant привести yes/no/y/n к единому виду

Update PortfolioProj..NashvilleHousing
set SoldAsVacant = 
	case	
		when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
	end


-- избавиться от дубликатов

with RowNumCTE as (
select *,
	row_number() over(
		partition by ParcelID, 
					PropertyAddress, 
					SalePrice, 
					SaleDate, 
					LegalReference
		order by UniqueID			
	) row_num
from PortfolioProj..NashvilleHousing 
)

delete
from RowNumCTE
where row_num > 1


-- удалить неиспользованные/ненужные колонки 

alter table PortfolioProj..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate