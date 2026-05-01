CREATE DATABASE DynamicBrandsDB;
USE DynamicBrandsDB;

-- ========================
-- USERS & SECURITY
-- ========================

CREATE TABLE Users (
    userId INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    lastName1 VARCHAR(50) NOT NULL,
    lastName2 VARCHAR(50),
    email VARCHAR(100) UNIQUE NOT NULL,
    passwordHash VARCHAR(255) NOT NULL,
    status VARCHAR(20) NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP NULL,
    deleted BOOLEAN DEFAULT FALSE
);

CREATE TABLE Roles (
    roleId INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE Permissions (
    permissionId INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE UserRoles (
    userId INT,
    roleId INT,
    assignedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    assignedBy INT,
    deleted BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (userId, roleId),
    FOREIGN KEY (userId) REFERENCES Users(userId),
    FOREIGN KEY (roleId) REFERENCES Roles(roleId),
    FOREIGN KEY (assignedBy) REFERENCES Users(userId)
);

CREATE TABLE RolePermissions (
    roleId INT,
    permissionId INT,
    grantedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    grantedBy INT,
    deleted BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (roleId, permissionId),
    FOREIGN KEY (roleId) REFERENCES Roles(roleId),
    FOREIGN KEY (permissionId) REFERENCES Permissions(permissionId),
    FOREIGN KEY (grantedBy) REFERENCES Users(userId)
);

-- ========================
-- LOCATION & CURRENCY
-- ========================

CREATE TABLE Countries (
    countryId INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    isoCode VARCHAR(10) UNIQUE
);

CREATE TABLE Currencies (
    currencyId INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(3) UNIQUE NOT NULL,
    symbol VARCHAR(5) NOT NULL,
    name VARCHAR(50) NOT NULL,
    baseCurrency BOOLEAN DEFAULT FALSE,
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    countryId INT NULL,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (countryId) REFERENCES Countries(countryId)
);

CREATE TABLE ExchangeRates (
    exchangeRateId INT AUTO_INCREMENT PRIMARY KEY,
    fromCurrencyId INT NOT NULL,
    toCurrencyId INT NOT NULL,
    rate DECIMAL(18,6) NOT NULL,
    effectiveDate DATE NOT NULL,
    expiryDate DATE NULL,
    source VARCHAR(50),
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    createdBy INT,
    UNIQUE (fromCurrencyId, toCurrencyId, effectiveDate),
    FOREIGN KEY (fromCurrencyId) REFERENCES Currencies(currencyId),
    FOREIGN KEY (toCurrencyId) REFERENCES Currencies(currencyId),
    FOREIGN KEY (createdBy) REFERENCES Users(userId)
);

CREATE TABLE ExchangeRateHistory (
    historyId INT AUTO_INCREMENT PRIMARY KEY,
    exchangeRateId INT NOT NULL,
    oldRate DECIMAL(18,6),
    newRate DECIMAL(18,6) NOT NULL,
    fromCurrencyId INT NOT NULL,
    toCurrencyId INT NOT NULL,
    changedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    changedBy INT,
    reason VARCHAR(255),
    FOREIGN KEY (exchangeRateId) REFERENCES ExchangeRates(exchangeRateId),
    FOREIGN KEY (fromCurrencyId) REFERENCES Currencies(currencyId),
    FOREIGN KEY (toCurrencyId) REFERENCES Currencies(currencyId),
    FOREIGN KEY (changedBy) REFERENCES Users(userId)
);

-- ========================
-- SITES
-- ========================

CREATE TABLE Sites (
    siteId INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    url VARCHAR(255) NOT NULL,
    countryId INT,
    currencyId INT,
    isActive BOOLEAN DEFAULT TRUE,
    validFrom DATE NOT NULL,
    validUntil DATE,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP NULL,
    createdBy INT,
    updatedBy INT,
    deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (countryId) REFERENCES Countries(countryId),
    FOREIGN KEY (currencyId) REFERENCES Currencies(currencyId),
    FOREIGN KEY (createdBy) REFERENCES Users(userId),
    FOREIGN KEY (updatedBy) REFERENCES Users(userId)
);

CREATE TABLE SiteHistory (
    historyId INT AUTO_INCREMENT PRIMARY KEY,
    siteId INT,
    previousStatus VARCHAR(20),
    newStatus VARCHAR(20),
    previousCurrencyId INT,
    newCurrencyId INT,
    changeReason VARCHAR(255),
    changedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changedBy INT,
    FOREIGN KEY (siteId) REFERENCES Sites(siteId),
    FOREIGN KEY (changedBy) REFERENCES Users(userId)
);

-- ========================
-- CONFIG
-- ========================

CREATE TABLE ConfigKeys (
    keyId INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    groupName VARCHAR(50)
);

CREATE TABLE SiteBrandingConfig (
    configId INT AUTO_INCREMENT PRIMARY KEY,
    siteId INT,
    keyId INT,
    value VARCHAR(255),
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP NULL,
    deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (siteId) REFERENCES Sites(siteId),
    FOREIGN KEY (keyId) REFERENCES ConfigKeys(keyId)
);

-- ========================
-- PRODUCTS
-- ========================

CREATE TABLE ProductCategories (
    categoryId INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE Brands (
    brandId INT AUTO_INCREMENT PRIMARY KEY,
    siteId INT,
    brandName VARCHAR(100),
    FOREIGN KEY (siteId) REFERENCES Sites(siteId)
);

CREATE TABLE Products (
    productId INT AUTO_INCREMENT PRIMARY KEY,
    externalProductId VARCHAR(50) UNIQUE NOT NULL,
    productName VARCHAR(150) NOT NULL,
    categoryId INT,
    brandId INT,
    baseCost DECIMAL(14,2) NOT NULL,
    baseCurrencyId INT,
    exchangeRateId INT,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP NULL,
    createdBy INT,
    updatedBy INT,
    deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (categoryId) REFERENCES ProductCategories(categoryId),
    FOREIGN KEY (brandId) REFERENCES Brands(brandId),
    FOREIGN KEY (baseCurrencyId) REFERENCES Currencies(currencyId),
    FOREIGN KEY (exchangeRateId) REFERENCES ExchangeRates(exchangeRateId),
    FOREIGN KEY (createdBy) REFERENCES Users(userId),
    FOREIGN KEY (updatedBy) REFERENCES Users(userId)
);

-- ========================
-- ATTRIBUTES (EAV)
-- ========================

CREATE TABLE AttributeKeyGroups (
    groupId INT AUTO_INCREMENT PRIMARY KEY,
    groupName VARCHAR(50) UNIQUE NOT NULL,
    description VARCHAR(255)
);

CREATE TABLE AttributeKeys (
    keyId INT AUTO_INCREMENT PRIMARY KEY,
    groupId INT,
    name VARCHAR(50) NOT NULL,
    dataType VARCHAR(20),
    unit VARCHAR(20),
    UNIQUE (groupId, name),
    FOREIGN KEY (groupId) REFERENCES AttributeKeyGroups(groupId)
);

CREATE TABLE ProductAttributes (
    attributeId INT AUTO_INCREMENT PRIMARY KEY,
    productId INT,
    keyId INT,
    value VARCHAR(500) NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP NULL,
    UNIQUE (productId, keyId),
    FOREIGN KEY (productId) REFERENCES Products(productId),
    FOREIGN KEY (keyId) REFERENCES AttributeKeys(keyId)
);

-- ========================
-- PRICING
-- ========================

CREATE TABLE ProductPrices (
    priceId INT AUTO_INCREMENT PRIMARY KEY,
    productId INT,
    siteId INT,
    priceLocal DECIMAL(14,2) NOT NULL,
    currencyId INT,
    exchangeRateId INT,
    validFrom DATE NOT NULL,
    validUntil DATE,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    createdBy INT,
    updatedBy INT,
    deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (productId) REFERENCES Products(productId),
    FOREIGN KEY (siteId) REFERENCES Sites(siteId),
    FOREIGN KEY (currencyId) REFERENCES Currencies(currencyId),
    FOREIGN KEY (exchangeRateId) REFERENCES ExchangeRates(exchangeRateId),
    FOREIGN KEY (createdBy) REFERENCES Users(userId),
    FOREIGN KEY (updatedBy) REFERENCES Users(userId)
);

-- ========================
-- CUSTOMERS
-- ========================

CREATE TABLE Customers (
    customerId INT AUTO_INCREMENT PRIMARY KEY,
    siteId INT,
    userId INT,
    firstName VARCHAR(100),
    lastName VARCHAR(100),
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP NULL,
    deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (siteId) REFERENCES Sites(siteId),
    FOREIGN KEY (userId) REFERENCES Users(userId)
);

CREATE TABLE ContactTypes (
    contactTypeId INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(50)
);

CREATE TABLE CustomerContacts (
    contactId INT AUTO_INCREMENT PRIMARY KEY,
    customerId INT,
    contactTypeId INT,
    value VARCHAR(255),
    isPrimary BOOLEAN DEFAULT FALSE,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customerId) REFERENCES Customers(customerId),
    FOREIGN KEY (contactTypeId) REFERENCES ContactTypes(contactTypeId)
);

-- ========================
-- ORDERS
-- ========================

CREATE TABLE OrderStatusCatalog (
    statusId INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) UNIQUE,
    description VARCHAR(100)
);

CREATE TABLE Orders (
    orderId INT AUTO_INCREMENT PRIMARY KEY,
    orderNumber VARCHAR(50) UNIQUE NOT NULL,
    siteId INT,
    customerId INT,
    currencyId INT,
    exchangeRateId INT,
    statusId INT,
    totalLocal DECIMAL(14,2),
    totalInBase DECIMAL(14,2),
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP NULL,
    createdBy INT,
    updatedBy INT,
    deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (siteId) REFERENCES Sites(siteId),
    FOREIGN KEY (customerId) REFERENCES Customers(customerId),
    FOREIGN KEY (currencyId) REFERENCES Currencies(currencyId),
    FOREIGN KEY (exchangeRateId) REFERENCES ExchangeRates(exchangeRateId),
    FOREIGN KEY (statusId) REFERENCES OrderStatusCatalog(statusId),
    FOREIGN KEY (createdBy) REFERENCES Users(userId),
    FOREIGN KEY (updatedBy) REFERENCES Users(userId)
);

CREATE TABLE OrderItems (
    orderItemId INT AUTO_INCREMENT PRIMARY KEY,
    orderId INT,
    productId INT,
    quantity INT,
    productName VARCHAR(150),
    unitPriceLocal DECIMAL(14,2),
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (orderId) REFERENCES Orders(orderId),
    FOREIGN KEY (productId) REFERENCES Products(productId)
);

-- ========================
-- PAYMENTS
-- ========================

CREATE TABLE PaymentMethods (
    methodId INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) UNIQUE,
    description VARCHAR(100)
);

