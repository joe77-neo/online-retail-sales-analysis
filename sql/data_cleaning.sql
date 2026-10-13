
-- ONLINE RETAIL SALES & CUSTOMER ANALYSIS
-- DATA CLEANING


-- 1. Check the original dataset
SELECT
    COUNT(*) AS total_rows
FROM retail_transactions;


-- 2. Check for duplicate records
WITH DuplicateCheck AS
(
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY
                InvoiceNo,
                StockCode,
                Description,
                Quantity,
                InvoiceDate,
                UnitPrice,
                CustomerID,
                Country
            ORDER BY InvoiceNo
        ) AS row_num
    FROM retail_transactions
)
SELECT
    COUNT(*) AS duplicate_rows
FROM DuplicateCheck
WHERE row_num > 1;


-- 3. Remove extra duplicate records
WITH DuplicateCheck AS
(
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY
                InvoiceNo,
                StockCode,
                Description,
                Quantity,
                InvoiceDate,
                UnitPrice,
                CustomerID,
                Country
            ORDER BY InvoiceNo
        ) AS row_num
    FROM retail_transactions
)
SELECT
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID,
    Country
INTO retail_transactions_clean
FROM DuplicateCheck
WHERE row_num = 1;


-- 4. Keep transactions with positive quantities
SELECT *
INTO retail_sales_clean
FROM retail_transactions_clean
WHERE Quantity > 0;


-- 5. Keep transactions with positive prices
SELECT *
INTO final_sales_clean
FROM retail_sales_clean
WHERE UnitPrice > 0;


-- 6. Create the Power BI source table
SELECT
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID,
    Country,
    Quantity * UnitPrice AS Revenue
INTO final_sales_powerbi
FROM final_sales_clean;
