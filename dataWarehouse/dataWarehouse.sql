-- =====================================
-- DATA WAREHOUSE: DynamicBrandsDW
-- PostgreSQL
-- =====================================

-- This script is intended to run inside the DynamicBrandsDW database.
-- The Docker container creates the database through POSTGRES_DB.

-- =========================
-- FACT TABLE 1: ETHERIA COSTS
-- =========================

CREATE TABLE IF NOT EXISTS EtheriaSupplyCosts (
    productCategory VARCHAR(100) NOT NULL,
    countryOrigin VARCHAR(50) NOT NULL,
    costType VARCHAR(50) NOT NULL,

    importCost DECIMAL(14,2) NOT NULL DEFAULT 0,
    shippingCost DECIMAL(14,2) NOT NULL DEFAULT 0,
    importFees DECIMAL(14,2) NOT NULL DEFAULT 0,
    totalSupplyCost DECIMAL(14,2) NOT NULL DEFAULT 0,

    monthName VARCHAR(20) NOT NULL,
    year INT NOT NULL,
    weekNumber INT NOT NULL,

    PRIMARY KEY (productCategory, countryOrigin, costType, year, monthName, weekNumber)
);

-- =========================
-- FACT TABLE 2: DYNAMIC SALES
-- =========================

CREATE TABLE IF NOT EXISTS DynamicSales (
    productCategory VARCHAR(100) NOT NULL,
    brandName VARCHAR(100) NOT NULL,
    siteName VARCHAR(100) NOT NULL,
    countryDestination VARCHAR(50) NOT NULL,

    totalSales DECIMAL(14,2) NOT NULL DEFAULT 0,
    productCost DECIMAL(14,2) NOT NULL DEFAULT 0,
    supplyCost DECIMAL(14,2) NOT NULL DEFAULT 0,
    totalCost DECIMAL(14,2) NOT NULL DEFAULT 0,
    totalProfit DECIMAL(14,2) NOT NULL DEFAULT 0,

    monthName VARCHAR(20) NOT NULL,
    year INT NOT NULL,
    weekNumber INT NOT NULL,

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
-- CENTRAL DASHBOARD TABLE
-- =========================

CREATE TABLE IF NOT EXISTS DashboardProfitability (
    productCategory VARCHAR(100) NOT NULL,
    brandName VARCHAR(100) NOT NULL,
    siteName VARCHAR(100) NOT NULL,
    countryOrigin VARCHAR(50) NOT NULL,
    countryDestination VARCHAR(50) NOT NULL,

    totalSales DECIMAL(14,2) NOT NULL DEFAULT 0,
    importCost DECIMAL(14,2) NOT NULL DEFAULT 0,
    shippingCost DECIMAL(14,2) NOT NULL DEFAULT 0,
    importFees DECIMAL(14,2) NOT NULL DEFAULT 0,
    productCost DECIMAL(14,2) NOT NULL DEFAULT 0,
    totalCost DECIMAL(14,2) NOT NULL DEFAULT 0,
    totalProfit DECIMAL(14,2) NOT NULL DEFAULT 0,
    profitMargin DECIMAL(8,4) NOT NULL DEFAULT 0,

    monthName VARCHAR(20) NOT NULL,
    year INT NOT NULL,
    weekNumber INT NOT NULL,

    PRIMARY KEY (
        productCategory,
        brandName,
        siteName,
        countryOrigin,
        countryDestination,
        year,
        monthName,
        weekNumber
    )
);

-- =========================
-- INDEXES (performance)
-- =========================

CREATE INDEX IF NOT EXISTS idx_etheria_time 
ON EtheriaSupplyCosts (year, monthName, weekNumber);

CREATE INDEX IF NOT EXISTS idx_dynamic_time 
ON DynamicSales (year, monthName, weekNumber);

CREATE INDEX IF NOT EXISTS idx_dashboard_category
ON DashboardProfitability (productCategory, year, weekNumber);

CREATE INDEX IF NOT EXISTS idx_dashboard_brand
ON DashboardProfitability (brandName, year, weekNumber);

CREATE INDEX IF NOT EXISTS idx_dashboard_country
ON DashboardProfitability (countryDestination, year, weekNumber);