CREATE TABLE PaymentStatusCatalog (
    statusId INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) UNIQUE,
    description VARCHAR(100)
);

CREATE TABLE Payments (
    paymentId INT AUTO_INCREMENT PRIMARY KEY,
    orderId INT,
    methodId INT,
    amount DECIMAL(14,2),
    currencyId INT,
    exchangeRateId INT,
    statusId INT,
    processedAt TIMESTAMP,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (orderId) REFERENCES Orders(orderId),
    FOREIGN KEY (methodId) REFERENCES PaymentMethods(methodId),
    FOREIGN KEY (currencyId) REFERENCES Currencies(currencyId),
    FOREIGN KEY (exchangeRateId) REFERENCES ExchangeRates(exchangeRateId),
    FOREIGN KEY (statusId) REFERENCES PaymentStatusCatalog(statusId)
);

-- ========================
-- INVENTORY
-- ========================

CREATE TABLE InventoryTransactionTypes (
    transactionTypeId INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) UNIQUE,
    affectSign TINYINT
);

CREATE TABLE InventoryTransactionHeader (
    transactionId BIGINT AUTO_INCREMENT PRIMARY KEY,
    transactionTypeId INT,
    referenceId INT,
    batchId INT,
    transactionDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    createdBy INT,
    FOREIGN KEY (transactionTypeId) REFERENCES InventoryTransactionTypes(transactionTypeId),
    FOREIGN KEY (createdBy) REFERENCES Users(userId)
);

