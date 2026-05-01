-- =====================================
-- DATA WAREHOUSE: DynamicBrandsDW
-- =====================================
-- Database engine: PostgreSQL
-- Context: Data Warehouse for aggregated analysis from Etheria Global (supply costs) and Dynamic Brands (sales).
-- Data is denormalized and summarized by product category and time periods.
-- All metrics in base currency (assumed USD for consistency).

-- Create the database
CREATE DATABASE DynamicBrandsDW;

-- =====================================
-- DIMENSION TABLES (if needed for future expansion, but kept minimal as per requirements)
-- =====================================

-- No additional dimensions needed; data is denormalized in fact tables.

-- =====================================
-- FACT TABLES
-- =====================================

-- EtheriaSupplyCosts: Aggregated supply costs from Etheria Global
CREATE TABLE EtheriaSupplyCosts (
    productCategory VARCHAR(100) NOT NULL,
    countryOrigin VARCHAR(50) NOT NULL,
    costType VARCHAR(50) NOT NULL,
    monthName VARCHAR(20) NOT NULL,
    year INT NOT NULL,
    weekNumber INT NOT NULL,
    totalCost DECIMAL(14,2) NOT NULL,
    quantityUnits INT NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (productCategory, countryOrigin, costType, year, monthName, weekNumber)
);

-- DynamicSales: Aggregated sales and profits from Dynamic Brands
CREATE TABLE DynamicSales (
    productCategory VARCHAR(100) NOT NULL,
    brandName VARCHAR(100) NOT NULL,
    siteName VARCHAR(100) NOT NULL,
    countryDestination VARCHAR(50) NOT NULL,
    monthName VARCHAR(20) NOT NULL,
    year INT NOT NULL,
    weekNumber INT NOT NULL,
    totalSales DECIMAL(14,2) NOT NULL,
    totalCost DECIMAL(14,2) NOT NULL,
    totalProfit DECIMAL(14,2) NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (productCategory, brandName, siteName, countryDestination, year, monthName, weekNumber)
);

-- =====================================
-- ETL LOGIC (Sample Queries for Data Extraction and Loading)
-- =====================================
-- Assumptions:
-- - Etheria Global DB is accessible via foreign data wrapper or direct connection (e.g., dblink or fdw).
-- - Dynamic Brands DB (MySQL) is accessible via foreign data wrapper (e.g., mysql_fdw extension).
-- - Base currency is USD; all amounts are pre-converted in OLTP systems.
-- - Dates are extracted from relevant timestamps (e.g., Orders.createdAt for sales).
-- - Run these ETL queries periodically (e.g., weekly) to populate DW.

-- Enable extensions if needed for cross-DB access
-- CREATE EXTENSION IF NOT EXISTS dblink;
-- CREATE EXTENSION IF NOT EXISTS mysql_fdw;  -- For MySQL access

-- ETL for EtheriaSupplyCosts (from Etheria Global PostgreSQL DB)
-- Aggregate costs by product category, supplier country, cost type, and time.
INSERT INTO EtheriaSupplyCosts (
    productCategory, countryOrigin, costType, monthName, year, weekNumber, totalCost, quantityUnits
)
SELECT
    pt.productTypeName AS productCategory,  -- Assuming ProductTypes.name maps to category
    c.countryName AS countryOrigin,
    CASE 
        WHEN iod.status = 'RECEIVED' THEN 'Import Cost'
        ELSE 'Other Cost'
    END AS costType,  -- Simplified; adjust based on actual cost types
    TO_CHAR(io.orderDate, 'Month') AS monthName,
    EXTRACT(YEAR FROM io.orderDate) AS year,
    EXTRACT(WEEK FROM io.orderDate) AS weekNumber,
    SUM(iod.lineTotal) AS totalCost,  -- Assumed in base currency
    SUM(iod.quantity) AS quantityUnits
FROM 
    etheria_global.ImportOrders io  -- Replace with actual schema prefix if using fdw
