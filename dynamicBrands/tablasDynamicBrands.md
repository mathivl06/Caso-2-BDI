# Database Design - Dynamic Brands

* Database engine: MySQL 8

* Database name: DynamicBrandsDB

* Context: Plataforma de e-commerce dinámico impulsada por IA que despliega múltiples sitios personalizados por país, marca y estrategia, reutilizando un catálogo base de productos y operando sobre datos de costos y logística provenientes de Etheria Global.

---

# TABLES:

## Users

* userId: INT AUTO_INCREMENT (PK)
* name: VARCHAR(50) NOT NULL
* lastName1: VARCHAR(50) NOT NULL
* lastName2: VARCHAR(50)
* email: VARCHAR(100) UNIQUE NOT NULL
* passwordHash: VARCHAR(255) NOT NULL
* status: VARCHAR(20) NOT NULL
* createdAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP
* updatedAt: TIMESTAMP
* deleted: BOOLEAN DEFAULT FALSE

---

## Roles

* roleId: INT AUTO_INCREMENT (PK)
* name: VARCHAR(50) UNIQUE NOT NULL

---

## Permissions

* permissionId: INT AUTO_INCREMENT (PK)
* code: VARCHAR(50) UNIQUE NOT NULL

---

## UserRoles

* userId: INT (FK → Users.userId)
* roleId: INT (FK → Roles.roleId)
* assignedAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP
* assignedBy: INT (FK → Users.userId)
* deleted: BOOLEAN DEFAULT FALSE
* PRIMARY KEY (userId, roleId)

---

## RolePermissions

* roleId: INT (FK → Roles.roleId)
* permissionId: INT (FK → Permissions.permissionId)
* grantedAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP
* grantedBy: INT (FK → Users.userId)
* deleted: BOOLEAN DEFAULT FALSE
* PRIMARY KEY (roleId, permissionId)

---

## Countries

* countryId: INT AUTO_INCREMENT (PK)
* name: VARCHAR(100)
* isoCode: VARCHAR(10) UNIQUE

---

## Currencies
* currencyId: INT AUTO_INCREMENT (PK)
* code: VARCHAR(3) UNIQUE NOT NULL (USD/COP/PEN/etc)
* symbol: VARCHAR(5) NOT NULL
* name: VARCHAR(50) NOT NULL
* baseCurrency: BOOLEAN DEFAULT FALSE (TRUE only for USD)
* enabled: BOOLEAN NOT NULL DEFAULT TRUE
* countryId: INT (FK → Countries.countryId, nullable)
* createdAt: TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP

---

## ExchangeRates 
* exchangeRateId: INT AUTO_INCREMENT (PK)
* fromCurrencyId: INT NOT NULL (FK → Currencies.currencyId)
* toCurrencyId: INT NOT NULL (FK → Currencies.currencyId)
* rate: DECIMAL(18,6) NOT NULL (e.g., 1 USD = 3450 COP)
* effectiveDate: DATE NOT NULL
* expiryDate: DATE (NULL = still active)
* source: VARCHAR(50) (BANCO_CENTRAL/OANDA/MANUAL)
* createdAt: TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
* createdBy: INT (FK → Users.userId)
* UNIQUE(fromCurrencyId, toCurrencyId, effectiveDate)

---

## ExchangeRateHistory 
* historyId: INT AUTO_INCREMENT (PK)
* exchangeRateId: INT NOT NULL (FK → ExchangeRates.exchangeRateId)
* oldRate: DECIMAL(18,6)
* newRate: DECIMAL(18,6) NOT NULL
* fromCurrencyId: INT NOT NULL (FK → Currencies.currencyId)
* toCurrencyId: INT NOT NULL (FK → Currencies.currencyId)
* changedAt: TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
* changedBy: INT (FK → Users.userId)
* reason: VARCHAR(255)

---

## Sites

* siteId: INT AUTO_INCREMENT (PK)
* name: VARCHAR(100) NOT NULL
* url: VARCHAR(255) NOT NULL
* countryId: INT (FK → Countries.countryId)
* currencyId: INT (FK → Currencies.currencyId)
* isActive: BOOLEAN DEFAULT TRUE
* validFrom: DATE NOT NULL
* validUntil: DATE
* createdAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP
* updatedAt: TIMESTAMP
* createdBy: INT (FK → Users.userId)
* updatedBy: INT (FK → Users.userId)
* deleted: BOOLEAN DEFAULT FALSE

