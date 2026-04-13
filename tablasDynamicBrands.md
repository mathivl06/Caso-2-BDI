# Database Design - Dynamic Brands

- Database engine: MySQL 8
- Database name: DynamicBrandsDB
- Context: Esta es una empresa de base tecnológica. Han desarrollado una IA capaz de generar sitios de e-commerce dinámicos. A partir de parámetros (logo, enfoque, país), la IA despliega tiendas virtuales con marcas blancas. Pueden abrir y cerrar "N" sitios en diferentes países de Latam con un solo clic, cada uno con un enfoque de marketing y mensajes distintos para el mismo producto base.

---

# Tables:

## Users
- userId: INT AUTO_INCREMENT (PK)
- name: VARCHAR(50) NOT NULL
- lastName1: VARCHAR(50) NOT NULL
- lastName2: VARCHAR(50)
- email: VARCHAR(100) UNIQUE NOT NULL
- passwordHash: VARCHAR(255) NOT NULL
- status: VARCHAR(20) NOT NULL
- createdAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP
- updatedAt: TIMESTAMP
- deleted: BOOLEAN DEFAULT FALSE

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

## ExchangeRateSources
- sourceId: INT AUTO_INCREMENT (PK)
- name: VARCHAR(100)

---

## ExchangeRates
- rateId: INT AUTO_INCREMENT (PK)
- currencyId: INT (FK → Currencies.currencyId)
- rateToUSD: DECIMAL(18,6)
- effectiveDate: DATE
- validUntil: DATE
- sourceId: INT (FK → ExchangeRateSources.sourceId)

---

## Sites
- siteId: INT AUTO_INCREMENT (PK)
- name: VARCHAR(100)
- url: VARCHAR(255)
- countryId: INT (FK → Countries.countryId)
- currencyId: INT (FK → Currencies.currencyId)
- isActive: BOOLEAN DEFAULT TRUE
- validFrom: DATE
- validUntil: DATE

---

## ConfigKeys
- keyId: INT AUTO_INCREMENT (PK)
- name: VARCHAR(50)
- groupName: VARCHAR(50)

---

## SiteBrandingConfig
- configId: INT AUTO_INCREMENT (PK)
- siteId: INT (FK → Sites.siteId)
- keyId: INT (FK → ConfigKeys.keyId)
- value: VARCHAR(255)
- createdAt: TIMESTAMP
- updatedAt: TIMESTAMP
- deleted: BOOLEAN

---

## SiteStatusCatalog
- statusId: INT AUTO_INCREMENT (PK)
- code: VARCHAR(20)
- description: VARCHAR(100)

---

## SiteStatusHistory
- historyId: INT AUTO_INCREMENT (PK)
- siteId: INT (FK → Sites.siteId)
- statusId: INT (FK → SiteStatusCatalog.statusId)
- changedAt: TIMESTAMP
- reasonCode: VARCHAR(50)

---

## ProductCategories
- categoryId: INT AUTO_INCREMENT (PK)
- name: VARCHAR(100)

---

## Products
- productId: INT AUTO_INCREMENT (PK)
- externalProductId: VARCHAR(50)
- productName: VARCHAR(150)
- categoryId: INT (FK → ProductCategories.categoryId)
- baseCostUSD: DECIMAL(14,2)

---

## AttributeKeys
- keyId: INT AUTO_INCREMENT (PK)
- name: VARCHAR(50)
- groupName: VARCHAR(50)

---

## ProductAttributes
- attributeId: INT AUTO_INCREMENT (PK)
- productId: INT (FK → Products.productId)
- keyId: INT (FK → AttributeKeys.keyId)
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

## Customers
- customerId: INT AUTO_INCREMENT (PK)
- siteId: INT (FK → Sites.siteId)
- userId: INT (FK → Users.userId)

---

## OrderStatusCatalog
- statusId: INT AUTO_INCREMENT (PK)
- code: VARCHAR(20)
- description: VARCHAR(100)

---

