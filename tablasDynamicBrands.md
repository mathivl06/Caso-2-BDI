- Database engine: MySQL 8 
- Database name: DynamicBrandsDB

- Context: Plataforma de e-commerce dinámico impulsado por IA que genera múltiples sitios por país, con branding independiente, productos compartidos y ventas en moneda local.

---

# Tables:

## Users
- userId: INT AUTO_INCREMENT (PK)
- fullName: VARCHAR(100) NOT NULL
- email: VARCHAR(100) UNIQUE NOT NULL
- passwordHash: VARCHAR(255) NOT NULL
- status: VARCHAR(20) NOT NULL
- createdAt: TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP

---

## Roles
- roleId: INT AUTO_INCREMENT (PK)
- name: VARCHAR(50) UNIQUE NOT NULL
- description: VARCHAR(150)
- createdAt: TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
- deleted: BOOLEAN NOT NULL DEFAULT FALSE

---

## Permissions
- permissionId: INT AUTO_INCREMENT (PK)
- code: VARCHAR(50) UNIQUE NOT NULL
- description: VARCHAR(150)
- deleted: BOOLEAN NOT NULL DEFAULT FALSE

---

## UserRoles
- userId: INT (FK → Users.userId)
- roleId: INT (FK → Roles.roleId)
- assignedAt: TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
- deleted: BOOLEAN NOT NULL DEFAULT FALSE
- PRIMARY KEY (userId, roleId)

---

## RolePermissions
- roleId: INT (FK → Roles.roleId)
- permissionId: INT (FK → Permissions.permissionId)
- assignedAt: TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
- deleted: BOOLEAN NOT NULL DEFAULT FALSE
- PRIMARY KEY (roleId, permissionId)

---

## Countries
- countryId: INT AUTO_INCREMENT (PK)
- name: VARCHAR(100) NOT NULL
- isoCode: VARCHAR(10) UNIQUE NOT NULL

---

## Currencies
- currencyId: INT AUTO_INCREMENT (PK)
- code: VARCHAR(10) UNIQUE NOT NULL
- name: VARCHAR(50)
- symbol: VARCHAR(10)

---

## ExchangeRates
- rateId: INT AUTO_INCREMENT (PK)
- currencyId: INT (FK → Currencies.currencyId)
- rateToUSD: DECIMAL(12,6) NOT NULL
- effectiveDate: DATE NOT NULL

---

## Sites
- siteId: INT AUTO_INCREMENT (PK)
- name: VARCHAR(100) NOT NULL
- countryId: INT (FK → Countries.countryId)
- currencyId: INT (FK → Currencies.currencyId)
- brandingConfig: JSON NOT NULL
- status: VARCHAR(20) NOT NULL
- createdAt: TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP

---

## Brands
- brandId: INT AUTO_INCREMENT (PK)
- siteId: INT (FK → Sites.siteId)
- brandName: VARCHAR(100) NOT NULL
- marketingMessage: TEXT
- logoUrl: VARCHAR(255)

---

## Products
- productId: INT AUTO_INCREMENT (PK)
- externalProductId: VARCHAR(50) NOT NULL
- name: VARCHAR(150) NOT NULL
- category: VARCHAR(100)
- baseCostUSD: DECIMAL(12,2) NOT NULL
- attributes: JSON NOT NULL
- createdAt: TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP

---

## ProductPrices
- priceId: INT AUTO_INCREMENT (PK)
- productId: INT (FK → Products.productId)
- siteId: INT (FK → Sites.siteId)
- priceLocal: DECIMAL(12,2) NOT NULL
- currencyId: INT (FK → Currencies.currencyId)
- validFrom: DATE NOT NULL

---

## Customers
- customerId: INT AUTO_INCREMENT (PK)
- fullName: VARCHAR(100) NOT NULL
- email: VARCHAR(100)
- countryId: INT (FK → Countries.countryId)
- createdAt: TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP

---

## Orders
- orderId: INT AUTO_INCREMENT (PK)
- siteId: INT (FK → Sites.siteId)
- customerId: INT (FK → Customers.customerId)
- orderDate: TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
- status: VARCHAR(20) NOT NULL
- currencyId: INT (FK → Currencies.currencyId)
- subtotal: DECIMAL(14,2)
- shippingCost: DECIMAL(14,2)
- taxes: DECIMAL(14,2)
- total: DECIMAL(14,2)

---

## OrderItems
- orderItemId: INT AUTO_INCREMENT (PK)
- orderId: INT (FK → Orders.orderId)
- productId: INT (FK → Products.productId)
- quantity: INT NOT NULL
- unitPrice: DECIMAL(12,2) NOT NULL
- subtotal: DECIMAL(14,2) NOT NULL

---

## Shipments
- shipmentId: INT AUTO_INCREMENT (PK)
- orderId: INT (FK → Orders.orderId)
- courierName: VARCHAR(100)
- trackingNumber: VARCHAR(100)
- status: VARCHAR(50)
- shippedAt: TIMESTAMP
- deliveredAt: TIMESTAMP

---

## InventoryRequests
- requestId: INT AUTO_INCREMENT (PK)
- productId: INT (FK → Products.productId)
- siteId: INT (FK → Sites.siteId)
- quantity: INT NOT NULL
- requestedAt: TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
- status: VARCHAR(20)

---

## AuditLog
- logId: INT AUTO_INCREMENT (PK)
- entity: VARCHAR(50)
- entityId: INT
- action: VARCHAR(50)
- details: JSON
- createdAt: TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP