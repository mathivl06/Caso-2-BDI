# Database Design - Dynamic Brands 

- Database engine: MySQL 8
- Database name: DynamicBrandsDB

---

## Users
- userId: INT AUTO_INCREMENT (PK)
- name: VARCHAR(20) NOT NULL
- lastName1: VARCHAR(20) NOT NULL
- lastName2: VARCHAR(20)
- email: VARCHAR(100) UNIQUE NOT NULL
- passwordHash: VARCHAR(255) NOT NULL
- status: VARCHAR(20) NOT NULL
- createdAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP

---

## Roles
- roleId: INT AUTO_INCREMENT (PK)
- name: VARCHAR(50) UNIQUE NOT NULL

---

## Permissions
- permissionId: INT AUTO_INCREMENT (PK)
- code: VARCHAR(50) UNIQUE NOT NULL

---

## UserRoles
- userId: INT (FK → Users.userId)
- roleId: INT (FK → Roles.roleId)
- PRIMARY KEY (userId, roleId)

---

## Countries
- countryId: INT AUTO_INCREMENT (PK)
- name: VARCHAR(100)
- isoCode: VARCHAR(10) UNIQUE

---

## Currencies
- currencyId: INT AUTO_INCREMENT (PK)
- code: VARCHAR(10)
- symbol: VARCHAR(10)

---

## ExchangeRates 
- rateId: INT AUTO_INCREMENT (PK)
- currencyId: INT (FK → Currencies.currencyId)
- rateToUSD: DECIMAL(18,6)
- effectiveDate: DATE
- validUntil: DATE NULL

---

## ExchangeRateSources
- sourceId: INT AUTO_INCREMENT (PK)
- name: VARCHAR(100)
- description: TEXT

---

## Sites
- siteId: INT AUTO_INCREMENT (PK)
- name: VARCHAR(100)
- countryId: INT (FK → Countries.countryId)
- currencyId: INT (FK → Currencies.currencyId)
- isActive: BOOLEAN DEFAULT TRUE
- validFrom: DATE
- validUntil: DATE

---

## SiteBrandingConfig
- configId: INT AUTO_INCREMENT (PK)
- siteId: INT (FK → Sites.siteId)
- key: VARCHAR(50)
- value: VARCHAR(255)

---

## SiteStatusHistory
- statusId: INT AUTO_INCREMENT (PK)
- siteId: INT (FK → Sites.siteId)
- statusId: INT (FK → SiteStatusCatalog.statusId)
- changedAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP
- reason: TEXT

---

## SiteStatusCatalog
- statusId: INT AUTO_INCREMENT (PK)
- code: VARCHAR(20) UNIQUE
- description: VARCHAR(100)

---

## Brands
- brandId: INT AUTO_INCREMENT (PK)
- siteId: INT (FK → Sites.siteId)
- brandName: VARCHAR(100)

---

## Products
- productId: INT AUTO_INCREMENT (PK)
- externalProductId: VARCHAR(50)
- productName: VARCHAR(150)
- category: VARCHAR(100)
- baseCostUSD: DECIMAL(14,2)

---

## ProductAttributes
- attributeId: INT AUTO_INCREMENT (PK)
- productId: INT (FK → Products.productId)
- key: VARCHAR(50)
- value: VARCHAR(255)

---

## ProductPrices 
- priceId: INT AUTO_INCREMENT (PK)
- productId: INT (FK → Products.productId)
- siteId: INT (FK → Sites.siteId)
- priceLocal: DECIMAL(14,2)
- currencyId: INT (FK → Currencies.currencyId)
- validFrom: DATE
- validUntil: DATE

---

## GlobalCustomers
- globalCustomerId: INT AUTO_INCREMENT (PK)
- fullName: VARCHAR(100)
- email: VARCHAR(100) UNIQUE

---

## CustomerSites
- customerSiteId: INT AUTO_INCREMENT (PK)
- globalCustomerId: INT (FK → GlobalCustomers.globalCustomerId)
- siteId: INT (FK → Sites.siteId)

---

## Orders
- orderId: INT AUTO_INCREMENT (PK)
- siteId: INT (FK → Sites.siteId)
- customerSiteId: INT (FK → CustomerSites.customerSiteId)
- currencyId: INT (FK → Currencies.currencyId)
- statusId: INT (FK → OrderStatusCatalog.statusId)
- orderDate: TIMESTAMP DEFAULT CURRENT_TIMESTAMP

---

## OrderStatusCatalog
- statusId: INT AUTO_INCREMENT (PK)
- code: VARCHAR(20) UNIQUE
- description: VARCHAR(100)

---

## OrderItems
- orderItemId: INT AUTO_INCREMENT (PK)
- orderId: INT (FK → Orders.orderId)
- productId: INT (FK → Products.productId)
- quantity: INT
- unitPrice: DECIMAL(14,2)

---

