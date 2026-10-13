-- ONLINE RETAIL SALES & CUSTOMER ANALYSIS
-- SQL ANALYSIS



-- 1. Total Revenue
SELECT
    SUM(Quantity * UnitPrice) AS total_revenue
FROM final_sales_clean;


-- 2. Monthly Revenue
SELECT
    YEAR(InvoiceDate) AS sales_year,
    MONTH(InvoiceDate) AS sales_month,
    SUM(Quantity * UnitPrice) AS monthly_revenue
FROM final_sales_clean
GROUP BY
    YEAR(InvoiceDate),
    MONTH(InvoiceDate)
ORDER BY
    sales_year,
    sales_month;


-- 3. Average Order Value (AOV)
SELECT
    SUM(Quantity * UnitPrice) /
        COUNT(DISTINCT InvoiceNo) AS average_order_value
FROM final_sales_clean;


-- 4. Unique Customers
SELECT
    COUNT(DISTINCT CustomerID) AS unique_customers
FROM final_sales_clean;


-- 5. Top 10 Customers by Revenue
SELECT TOP 10
    CustomerID,
    SUM(Quantity * UnitPrice) AS customer_revenue
FROM final_sales_clean
WHERE CustomerID IS NOT NULL
GROUP BY
    CustomerID
ORDER BY
    customer_revenue DESC;


-- 6. Top 10 Products by Revenue
-- Exclude non-product transaction codes
SELECT TOP 10
    StockCode,
    Description,
    SUM(Quantity * UnitPrice) AS product_revenue
FROM final_sales_clean
WHERE StockCode NOT IN ('DOT', 'POST', 'M')
GROUP BY
    StockCode,
    Description
ORDER BY
    product_revenue DESC;


-- 7. Top 10 Products by Quantity
SELECT TOP 10
    StockCode,
    Description,
    SUM(Quantity) AS quantity_sold
FROM final_sales_clean
WHERE StockCode NOT IN ('DOT', 'POST', 'M')
GROUP BY
    StockCode,
    Description
ORDER BY
    quantity_sold DESC;


-- 8. Customer Order Frequency
SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS order_count
FROM final_sales_clean
WHERE CustomerID IS NOT NULL
GROUP BY
    CustomerID
ORDER BY
    order_count DESC;


-- 9. One-time vs Repeat Customers
WITH CustomerOrders AS
(
    SELECT
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS order_count
    FROM final_sales_clean
    WHERE CustomerID IS NOT NULL
    GROUP BY
        CustomerID
)
SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,
    COUNT(*) AS customer_count
FROM CustomerOrders
GROUP BY
    CASE
        WHEN order_count = 1 THEN 'One-time Customer'
        ELSE 'Repeat Customer'
    END;


-- 10. One-time vs Repeat Customer Revenue
WITH CustomerOrders AS
(
    SELECT
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS order_count
    FROM final_sales_clean
    WHERE CustomerID IS NOT NULL
    GROUP BY
        CustomerID
)
SELECT
    CASE
        WHEN co.order_count = 1 THEN 'One-time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,
    SUM(fs.Quantity * fs.UnitPrice) AS customer_revenue
FROM final_sales_clean fs
JOIN CustomerOrders co
    ON fs.CustomerID = co.CustomerID
GROUP BY
    CASE
        WHEN co.order_count = 1 THEN 'One-time Customer'
        ELSE 'Repeat Customer'
    END;


-- 11. Revenue by Country
SELECT TOP 10
    Country,
    SUM(Quantity * UnitPrice) AS country_revenue
FROM final_sales_clean
GROUP BY
    Country
ORDER BY
    country_revenue DESC;


-- 12. Top 10 Customer Revenue Share
WITH CustomerRevenue AS
(
    SELECT
        CustomerID,
        SUM(Quantity * UnitPrice) AS customer_revenue
    FROM final_sales_clean
    WHERE CustomerID IS NOT NULL
    GROUP BY
        CustomerID
),
TopCustomers AS
(
    SELECT TOP 10
        CustomerID,
        customer_revenue
    FROM CustomerRevenue
    ORDER BY
        customer_revenue DESC
)
SELECT
    SUM(customer_revenue) AS top_10_revenue,
    (SELECT SUM(customer_revenue)
     FROM CustomerRevenue) AS known_customer_revenue,
    SUM(customer_revenue) * 100.0 /
        (SELECT SUM(customer_revenue)
         FROM CustomerRevenue) AS top_10_revenue_share
FROM TopCustomers;


-- 13. Top 10 Product Revenue Share
WITH ProductRevenue AS
(
    SELECT
        StockCode,
        Description,
        SUM(Quantity * UnitPrice) AS product_revenue
    FROM final_sales_clean
    WHERE StockCode NOT IN ('DOT', 'POST', 'M')
    GROUP BY
        StockCode,
        Description
),
TopProducts AS
(
    SELECT TOP 10
        StockCode,
        Description,
        product_revenue
    FROM ProductRevenue
    ORDER BY
        product_revenue DESC
)
SELECT
    SUM(product_revenue) AS top_10_product_revenue,
    (SELECT SUM(product_revenue)
     FROM ProductRevenue) AS total_product_revenue,
    SUM(product_revenue) * 100.0 /
        (SELECT SUM(product_revenue)
         FROM ProductRevenue) AS top_10_revenue_share
FROM TopProducts;


-- 14. Identify Extreme Quantity Outliers
SELECT
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    UnitPrice,
    InvoiceDate,
    CustomerID,
    Country
FROM final_sales_clean
WHERE Quantity >= 10000
ORDER BY
    Quantity DESC;
