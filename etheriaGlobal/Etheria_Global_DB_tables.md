- Database engine: PostgreSQL 18
- Database name: Etheria Global: Sourcing & Logistics DB
- Context: Esta empresa se encarga de la cadena de suministro. Importan productos naturales y curativos exóticos de todo el mundo (bebidas, alimentos, cosmética dermatológica, capilar, aromaterapia, jabones y aceites esenciales). Todos los productos son de gama alta y poseen propiedades medicinales/saludables. Se importan en "bulk" (cajas sin marca ni etiquetado) en moneda base (base currency). Todo llega a un centro logístico en la costa Caribe de Nicaragua.

# Table Definitions

## GEOGRAPHY & LOCATIONS

## Countries
- countryId SERIAL (PK)
- countryName VARCHAR(30) NOT NULL
- enabled BOOLEAN NOT NULL DEFAULT TRUE
- createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
- updatedAt TIMESTAMP
- createdBy INT (FK → Users, nullable for system)
- updatedBy INT (FK → Users, nullable)

## States
- stateId SERIAL (PK)
- stateName VARCHAR(30) NOT NULL
- countryId INT NOT NULL (FK → Countries.countryId)
- enabled BOOLEAN NOT NULL DEFAULT TRUE
- createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP

## Cities
- cityId SERIAL (PK)
- cityName VARCHAR(40) NOT NULL
- stateId INT NOT NULL (FK → States.stateId)
- enabled BOOLEAN NOT NULL DEFAULT TRUE

## AddressTypes (CATALOG)
- addressTypeId SERIAL (PK)
- code VARCHAR(20) UNIQUE NOT NULL (ENV/FAC/OFI/WAREHOUSE/HUB)
- name VARCHAR(50) NOT NULL
- description VARCHAR(255)

## Addresses
- addressId SERIAL (PK)
- addressLine1 VARCHAR(100) NOT NULL
- addressLine2 VARCHAR(100)
- cityId INT NOT NULL (FK → Cities.cityId)
- zipCode VARCHAR(10)
- latitude DECIMAL(10,8)
- longitude DECIMAL(11,8)
- notes TEXT
- createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
- updatedAt TIMESTAMP
- deleted BOOLEAN DEFAULT FALSE

## Currencies
- currencyId SERIAL (PK)
- code VARCHAR(3) UNIQUE NOT NULL (USD/COP/PEN/etc)
- symbol VARCHAR(5) NOT NULL
- name VARCHAR(50) NOT NULL
- baseCurrency BOOLEAN DEFAULT FALSE (TRUE only for USD)
- enabled BOOLEAN NOT NULL DEFAULT TRUE
- countryId INT (FK → Countries.countryId, nullable)
- createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP

## ExchangeRates (Shared across all DBs)
- exchangeRateId SERIAL (PK)
- fromCurrencyId INT NOT NULL (FK → Currencies.currencyId)
- toCurrencyId INT NOT NULL (FK → Currencies.currencyId)
- rate DECIMAL(18,6) NOT NULL (e.g., 1 USD = 3450 COP)
- effectiveDate DATE NOT NULL
- expiryDate DATE (NULL = still active)
- source VARCHAR(50) (BANCO_CENTRAL/OANDA/MANUAL)
- createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
- createdBy INT (FK → Users)
- UNIQUE(fromCurrencyId, toCurrencyId, effectiveDate)

## ExchangeRateHistory (Audit trail for rates)
- historyId SERIAL (PK)
- exchangeRateId INT NOT NULL (FK → ExchangeRates.exchangeRateId)
- oldRate DECIMAL(18,6)
- newRate DECIMAL(18,6) NOT NULL
- changedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
- changedBy INT (FK → Users)
- reason VARCHAR(255)

## BankingIntermediaries
- bankingIntermediaryId (PK)
- bankingIntermediaryName varchar(50)
- headquartersAddress (FK)

## CurrenciesPerBankingIntermediary
- bankingIntermediaryId (FK) (CK)
- currencyId (FK) (CK)

---

# PERSONS & CONTACTS (UNIFIED PATTERN)

## Persons (Master table for all people)
- personId SERIAL (PK)
- firstName VARCHAR(50) NOT NULL
- lastName VARCHAR(50) NOT NULL
- email VARCHAR(100)
- idDocument VARCHAR(30) (passport/cedula/etc)
- active BOOLEAN DEFAULT TRUE
- createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
- updatedAt TIMESTAMP
- deleted BOOLEAN DEFAULT FALSE

