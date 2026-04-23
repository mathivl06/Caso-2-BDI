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

## Sites
- siteId: INT AUTO_INCREMENT (PK)
- name: VARCHAR(100)
- url: VARCHAR(255)
- countryId: INT (FK → Countries.countryId)
- currencyId: INT (FK → Currencies.currencyId)
- isActive: BOOLEAN DEFAULT TRUE
- validFrom: DATE
- validUntil: DATE
- createdAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP

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
- createdAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP
- updatedAt: TIMESTAMP
- deleted: BOOLEAN DEFAULT FALSE

---

## SiteStatusCatalog
- statusId: INT AUTO_INCREMENT (PK)
- code: VARCHAR(20) UNIQUE
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

## Brands
- brandId: INT AUTO_INCREMENT (PK)
- siteId: INT (FK → Sites.siteId)
- brandName: VARCHAR(100)

---

## Products
- productId: INT AUTO_INCREMENT (PK)
- externalProductId: VARCHAR(50) UNIQUE
- productName: VARCHAR(150)
- categoryId: INT (FK → ProductCategories.categoryId)
- baseCostUSD: DECIMAL(14,2)
- createdAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP

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
- createdAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP

---

## Customers
- customerId: INT AUTO_INCREMENT (PK)
- siteId: INT (FK → Sites.siteId)
- userId: INT (FK → Users.userId)
- createdAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP

---

## OrderStatusCatalog
- statusId: INT AUTO_INCREMENT (PK)
- code: VARCHAR(20) UNIQUE
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
- createdAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP
- updatedAt: TIMESTAMP
- deleted: BOOLEAN DEFAULT FALSE

---

## OrderItems
- orderItemId: INT AUTO_INCREMENT (PK)
- orderId: INT (FK → Orders.orderId)
- productId: INT (FK → Products.productId)
- currencyId: INT (FK → Currencies.currencyId)
- quantity: INT
- productName: VARCHAR(150)
- unitPrice: DECIMAL(14,2)

---

## PaymentStatusCatalog
- statusId: INT AUTO_INCREMENT (PK)
- code: VARCHAR(20) UNIQUE
- description: VARCHAR(100)

---

## Payments
- paymentId: INT AUTO_INCREMENT (PK)
- orderId: INT (FK → Orders.orderId)
- method: VARCHAR(50)
- amount: DECIMAL(14,2)
- currencyId: INT (FK → Currencies.currencyId)
- statusId: INT (FK → PaymentStatusCatalog.statusId)
- processedAt: TIMESTAMP
- createdAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP

---

## OrderItemBatches
- id: INT AUTO_INCREMENT (PK)
- orderItemId: INT (FK → OrderItems.orderItemId)
- externalBatchId: VARCHAR(50)
- assignedAt: TIMESTAMP

---

## ShipmentStatusCatalog
- statusId: INT AUTO_INCREMENT (PK)
- code: VARCHAR(20) UNIQUE
- description: VARCHAR(100)

---

## Shipments
- shipmentId: INT AUTO_INCREMENT (PK)
- orderId: INT (FK → Orders.orderId)
- trackingNumber: VARCHAR(100)
- carrier: VARCHAR(100)
- statusId: INT (FK → ShipmentStatusCatalog.statusId)
- createdAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP

---

## RestrictionReasonsCatalog
- reasonId: INT AUTO_INCREMENT (PK)
- code: VARCHAR(50) UNIQUE
- description: VARCHAR(100)

---

## ProductRestrictions
- restrictionId: INT AUTO_INCREMENT (PK)
- productId: INT (FK → Products.productId)
- countryId: INT (FK → Countries.countryId)
- reasonId: INT (FK → RestrictionReasonsCatalog.reasonId)
