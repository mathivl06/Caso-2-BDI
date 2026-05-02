-- =========================================
-- 1. CREACIÓN DE ESTRUCTURA
-- =========================================

\i /scripts/Script_creacion_EtheriaDB_Postgres.sql

-- =========================================
-- 2. STORED PROCEDURES
-- =========================================

\i /scripts/01_log_procedure.sql
\i /scripts/02_import_procedures.sql
\i /scripts/03_inventory_procedures.sql
\i /scripts/04_dispatch_procedures.sql
\i /scripts/05_seed_orchestrator.sql

-- =========================================
-- 3. DATOS BASE (CRÍTICO)
-- =========================================

-- Person base (system user)
INSERT INTO Persons (personId, firstName, lastName, email)
VALUES (1, 'System', 'Admin', 'system@local')
ON CONFLICT (personId) DO NOTHING;

-- Currency base (USD)
INSERT INTO Currencies (currencyId, code, symbol, name, baseCurrency)
VALUES (1, 'USD', '$', 'US Dollar', TRUE)
ON CONFLICT (currencyId) DO NOTHING;

-- País base
INSERT INTO Countries (countryId, countryName)
VALUES (1, 'Nicaragua')
ON CONFLICT (countryId) DO NOTHING;

-- Status Import
INSERT INTO ImportOrderStatusCatalog (statusId, code, name)
VALUES (1, 'PENDING', 'Pending')
ON CONFLICT (statusId) DO NOTHING;

-- Status Dispatch
INSERT INTO DispatchOrderStatusCatalog (statusId, code, name)
VALUES (1, 'PENDING', 'Pending')
ON CONFLICT (statusId) DO NOTHING;

-- Inventory Transaction Types
INSERT INTO InventoryTransactionTypes (transactionTypeId, code, name, affectSign)
VALUES 
(1, 'ENT', 'Entrada', 1),
(2, 'SAL', 'Salida', -1)
ON CONFLICT (transactionTypeId) DO NOTHING;

-- =========================================
-- 4. DATOS MÍNIMOS PARA RELACIONES
-- =========================================

-- Address mínima
INSERT INTO States (stateId, stateName, countryId)
VALUES (1, 'Default State', 1)
ON CONFLICT DO NOTHING;

INSERT INTO Cities (cityId, cityName, stateId)
VALUES (1, 'Default City', 1)
ON CONFLICT DO NOTHING;

INSERT INTO Addresses (addressId, addressLine1, cityId)
VALUES (1, 'Default Address', 1)
ON CONFLICT DO NOTHING;

-- Supplier mínimo
INSERT INTO Suppliers (supplierId, supplierName, addressId, countryId, createdBy)
VALUES (1, 'Default Supplier', 1, 1, 1)
ON CONFLICT DO NOTHING;

-- ProductType + Product
INSERT INTO ProductTypes (productTypeId, productTypeName)
VALUES (1, 'General')
ON CONFLICT DO NOTHING;

INSERT INTO Products (productId, productName, productTypeId)
VALUES (1, 'Sample Product', 1)
ON CONFLICT DO NOTHING;

-- Warehouse mínimo
INSERT INTO Warehouses (warehouseId, warehouseName, addressId)
VALUES (1, 'Main Warehouse', 1)
ON CONFLICT DO NOTHING;

-- =========================================
-- 5. EJECUTAR ORQUESTADOR
-- =========================================

CALL sp_seed_data();