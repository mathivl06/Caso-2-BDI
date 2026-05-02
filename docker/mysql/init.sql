-- Crear tablas de Dynamic Brands
SOURCE /scripts/dynamicBrands.sql;

-- =========================================
-- DATOS BASE PARA PRUEBAS DEL ETL
-- =========================================
-- Estos datos permiten probar ventas por pais, sitio, marca y categoria.
-- El ETL convierte las ventas locales a USD usando ExchangeRates.

USE DynamicBrandsDB;

-- ========================
-- USERS & SECURITY
-- ========================

INSERT IGNORE INTO Users
    (userId, name, lastName1, lastName2, email, passwordHash, status)
VALUES
    (1, 'System', 'Admin', NULL, 'system@dynamic.local', 'not-used-for-seed', 'ACTIVE'),
    (2, 'Marketing', 'Manager', NULL, 'marketing@dynamic.local', 'not-used-for-seed', 'ACTIVE');

INSERT IGNORE INTO Roles (roleId, name)
VALUES
    (1, 'ADMIN'),
    (2, 'MARKETING_MANAGER');

INSERT IGNORE INTO Permissions (permissionId, code)
VALUES
    (1, 'SITE_MANAGE'),
    (2, 'ORDER_VIEW'),
    (3, 'PRODUCT_MANAGE');

INSERT IGNORE INTO UserRoles (userId, roleId, assignedBy)
VALUES
    (1, 1, 1),
    (2, 2, 1);

INSERT IGNORE INTO RolePermissions (roleId, permissionId, grantedBy)
VALUES
    (1, 1, 1),
    (1, 2, 1),
    (1, 3, 1),
    (2, 1, 1),
    (2, 2, 1);

-- ========================
-- LOCATION & CURRENCY
-- ========================

INSERT IGNORE INTO Countries (countryId, name, isoCode)
VALUES
    (1, 'Colombia', 'CO'),
    (2, 'Peru', 'PE'),
    (3, 'Mexico', 'MX'),
    (4, 'Costa Rica', 'CR'),
    (5, 'Chile', 'CL');

INSERT IGNORE INTO Currencies
    (currencyId, code, symbol, name, baseCurrency, enabled, countryId)
VALUES
    (1, 'USD', '$', 'US Dollar', TRUE, TRUE, NULL),
    (2, 'COP', '$', 'Colombian Peso', FALSE, TRUE, 1),
    (3, 'PEN', 'S/', 'Peruvian Sol', FALSE, TRUE, 2),
    (4, 'MXN', '$', 'Mexican Peso', FALSE, TRUE, 3),
    (5, 'CRC', 'CRC', 'Costa Rican Colon', FALSE, TRUE, 4),
    (6, 'CLP', '$', 'Chilean Peso', FALSE, TRUE, 5);

INSERT IGNORE INTO ExchangeRates
    (exchangeRateId, fromCurrencyId, toCurrencyId, rate, effectiveDate, expiryDate, source, createdBy)
VALUES
    (1, 2, 1, 0.000250, '2026-01-01', NULL, 'seed', 1),
    (2, 3, 1, 0.270000, '2026-01-01', NULL, 'seed', 1),
    (3, 4, 1, 0.058000, '2026-01-01', NULL, 'seed', 1),
    (4, 5, 1, 0.001950, '2026-01-01', NULL, 'seed', 1),
    (5, 6, 1, 0.001050, '2026-01-01', NULL, 'seed', 1);

-- ========================
-- SITES & BRANDING
-- ========================

INSERT IGNORE INTO Sites
    (siteId, name, url, countryId, currencyId, isActive, validFrom, createdBy)
VALUES
    (1, 'Auralis Colombia', 'https://co.auralis.example', 1, 2, TRUE, '2026-01-01', 2),
    (2, 'Nativa Colombia', 'https://co.nativa.example', 1, 2, TRUE, '2026-01-01', 2),
    (3, 'Andes Glow Peru', 'https://pe.andesglow.example', 2, 3, TRUE, '2026-01-01', 2),
    (4, 'Luma Verde Peru', 'https://pe.lumaverde.example', 2, 3, TRUE, '2026-01-01', 2),
    (5, 'Solara Mexico', 'https://mx.solara.example', 3, 4, TRUE, '2026-01-01', 2),
    (6, 'Raiz Viva Mexico', 'https://mx.raizviva.example', 3, 4, TRUE, '2026-01-01', 2),
    (7, 'Pura Botanica CR', 'https://cr.purabotanica.example', 4, 5, TRUE, '2026-01-01', 2),
    (8, 'Selva Skin CR', 'https://cr.selvaskin.example', 4, 5, TRUE, '2026-01-01', 2),
    (9, 'Pacifica Chile', 'https://cl.pacifica.example', 5, 6, TRUE, '2026-01-01', 2);

INSERT IGNORE INTO ConfigKeys (keyId, name, groupName)
VALUES
    (1, 'logoPrompt', 'branding'),
    (2, 'marketingFocus', 'branding'),
    (3, 'tone', 'branding');

