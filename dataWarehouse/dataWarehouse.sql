-- =====================================
-- DATA WAREHOUSE: DynamicBrandsDW
-- PostgreSQL
-- =====================================

CREATE DATABASE DynamicBrandsDW;

-- =========================
-- FACT TABLE 1: ETHERIA COSTS
-- =========================

CREATE TABLE EtheriaSupplyCosts (
    productCategory VARCHAR(100),
    countryOrigin VARCHAR(50),
    costType VARCHAR(50),

    importCost DECIMAL(14,2),
    shippingCost DECIMAL(14,2),
    importFees DECIMAL(14,2),
    totalSupplyCost DECIMAL(14,2),

    monthName VARCHAR(20),
    year INT,
    weekNumber INT,

    PRIMARY KEY (productCategory, countryOrigin, costType, year, monthName, weekNumber)
);

-- =========================
-- FACT TABLE 2: DYNAMIC SALES
-- =========================

CREATE TABLE DynamicSales (
    productCategory VARCHAR(100),
    brandName VARCHAR(100),
    siteName VARCHAR(100),
    countryDestination VARCHAR(50),

    totalSales DECIMAL(14,2),
    productCost DECIMAL(14,2),
    supplyCost DECIMAL(14,2),
    totalCost DECIMAL(14,2),
    totalProfit DECIMAL(14,2),

    monthName VARCHAR(20),
    year INT,
    weekNumber INT,

    PRIMARY KEY (
        productCategory,
        brandName,
        siteName,
        countryDestination,
        year,
        monthName,
        weekNumber
    )
);

-- =========================
-- INDEXES (performance)
-- =========================

CREATE INDEX idx_etheria_time 
ON EtheriaSupplyCosts (year, monthName, weekNumber);

CREATE INDEX idx_dynamic_time 
ON DynamicSales (year, monthName, weekNumber);

-- =========================
-- ANALYTICAL QUERY
-- =========================

SELECT 
    d.productCategory,
    d.brandName,
    d.siteName,
    d.countryDestination,
    e.countryOrigin,
    d.year,
    d.monthName,
    d.weekNumber,
    e.totalSupplyCost,
    d.totalSales,
    d.totalCost,
    d.totalProfit
FROM DynamicSales d
LEFT JOIN EtheriaSupplyCosts e
    ON d.productCategory = e.productCategory
    AND d.year = e.year
    AND d.monthName = e.monthName
    AND d.weekNumber = e.weekNumber;