## PersonContactTypes (CATALOG)
- contactTypeId SERIAL (PK)
- code VARCHAR(20) UNIQUE NOT NULL (EMAIL/PHONE/WHATSAPP/TELEGRAM)
- name VARCHAR(50) NOT NULL

## PersonContacts (CONTACT INFO PATTERN)
- contactId SERIAL (PK)
- personId INT NOT NULL (FK → Persons.personId)
- contactTypeId INT NOT NULL (FK → PersonContactTypes.contactTypeId)
- value VARCHAR(255) NOT NULL
- isPrimary BOOLEAN DEFAULT FALSE
- verified BOOLEAN DEFAULT FALSE
- verifiedAt TIMESTAMP
- validFrom DATE NOT NULL DEFAULT CURRENT_DATE
- validUntil DATE
- createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP

---

# PRODUCTS & SOURCING

## ProductTypes
- productTypeId SERIAL (PK)
- productTypeName VARCHAR(30) NOT NULL
- enabled BOOLEAN DEFAULT TRUE

## Products
- productId SERIAL (PK)
- externalProductId VARCHAR(50) UNIQUE
- productName VARCHAR(100) NOT NULL
- productTypeId INT NOT NULL (FK → ProductTypes.productTypeId)
- description TEXT
- enabled BOOLEAN DEFAULT TRUE
- createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
- updatedAt TIMESTAMP
- createdBy INT (FK → Persons, optional)
- updatedBy INT (FK → Persons, optional)
- deleted BOOLEAN DEFAULT FALSE

## Suppliers (Now references Persons for contact)
- supplierId SERIAL (PK)
- supplierName VARCHAR(100) NOT NULL
- personContactId INT (FK → PersonContacts.contactId, main contact)
- addressId INT NOT NULL (FK → Addresses.addressId)
- countryId INT NOT NULL (FK → Countries.countryId)
- enabled BOOLEAN DEFAULT TRUE
- createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
- updatedAt TIMESTAMP
- createdBy INT (FK → Persons)
- updatedBy INT (FK → Persons)
- deleted BOOLEAN DEFAULT FALSE

---

# INVENTORY MOVEMENTS PATTERN (TRANSACTIONS/MOVEMENTS)

## InventoryTransactionTypes (CATALOG)
- transactionTypeId SERIAL (PK)
- code VARCHAR(20) UNIQUE NOT NULL (ENT/SAL/AJ/TRF/RCV/SHD)
- name VARCHAR(50) NOT NULL
- affectSign SMALLINT NOT NULL CHECK (affectSign IN (-1, 1))
- description VARCHAR(255)
- notes:
  - ENT = Entrada (ingreso)
  - SAL = Salida (egreso)
  - AJ = Ajuste (corrección)
  - TRF = Transferencia entre bodegas
  - RCV = Recepción de compra
  - SHD = Shredding/destrucción

## InventoryTransactionHeader
- transactionId BIGSERIAL (PK)
- transactionTypeId INT NOT NULL (FK → InventoryTransactionTypes.transactionTypeId)
- batchId INT NOT NULL (FK → Batches.batchId)
- warehouseIdFrom INT NOT NULL (FK → Warehouses.warehouseId)
- warehouseIdTo INT (FK → Warehouses.warehouseId, for TRF)
- transactionDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
- referenceType VARCHAR(50) (IMPORT/DISPATCH/ADJUSTMENT/TRANSFER)
- referenceId INT (importOrderId/dispatchOrderId/etc)
- notes TEXT
- createdBy INT NOT NULL (FK → Persons)
- createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP

## InventoryTransactionDetail
- transactionDetailId BIGSERIAL (PK)
- transactionId BIGINT NOT NULL (FK → InventoryTransactionHeader.transactionId)
- productId INT NOT NULL (FK → Products.productId)
- quantity DECIMAL(14,4) NOT NULL CHECK (quantity > 0)
- unitCost DECIMAL(14,4) NOT NULL (snapshot of cost at that moment)
- currencyId INT NOT NULL (FK → Currencies.currencyId)
- exchangeRateId INT (FK → ExchangeRates.exchangeRateId, snapshot)
- notes TEXT

---

# IMPORTS (MASTER-DETAIL PATTERN)

## ImportOrderStatusCatalog
- statusId SERIAL (PK)
- code VARCHAR(20) UNIQUE NOT NULL (PENDING/RECEIVED/PROCESSING/SHIPPED/DELIVERED)
- name VARCHAR(50) NOT NULL
- isFinal BOOLEAN DEFAULT FALSE