INSERT IGNORE INTO SiteBrandingConfig (configId, siteId, keyId, value)
VALUES
    (1, 1, 1, 'minimal golden oil drop'),
    (2, 1, 2, 'premium wellness'),
    (3, 3, 2, 'natural skincare'),
    (4, 5, 2, 'urban healthy lifestyle'),
    (5, 7, 2, 'tropical botanicals'),
    (6, 9, 2, 'coastal self-care');

-- ========================
-- PRODUCTS
-- ========================

INSERT IGNORE INTO ProductCategories (categoryId, name)
VALUES
    (1, 'General'),
    (2, 'Aceites'),
    (3, 'Cosmetica dermatologica'),
    (4, 'Aromaterapia'),
    (5, 'Bebidas naturales');

INSERT IGNORE INTO Brands (brandId, siteId, brandName)
VALUES
    (1, 1, 'Auralis'),
    (2, 2, 'Nativa Lux'),
    (3, 3, 'Andes Glow'),
    (4, 4, 'Luma Verde'),
    (5, 5, 'Solara'),
    (6, 6, 'Raiz Viva'),
    (7, 7, 'Pura Botanica'),
    (8, 8, 'Selva Skin'),
    (9, 9, 'Pacifica');

INSERT IGNORE INTO Products
    (productId, externalProductId, productName, categoryId, brandId, baseCost, baseCurrencyId, createdBy)
VALUES
    (1, 'EXT-001', 'Sample Product', 1, 1, 8.00, 1, 2),
    (2, 'OIL-ARG-001', 'Aceite esencial de argan', 2, 1, 11.50, 1, 2),
    (3, 'OIL-LAV-002', 'Aceite esencial de lavanda', 2, 3, 7.20, 1, 2),
    (4, 'SKN-ALOE-001', 'Serum dermatologico de aloe', 3, 5, 13.00, 1, 2),
    (5, 'ARO-EUC-001', 'Blend aromaterapia eucalipto', 4, 7, 6.50, 1, 2),
    (6, 'BEV-MACA-001', 'Bebida natural de maca', 5, 9, 4.80, 1, 2);

INSERT IGNORE INTO ProductPrices
    (priceId, productId, siteId, priceLocal, currencyId, exchangeRateId, validFrom, createdBy)
VALUES
    (1, 1, 1, 98000.00, 2, 1, '2026-01-01', 2),
    (2, 2, 1, 128000.00, 2, 1, '2026-01-01', 2),
    (3, 2, 2, 136000.00, 2, 1, '2026-01-01', 2),
    (4, 3, 3, 118.00, 3, 2, '2026-01-01', 2),
    (5, 3, 4, 112.00, 3, 2, '2026-01-01', 2),
    (6, 4, 5, 820.00, 4, 3, '2026-01-01', 2),
    (7, 4, 6, 790.00, 4, 3, '2026-01-01', 2),
    (8, 5, 7, 24500.00, 5, 4, '2026-01-01', 2),
    (9, 5, 8, 26500.00, 5, 4, '2026-01-01', 2),
    (10, 6, 9, 32900.00, 6, 5, '2026-01-01', 2);

INSERT IGNORE INTO AttributeKeyGroups (groupId, groupName, description)
VALUES
    (1, 'wellness', 'Atributos funcionales del producto');

INSERT IGNORE INTO AttributeKeys (keyId, groupId, name, dataType, unit)
VALUES
    (1, 1, 'beneficio', 'string', NULL),
    (2, 1, 'aroma', 'string', NULL);

INSERT IGNORE INTO ProductAttributes (attributeId, productId, keyId, value)
VALUES
    (1, 2, 1, 'hidratacion premium'),
    (2, 3, 2, 'lavanda floral'),
    (3, 4, 1, 'cuidado de piel sensible'),
    (4, 5, 2, 'eucalipto fresco');

-- ========================
-- CUSTOMERS & ORDERS
-- ========================

INSERT IGNORE INTO Customers
    (customerId, siteId, userId, firstName, lastName)
VALUES
    (1, 1, NULL, 'Laura', 'Gomez'),
    (2, 2, NULL, 'Camila', 'Restrepo'),
    (3, 3, NULL, 'Valeria', 'Quispe'),
    (4, 5, NULL, 'Sofia', 'Hernandez'),
    (5, 7, NULL, 'Mariana', 'Solano'),
    (6, 9, NULL, 'Isidora', 'Rojas');

INSERT IGNORE INTO ContactTypes (contactTypeId, code, name)
VALUES
    (1, 'EMAIL', 'Email'),
    (2, 'PHONE', 'Phone');

INSERT IGNORE INTO CustomerContacts (contactId, customerId, contactTypeId, value, isPrimary)
VALUES
    (1, 1, 1, 'laura@example.com', TRUE),
    (2, 2, 1, 'camila@example.com', TRUE),
    (3, 3, 1, 'valeria@example.com', TRUE),
    (4, 4, 1, 'sofia@example.com', TRUE),
    (5, 5, 1, 'mariana@example.com', TRUE),
    (6, 6, 1, 'isidora@example.com', TRUE);