## Orders
- orderId: INT AUTO_INCREMENT (PK)
- orderNumber: VARCHAR(50) UNIQUE
- siteId: INT (FK → Sites.siteId)
- customerId: INT (FK → Customers.customerId)
- currencyId: INT (FK → Currencies.currencyId)
- statusId: INT (FK → OrderStatusCatalog.statusId)
- subtotalLocal: DECIMAL(14,2)
- taxesLocal: DECIMAL(14,2)
- totalLocal: DECIMAL(14,2)
- subtotalUSD: DECIMAL(14,2)
- taxesUSD: DECIMAL(14,2)
- totalUSD: DECIMAL(14,2)
- createdAt: TIMESTAMP

---

## OrderItems
- orderItemId: INT AUTO_INCREMENT (PK)
- orderId: INT (FK → Orders.orderId)
- productId: INT (FK → Products.productId)
- currencyId: INT (FK → Currencies.currencyId)
- quantity: INT
- unitPrice: DECIMAL(14,2)

---

## Payments
- paymentId: INT AUTO_INCREMENT (PK)
- orderId: INT (FK → Orders.orderId)
- method: VARCHAR(50)
- amount: DECIMAL(14,2)
- currencyId: INT (FK → Currencies.currencyId)
- status: VARCHAR(20)
- processedAt: TIMESTAMP

---

## Producers
- producerId: INT AUTO_INCREMENT (PK)
- name: VARCHAR(100)
- countryId: INT (FK → Countries.countryId)

---

## PurchaseOrders
- purchaseOrderId: INT AUTO_INCREMENT (PK)
- producerId: INT (FK → Producers.producerId)
- orderDate: DATE
- status: VARCHAR(20)

---

## PurchaseOrderItems
- purchaseItemId: INT AUTO_INCREMENT (PK)
- purchaseOrderId: INT (FK → PurchaseOrders.purchaseOrderId)
- productId: INT (FK → Products.productId)
- quantity: DECIMAL(14,4)
- costUSD: DECIMAL(14,2)

---

## Lots
- lotId: INT AUTO_INCREMENT (PK)
- purchaseOrderId: INT (FK → PurchaseOrders.purchaseOrderId)
- createdAt: DATE

---

## InventoryTransactions
- transactionId: INT AUTO_INCREMENT (PK)
- batchId: INT
- batchType: VARCHAR(20)
- transactionType: VARCHAR(20)
- quantity: DECIMAL(14,4)
- referenceId: INT
- createdAt: TIMESTAMP

---

## FinishedInventoryBatches
- finishedBatchId: INT AUTO_INCREMENT (PK)
- productId: INT (FK → Products.productId)
- lotId: INT (FK → Lots.lotId)
- quantityProduced: INT
- statusId: INT
- createdAt: TIMESTAMP

---

## OrderItemBatches
- id: INT AUTO_INCREMENT (PK)
- orderItemId: INT (FK → OrderItems.orderItemId)
- finishedBatchId: INT (FK → FinishedInventoryBatches.finishedBatchId)
- assignedAt: TIMESTAMP

---

## StorageTypes
- typeId: INT AUTO_INCREMENT (PK)
- name: VARCHAR(50)

---

## Hubs
- hubId: INT AUTO_INCREMENT (PK)
- name: VARCHAR(100)
- countryId: INT (FK → Countries.countryId)
- portName: VARCHAR(100)

---

## Storages
- storageId: INT AUTO_INCREMENT (PK)
- hubId: INT (FK → Hubs.hubId)
- typeId: INT (FK → StorageTypes.typeId)
- locationCode: VARCHAR(50)

---

## ShipmentStatusCatalog
- statusId: INT AUTO_INCREMENT (PK)
- code: VARCHAR(20)

---

## Shipments
- shipmentId: INT AUTO_INCREMENT (PK)
- orderId: INT (FK → Orders.orderId)
- trackingNumber: VARCHAR(100)
- statusId: INT (FK → ShipmentStatusCatalog.statusId)

---

## ProductRestrictions
- restrictionId: INT AUTO_INCREMENT (PK)
- productId: INT (FK → Products.productId)
- countryId: INT (FK → Countries.countryId)
- reasonCode: VARCHAR(50)