## ImportOrders (Master)
- importOrderId SERIAL (PK)
- importOrderNumber VARCHAR(50) UNIQUE NOT NULL
- supplierId INT NOT NULL (FK → Suppliers.supplierId)
- orderDate TIMESTAMP NOT NULL
- expectedArrivalDate DATE
- actualArrivalDate TIMESTAMP
- totalCost DECIMAL(14,2) NOT NULL
- currencyId INT NOT NULL (FK → Currencies.currencyId)
- exchangeRateId INT (FK → ExchangeRates.exchangeRateId)
- statusId INT NOT NULL (FK → ImportOrderStatusCatalog.statusId)
- paymentStatus VARCHAR(20) (PENDING/PAID/PARTIAL)
- createdBy INT NOT NULL (FK → Persons)
- updatedBy INT (FK → Persons)
- createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
- updatedAt TIMESTAMP
- deleted BOOLEAN DEFAULT FALSE

## ImportOrderDetails (Detail)
- importOrderDetailId SERIAL (PK)
- importOrderId INT NOT NULL (FK → ImportOrders.importOrderId)
- productId INT NOT NULL (FK → Products.productId)
- quantity INTEGER NOT NULL CHECK (quantity > 0)
- unitCost DECIMAL(14,4) NOT NULL (snapshot per detail)
- currencyId INT NOT NULL (FK → Currencies.currencyId)
- exchangeRateId INT (FK → ExchangeRates.exchangeRateId)
- lineTotal DECIMAL(14,2) NOT NULL (quantity * unitCost * rate)
- status VARCHAR(20) (PENDING/RECEIVED/PARTIAL)

## Batches (Bulk shipments received)
- batchId SERIAL (PK)
- batchNumber VARCHAR(50) UNIQUE NOT NULL
- importOrderId INT NOT NULL (FK → ImportOrders.importOrderId)
- productId INT NOT NULL (FK → Products.productId)
- quantityReceived DECIMAL(14,4) NOT NULL
- quantityExpected DECIMAL(14,4)
- unitCost DECIMAL(14,4) NOT NULL (snapshot)
- currencyId INT NOT NULL (FK → Currencies.currencyId)
- exchangeRateId INT (FK → ExchangeRates.exchangeRateId)
- expirationDate DATE
- receivedAt TIMESTAMP NOT NULL
- receivedBy INT NOT NULL (FK → Persons)
- notes TEXT
- createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP

---

# WAREHOUSES & STORAGE

## WarehouseTypes (CATALOG)
- warehouseTypeId SERIAL (PK)
- code VARCHAR(20) UNIQUE NOT NULL (COLD/DRY/CLIMATE/HAZMAT)
- name VARCHAR(50) NOT NULL

## Warehouses
- warehouseId SERIAL (PK)
- warehouseName VARCHAR(100) NOT NULL
- warehouseTypeId INT (FK → WarehouseTypes.warehouseTypeId)
- addressId INT NOT NULL (FK → Addresses.addressId)
- manager INT (FK → Persons, warehouse manager)
- capacity DECIMAL(14,2) (cubic meters or units)
- createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
- createdBy INT (FK → Persons)
- enabled BOOLEAN DEFAULT TRUE
- deleted BOOLEAN DEFAULT FALSE

## StorageLocations (Where exactly in warehouse)
- locationId SERIAL (PK)
- warehouseId INT NOT NULL (FK → Warehouses.warehouseId)
- locationCode VARCHAR(50) NOT NULL (RACK-A-001, etc)
- level SMALLINT (floor level)
- aisle VARCHAR(10)
- shelf VARCHAR(10)
- bin VARCHAR(10)
- capacity DECIMAL(14,2)
- UNIQUE(warehouseId, locationCode)

---

# DISPATCH OPERATIONS

## DispatchOrderStatusCatalog
- statusId SERIAL (PK)
- code VARCHAR(20) UNIQUE NOT NULL (PENDING/PACKED/DISPATCHED/IN_TRANSIT/DELIVERED)
- name VARCHAR(50) NOT NULL
- isFinal BOOLEAN DEFAULT FALSE

## DispatchOrders (Master)
- dispatchOrderId SERIAL (PK)
- dispatchOrderNumber VARCHAR(50) UNIQUE NOT NULL
- destinationCountryId INT NOT NULL (FK → Countries.countryId)
- dispatchDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
- expectedDeliveryDate DATE
- statusId INT NOT NULL (FK → DispatchOrderStatusCatalog.statusId)
- notes TEXT
- createdBy INT NOT NULL (FK → Persons)
- updatedBy INT (FK → Persons)
- createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
- updatedAt TIMESTAMP
- deleted BOOLEAN DEFAULT FALSE

