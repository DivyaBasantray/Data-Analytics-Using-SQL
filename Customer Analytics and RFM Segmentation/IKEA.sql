CREATE DATABASE EcommerceCustomerAnalytics;

USE EcommerceCustomerAnalytics;

-- CHECK ROW COUNTS AFTER IMPORT

SELECT COUNT(*) AS Rows_2009_2010
FROM dbo.[YEAR 2009-2010];

SELECT COUNT(*) AS Rows_2010_2011
FROM dbo.[YEAR 2010-2011];

-- COMBINE BOTH YEARS AND CONVERT TYPES

SELECT
	Invoice, StockCode, Description, Quantity,

	COALESCE(
		TRY_CONVERT(DATETIME2, InvoiceDate, 120),
		TRY_CONVERT(DATETIME2, InvoiceDate, 105)
	) AS InvoiceDate,

	TRY_CONVERT(DECIMAL(10,2), Price) AS Price,
	Customer_ID, Country, '2009-2010' AS SourceSheet

INTO dbo.RetailCombined
FROM dbo.[YEAR 2009-2010]

UNION ALL

SELECT
	Invoice, StockCode, Description, Quantity,

	COALESCE(
		TRY_CONVERT(DATETIME2, InvoiceDate, 120),
		TRY_CONVERT(DATETIME2, InvoiceDate, 105)
	) AS InvoiceDate,

	TRY_CONVERT(DECIMAL(10,2), Price) AS Price,
	Customer_ID, Country, '2010-2011' AS SourceSheet
FROM dbo.[YEAR 2010-2011];

-- CONFIRM IF THE CONVERSION WORKED CLEANLY

SELECT COUNT(*) AS Total_Rows
FROM dbo.RetailCombined;

SELECT COUNT(*) AS Failed_Dates
FROM dbo.RetailCombined
WHERE InvoiceDate IS NULL;

SELECT COUNT(*) AS Failed_Prices
FROM dbo.RetailCombined
WHERE Price IS NULL;

-- DATA EXPLORATION

-- CHECK 1: MISSING CUSTOMER ID

SELECT COUNT(*) AS Missing_Customer_ID
FROM dbo.RetailCombined
WHERE Customer_ID IS NULL;

-- CHECK 2: NEGATIVE OR ZERO QUANTITY

SELECT COUNT(*) AS Negative_Qty
FROM dbo.RetailCombined
WHERE Quantity <= 0;

-- CHECK 3: MISSING DESCRIPTION

SELECT COUNT(*) AS Missing_Description
FROM dbo.RetailCombined
WHERE Description IS NULL;

-- CHECK 4: EXACT DUPLICATE ROWS

SELECT Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, Country,
	   COUNT(*) AS Exact_Dupe_Count

FROM dbo.RetailCombined
GROUP BY Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, Country
HAVING COUNT(*) > 1;

-- DEDUPLICATE AND PRODUCE THE FINAL CLEANED TABLE

WITH Deduped AS(
	SELECT *,
		ROW_NUMBER() OVER(
			PARTITION BY Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, Country
			ORDER BY (SELECT NULL)
		) AS RowNum
	FROM dbo.RetailCombined
)
SELECT Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, Country, SourceSheet
INTO dbo.RetailCleaned
FROM Deduped
WHERE RowNum = 1;

SELECT *
FROM dbo.RetailCleaned;

SELECT COUNT()
FROM dbo.RetailCleaned;

SELECT
    Invoice, StockCode, Description, Quantity,
    COALESCE(
        TRY_CONVERT(datetime2, InvoiceDate, 120),
        TRY_CONVERT(datetime2, InvoiceDate, 105)
    ) AS InvoiceDate,
    TRY_CONVERT(decimal(10,2), Price) AS Price,
    Customer_ID, Country
INTO dbo.RetailCombined
FROM dbo.[Year 2009-2010];
