# Data Warehouse Design - Dynamic Brands & Etheria

- Database engine: PostgreSQL
- Database name: DynamicBrandsDW

- Context:
Este Data Warehouse integra datos de Dynamic Brands (ventas e-commerce) y Etheria Global (supply chain) para análisis estratégico, incluyendo ventas, inventario, logística y proveedores.

---

# Tables:

## DimDate
- dateKey: INT (PK)
- fullDate: DATE
- day: INT
- month: INT
- year: INT
- quarter: INT

---

## DimProduct
- productKey: SERIAL (PK)
- externalProductId: VARCHAR(50)
- productName: VARCHAR(150)
- category: VARCHAR(100)
- productType: VARCHAR(50)

---

## DimCustomer
- customerKey: SERIAL (PK)
- customerId: INT
- country: VARCHAR(100)

---

## DimSite
- siteKey: SERIAL (PK)
- siteId: INT
- siteName: VARCHAR(100)
- country: VARCHAR(100)
- currency: VARCHAR(10)

---

## DimSupplier
- supplierKey: SERIAL (PK)
- supplierId: INT
- supplierName: VARCHAR(100)
- country: VARCHAR(100)

---

## DimWarehouse
- warehouseKey: SERIAL (PK)
- warehouseId: INT
- warehouseName: VARCHAR(100)
- country: VARCHAR(100)

---

## DimBatch
- batchKey: SERIAL (PK)
- batchId: INT
- arrivalDate: TIMESTAMP

---

## DimPaymentStatus
- paymentStatusKey: SERIAL (PK)
- code: VARCHAR(20)
- description: VARCHAR(100)

---

## DimOrderStatus
- orderStatusKey: SERIAL (PK)
- code: VARCHAR(20)
- description: VARCHAR(100)

---

# Fact Tables:

## FactSales
- salesId: SERIAL (PK)
- orderId: INT
- orderItemId: INT

- productKey: INT (FK → DimProduct.productKey)
- customerKey: INT (FK → DimCustomer.customerKey)
- siteKey: INT (FK → DimSite.siteKey)
- dateKey: INT (FK → DimDate.dateKey)

- quantity: INT
- unitPrice: DECIMAL(14,2)

- subtotalLocal: DECIMAL(14,2)
- subtotalUSD: DECIMAL(14,2)
- taxesUSD: DECIMAL(14,2)
- totalUSD: DECIMAL(14,2)

- paymentStatusKey: INT (FK → DimPaymentStatus.paymentStatusKey)
- orderStatusKey: INT (FK → DimOrderStatus.orderStatusKey)

---

## FactInventory
- inventoryFactId: SERIAL (PK)

- batchKey: INT (FK → DimBatch.batchKey)
- productKey: INT (FK → DimProduct.productKey)
- warehouseKey: INT (FK → DimWarehouse.warehouseKey)
- dateKey: INT (FK → DimDate.dateKey)

- quantityAvailable: INT
- unitCostUSD: DECIMAL(14,2)

---

## FactSupply
- supplyId: SERIAL (PK)

- supplierKey: INT (FK → DimSupplier.supplierKey)
- productKey: INT (FK → DimProduct.productKey)
- dateKey: INT (FK → DimDate.dateKey)

- quantity: INT
- unitCostUSD: DECIMAL(14,2)
- totalCostUSD: DECIMAL(14,2)

---

## FactShipment
- shipmentFactId: SERIAL (PK)

- shipmentId: INT
- orderId: INT

- productKey: INT (FK → DimProduct.productKey)
- batchKey: INT (FK → DimBatch.batchKey)
- siteKey: INT (FK → DimSite.siteKey)
- dateKey: INT (FK → DimDate.dateKey)

- shippingCostUSD: DECIMAL(14,2)
- deliveryTimeDays: INT