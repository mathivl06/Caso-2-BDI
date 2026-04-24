-- =========================
-- GEOGRAPHY
-- =========================

CREATE TABLE Countries (
    countryId SERIAL PRIMARY KEY,
    countryName VARCHAR(30) NOT NULL,
    enabled BOOLEAN NOT NULL
);

CREATE TABLE States (
    stateId SERIAL PRIMARY KEY,
    stateName VARCHAR(30) NOT NULL,
    countryId INT REFERENCES Countries(countryId)
);

CREATE TABLE Cities (
    cityId SERIAL PRIMARY KEY,
    cityName VARCHAR(40) NOT NULL,
    stateId INT REFERENCES States(stateId)
);

CREATE TABLE Addresses (
    addressId SERIAL PRIMARY KEY,
    address1 VARCHAR(40),
    address2 VARCHAR(40),
    zipCode INTEGER,
    cityId INT REFERENCES Cities(cityId)
);

-- =========================
-- CURRENCY
-- =========================

CREATE TABLE Currencies (
    currencyId SERIAL PRIMARY KEY,
    currencySymbol VARCHAR(5),
    currencyName VARCHAR(20),
    enabled BOOLEAN,
    countryId INT REFERENCES Countries(countryId)
);

CREATE TABLE ExchangeRateHistory (
    exchangeRateHistoryId SERIAL PRIMARY KEY,
    firstCurrencyId INT REFERENCES Currencies(currencyId),
    secondCurrencyId INT REFERENCES Currencies(currencyId),
    exchangeRate DECIMAL NOT NULL,
    effectiveDate TIMESTAMP NOT NULL,
    UNIQUE(firstCurrencyId, secondCurrencyId, effectiveDate)
);

-- =========================
-- BANKING
-- =========================

CREATE TABLE BankingIntermediaries (
    bankingIntermediaryId SERIAL PRIMARY KEY,
    bankingIntermediaryName VARCHAR(50),
    headquartersAddress INT REFERENCES Addresses(addressId)
);

CREATE TABLE CurrenciesPerBankingIntermediary (
    bankingIntermediaryId INT REFERENCES BankingIntermediaries(bankingIntermediaryId),
    currencyId INT REFERENCES Currencies(currencyId),
    PRIMARY KEY (bankingIntermediaryId, currencyId)
);

-- =========================
-- PRODUCTS
-- =========================

CREATE TABLE ProductTypes (
    productTypeId SERIAL PRIMARY KEY,
    productTypeName VARCHAR(30)
);

CREATE TABLE Products (
    productId SERIAL PRIMARY KEY,
    externalProductId VARCHAR(50) UNIQUE,
    productName VARCHAR(40),
    productTypeId INT REFERENCES ProductTypes(productTypeId),
    description VARCHAR(255),
    enabled BOOLEAN
);

-- =========================
-- SUPPLIERS
-- =========================

CREATE TABLE Suppliers (
    supplierId SERIAL PRIMARY KEY,
    supplierName VARCHAR(50),
    addressId INT REFERENCES Addresses(addressId),
    countryId INT REFERENCES Countries(countryId),
    enabled BOOLEAN
);

-- =========================
-- STATUS CATALOGS
-- =========================

CREATE TABLE ImportOrderStatusCatalog (
    statusId SERIAL PRIMARY KEY,
    statusName VARCHAR(20)
);

CREATE TABLE DispatchOrderStatusCatalog (
    statusId SERIAL PRIMARY KEY,
    statusName VARCHAR(20)
);

CREATE TABLE LogStatusCatalog (
    statusId SERIAL PRIMARY KEY,
    statusName VARCHAR(20)
);

-- =========================
-- IMPORTS
-- =========================

CREATE TABLE ImportOrders (
    importOrderId SERIAL PRIMARY KEY,
    supplierId INT REFERENCES Suppliers(supplierId),
    orderDate TIMESTAMP,
    arrivalDate TIMESTAMP,
    totalCostUSD DECIMAL,
    importOrderStatusId INT REFERENCES ImportOrderStatusCatalog(statusId)
);

CREATE TABLE ImportOrderDetails (
    importOrderDetailId SERIAL PRIMARY KEY,
    importOrderId INT REFERENCES ImportOrders(importOrderId),
    productId INT REFERENCES Products(productId),
    quantity INTEGER,
    unitCostUSD DECIMAL
);

-- =========================
-- BATCHES
-- =========================

CREATE TABLE Batches (
    batchId SERIAL PRIMARY KEY,
    productId INT REFERENCES Products(productId),
    importOrderId INT REFERENCES ImportOrders(importOrderId),
    arrivalDate TIMESTAMP,
    quantityReceived INTEGER,
    unitCostUSD DECIMAL
);

-- =========================
-- WAREHOUSE & INVENTORY
-- =========================

CREATE TABLE Warehouses (
    warehouseId SERIAL PRIMARY KEY,
    warehouseName VARCHAR(50),
    addressId INT REFERENCES Addresses(addressId)
);

CREATE TABLE Inventory (
    inventoryId SERIAL PRIMARY KEY,
    batchId INT REFERENCES Batches(batchId),
    warehouseId INT REFERENCES Warehouses(warehouseId),
    quantity INTEGER
);

-- =========================
-- DISPATCH
-- =========================

CREATE TABLE DispatchOrders (
    dispatchOrderId SERIAL PRIMARY KEY,
    dispatchDate TIMESTAMP,
    destinationCountryId INT REFERENCES Countries(countryId),
    dispatchStatusId INT REFERENCES DispatchOrderStatusCatalog(statusId)
);

CREATE TABLE DispatchOrderDetails (
    dispatchOrderDetailId SERIAL PRIMARY KEY,
    dispatchOrderId INT REFERENCES DispatchOrders(dispatchOrderId),
    batchId INT REFERENCES Batches(batchId),
    quantity INTEGER
);

-- =========================
-- SHIPPING
-- =========================

CREATE TABLE CourierServices (
    courierServiceId SERIAL PRIMARY KEY,
    courierName VARCHAR(50),
    contactInfo VARCHAR(100)
);

CREATE TABLE Shipments (
    shipmentId SERIAL PRIMARY KEY,
    dispatchOrderId INT REFERENCES DispatchOrders(dispatchOrderId),
    courierServiceId INT REFERENCES CourierServices(courierServiceId),
    shipmentDate TIMESTAMP,
    deliveryDate TIMESTAMP,
    shippingCostUSD DECIMAL
);

-- =========================
-- INVENTORY TRANSACTIONS
-- =========================

CREATE TABLE InventoryTransactionType (
    inventoryTransactionTypeId SERIAL PRIMARY KEY,
    inventoryTransactionTypeName VARCHAR(20)
);

CREATE TABLE InventoryTransactions (
    transactionId SERIAL PRIMARY KEY,
    batchId INT REFERENCES Batches(batchId),
    warehouseId INT REFERENCES Warehouses(warehouseId),
    quantity INTEGER,
    inventoryTransactionTypeId INT REFERENCES InventoryTransactionType(inventoryTransactionTypeId),
    transactionDate TIMESTAMP,
    referenceId INTEGER
);

-- =========================
-- LOGS
-- =========================

CREATE TABLE Logs (
    logId SERIAL PRIMARY KEY,
    procedureName VARCHAR(50),
    message VARCHAR(255),
    logDate TIMESTAMP,
    logStatusId INT REFERENCES LogStatusCatalog(statusId)
);