## Lots
- lotId: INT AUTO_INCREMENT (PK)
- lotNumber: VARCHAR(50) UNIQUE
- origin: VARCHAR(100)
- createdAt: DATE

---

## RawInventoryBatches
- rawBatchId: INT AUTO_INCREMENT (PK)
- productId: INT (FK → Products.productId)
- storageId: INT (FK → Storages.storageId)
- lotId: INT (FK → Lots.lotId)
- initialQuantity: DECIMAL(14,4)
- currentQuantity: DECIMAL(14,4)
- expirationDate: DATE

---

## FinishedInventoryBatches
- finishedBatchId: INT AUTO_INCREMENT (PK)
- workOrderId: INT (FK → KittingWorkOrders.workOrderId)
- productId: INT (FK → Products.productId)
- lotId: INT (FK → Lots.lotId)
- quantityProduced: INT
- createdAt: TIMESTAMP

---

## OrderItemBatches
- OrderItemBatchesId: INT AUTO_INCREMENT (PK)
- orderItemId: INT (FK → OrderItems.orderItemId)
- finishedBatchId: INT (FK → FinishedInventoryBatches.finishedBatchId)

---

## Hubs
- hubId: INT AUTO_INCREMENT (PK)
- name: VARCHAR(100)
- countryId: INT (FK → Countries.countryId)
- city: VARCHAR(100)
- isActive: BOOLEAN

---

## Storages
- storageId: INT AUTO_INCREMENT (PK)
- hubId: INT (FK → Hubs.hubId)
- name: VARCHAR(50)
- type: VARCHAR(50)

---

## KittingWorkOrders
- workOrderId: INT AUTO_INCREMENT (PK)
- siteId: INT (FK → Sites.siteId)
- statusId: INT (FK → WorkOrderStatusCatalog.statusId)
- createdAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP

---

## WorkOrderStatusCatalog
- statusId: INT AUTO_INCREMENT (PK)
- code: VARCHAR(20) UNIQUE
- description: VARCHAR(100)

---

## KittingMaterialConsumption
- consumptionId: INT AUTO_INCREMENT (PK)
- workOrderId: INT (FK → KittingWorkOrders.workOrderId)
- rawBatchId: INT (FK → RawInventoryBatches.rawBatchId)
- quantityUsed: DECIMAL(14,4)

---

## Shipments
- shipmentId: INT AUTO_INCREMENT (PK)
- orderId: INT (FK → Orders.orderId)
- courierId: INT (FK → Couriers.courierId)
- trackingNumber: VARCHAR(100)
- statusId: INT (FK → ShipmentStatusCatalog.statusId)

---

## Couriers
- courierId: INT AUTO_INCREMENT (PK)
- name: VARCHAR(100)
- contactInfo: TEXT

---

## ShipmentStatusCatalog
- statusId: INT AUTO_INCREMENT (PK)
- code: VARCHAR(20) UNIQUE
- description: VARCHAR(100)

---

## ProductRestrictions
- restrictionId: INT AUTO_INCREMENT (PK)
- productId: INT (FK → Products.productId)
- countryId: INT (FK → Countries.countryId)
- isRestricted: BOOLEAN

---

## ProductRestrictionHistory
- restrictionHistoryId: INT AUTO_INCREMENT (PK)
- productId: INT (FK → Products.productId)
- countryId: INT (FK → Countries.countryId)
- restrictionStatusId: INT (FK → RestrictionStatusCatalog.statusId)
- restrictionTypeId: INT (FK → RestrictionTypes.typeId)
- validFrom: DATE
- validUntil: DATE

---

## RestrictionStatusCatalog
- restrictionStatusId: INT AUTO_INCREMENT (PK)
- code: VARCHAR(20) UNIQUE
- description: VARCHAR(100)

---

## RestrictionTypes
- typeId: INT AUTO_INCREMENT (PK)
- code: VARCHAR(20) UNIQUE
- description: VARCHAR(100)

---

## InventoryAdjustments
- adjustmentId: INT AUTO_INCREMENT (PK)
- batchId: INT (FK → RawInventoryBatches.rawBatchId OR FinishedInventoryBatches.finishedBatchId)
- adjustmentTypeId: INT (FK → AdjustmentTypeCatalog.typeId)
- quantityChanged: DECIMAL(14,4)
- reason: TEXT
- adjustedAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP

---

## AdjustmentTypeCatalog
- typeId: INT AUTO_INCREMENT (PK)
- code: VARCHAR(20) UNIQUE
- description: VARCHAR(100)

---

## ProcessSteps
- stepId: INT AUTO_INCREMENT (PK)
- name: VARCHAR(100)
- description: TEXT
- categoryId: INT (FK → ProcessCategories.categoryId)

---

## ProcessCategories
- categoryId: INT AUTO_INCREMENT (PK)
- code: VARCHAR(20) UNIQUE
- description: VARCHAR(100)


## Hacer:
- Pedirle a la IA ejemplos para comprobar redundancia y duplicacion de datos.