INSERT IGNORE INTO OrderStatusCatalog (statusId, code, description)
VALUES
    (1, 'PAID', 'Paid order'),
    (2, 'SHIPPED', 'Shipped order'),
    (3, 'DELIVERED', 'Delivered order');

INSERT IGNORE INTO Orders
    (orderId, orderNumber, siteId, customerId, currencyId, exchangeRateId, statusId, totalLocal, totalInBase, createdAt, createdBy)
VALUES
    (1, 'DB-CO-0001', 1, 1, 2, 1, 3, 354000.00, 88.50, '2026-02-05 10:15:00', 2),
    (2, 'DB-CO-0002', 2, 2, 2, 1, 2, 272000.00, 68.00, '2026-02-12 16:35:00', 2),
    (3, 'DB-PE-0001', 3, 3, 3, 2, 3, 354.00, 95.58, '2026-02-19 09:20:00', 2),
    (4, 'DB-MX-0001', 5, 4, 4, 3, 3, 1640.00, 95.12, '2026-03-04 13:10:00', 2),
    (5, 'DB-CR-0001', 7, 5, 5, 4, 2, 73500.00, 143.33, '2026-03-11 18:45:00', 2),
    (6, 'DB-CL-0001', 9, 6, 6, 5, 3, 98700.00, 103.64, '2026-03-18 11:05:00', 2);

INSERT IGNORE INTO OrderItems
    (orderItemId, orderId, productId, quantity, productName, unitPriceLocal)
VALUES
    (1, 1, 1, 1, 'Sample Product', 98000.00),
    (2, 1, 2, 2, 'Aceite esencial de argan', 128000.00),
    (3, 2, 2, 2, 'Aceite esencial de argan', 136000.00),
    (4, 3, 3, 3, 'Aceite esencial de lavanda', 118.00),
    (5, 4, 4, 2, 'Serum dermatologico de aloe', 820.00),
    (6, 5, 5, 3, 'Blend aromaterapia eucalipto', 24500.00),
    (7, 6, 6, 3, 'Bebida natural de maca', 32900.00);

-- ========================
-- PAYMENTS, SHIPPING & RESTRICTIONS
-- ========================

INSERT IGNORE INTO PaymentMethods (methodId, code, description)
VALUES
    (1, 'CARD', 'Credit card'),
    (2, 'WALLET', 'Digital wallet');

INSERT IGNORE INTO PaymentStatusCatalog (statusId, code, description)
VALUES
    (1, 'APPROVED', 'Approved payment');

INSERT IGNORE INTO Payments
    (paymentId, orderId, methodId, amount, currencyId, exchangeRateId, statusId, processedAt)
VALUES
    (1, 1, 1, 354000.00, 2, 1, 1, '2026-02-05 10:16:00'),
    (2, 2, 1, 272000.00, 2, 1, 1, '2026-02-12 16:36:00'),
    (3, 3, 2, 354.00, 3, 2, 1, '2026-02-19 09:21:00'),
    (4, 4, 1, 1640.00, 4, 3, 1, '2026-03-04 13:11:00'),
    (5, 5, 2, 73500.00, 5, 4, 1, '2026-03-11 18:46:00'),
    (6, 6, 1, 98700.00, 6, 5, 1, '2026-03-18 11:06:00');

INSERT IGNORE INTO Couriers (courierId, courierName)
VALUES
    (1, 'Latam Express'),
    (2, 'Andes Courier');

INSERT IGNORE INTO ShipmentStatusCatalog (statusId, code, description)
VALUES
    (1, 'IN_TRANSIT', 'Shipment in transit'),
    (2, 'DELIVERED', 'Shipment delivered');

INSERT IGNORE INTO Shipments
    (shipmentId, orderId, courierId, trackingNumber, statusId, createdAt)
VALUES
    (1, 1, 1, 'TRK-CO-0001', 2, '2026-02-06 08:00:00'),
    (2, 2, 1, 'TRK-CO-0002', 1, '2026-02-13 08:00:00'),
    (3, 3, 2, 'TRK-PE-0001', 2, '2026-02-20 08:00:00'),
    (4, 4, 1, 'TRK-MX-0001', 2, '2026-03-05 08:00:00'),
    (5, 5, 2, 'TRK-CR-0001', 1, '2026-03-12 08:00:00'),
    (6, 6, 1, 'TRK-CL-0001', 2, '2026-03-19 08:00:00');

INSERT IGNORE INTO RestrictionReasonsCatalog (reasonId, code, description)
VALUES
    (1, 'HEALTH_LABEL', 'Requires health label validation');

INSERT IGNORE INTO ProductRestrictions (restrictionId, productId, countryId, reasonId)
VALUES
    (1, 4, 1, 1),
    (2, 5, 2, 1);
