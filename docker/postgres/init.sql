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

-- Paises base: hub, origenes y destinos de prueba
INSERT INTO Countries (countryId, countryName)
VALUES
    (1, 'Nicaragua'),
    (2, 'Morocco'),
    (3, 'Bulgaria'),
    (4, 'Peru'),
    (5, 'Mexico'),
    (6, 'Colombia'),
    (7, 'Costa Rica'),
    (8, 'Chile')
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
VALUES
    (1, 'Default Supplier', 1, 1, 1),
    (2, 'Atlas Botanicals', 1, 2, 1),
    (3, 'Balkan Lavender Co', 1, 3, 1),
    (4, 'Andean Naturals', 1, 4, 1),
    (5, 'Meso Skin Labs', 1, 5, 1)
ON CONFLICT (supplierId) DO NOTHING;

INSERT INTO ProductTypes (productTypeId, productTypeName)
VALUES
    (1, 'General'),
    (2, 'Aceites'),
    (3, 'Cosmetica dermatologica'),
    (4, 'Aromaterapia'),
    (5, 'Bebidas naturales')
ON CONFLICT (productTypeId) DO NOTHING;

INSERT INTO Products (productId, externalProductId, productName, productTypeId)
VALUES
    (1, 'EXT-001', 'Sample Product', 1),
    (2, 'OIL-ARG-001', 'Aceite esencial de argan bulk', 2),
    (3, 'OIL-LAV-002', 'Aceite esencial de lavanda bulk', 2),
    (4, 'SKN-ALOE-001', 'Serum dermatologico de aloe bulk', 3),
    (5, 'ARO-EUC-001', 'Blend aromaterapia eucalipto bulk', 4),
    (6, 'BEV-MACA-001', 'Bebida natural de maca bulk', 5)
ON CONFLICT (productId) DO NOTHING;

INSERT INTO Warehouses (warehouseId, warehouseName, addressId, createdBy)
VALUES (1, 'Main Warehouse', 1, 1)
ON CONFLICT (warehouseId) DO NOTHING;

-- =========================================
-- 3. DATOS TRANSACCIONALES PARA PRUEBA ETL
-- =========================================
-- Fechas alineadas con las ventas de Dynamic Brands para que el cruce
-- category + year + month + ISO week produzca costos y margen.

INSERT INTO ImportOrders
    (importOrderId, importOrderNumber, supplierId, orderDate, expectedArrivalDate, actualArrivalDate, totalCost, currencyId, statusId, paymentStatus, createdBy)
VALUES
    (1, 'EG-IMP-2026-0001', 1, '2026-02-05 08:00:00', '2026-02-10', '2026-02-09 14:00:00', 240.00, 1, 1, 'PAID', 1),
    (2, 'EG-IMP-2026-0002', 2, '2026-02-05 08:30:00', '2026-02-10', '2026-02-09 14:30:00', 345.00, 1, 1, 'PAID', 1),
    (3, 'EG-IMP-2026-0003', 2, '2026-02-12 09:00:00', '2026-02-17', '2026-02-16 14:00:00', 345.00, 1, 1, 'PAID', 1),
    (4, 'EG-IMP-2026-0004', 3, '2026-02-19 09:30:00', '2026-02-24', '2026-02-23 15:00:00', 216.00, 1, 1, 'PAID', 1),
    (5, 'EG-IMP-2026-0005', 5, '2026-03-04 10:00:00', '2026-03-09', '2026-03-08 13:00:00', 390.00, 1, 1, 'PAID', 1),
    (6, 'EG-IMP-2026-0006', 3, '2026-03-11 10:30:00', '2026-03-16', '2026-03-15 13:30:00', 195.00, 1, 1, 'PAID', 1),
    (7, 'EG-IMP-2026-0007', 4, '2026-03-18 11:00:00', '2026-03-23', '2026-03-22 12:00:00', 144.00, 1, 1, 'PAID', 1)
ON CONFLICT (importOrderId) DO NOTHING;

INSERT INTO ImportOrderDetails
    (importOrderDetailId, importOrderId, productId, quantity, unitCost, currencyId, lineTotal, status)
VALUES
    (1, 1, 1, 30, 8.0000, 1, 240.00, 'RECEIVED'),
    (2, 2, 2, 30, 11.5000, 1, 345.00, 'RECEIVED'),
    (3, 3, 2, 30, 11.5000, 1, 345.00, 'RECEIVED'),
    (4, 4, 3, 30, 7.2000, 1, 216.00, 'RECEIVED'),
    (5, 5, 4, 30, 13.0000, 1, 390.00, 'RECEIVED'),
    (6, 6, 5, 30, 6.5000, 1, 195.00, 'RECEIVED'),
    (7, 7, 6, 30, 4.8000, 1, 144.00, 'RECEIVED')