---

## SiteHistory

* historyId: INT AUTO_INCREMENT (PK)
* siteId: INT (FK → Sites.siteId)
* previousStatus: VARCHAR(20)
* newStatus: VARCHAR(20)
* previousCurrencyId: INT
* newCurrencyId: INT
* changeReason: VARCHAR(255)
* changedAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP
* changedBy: INT (FK → Users.userId)

---

## ConfigKeys

* keyId: INT AUTO_INCREMENT (PK)
* name: VARCHAR(50)
* groupName: VARCHAR(50)

---

## SiteBrandingConfig

* configId: INT AUTO_INCREMENT (PK)
* siteId: INT (FK → Sites.siteId)
* keyId: INT (FK → ConfigKeys.keyId)
* value: VARCHAR(255)
* createdAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP
* updatedAt: TIMESTAMP
* deleted: BOOLEAN DEFAULT FALSE

---

## ProductCategories

* categoryId: INT AUTO_INCREMENT (PK)
* name: VARCHAR(100)

---

## Brands

* brandId: INT AUTO_INCREMENT (PK)
* siteId: INT (FK → Sites.siteId)
* brandName: VARCHAR(100)

---

## Products

* productId: INT AUTO_INCREMENT (PK)
* externalProductId: VARCHAR(50) UNIQUE NOT NULL
* productName: VARCHAR(150) NOT NULL
* categoryId: INT (FK → ProductCategories.categoryId)
* brandId: INT (FK → Brands.brandId)
* baseCost: DECIMAL(14,2) NOT NULL
* baseCurrencyId: INT (FK → Currencies.currencyId)
* exchangeRateId: INT (FK → ExchangeRates.exchangeRateId)
* createdAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP
* updatedAt: TIMESTAMP
* createdBy: INT (FK → Users.userId)
* updatedBy: INT (FK → Users.userId)
* deleted: BOOLEAN DEFAULT FALSE

---

## AttributeKeyGroups

* groupId: INT AUTO_INCREMENT (PK)
* groupName: VARCHAR(50) UNIQUE NOT NULL
* description: VARCHAR(255)

---

## AttributeKeys

* keyId: INT AUTO_INCREMENT (PK)
* groupId: INT (FK → AttributeKeyGroups.groupId)
* name: VARCHAR(50) NOT NULL
* dataType: VARCHAR(20)
* unit: VARCHAR(20)
* UNIQUE(groupId, name)

---

## ProductAttributes

* attributeId: INT AUTO_INCREMENT (PK)
* productId: INT (FK → Products.productId)
* keyId: INT (FK → AttributeKeys.keyId)
* value: VARCHAR(500) NOT NULL
* createdAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP
* updatedAt: TIMESTAMP
* UNIQUE(productId, keyId)

---

## ProductPrices

* priceId: INT AUTO_INCREMENT (PK)
* productId: INT (FK → Products.productId)
* siteId: INT (FK → Sites.siteId)
* priceLocal: DECIMAL(14,2) NOT NULL
* currencyId: INT (FK → Currencies.currencyId)
* exchangeRateId: INT (FK → ExchangeRates.exchangeRateId)
* validFrom: DATE NOT NULL
* validUntil: DATE
* createdAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP
* createdBy: INT (FK → Users.userId)
* updatedBy: INT (FK → Users.userId)
* deleted: BOOLEAN DEFAULT FALSE

---

## Customers

* customerId: INT AUTO_INCREMENT (PK)
* siteId: INT (FK → Sites.siteId)
* userId: INT (FK → Users.userId)
* firstName: VARCHAR(100)
* lastName: VARCHAR(100)
* createdAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP
* updatedAt: TIMESTAMP
* deleted: BOOLEAN DEFAULT FALSE

---

## ContactTypes

* contactTypeId: INT AUTO_INCREMENT (PK)
* code: VARCHAR(20) UNIQUE NOT NULL
* name: VARCHAR(50)

---

## CustomerContacts

* contactId: INT AUTO_INCREMENT (PK)
* customerId: INT (FK → Customers.customerId)
* contactTypeId: INT (FK → ContactTypes.contactTypeId)
* value: VARCHAR(255)
* isPrimary: BOOLEAN DEFAULT FALSE
* createdAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP

---

## OrderStatusCatalog

* statusId: INT AUTO_INCREMENT (PK)
* code: VARCHAR(20) UNIQUE
* description: VARCHAR(100)