CREATE TABLE InventoryTransactionDetail (
    detailId BIGINT AUTO_INCREMENT PRIMARY KEY,
    transactionId BIGINT,
    productId INT,
    quantity DECIMAL(14,4),
    FOREIGN KEY (transactionId) REFERENCES InventoryTransactionHeader(transactionId),
    FOREIGN KEY (productId) REFERENCES Products(productId)
);

-- ========================
-- SHIPPING
-- ========================

CREATE TABLE Couriers (
    courierId INT AUTO_INCREMENT PRIMARY KEY,
    courierName VARCHAR(100),
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ShipmentStatusCatalog (
    statusId INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) UNIQUE,
    description VARCHAR(100)
);

CREATE TABLE Shipments (
    shipmentId INT AUTO_INCREMENT PRIMARY KEY,
    orderId INT,
    courierId INT,
    trackingNumber VARCHAR(100),
    statusId INT,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (orderId) REFERENCES Orders(orderId),
    FOREIGN KEY (courierId) REFERENCES Couriers(courierId),
    FOREIGN KEY (statusId) REFERENCES ShipmentStatusCatalog(statusId)
);

-- ========================
-- RESTRICTIONS
-- ========================

CREATE TABLE RestrictionReasonsCatalog (
    reasonId INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) UNIQUE,
    description VARCHAR(100)
);

CREATE TABLE ProductRestrictions (
    restrictionId INT AUTO_INCREMENT PRIMARY KEY,
    productId INT,
    countryId INT,
    reasonId INT,
    FOREIGN KEY (productId) REFERENCES Products(productId),
    FOREIGN KEY (countryId) REFERENCES Countries(countryId),
    FOREIGN KEY (reasonId) REFERENCES RestrictionReasonsCatalog(reasonId)
);

-- ========================
-- LOGGING
-- ========================

CREATE TABLE LogLevels (
    levelId INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) UNIQUE,
    priority INT
);

CREATE TABLE AppLogs (
    logId BIGINT AUTO_INCREMENT PRIMARY KEY,
    userId INT,
    levelId INT,
    module VARCHAR(50),
    action VARCHAR(100),
    entity VARCHAR(50),
    entityId INT,
    message TEXT,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (userId) REFERENCES Users(userId),
    FOREIGN KEY (levelId) REFERENCES LogLevels(levelId)
);