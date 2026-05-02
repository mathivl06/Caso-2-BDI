-- =====================================
-- ETL PROCESS
-- =====================================

-- =========================
-- CONTROL TABLE
-- =========================

CREATE TABLE IF NOT EXISTS etl_runs (
    run_id SERIAL PRIMARY KEY,
    process_name VARCHAR(100),
    last_run TIMESTAMP,
    current_run TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20),
    rows_processed INT
);

-- =========================
-- STAGING TABLES
-- =========================

CREATE TABLE IF NOT EXISTS stg_etheria_costs (
    productCategory VARCHAR(100),
    countryOrigin VARCHAR(50),
    costType VARCHAR(50),
    orderDate DATE,
    importCost DECIMAL(14,2),
    shippingCost DECIMAL(14,2),
    importFees DECIMAL(14,2),
    quantity INT
);

CREATE TABLE IF NOT EXISTS stg_dynamic_sales (
    productCategory VARCHAR(100),
    brandName VARCHAR(100),
    siteName VARCHAR(100),
    countryDestination VARCHAR(50),
    createdAt TIMESTAMP,
    totalInBase DECIMAL(14,2),
    baseCost DECIMAL(14,2),
    quantity INT
);

-- =========================
-- GET LAST RUN
-- =========================

WITH last_run_cte AS (
    SELECT COALESCE(MAX(current_run), '2000-01-01') AS last_run
    FROM etl_runs
    WHERE process_name = 'main_etl'
)

-- =========================
-- EXTRACT → STAGING (ETHERIA)
-- =========================

INSERT INTO stg_etheria_costs
SELECT
    pt.productTypeName,
    c.countryName,
    iod.status,
    io.orderDate,
    iod.lineTotal,
    iod.shippingCost,
    iod.importFees,
    iod.quantity
FROM etheria_global.ImportOrders io
JOIN etheria_global.ImportOrderDetails iod 
    ON io.importOrderId = iod.importOrderId
JOIN etheria_global.Suppliers s 
    ON io.supplierId = s.supplierId
JOIN etheria_global.Countries c 
    ON s.countryId = c.countryId
JOIN etheria_global.Products p 
    ON iod.productId = p.productId
JOIN etheria_global.ProductTypes pt 
    ON p.productTypeId = pt.productTypeId,
last_run_cte l
WHERE io.orderDate > l.last_run;

-- =========================
-- EXTRACT → STAGING (DYNAMIC)
-- =========================

INSERT INTO stg_dynamic_sales
SELECT
    pc.name,
    b.brandName,
    s.name,
    c.name,
    o.createdAt,
    o.totalInBase,
    p.baseCost,
    oi.quantity
FROM dynamic_brands.Orders o
JOIN dynamic_brands.OrderItems oi 
    ON o.orderId = oi.orderId
JOIN dynamic_brands.Products p 
    ON oi.productId = p.productId
JOIN dynamic_brands.ProductCategories pc 
    ON p.categoryId = pc.categoryId
JOIN dynamic_brands.Brands b 
    ON p.brandId = b.brandId
JOIN dynamic_brands.Sites s 
    ON o.siteId = s.siteId
JOIN dynamic_brands.Countries c 
    ON s.countryId = c.countryId,
last_run_cte l
WHERE o.createdAt > l.last_run;

-- =========================
-- TRANSFORM → ETHERIA DW
-- =========================

INSERT INTO EtheriaSupplyCosts
SELECT
    productCategory,
    countryOrigin,
    costType,

    SUM(importCost),
    SUM(shippingCost),
    SUM(importFees),
    SUM(importCost + shippingCost + importFees),

    TO_CHAR(orderDate, 'Month'),
    EXTRACT(YEAR FROM orderDate),
    EXTRACT(WEEK FROM orderDate)

FROM stg_etheria_costs
GROUP BY productCategory, countryOrigin, costType, orderDate
ON CONFLICT (productCategory, countryOrigin, costType, year, monthName, weekNumber)
DO UPDATE SET
    importCost = EXCLUDED.importCost,
    shippingCost = EXCLUDED.shippingCost,
    importFees = EXCLUDED.importFees,
    totalSupplyCost = EXCLUDED.totalSupplyCost;

-- =========================
-- TRANSFORM → DYNAMIC DW
-- =========================

INSERT INTO DynamicSales
SELECT
    d.productCategory,
    d.brandName,
    d.siteName,
    d.countryDestination,

    SUM(d.totalInBase),
    SUM(d.baseCost * d.quantity),

    COALESCE(SUM(e.totalSupplyCost), 0),

    SUM(d.baseCost * d.quantity) + COALESCE(SUM(e.totalSupplyCost), 0),

    SUM(d.totalInBase - (
        (d.baseCost * d.quantity) + COALESCE(e.totalSupplyCost, 0)
    )),

    TO_CHAR(d.createdAt, 'Month'),
    EXTRACT(YEAR FROM d.createdAt),
    EXTRACT(WEEK FROM d.createdAt)

FROM stg_dynamic_sales d
LEFT JOIN EtheriaSupplyCosts e
    ON d.productCategory = e.productCategory
    AND EXTRACT(YEAR FROM d.createdAt) = e.year
    AND EXTRACT(WEEK FROM d.createdAt) = e.weekNumber

GROUP BY 
    d.productCategory, d.brandName, d.siteName, 
    d.countryDestination, d.createdAt
ON CONFLICT (
    productCategory, brandName, siteName, 
    countryDestination, year, monthName, weekNumber
)
DO UPDATE SET
    totalSales = EXCLUDED.totalSales,
    productCost = EXCLUDED.productCost,
    supplyCost = EXCLUDED.supplyCost,
    totalCost = EXCLUDED.totalCost,
    totalProfit = EXCLUDED.totalProfit;

-- =========================
-- CLEAN STAGING
-- =========================

TRUNCATE TABLE stg_etheria_costs;
TRUNCATE TABLE stg_dynamic_sales;

-- =========================
-- LOG EXECUTION
-- =========================

INSERT INTO etl_runs (process_name, last_run, status, rows_processed)
VALUES (
    'main_etl',
    CURRENT_TIMESTAMP,
    'SUCCESS',
    (SELECT COUNT(*) FROM DynamicSales)
);