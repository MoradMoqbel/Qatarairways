
-- A glimpse on our data

SELECT * 
FROM Nashvillehosuing

-- Populate Property Address data

SELECT PropertyAddress 
FROM Nashvillehosuing
WHERE PropertyAddress IS NULL


-- Join our table on itself, so we can fill our null PropertyAddress values
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Nashvillehosuing a
JOIN Nashvillehosuing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL

-- Breaking down PropertyAddress into individual columns

UPDATE Nashvillehosuing
SET PropertyAddress = REPLACE(PropertyAddress, ',', '.')


ALTER TABLE Nashvillehosuing 
ADD PropertySplitAddress VARCHAR(255);

UPDATE Nashvillehosuing
SET PropertySplitAddress = PARSENAME(PropertyAddress,2);

ALTER TABLE Nashvillehosuing 
ADD PropertySplitCity VARCHAR(255);

UPDATE Nashvillehosuing
SET PropertySplitCity = PARSENAME(PropertyAddress,1);

 -- Breaking down OwenerAddress into individual columns

UPDATE Nashvillehosuing
SET OwnerAddress = REPLACE(PropertyAddress, ',', '.')

ALTER TABLE Nashvillehosuing 
ADD OwnerSplitAddress VARCHAR(255),
    OwnerSplitCity    VARCHAR(255),
    OwnerSplitState   VARCHAR(255);

UPDATE Nashvillehosuing
SET OwnerSplitAddress = PARSENAME(OwnerAddress,3),
    OwnerSplitCity    = PARSENAME(OwnerAddress,2),
    OwnerSplitState   = PARSENAME(OwnerAddress,1);


-- change "N and Y" values in column SoldAsVacant to "No and Yes" --

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Nashvillehosuing 
GROUP BY SoldAsVacant
ORDER BY 2

-- There are about 52 vlaues had been recorded as Y and 399 as N, so we are going to fix that with update statement --

UPDATE Nashvillehosuing
SET SoldAsVacant = CASE 
                        WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
                        ELSE SoldAsVacant
                        END;
-- Remove duplicates by creating A Common table expression--

WITH DWND AS(
SELECT *,
          ROW_NUMBER() OVER (
          PARTITION BY ParcelID,
                       LegalReference,
                       SalePrice,
                       SaleDate ORDER BY UniqueID) row_num

FROM Nashvillehosuing
)

SELECT * FROM DWND WHERE row_num > 1


-- Delete unuseful columns --

ALTER TABLE Nashvillehosuing
DROP COLUMN PropertyAddress,OwnerAddress,TaxDistrict

-- DONE !!! --
