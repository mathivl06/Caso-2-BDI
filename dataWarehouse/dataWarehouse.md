# Data Warehouse Design - Dynamic Brands + Etheria Global

* Database engine: PostgreSQL

* Database name: DynamicBrandsDW

* Context: Data Warehouse orientado a análisis estratégico. Contiene datos agregados (no transaccionales) provenientes de Dynamic Brands (ventas) y Etheria Global (costos). La información se maneja a nivel resumido por categoría de producto y periodo de tiempo.

---

# Tables:

## EtheriaSupplyCosts

* productCategory: VARCHAR(100) NOT NULL

* countryOrigin: VARCHAR(50) NOT NULL

* costType: VARCHAR(50) NOT NULL

* monthName: VARCHAR(20) NOT NULL

* year: INT NOT NULL

* weekNumber: INT NOT NULL

* totalCost: DECIMAL(14,2) NOT NULL

* quantityUnits: INT NOT NULL

* createdAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP

* PRIMARY KEY (productCategory, countryOrigin, costType, year, monthName, weekNumber)

---

## DynamicSales

* productCategory: VARCHAR(100) NOT NULL

* brandName: VARCHAR(100) NOT NULL

* siteName: VARCHAR(100) NOT NULL

* countryDestination: VARCHAR(50) NOT NULL

* monthName: VARCHAR(20) NOT NULL

* year: INT NOT NULL

* weekNumber: INT NOT NULL

* totalSales: DECIMAL(14,2) NOT NULL

* totalCost: DECIMAL(14,2) NOT NULL

* totalProfit: DECIMAL(14,2) NOT NULL

* createdAt: TIMESTAMP DEFAULT CURRENT_TIMESTAMP

* PRIMARY KEY (productCategory, brandName, siteName, countryDestination, year, monthName, weekNumber)

---

# Join Logic:

Las tablas se integran mediante:

* productCategory
* year
* monthName
* weekNumber

---

# Example Query:

```sql
SELECT 
    d.productCategory,
    d.brandName,
    d.siteName,
    d.countryDestination,
    e.countryOrigin,
    d.year,
    d.monthName,
    d.weekNumber,

    e.totalCost AS supplyCost,
    d.totalSales,
    d.totalProfit

FROM DynamicSales d
LEFT JOIN EtheriaSupplyCosts e
    ON d.productCategory = e.productCategory
    AND d.year = e.year
    AND d.monthName = e.monthName
    AND d.weekNumber = e.weekNumber;
```

---

# Required Data From OLTP Systems:

## Etheria Global debe proveer:

* productCategory
* countryOrigin (desde supplier)
* costType
* costos convertidos a moneda base
* fechas (para monthName, year, weekNumber)

## Dynamic Brands debe proveer:

* productCategory
* brandName (desde Brands)
* siteName (desde Sites)
* countryDestination (desde Sites → Countries)
* ventas en moneda base
* costos en moneda base
* fechas (Orders.createdAt)

---

# Notes:

* Todas las métricas están en moneda base (no se usa USD en nombres)
* No hay datos transaccionales, solo agregados
* Máximo 2 tablas, desnormalizadas
* El cruce se hace por categoría + tiempo

---