ON CONFLICT (importOrderDetailId) DO NOTHING;

INSERT INTO Batches
    (batchId, batchNumber, importOrderId, productId, quantityReceived, quantityExpected, unitCost, currencyId, expirationDate, receivedAt, receivedBy)
VALUES
    (1, 'BATCH-EXT-001-20260205', 1, 1, 30, 30, 8.0000, 1, '2027-02-05', '2026-02-09 14:30:00', 1),
    (2, 'BATCH-OIL-ARG-20260205', 2, 2, 30, 30, 11.5000, 1, '2027-02-05', '2026-02-09 15:00:00', 1),
    (3, 'BATCH-OIL-ARG-20260212', 3, 2, 30, 30, 11.5000, 1, '2027-02-12', '2026-02-16 14:30:00', 1),
    (4, 'BATCH-OIL-LAV-20260219', 4, 3, 30, 30, 7.2000, 1, '2027-02-19', '2026-02-23 15:30:00', 1),
    (5, 'BATCH-SKN-ALOE-20260304', 5, 4, 30, 30, 13.0000, 1, '2027-03-04', '2026-03-08 13:30:00', 1),
    (6, 'BATCH-ARO-EUC-20260311', 6, 5, 30, 30, 6.5000, 1, '2027-03-11', '2026-03-15 14:00:00', 1),
    (7, 'BATCH-BEV-MACA-20260318', 7, 6, 30, 30, 4.8000, 1, '2027-03-18', '2026-03-22 12:30:00', 1)
ON CONFLICT (batchId) DO NOTHING;

INSERT INTO DispatchOrders
    (dispatchOrderId, dispatchOrderNumber, destinationCountryId, dispatchDate, expectedDeliveryDate, statusId, createdBy)
VALUES
    (1, 'EG-DSP-CO-0001', 6, '2026-02-05 12:00:00', '2026-02-08', 1, 1),
    (2, 'EG-DSP-CO-0002', 6, '2026-02-12 12:00:00', '2026-02-15', 1, 1),
    (3, 'EG-DSP-PE-0001', 4, '2026-02-19 12:00:00', '2026-02-22', 1, 1),
    (4, 'EG-DSP-MX-0001', 5, '2026-03-04 12:00:00', '2026-03-07', 1, 1),
    (5, 'EG-DSP-CR-0001', 7, '2026-03-11 12:00:00', '2026-03-14', 1, 1),
    (6, 'EG-DSP-CL-0001', 8, '2026-03-18 12:00:00', '2026-03-21', 1, 1)
ON CONFLICT (dispatchOrderId) DO NOTHING;

INSERT INTO DispatchOrderDetails
    (dispatchOrderDetailId, dispatchOrderId, batchId, quantityDispatched)
VALUES
    (1, 1, 1, 1),
    (2, 1, 2, 2),
    (3, 2, 3, 2),
    (4, 3, 4, 3),
    (5, 4, 5, 2),
    (6, 5, 6, 3),
    (7, 6, 7, 3)
ON CONFLICT (dispatchOrderDetailId) DO NOTHING;

INSERT INTO CourierServices
    (courierServiceId, courierName, addressId, createdBy)
VALUES
    (1, 'Latam Express Logistics', 1, 1),
    (2, 'Andes Courier Service', 1, 1)
ON CONFLICT (courierServiceId) DO NOTHING;

INSERT INTO ShipmentStatusCatalog (statusId, code, name, isFinal)
VALUES
    (1, 'IN_TRANSIT', 'In Transit', FALSE),
    (2, 'DELIVERED', 'Delivered', TRUE)
ON CONFLICT (statusId) DO NOTHING;

INSERT INTO Shipments
    (shipmentId, shipmentNumber, dispatchOrderId, courierServiceId, trackingNumber, shipmentDate, estimatedDeliveryDate, actualDeliveryDate, shippingCost, currencyId, statusId, createdBy)
VALUES
    (1, 'EG-SHP-CO-0001', 1, 1, 'EGTRK-CO-0001', '2026-02-05 15:00:00', '2026-02-08', '2026-02-08 10:00:00', 18.00, 1, 2, 1),
    (2, 'EG-SHP-CO-0002', 2, 1, 'EGTRK-CO-0002', '2026-02-12 15:00:00', '2026-02-15', NULL, 12.00, 1, 1, 1),
    (3, 'EG-SHP-PE-0001', 3, 2, 'EGTRK-PE-0001', '2026-02-19 15:00:00', '2026-02-22', '2026-02-22 11:00:00', 16.00, 1, 2, 1),
    (4, 'EG-SHP-MX-0001', 4, 1, 'EGTRK-MX-0001', '2026-03-04 15:00:00', '2026-03-07', '2026-03-07 09:30:00', 22.00, 1, 2, 1),
    (5, 'EG-SHP-CR-0001', 5, 2, 'EGTRK-CR-0001', '2026-03-11 15:00:00', '2026-03-14', NULL, 10.00, 1, 1, 1),
    (6, 'EG-SHP-CL-0001', 6, 1, 'EGTRK-CL-0001', '2026-03-18 15:00:00', '2026-03-21', '2026-03-21 12:00:00', 24.00, 1, 2, 1)
ON CONFLICT (shipmentId) DO NOTHING;

-- Ajustar secuencias despues de insertar IDs explicitos.
SELECT setval(pg_get_serial_sequence('persons', 'personid'), COALESCE(MAX(personId), 1), TRUE) FROM Persons;
SELECT setval(pg_get_serial_sequence('countries', 'countryid'), COALESCE(MAX(countryId), 1), TRUE) FROM Countries;
SELECT setval(pg_get_serial_sequence('currencies', 'currencyid'), COALESCE(MAX(currencyId), 1), TRUE) FROM Currencies;
SELECT setval(pg_get_serial_sequence('states', 'stateid'), COALESCE(MAX(stateId), 1), TRUE) FROM States;
SELECT setval(pg_get_serial_sequence('cities', 'cityid'), COALESCE(MAX(cityId), 1), TRUE) FROM Cities;
SELECT setval(pg_get_serial_sequence('addresses', 'addressid'), COALESCE(MAX(addressId), 1), TRUE) FROM Addresses;
SELECT setval(pg_get_serial_sequence('importorderstatuscatalog', 'statusid'), COALESCE(MAX(statusId), 1), TRUE) FROM ImportOrderStatusCatalog;
SELECT setval(pg_get_serial_sequence('dispatchorderstatuscatalog', 'statusid'), COALESCE(MAX(statusId), 1), TRUE) FROM DispatchOrderStatusCatalog;
SELECT setval(pg_get_serial_sequence('inventorytransactiontypes', 'transactiontypeid'), COALESCE(MAX(transactionTypeId), 1), TRUE) FROM InventoryTransactionTypes;
SELECT setval(pg_get_serial_sequence('suppliers', 'supplierid'), COALESCE(MAX(supplierId), 1), TRUE) FROM Suppliers;
SELECT setval(pg_get_serial_sequence('producttypes', 'producttypeid'), COALESCE(MAX(productTypeId), 1), TRUE) FROM ProductTypes;
SELECT setval(pg_get_serial_sequence('products', 'productid'), COALESCE(MAX(productId), 1), TRUE) FROM Products;
SELECT setval(pg_get_serial_sequence('warehouses', 'warehouseid'), COALESCE(MAX(warehouseId), 1), TRUE) FROM Warehouses;
SELECT setval(pg_get_serial_sequence('importorders', 'importorderid'), COALESCE(MAX(importOrderId), 1), TRUE) FROM ImportOrders;
SELECT setval(pg_get_serial_sequence('importorderdetails', 'importorderdetailid'), COALESCE(MAX(importOrderDetailId), 1), TRUE) FROM ImportOrderDetails;
SELECT setval(pg_get_serial_sequence('batches', 'batchid'), COALESCE(MAX(batchId), 1), TRUE) FROM Batches;
SELECT setval(pg_get_serial_sequence('dispatchorders', 'dispatchorderid'), COALESCE(MAX(dispatchOrderId), 1), TRUE) FROM DispatchOrders;
SELECT setval(pg_get_serial_sequence('dispatchorderdetails', 'dispatchorderdetailid'), COALESCE(MAX(dispatchOrderDetailId), 1), TRUE) FROM DispatchOrderDetails;
SELECT setval(pg_get_serial_sequence('courierservices', 'courierserviceid'), COALESCE(MAX(courierServiceId), 1), TRUE) FROM CourierServices;
SELECT setval(pg_get_serial_sequence('shipmentstatuscatalog', 'statusid'), COALESCE(MAX(statusId), 1), TRUE) FROM ShipmentStatusCatalog;
SELECT setval(pg_get_serial_sequence('shipments', 'shipmentid'), COALESCE(MAX(shipmentId), 1), TRUE) FROM Shipments;
