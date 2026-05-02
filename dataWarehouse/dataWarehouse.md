# Data Warehouse Design - Dynamic Brands + Etheria Global

* Database engine: PostgreSQL
* Database name: DynamicBrandsDW
* Context: Data Warehouse orientado a analisis estrategico. Contiene datos agregados provenientes de Dynamic Brands (ventas) y Etheria Global (costos).
* El DW no contiene tablas de auditoria, logging, control de ejecucion ni staging. Esas responsabilidades quedan fuera del modelo analitico y se manejan desde el proceso ETL en Python.

---

# Tables

## EtheriaSupplyCosts

* productCategory: VARCHAR(100) NOT NULL
* countryOrigin: VARCHAR(50) NOT NULL
* costType: VARCHAR(50) NOT NULL
* importCost: DECIMAL(14,2) NOT NULL
* shippingCost: DECIMAL(14,2) NOT NULL
* importFees: DECIMAL(14,2) NOT NULL
* totalSupplyCost: DECIMAL(14,2) NOT NULL
* monthName: VARCHAR(20) NOT NULL
* year: INT NOT NULL
* weekNumber: INT NOT NULL
* PRIMARY KEY (productCategory, countryOrigin, costType, year, monthName, weekNumber)

## DynamicSales

* productCategory: VARCHAR(100) NOT NULL
* brandName: VARCHAR(100) NOT NULL
* siteName: VARCHAR(100) NOT NULL
* countryDestination: VARCHAR(50) NOT NULL
* totalSales: DECIMAL(14,2) NOT NULL
* productCost: DECIMAL(14,2) NOT NULL
* supplyCost: DECIMAL(14,2) NOT NULL
* totalCost: DECIMAL(14,2) NOT NULL
* totalProfit: DECIMAL(14,2) NOT NULL
* monthName: VARCHAR(20) NOT NULL
* year: INT NOT NULL
* weekNumber: INT NOT NULL
* PRIMARY KEY (productCategory, brandName, siteName, countryDestination, year, monthName, weekNumber)

## DashboardProfitability

Tabla centralizada para consumo directo del dashboard gerencial.

* productCategory: VARCHAR(100) NOT NULL
* brandName: VARCHAR(100) NOT NULL
* siteName: VARCHAR(100) NOT NULL
* countryOrigin: VARCHAR(50) NOT NULL
* countryDestination: VARCHAR(50) NOT NULL
* totalSales: DECIMAL(14,2) NOT NULL
* importCost: DECIMAL(14,2) NOT NULL
* shippingCost: DECIMAL(14,2) NOT NULL
* importFees: DECIMAL(14,2) NOT NULL
* productCost: DECIMAL(14,2) NOT NULL
* totalCost: DECIMAL(14,2) NOT NULL
* totalProfit: DECIMAL(14,2) NOT NULL
* profitMargin: DECIMAL(8,4) NOT NULL
* monthName: VARCHAR(20) NOT NULL
* year: INT NOT NULL
* weekNumber: INT NOT NULL
* PRIMARY KEY (productCategory, brandName, siteName, countryOrigin, countryDestination, year, monthName, weekNumber)

---

# Integration Logic

El ETL carga primero `EtheriaSupplyCosts` y `DynamicSales`, y luego materializa `DashboardProfitability` para evitar joins complejos desde el dashboard.

La integracion base se realiza mediante:

* productCategory
* year
* monthName
* weekNumber

Cuando hay multiples paises de origen para una categoria y periodo, el ETL distribuye ventas y costos por participacion proporcional para que las sumas de `DashboardProfitability` no dupliquen ingresos.

---

# Recommended Dashboard Queries

```sql
-- Rentabilidad por categoria
SELECT
    productCategory,
    SUM(totalSales) AS sales,
    SUM(totalCost) AS cost,
    SUM(totalProfit) AS profit,
    ROUND(SUM(totalProfit) * 100.0 / NULLIF(SUM(totalSales), 0), 2) AS margin_pct
FROM DashboardProfitability
GROUP BY productCategory
ORDER BY profit DESC;

-- Marca IA mas efectiva
SELECT
    brandName,
    SUM(totalSales) AS sales,
    SUM(totalProfit) AS profit,
    ROUND(SUM(totalProfit) * 100.0 / NULLIF(SUM(totalSales), 0), 2) AS margin_pct
FROM DashboardProfitability
GROUP BY brandName
ORDER BY profit DESC;

-- Margen por pais considerando envio y permisos
SELECT
    countryDestination,
    SUM(totalSales) AS sales,
    SUM(productCost + importCost + shippingCost + importFees) AS cost,
    SUM(totalProfit) AS profit,
    ROUND(SUM(totalProfit) * 100.0 / NULLIF(SUM(totalSales), 0), 2) AS margin_pct
FROM DashboardProfitability
GROUP BY countryDestination
ORDER BY margin_pct DESC;
```

---

# Required Data From OLTP Systems

## Etheria Global debe proveer

* productCategory
* countryOrigin (desde supplier)
* importCost, shippingCost e importFees convertidos a USD
* fechas (para monthName, year, weekNumber)

## Dynamic Brands debe proveer

* productCategory
* brandName (desde Brands)
* siteName (desde Sites)
* countryDestination (desde Sites -> Countries)
* ventas convertidas a USD
* costos de producto convertidos a USD
* fechas (Orders.createdAt)

---

# Notes

* Todas las metricas monetarias se cargan en USD como moneda base.
* No hay datos transaccionales, solo agregados.
* El dashboard debe leer principalmente de `DashboardProfitability`.
* Si no existe una tabla fuente para permisos/aranceles, el ETL aplica una regla parametrizable por porcentaje sobre el costo de importacion.
