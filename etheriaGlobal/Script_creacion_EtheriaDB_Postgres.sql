-- =====================================
-- PERSONS (base for FK dependencies)
-- =====================================

CREATE TABLE Persons (
    personId SERIAL PRIMARY KEY,
    firstName VARCHAR(50) NOT NULL,
    lastName VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    idDocument VARCHAR(30),
    active BOOLEAN DEFAULT TRUE,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP,
    deleted BOOLEAN DEFAULT FALSE
);

-- =====================================
-- GEOGRAPHY
-- =====================================

CREATE TABLE Countries (
    countryId SERIAL PRIMARY KEY,
    countryName VARCHAR(30) NOT NULL,
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP,
    createdBy INT REFERENCES Persons(personId),
    updatedBy INT REFERENCES Persons(personId)
);

CREATE TABLE States (
    stateId SERIAL PRIMARY KEY,
    stateName VARCHAR(30) NOT NULL,
    countryId INT NOT NULL REFERENCES Countries(countryId),
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Cities (
    cityId SERIAL PRIMARY KEY,
    cityName VARCHAR(40) NOT NULL,
    stateId INT NOT NULL REFERENCES States(stateId),
    enabled BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE AddressTypes (
    addressTypeId SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(50) NOT NULL,
    description VARCHAR(255)
);

CREATE TABLE Addresses (
    addressId SERIAL PRIMARY KEY,
    addressLine1 VARCHAR(100) NOT NULL,
    addressLine2 VARCHAR(100),
    cityId INT NOT NULL REFERENCES Cities(cityId),
    zipCode VARCHAR(10),
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    notes TEXT,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP,
    deleted BOOLEAN DEFAULT FALSE
);

-- =====================================
-- CURRENCIES
-- =====================================

CREATE TABLE Currencies (
    currencyId SERIAL PRIMARY KEY,
    code VARCHAR(3) UNIQUE NOT NULL,
    symbol VARCHAR(5) NOT NULL,
    name VARCHAR(50) NOT NULL,
    baseCurrency BOOLEAN DEFAULT FALSE,
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    countryId INT REFERENCES Countries(countryId),
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ExchangeRates (
    exchangeRateId SERIAL PRIMARY KEY,
    fromCurrencyId INT NOT NULL REFERENCES Currencies(currencyId),
    toCurrencyId INT NOT NULL REFERENCES Currencies(currencyId),
    rate DECIMAL(18,6) NOT NULL,
    effectiveDate DATE NOT NULL,
    expiryDate DATE,
    source VARCHAR(50),
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    createdBy INT REFERENCES Persons(personId),
    UNIQUE(fromCurrencyId, toCurrencyId, effectiveDate)
);

CREATE TABLE ExchangeRateHistory (
    historyId SERIAL PRIMARY KEY,
    exchangeRateId INT NOT NULL REFERENCES ExchangeRates(exchangeRateId),
    oldRate DECIMAL(18,6),
    newRate DECIMAL(18,6) NOT NULL,
    changedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    changedBy INT REFERENCES Persons(personId),
    reason VARCHAR(255)
);

-- =====================================
-- CONTACTS
-- =====================================

CREATE TABLE PersonContactTypes (
    contactTypeId SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE PersonContacts (
    contactId SERIAL PRIMARY KEY,
    personId INT NOT NULL REFERENCES Persons(personId),
    contactTypeId INT NOT NULL REFERENCES PersonContactTypes(contactTypeId),
    value VARCHAR(255) NOT NULL,
    isPrimary BOOLEAN DEFAULT FALSE,
    verified BOOLEAN DEFAULT FALSE,
    verifiedAt TIMESTAMP,
    validFrom DATE NOT NULL DEFAULT CURRENT_DATE,
    validUntil DATE,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =====================================
-- PRODUCTS
-- =====================================

CREATE TABLE ProductTypes (
    productTypeId SERIAL PRIMARY KEY,
    productTypeName VARCHAR(30) NOT NULL,
    enabled BOOLEAN DEFAULT TRUE
);

CREATE TABLE Products (
    productId SERIAL PRIMARY KEY,
    externalProductId VARCHAR(50) UNIQUE,
    productName VARCHAR(100) NOT NULL,
    productTypeId INT NOT NULL REFERENCES ProductTypes(productTypeId),
    description TEXT,
    enabled BOOLEAN DEFAULT TRUE,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP,
    createdBy INT REFERENCES Persons(personId),
    updatedBy INT REFERENCES Persons(personId),
    deleted BOOLEAN DEFAULT FALSE
);

-- =====================================
-- SUPPLIERS
-- =====================================

CREATE TABLE Suppliers (
    supplierId SERIAL PRIMARY KEY,
    supplierName VARCHAR(100) NOT NULL,
    personContactId INT REFERENCES PersonContacts(contactId),
    addressId INT NOT NULL REFERENCES Addresses(addressId),
    countryId INT NOT NULL REFERENCES Countries(countryId),
    enabled BOOLEAN DEFAULT TRUE,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP,
    createdBy INT REFERENCES Persons(personId),
    updatedBy INT REFERENCES Persons(personId),
    deleted BOOLEAN DEFAULT FALSE
);

-- =====================================
-- INVENTORY TRANSACTIONS
-- =====================================

CREATE TABLE InventoryTransactionTypes (
    transactionTypeId SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(50) NOT NULL,
    affectSign SMALLINT NOT NULL CHECK (affectSign IN (-1,1)),
    description VARCHAR(255)
);

-- =====================================
-- IMPORTS
-- =====================================

CREATE TABLE ImportOrderStatusCatalog (
    statusId SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(50) NOT NULL,
    isFinal BOOLEAN DEFAULT FALSE
);

CREATE TABLE ImportOrders (
    importOrderId SERIAL PRIMARY KEY,
    importOrderNumber VARCHAR(50) UNIQUE NOT NULL,
    supplierId INT NOT NULL REFERENCES Suppliers(supplierId),
    orderDate TIMESTAMP NOT NULL,
    expectedArrivalDate DATE,
    actualArrivalDate TIMESTAMP,
    totalCost DECIMAL(14,2) NOT NULL,
    currencyId INT NOT NULL REFERENCES Currencies(currencyId),
    exchangeRateId INT REFERENCES ExchangeRates(exchangeRateId),
    statusId INT NOT NULL REFERENCES ImportOrderStatusCatalog(statusId),
    paymentStatus VARCHAR(20),
    createdBy INT NOT NULL REFERENCES Persons(personId),
    updatedBy INT REFERENCES Persons(personId),
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP,
    deleted BOOLEAN DEFAULT FALSE
);

CREATE TABLE ImportOrderDetails (
    importOrderDetailId SERIAL PRIMARY KEY,
    importOrderId INT NOT NULL REFERENCES ImportOrders(importOrderId),
    productId INT NOT NULL REFERENCES Products(productId),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unitCost DECIMAL(14,4) NOT NULL,
    currencyId INT NOT NULL REFERENCES Currencies(currencyId),
    exchangeRateId INT REFERENCES ExchangeRates(exchangeRateId),
    lineTotal DECIMAL(14,2) NOT NULL,
    status VARCHAR(20)
);

-- =====================================
-- BATCHES
-- =====================================

CREATE TABLE Batches (
    batchId SERIAL PRIMARY KEY,
    batchNumber VARCHAR(50) UNIQUE NOT NULL,
    importOrderId INT NOT NULL REFERENCES ImportOrders(importOrderId),
    productId INT NOT NULL REFERENCES Products(productId),
    quantityReceived DECIMAL(14,4) NOT NULL,
    quantityExpected DECIMAL(14,4),
    unitCost DECIMAL(14,4) NOT NULL,
    currencyId INT NOT NULL REFERENCES Currencies(currencyId),
    exchangeRateId INT REFERENCES ExchangeRates(exchangeRateId),
    expirationDate DATE,
    receivedAt TIMESTAMP NOT NULL,
    receivedBy INT NOT NULL REFERENCES Persons(personId),
    notes TEXT,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =====================================
-- WAREHOUSES
-- =====================================

CREATE TABLE WarehouseTypes (
    warehouseTypeId SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE Warehouses (
    warehouseId SERIAL PRIMARY KEY,
    warehouseName VARCHAR(100) NOT NULL,
    warehouseTypeId INT REFERENCES WarehouseTypes(warehouseTypeId),
    addressId INT NOT NULL REFERENCES Addresses(addressId),
    manager INT REFERENCES Persons(personId),
    capacity DECIMAL(14,2),
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    createdBy INT REFERENCES Persons(personId),
    enabled BOOLEAN DEFAULT TRUE,
    deleted BOOLEAN DEFAULT FALSE
);

-- =====================================
-- DISPATCH
-- =====================================

CREATE TABLE DispatchOrderStatusCatalog (
    statusId SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(50) NOT NULL,
    isFinal BOOLEAN DEFAULT FALSE
);

CREATE TABLE DispatchOrders (
    dispatchOrderId SERIAL PRIMARY KEY,
    dispatchOrderNumber VARCHAR(50) UNIQUE NOT NULL,
    destinationCountryId INT NOT NULL REFERENCES Countries(countryId),
    dispatchDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expectedDeliveryDate DATE,
    statusId INT NOT NULL REFERENCES DispatchOrderStatusCatalog(statusId),
    notes TEXT,
    createdBy INT NOT NULL REFERENCES Persons(personId),
    updatedBy INT REFERENCES Persons(personId),
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP,
    deleted BOOLEAN DEFAULT FALSE
);

CREATE TABLE DispatchOrderDetails (
    dispatchOrderDetailId SERIAL PRIMARY KEY,
    dispatchOrderId INT NOT NULL REFERENCES DispatchOrders(dispatchOrderId),
    batchId INT NOT NULL REFERENCES Batches(batchId),
    quantityDispatched DECIMAL(14,4) NOT NULL CHECK (quantityDispatched > 0),
    notes TEXT
);

-- =====================================
-- SHIPMENTS
-- =====================================

CREATE TABLE CourierServices (
    courierServiceId SERIAL PRIMARY KEY,
    courierName VARCHAR(100) NOT NULL,
    personContactId INT REFERENCES PersonContacts(contactId),
    addressId INT REFERENCES Addresses(addressId),
    enabled BOOLEAN DEFAULT TRUE,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP,
    createdBy INT REFERENCES Persons(personId),
    deleted BOOLEAN DEFAULT FALSE
);

CREATE TABLE ShipmentStatusCatalog (
    statusId SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(50) NOT NULL,
    isFinal BOOLEAN DEFAULT FALSE
);

CREATE TABLE Shipments (
    shipmentId SERIAL PRIMARY KEY,
    shipmentNumber VARCHAR(50) UNIQUE NOT NULL,
    dispatchOrderId INT NOT NULL REFERENCES DispatchOrders(dispatchOrderId),
    courierServiceId INT NOT NULL REFERENCES CourierServices(courierServiceId),
    trackingNumber VARCHAR(100),
    shipmentDate TIMESTAMP NOT NULL,
    estimatedDeliveryDate DATE,
    actualDeliveryDate TIMESTAMP,
    shippingCost DECIMAL(14,2),
    currencyId INT REFERENCES Currencies(currencyId),
    exchangeRateId INT REFERENCES ExchangeRates(exchangeRateId),
    statusId INT NOT NULL REFERENCES ShipmentStatusCatalog(statusId),
    notes TEXT,
    createdBy INT NOT NULL REFERENCES Persons(personId),
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP,
    deleted BOOLEAN DEFAULT FALSE
);

-- =====================================
-- LOGS
-- =====================================

CREATE TABLE AppLogs (
    logId BIGSERIAL PRIMARY KEY,
    personId INT REFERENCES Persons(personId),
    level VARCHAR(20) NOT NULL CHECK (level IN ('INFO','WARN','ERROR','SECURITY')),
    module VARCHAR(50) NOT NULL,
    action VARCHAR(100) NOT NULL,
    entity VARCHAR(50),
    entityId INT,
    message TEXT,
    traceId VARCHAR(50),
    spanId VARCHAR(50),
    payloadJson JSONB,
    ip INET,
    userAgent TEXT,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- INDEXES

CREATE INDEX idx_applogs_createdat ON AppLogs(createdAt DESC);
CREATE INDEX idx_applogs_level_createdat ON AppLogs(level, createdAt DESC);
CREATE INDEX idx_applogs_traceid ON AppLogs(traceId);