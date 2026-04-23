CREATE DATABASE IF NOT EXISTS DynamicBrandsDB;
USE DynamicBrandsDB;

-- ======================
-- USERS & SECURITY
-- ======================

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
    PRIMARY KEY (userId, roleId),
    FOREIGN KEY (userId) REFERENCES Users(userId),
    FOREIGN KEY (roleId) REFERENCES Roles(roleId)
);

-- ======================
-- LOCATION & MONEY
-- ======================

CREATE TABLE Countries (
    countryId INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    isoCode VARCHAR(10) UNIQUE
);

CREATE TABLE Currencies (
    currencyId INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(10),
    symbol VARCHAR(10)
);

-- ======================
-- SITES
-- ======================

CREATE TABLE Sites (
    siteId INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    url VARCHAR(255),
    countryId INT,
    currencyId INT,
    isActive BOOLEAN DEFAULT TRUE,
    validFrom DATE,
    validUntil DATE,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (countryId) REFERENCES Countries(countryId),
    FOREIGN KEY (currencyId) REFERENCES Currencies(currencyId)
);

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

CREATE TABLE SiteStatusCatalog (
    statusId INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) UNIQUE,
    description VARCHAR(100)
);

CREATE TABLE SiteStatusHistory (
    historyId INT AUTO_INCREMENT PRIMARY KEY,
    siteId INT,
    statusId INT,
    changedAt TIMESTAMP,
    reasonCode VARCHAR(50),
    FOREIGN KEY (siteId) REFERENCES Sites(siteId),
    FOREIGN KEY (statusId) REFERENCES SiteStatusCatalog(statusId)
);

-- ======================
-- PRODUCTS
-- ======================

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
    externalProductId VARCHAR(50) UNIQUE,
    productName VARCHAR(150),
    categoryId INT,
    baseCostUSD DECIMAL(14,2),
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (categoryId) REFERENCES ProductCategories(categoryId)
);

CREATE TABLE AttributeKeys (
    keyId INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    groupName VARCHAR(50)
);

CREATE TABLE ProductAttributes (
    attributeId INT AUTO_INCREMENT PRIMARY KEY,
    productId INT,
    keyId INT,
    value VARCHAR(255),
    FOREIGN KEY (productId) REFERENCES Products(productId),
    FOREIGN KEY (keyId) REFERENCES AttributeKeys(keyId)
);

CREATE TABLE ProductPrices (
    priceId INT AUTO_INCREMENT PRIMARY KEY,
    productId INT,
    siteId INT,
    priceLocal DECIMAL(14,2),
    currencyId INT,
    validFrom DATE,
    validUntil DATE,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (productId) REFERENCES Products(productId),
    FOREIGN KEY (siteId) REFERENCES Sites(siteId),
    FOREIGN KEY (currencyId) REFERENCES Currencies(currencyId)
);

-- ======================
-- CUSTOMERS & ORDERS
-- ======================

CREATE TABLE Customers (
    customerId INT AUTO_INCREMENT PRIMARY KEY,
    siteId INT,
    userId INT,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (siteId) REFERENCES Sites(siteId),
    FOREIGN KEY (userId) REFERENCES Users(userId)
);

CREATE TABLE OrderStatusCatalog (
    statusId INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) UNIQUE,
    description VARCHAR(100)
);

CREATE TABLE Orders (
    orderId INT AUTO_INCREMENT PRIMARY KEY,
    orderNumber VARCHAR(50) UNIQUE,
    siteId INT,
    customerId INT,
    currencyId INT,
    statusId INT,
    subtotalLocal DECIMAL(14,2),
    taxesLocal DECIMAL(14,2),
    totalLocal DECIMAL(14,2),
    subtotalUSD DECIMAL(14,2),
    taxesUSD DECIMAL(14,2),
    totalUSD DECIMAL(14,2),
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP NULL,
    deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (siteId) REFERENCES Sites(siteId),
    FOREIGN KEY (customerId) REFERENCES Customers(customerId),
    FOREIGN KEY (currencyId) REFERENCES Currencies(currencyId),
    FOREIGN KEY (statusId) REFERENCES OrderStatusCatalog(statusId)
);

CREATE TABLE OrderItems (
    orderItemId INT AUTO_INCREMENT PRIMARY KEY,
    orderId INT,
    productId INT,
    currencyId INT,
    quantity INT,
    productName VARCHAR(150),
    unitPrice DECIMAL(14,2),
    FOREIGN KEY (orderId) REFERENCES Orders(orderId),
    FOREIGN KEY (productId) REFERENCES Products(productId),
    FOREIGN KEY (currencyId) REFERENCES Currencies(currencyId)
);

-- ======================
-- PAYMENTS
-- ======================

CREATE TABLE PaymentStatusCatalog (
    statusId INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) UNIQUE,
    description VARCHAR(100)
);

CREATE TABLE Payments (
    paymentId INT AUTO_INCREMENT PRIMARY KEY,
    orderId INT,
    method VARCHAR(50),
    amount DECIMAL(14,2),
    currencyId INT,
    statusId INT,
    processedAt TIMESTAMP,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (orderId) REFERENCES Orders(orderId),
    FOREIGN KEY (currencyId) REFERENCES Currencies(currencyId),
    FOREIGN KEY (statusId) REFERENCES PaymentStatusCatalog(statusId)
);

-- ======================
-- LOGISTICS
-- ======================

CREATE TABLE OrderItemBatches (
    id INT AUTO_INCREMENT PRIMARY KEY,
    orderItemId INT,
    externalBatchId VARCHAR(50),
    assignedAt TIMESTAMP,
    FOREIGN KEY (orderItemId) REFERENCES OrderItems(orderItemId)
);

CREATE TABLE ShipmentStatusCatalog (
    statusId INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) UNIQUE,
    description VARCHAR(100)
);

CREATE TABLE Shipments (
    shipmentId INT AUTO_INCREMENT PRIMARY KEY,
    orderId INT,
    trackingNumber VARCHAR(100),
    carrier VARCHAR(100),
    statusId INT,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (orderId) REFERENCES Orders(orderId),
    FOREIGN KEY (statusId) REFERENCES ShipmentStatusCatalog(statusId)
);

-- ======================
-- RESTRICTIONS
-- ======================

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