## DispatchOrderDetails (Detail)
- dispatchOrderDetailId SERIAL (PK)
- dispatchOrderId INT NOT NULL (FK → DispatchOrders.dispatchOrderId)
- batchId INT NOT NULL (FK → Batches.batchId)
- quantityDispatched DECIMAL(14,4) NOT NULL CHECK (quantityDispatched > 0)
- notes TEXT

---

# LOGISTICS & SHIPPING

## CourierServices (With Contact Pattern)
- courierServiceId SERIAL (PK)
- courierName VARCHAR(100) NOT NULL
- personContactId INT (FK → PersonContacts.contactId, main contact)
- addressId INT (FK → Addresses.addressId, headquarters)
- enabled BOOLEAN DEFAULT TRUE
- createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
- updatedAt TIMESTAMP
- createdBy INT (FK → Persons)
- deleted BOOLEAN DEFAULT FALSE

## ShipmentStatusCatalog
- statusId SERIAL (PK)
- code VARCHAR(20) UNIQUE NOT NULL (PICKUP/IN_TRANSIT/DELIVERY_ATTEMPT/DELIVERED/RETURNED)
- name VARCHAR(50) NOT NULL
- isFinal BOOLEAN DEFAULT FALSE

## Shipments
- shipmentId SERIAL (PK)
- shipmentNumber VARCHAR(50) UNIQUE NOT NULL
- dispatchOrderId INT NOT NULL (FK → DispatchOrders.dispatchOrderId)
- courierServiceId INT NOT NULL (FK → CourierServices.courierServiceId)
- trackingNumber VARCHAR(100)
- shipmentDate TIMESTAMP NOT NULL
- estimatedDeliveryDate DATE
- actualDeliveryDate TIMESTAMP
- shippingCost DECIMAL(14,2)
- currencyId INT (FK → Currencies.currencyId)
- exchangeRateId INT (FK → ExchangeRates.exchangeRateId)
- statusId INT NOT NULL (FK → ShipmentStatusCatalog.statusId)
- notes TEXT
- createdBy INT NOT NULL (FK → Persons)
- createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
- updatedAt TIMESTAMP
- deleted BOOLEAN DEFAULT FALSE

---

# PRODUCT RESTRICTIONS & COMPLIANCE

## RestrictionTypes (CATALOG)
- restrictionTypeId SERIAL (PK)
- code VARCHAR(20) UNIQUE NOT NULL (BANNED/RESTRICTED/PERMIT_REQUIRED/TARIFF_DUTY)
- name VARCHAR(50) NOT NULL
- description TEXT

## RestrictionStatusCatalog
- statusId SERIAL (PK)
- code VARCHAR(20) UNIQUE NOT NULL (ACTIVE/EXPIRED/SUSPENDED)
- name VARCHAR(50) NOT NULL

## ProductRestrictions (CURRENT/HISTORICAL PATTERN)
- restrictionId SERIAL (PK)
- productId INT NOT NULL (FK → Products.productId)
- countryId INT NOT NULL (FK → Countries.countryId)
- restrictionTypeId INT NOT NULL (FK → RestrictionTypes.restrictionTypeId)
- statusId INT NOT NULL (FK → RestrictionStatusCatalog.statusId)
- reason TEXT
- validFrom DATE NOT NULL
- validUntil DATE
- createdBy INT NOT NULL (FK → Persons)
- createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP

---

# AUDIT & OBSERVABILITY

## LogLevels (CATALOG)
- levelId SERIAL (PK)
- code VARCHAR(20) UNIQUE NOT NULL (INFO/WARN/ERROR/SECURITY)
- priority INT

## AppLogs (LOGS PATTERN - Mejorado)
- logId BIGSERIAL (PK)
- personId INT (FK → Persons.personId, nullable for system events)
- level VARCHAR(20) NOT NULL CHECK (level IN ('INFO','WARN','ERROR','SECURITY'))
- module VARCHAR(50) NOT NULL (auth/inventory/orders/payments/etc)
- action VARCHAR(100) NOT NULL (what happened)
- entity VARCHAR(50) (what was affected: Product, Batch, Order)
- entityId INT (FK varies, or plain int reference)
- message TEXT
- traceId VARCHAR(50) (for correlating across services)
- spanId VARCHAR(50) (optional, for distributed tracing)
- payloadJson JSONB (context data, avoid PII)
- ip INET
- userAgent TEXT
- createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
- INDEX ON (createdAt DESC)
- INDEX ON (level, createdAt DESC)
- INDEX ON (traceId)