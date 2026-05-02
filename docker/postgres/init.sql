-- =========================================
-- 1. ESTRUCTURA ETHERIA GLOBAL
-- =========================================

\i /scripts/Script_creacion_EtheriaDB_Postgres.sql

-- =========================================
-- 2. DATOS BASE MINIMOS
-- =========================================
-- Este init debe dejar PostgreSQL listo para arrancar en Docker.
-- Los stored procedures de seed no se ejecutan aqui porque los scripts
-- actuales en /scripts/sp no coinciden todavia con el esquema vigente.

-- Usuario base del sistema
INSERT INTO Persons (personId, firstName, lastName, email)
VALUES (1, 'System', 'Admin', 'system@local')
ON CONFLICT (personId) DO NOTHING;

-- Pais base del hub logistico
INSERT INTO Countries (countryId, countryName)
VALUES (1, 'Nicaragua')
ON CONFLICT (countryId) DO NOTHING;

-- Moneda base
INSERT INTO Currencies (currencyId, code, symbol, name, baseCurrency, countryId)
VALUES (1, 'USD', '$', 'US Dollar', TRUE, NULL)
ON CONFLICT (currencyId) DO NOTHING;

-- Estado y ciudad base para direcciones obligatorias
INSERT INTO States (stateId, stateName, countryId)
VALUES (1, 'Default State', 1)
ON CONFLICT (stateId) DO NOTHING;

INSERT INTO Cities (cityId, cityName, stateId)
VALUES (1, 'Default City', 1)
ON CONFLICT (cityId) DO NOTHING;

INSERT INTO Addresses (addressId, addressLine1, cityId)
VALUES (1, 'Default Address', 1)
ON CONFLICT (addressId) DO NOTHING;

-- Catalogos operativos minimos
INSERT INTO ImportOrderStatusCatalog (statusId, code, name, isFinal)
VALUES (1, 'PENDING', 'Pending', FALSE)
ON CONFLICT (statusId) DO NOTHING;

INSERT INTO DispatchOrderStatusCatalog (statusId, code, name, isFinal)
VALUES (1, 'PENDING', 'Pending', FALSE)
ON CONFLICT (statusId) DO NOTHING;

INSERT INTO InventoryTransactionTypes (transactionTypeId, code, name, affectSign)
VALUES
    (1, 'ENT', 'Entrada', 1),
    (2, 'SAL', 'Salida', -1)
ON CONFLICT (transactionTypeId) DO NOTHING;

-- Entidades minimas para relaciones obligatorias
INSERT INTO Suppliers (supplierId, supplierName, addressId, countryId, createdBy)
VALUES (1, 'Default Supplier', 1, 1, 1)
ON CONFLICT (supplierId) DO NOTHING;

INSERT INTO ProductTypes (productTypeId, productTypeName)
VALUES (1, 'General')
ON CONFLICT (productTypeId) DO NOTHING;

INSERT INTO Products (productId, externalProductId, productName, productTypeId)
VALUES (1, 'EXT-001', 'Sample Product', 1)
ON CONFLICT (productId) DO NOTHING;

INSERT INTO Warehouses (warehouseId, warehouseName, addressId, createdBy)
VALUES (1, 'Main Warehouse', 1, 1)
ON CONFLICT (warehouseId) DO NOTHING;

-- Ajustar secuencias despues de insertar IDs explicitos.
SELECT setval(pg_get_serial_sequence('Persons', 'personid'), COALESCE(MAX(personId), 1), TRUE) FROM Persons;
SELECT setval(pg_get_serial_sequence('Countries', 'countryid'), COALESCE(MAX(countryId), 1), TRUE) FROM Countries;
SELECT setval(pg_get_serial_sequence('Currencies', 'currencyid'), COALESCE(MAX(currencyId), 1), TRUE) FROM Currencies;
SELECT setval(pg_get_serial_sequence('States', 'stateid'), COALESCE(MAX(stateId), 1), TRUE) FROM States;
SELECT setval(pg_get_serial_sequence('Cities', 'cityid'), COALESCE(MAX(cityId), 1), TRUE) FROM Cities;
SELECT setval(pg_get_serial_sequence('Addresses', 'addressid'), COALESCE(MAX(addressId), 1), TRUE) FROM Addresses;
SELECT setval(pg_get_serial_sequence('ImportOrderStatusCatalog', 'statusid'), COALESCE(MAX(statusId), 1), TRUE) FROM ImportOrderStatusCatalog;
SELECT setval(pg_get_serial_sequence('DispatchOrderStatusCatalog', 'statusid'), COALESCE(MAX(statusId), 1), TRUE) FROM DispatchOrderStatusCatalog;
SELECT setval(pg_get_serial_sequence('InventoryTransactionTypes', 'transactiontypeid'), COALESCE(MAX(transactionTypeId), 1), TRUE) FROM InventoryTransactionTypes;
SELECT setval(pg_get_serial_sequence('Suppliers', 'supplierid'), COALESCE(MAX(supplierId), 1), TRUE) FROM Suppliers;
SELECT setval(pg_get_serial_sequence('ProductTypes', 'producttypeid'), COALESCE(MAX(productTypeId), 1), TRUE) FROM ProductTypes;
SELECT setval(pg_get_serial_sequence('Products', 'productid'), COALESCE(MAX(productId), 1), TRUE) FROM Products;
SELECT setval(pg_get_serial_sequence('Warehouses', 'warehouseid'), COALESCE(MAX(warehouseId), 1), TRUE) FROM Warehouses;
