/* DATA CLEANING IN SQL */

Select *
from PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select Sale_Date, Convert(Date, SaleDate)
From PortfolioProject..NashvilleHousing


Alter Table NashvilleHousing
Add Sale_Date Date;

Update NashvilleHousing
Set Sale_Date = Convert(Date, SaleDate)

------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is Null
Order By ParcelID

-- With Self Joining Populating Duplicate Parcel Id with Null value in PropertyAdress

Select a.[UniqueID ], a.ParcelID, a.PropertyAddress,b.[UniqueID ], b.ParcelID, b.PropertyAddress
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress Is Null

--Removing Null - Now we can update NUll in Column PropertyAdress with Correct address 

Update a --a is allias for PortfolioProject..NashvilleHousing (When we have join in query we can update Table by using It's allias)
Set PropertyAddress = IsNull(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress Is Null

-------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Property Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is Null
--Order By ParcelID

Select
Substring (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) As Address,
Substring (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress)) As Address
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = Substring (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table NashvilleHousing
Add PropertySplitCity Date;

Alter Table NashvilleHousing
Alter Column PropertySplitCity nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = Substring (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress))


-------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Owner Address into Individual Columns (Address, City, State) using PARSENAME()

/* We can use PARSENAME() to sperate a string by it's delimiter */
/* PARSENAME() only works with dot (.) but we can use REPLACE within the PARSENAME and replace dot(.) with
desired delimiter */


Select 
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

Select *
From PortfolioProject..NashvilleHousing


------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group By SoldAsVacant
Order By 2

Select SoldAsVacant,
Case when SoldAsVacant = 'Y' Then 'Yes'
	 when SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
From PortfolioProject..NashvilleHousing


Update NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'Yes'
	 when SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End

------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates Using ROW_NUMBER()

With RowNumCTE As (
Select *,
	Row_Number() Over (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 OwnerName,
				 LegalReference
				 Order By UniqueID
				 ) Row_Num

From PortfolioProject..NashvilleHousing
)
Delete
From RowNumCTE
Where Row_Num > 1

----------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioProject..NashvilleHousing


Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, PropertyAddress, TaxDistrict


Alter Table PortfolioProject..NashvilleHousing
Drop Column SaleDate