---

## Orders

* orderId: INT AUTO_INCREMENT (PK)
* orderNumber: VARCHAR(50) UNIQUE NOT NULL
* siteId: INT (FK → Sites.siteId)
* customerId: INT (FK → Customers.customerId)
* currencyId: INT (FK → Currencies.currencyId)
* exchangeRateId: INT (FK → ExchangeRates.exchangeRateId)
* statusId: INT (FK → OrderStatusCatalog.statusId)
* totalLocal: DECIMAL(14,2)
* totalInBase: DECIMAL(14,2)
* createdAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP
* updatedAt: TIMESTAMP
* createdBy: INT (FK → Users.userId)
* updatedBy: INT (FK → Users.userId)
* deleted: BOOLEAN DEFAULT FALSE

---

## OrderItems

* orderItemId: INT AUTO_INCREMENT (PK)
* orderId: INT (FK → Orders.orderId)
* productId: INT (FK → Products.productId)
* quantity: INT
* productName: VARCHAR(150)
* unitPriceLocal: DECIMAL(14,2)
* createdAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP

---

## PaymentMethods (CATALOG)

* methodId: INT AUTO_INCREMENT (PK)
* code: VARCHAR(20) UNIQUE
* description: VARCHAR(100)

---

## PaymentStatusCatalog

* statusId: INT AUTO_INCREMENT (PK)
* code: VARCHAR(20) UNIQUE
* description: VARCHAR(100)

---

## Payments

* paymentId: INT AUTO_INCREMENT (PK)
* orderId: INT (FK → Orders.orderId)
* methodId: INT (FK → PaymentMethods.methodId)
* amount: DECIMAL(14,2)
* currencyId: INT (FK → Currencies.currencyId)
* exchangeRateId: INT (FK → ExchangeRates.exchangeRateId)
* statusId: INT (FK → PaymentStatusCatalog.statusId)
* processedAt: TIMESTAMP
* createdAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP

---

## InventoryTransactionTypes

* transactionTypeId: INT AUTO_INCREMENT (PK)
* code: VARCHAR(20) UNIQUE
* affectSign: TINYINT

---

## InventoryTransactionHeader

* transactionId: BIGINT AUTO_INCREMENT (PK)
* transactionTypeId: INT (FK → InventoryTransactionTypes.transactionTypeId)
* referenceId: INT
* batchId: INT
* transactionDate: TIMESTAMP DEFAULT CURRENT_TIMESTAMP
* createdBy: INT (FK → Users.userId)

---

## InventoryTransactionDetail

* detailId: BIGINT AUTO_INCREMENT (PK)
* transactionId: BIGINT (FK → InventoryTransactionHeader.transactionId)
* productId: INT (FK → Products.productId)
* quantity: DECIMAL(14,4)

---

## Couriers

* courierId: INT AUTO_INCREMENT (PK)
* courierName: VARCHAR(100)
* createdAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP

---

## ShipmentStatusCatalog

* statusId: INT AUTO_INCREMENT (PK)
* code: VARCHAR(20) UNIQUE
* description: VARCHAR(100)

---

## Shipments

* shipmentId: INT AUTO_INCREMENT (PK)
* orderId: INT (FK → Orders.orderId)
* courierId: INT (FK → Couriers.courierId)
* trackingNumber: VARCHAR(100)
* statusId: INT (FK → ShipmentStatusCatalog.statusId)
* createdAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP

---

## RestrictionReasonsCatalog

* reasonId: INT AUTO_INCREMENT (PK)
* code: VARCHAR(50) UNIQUE
* description: VARCHAR(100)

---

## ProductRestrictions

* restrictionId: INT AUTO_INCREMENT (PK)
* productId: INT (FK → Products.productId)
* countryId: INT (FK → Countries.countryId)
* reasonId: INT (FK → RestrictionReasonsCatalog.reasonId)

---

## LogLevels

* levelId: INT AUTO_INCREMENT (PK)
* code: VARCHAR(20) UNIQUE
* priority: INT

---

## AppLogs

* logId: BIGINT AUTO_INCREMENT (PK)
* userId: INT (FK → Users.userId)
* levelId: INT (FK → LogLevels.levelId)
* module: VARCHAR(50)
* action: VARCHAR(100)
* entity: VARCHAR(50)
* entityId: INT
* message: TEXT
* createdAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP

---

