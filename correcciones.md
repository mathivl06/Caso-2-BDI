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

-- rnunez: en general de las tablas veo que falta mucho deleted, postime, updateat para controlar cuando se modifican tablas que con catalogos. En esta tabla en particular mejor normalizá los key, para que haya un inventario de keys y que esos keys estén agrupados por algo, pues pueden ser muchos valores de configuracion. Nos falta saber tambien cual es el URL del site. 
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
- category: VARCHAR(100) --rnunez: esto normalizalo
- baseCostUSD: DECIMAL(14,2)

---

## ProductAttributes
- attributeId: INT AUTO_INCREMENT (PK)
- productId: INT (FK → Products.productId)
- key: VARCHAR(50) -- rnunez: lo mismo pasa aqui con estos keys
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

-- rnunez: no entiendo para que es esta tabla, creo que queres tener los customers que usan cada site, pero arriba tenes los users y nos los vinculaste enton
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
- rnunez: como sabes la moneda de compra venta de esto , agregar un order number en orders, les falta informacion de pagos y procesamiento de pagos. 
---


-- rnunez: supongo que aquí inicia etheria global
## Lots
- lotId: INT AUTO_INCREMENT (PK)
- lotNumber: VARCHAR(50) UNIQUE  -- rnunez, está muyy debil esto como varchary el origin como varchar tambien, esto debería poderse mapear con los pedidos y compras
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

## OrderItemBatches , rnunez: algo nos falta con estos batches, creo que seria mejor manejar estados, nos falta como saber caundo es que pasan las cosas, quien las hace, y bueno voy a ver estos batches como se asocian abajo. 
- OrderItemBatchesId: INT AUTO_INCREMENT (PK)
- orderItemId: INT (FK → OrderItems.orderItemId)
- finishedBatchId: INT (FK → FinishedInventoryBatches.finishedBatchId)

---

## Hubs
- hubId: INT AUTO_INCREMENT (PK)
- name: VARCHAR(100)
- countryId: INT (FK → Countries.countryId)
- city: VARCHAR(100) -- rnunez: son mas importante los puertos, aunque solo tengamos un hub
- isActive: BOOLEAN

---

## Storages
- storageId: INT AUTO_INCREMENT (PK)  -- rnunez los storages dado que asocias a batches ocupamos dar location dentro de las bodegas para encontra los productos, averigua eso como se hace usualmente
- hubId: INT (FK → Hubs.hubId)
- name: VARCHAR(50)
- type: VARCHAR(50) -- rnunez, normalizar

---

## KittingWorkOrders  -- rnunez esta tabla parece no estar aportando nada, pues solo se asocia al site. 
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

## KittingMaterialConsumption  -- rnunez, usemos patron de transacciones para los movimientos no tablas que representen los tipos de movimientos
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
- contactInfo: TEXT -- rnunez, jamas esto lo vimos en clase

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
- isRestricted: BOOLEAN  -- rnunez, reason?

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
- reason: TEXT -- rnunez, no usemos text asi 
- adjustedAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP

-- rnunez, lo que no veo del todo es todo lo relacionado a comprar el producto al producor original , que eso es justo lo que tiene q hacer esta empresa, y de eso no hay nada, esa compra, esos productores, o fabricantes, la compra la transacciones, el pago, etc. 

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