JOIN etheria_global.ImportOrderDetails iod ON io.importOrderId = iod.importOrderId
JOIN etheria_global.Suppliers s ON io.supplierId = s.supplierId
JOIN etheria_global.Countries c ON s.countryId = c.countryId
JOIN etheria_global.Products p ON iod.productId = p.productId
JOIN etheria_global.ProductTypes pt ON p.productTypeId = pt.productTypeId
WHERE io.deleted = FALSE
  AND p.deleted = FALSE
  AND s.deleted = FALSE
GROUP BY pt.productTypeName, c.countryName, costType, monthName, year, weekNumber
ON CONFLICT (productCategory, countryOrigin, costType, year, monthName, weekNumber) 
DO UPDATE SET 
    totalCost = EXCLUDED.totalCost,
    quantityUnits = EXCLUDED.quantityUnits,
    createdAt = CURRENT_TIMESTAMP;

-- ETL for DynamicSales (from Dynamic Brands MySQL DB)
-- Aggregate sales, costs, and profits by product category, brand, site, destination country, and time.
INSERT INTO DynamicSales (
    productCategory, brandName, siteName, countryDestination, monthName, year, weekNumber, totalSales, totalCost, totalProfit
)
SELECT
    pc.name AS productCategory,
    b.brandName,
    s.name AS siteName,
    c.name AS countryDestination,
    DATE_FORMAT(o.createdAt, '%M') AS monthName,
    YEAR(o.createdAt) AS year,
    WEEK(o.createdAt) AS weekNumber,
    SUM(o.totalInBase) AS totalSales,  -- Sales in base currency
    SUM(p.baseCost * oi.quantity) AS totalCost,  -- Costs in base currency
    SUM(o.totalInBase - (p.baseCost * oi.quantity)) AS totalProfit
FROM 
    dynamic_brands.Orders o  -- Replace with actual schema prefix if using fdw
JOIN dynamic_brands.OrderItems oi ON o.orderId = oi.orderId
JOIN dynamic_brands.Products p ON oi.productId = p.productId
JOIN dynamic_brands.ProductCategories pc ON p.categoryId = pc.categoryId
JOIN dynamic_brands.Brands b ON p.brandId = b.brandId
JOIN dynamic_brands.Sites s ON o.siteId = s.siteId
JOIN dynamic_brands.Countries c ON s.countryId = c.countryId
WHERE o.deleted = FALSE
  AND p.deleted = FALSE
  AND s.deleted = FALSE
GROUP BY pc.name, b.brandName, s.name, c.name, monthName, year, weekNumber
ON CONFLICT (productCategory, brandName, siteName, countryDestination, year, monthName, weekNumber) 
DO UPDATE SET 
    totalSales = EXCLUDED.totalSales,
    totalCost = EXCLUDED.totalCost,
    totalProfit = EXCLUDED.totalProfit,
    createdAt = CURRENT_TIMESTAMP;

-- =====================================
-- SAMPLE QUERY FOR ANALYSIS (as per dataWarehouse.md)
-- =====================================

SELECT 
    d.productCategory,
    d.brandName,
    d.siteName,
    d.countryDestination,
    e.countryOrigin,
    d.year,
    d.monthName,
    d.weekNumber,
    e.totalCost AS supplyCost,
    d.totalSales,
    d.totalProfit
FROM DynamicSales d
LEFT JOIN EtheriaSupplyCosts e
    ON d.productCategory = e.productCategory
    AND d.year = e.year
    AND d.monthName = e.monthName
    AND d.weekNumber = e.weekNumber;

-- =====================================
-- INDEXES FOR PERFORMANCE
-- =====================================

CREATE INDEX idx_etheria_costs_time ON EtheriaSupplyCosts (year, monthName, weekNumber);
CREATE INDEX idx_dynamic_sales_time ON DynamicSales (year, monthName, weekNumber);
CREATE INDEX idx_dynamic_sales_category ON DynamicSales (productCategory);

-- =====================================
-- NOTES
-- =====================================
-- - Adjust schema prefixes (e.g., etheria_global, dynamic_brands) based on your fdw setup.
-- - Ensure base currency conversions are handled in OLTP before ETL.
-- - Run ETL in a transaction for consistency.
-- - Add error handling and logging in production scripts.