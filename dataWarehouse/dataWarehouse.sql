CREATE DATABASE "DynamicBrandsDW";
\c DynamicBrandsDW;

-- ======================
-- DIMENSIONS
-- ======================

CREATE TABLE DimDate (
    dateKey INT PRIMARY KEY,
    fullDate DATE,
    day INT,
    month INT,
    year INT,
    quarter INT
);

CREATE TABLE DimProduct (
    productKey SERIAL PRIMARY KEY,
    externalProductId VARCHAR(50),
    productName VARCHAR(150),
    category VARCHAR(100),
    productType VARCHAR(50)
);

CREATE TABLE DimCustomer (
    customerKey SERIAL PRIMARY KEY,
    customerId INT,
    country VARCHAR(100)
);

CREATE TABLE DimSite (
    siteKey SERIAL PRIMARY KEY,
    siteId INT,
    siteName VARCHAR(100),
    country VARCHAR(100),
    currency VARCHAR(10)
);

CREATE TABLE DimSupplier (
    supplierKey SERIAL PRIMARY KEY,
    supplierId INT,
    supplierName VARCHAR(100),
    country VARCHAR(100)
);

CREATE TABLE DimWarehouse (
    warehouseKey SERIAL PRIMARY KEY,
    warehouseId INT,
    warehouseName VARCHAR(100),
    country VARCHAR(100)
);

CREATE TABLE DimBatch (
    batchKey SERIAL PRIMARY KEY,
    batchId INT,
    arrivalDate TIMESTAMP
);

CREATE TABLE DimPaymentStatus (
    paymentStatusKey SERIAL PRIMARY KEY,
    code VARCHAR(20),
    description VARCHAR(100)
);

CREATE TABLE DimOrderStatus (
    orderStatusKey SERIAL PRIMARY KEY,
    code VARCHAR(20),
    description VARCHAR(100)
);

-- ======================
-- FACT TABLES
-- ======================

CREATE TABLE FactSales (
    salesId SERIAL PRIMARY KEY,
    orderId INT,
    orderItemId INT,

    productKey INT,
    customerKey INT,
    siteKey INT,
    dateKey INT,

    quantity INT,
    unitPrice DECIMAL(14,2),

    subtotalLocal DECIMAL(14,2),
    subtotalUSD DECIMAL(14,2),
    taxesUSD DECIMAL(14,2),
    totalUSD DECIMAL(14,2),

    paymentStatusKey INT,
    orderStatusKey INT,

    FOREIGN KEY (productKey) REFERENCES DimProduct(productKey),
    FOREIGN KEY (customerKey) REFERENCES DimCustomer(customerKey),
    FOREIGN KEY (siteKey) REFERENCES DimSite(siteKey),
    FOREIGN KEY (dateKey) REFERENCES DimDate(dateKey),
    FOREIGN KEY (paymentStatusKey) REFERENCES DimPaymentStatus(paymentStatusKey),
    FOREIGN KEY (orderStatusKey) REFERENCES DimOrderStatus(orderStatusKey)
);

CREATE TABLE FactInventory (
    inventoryFactId SERIAL PRIMARY KEY,

    batchKey INT,
    productKey INT,
    warehouseKey INT,
    dateKey INT,

    quantityAvailable INT,
    unitCostUSD DECIMAL(14,2),

    FOREIGN KEY (batchKey) REFERENCES DimBatch(batchKey),
    FOREIGN KEY (productKey) REFERENCES DimProduct(productKey),
    FOREIGN KEY (warehouseKey) REFERENCES DimWarehouse(warehouseKey),
    FOREIGN KEY (dateKey) REFERENCES DimDate(dateKey)
);

CREATE TABLE FactSupply (
    supplyId SERIAL PRIMARY KEY,

    supplierKey INT,
    productKey INT,
    dateKey INT,

    quantity INT,
    unitCostUSD DECIMAL(14,2),
    totalCostUSD DECIMAL(14,2),

    FOREIGN KEY (supplierKey) REFERENCES DimSupplier(supplierKey),
    FOREIGN KEY (productKey) REFERENCES DimProduct(productKey),
    FOREIGN KEY (dateKey) REFERENCES DimDate(dateKey)
);

CREATE TABLE FactShipment (
    shipmentFactId SERIAL PRIMARY KEY,

    shipmentId INT,
    orderId INT,

    productKey INT,
    batchKey INT,
    siteKey INT,
    dateKey INT,

    shippingCostUSD DECIMAL(14,2),
    deliveryTimeDays INT,

    FOREIGN KEY (productKey) REFERENCES DimProduct(productKey),
    FOREIGN KEY (batchKey) REFERENCES DimBatch(batchKey),
    FOREIGN KEY (siteKey) REFERENCES DimSite(siteKey),
    FOREIGN KEY (dateKey) REFERENCES DimDate(dateKey)
);