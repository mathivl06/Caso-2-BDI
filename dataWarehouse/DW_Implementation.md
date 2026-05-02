# Data Warehouse ETL Implementation

## Arquitectura

El cruce entre motores se hace desde `etl/etl.py`:

* Lee costos de Etheria Global desde PostgreSQL.
* Lee ventas de Dynamic Brands desde MySQL.
* Convierte montos a USD.
* Carga el Data Warehouse en PostgreSQL.

El Data Warehouse no guarda datos tecnicos del ETL. Solo contiene tablas analiticas para dashboard.

## Tablas cargadas

* `EtheriaSupplyCosts`: costos agregados por categoria, pais origen y periodo.
* `DynamicSales`: ventas agregadas por categoria, marca, sitio, pais destino y periodo.
* `DashboardProfitability`: tabla central para dashboard con ventas, costos, utilidad y margen.

## Politica de carga

La primera version usa `full refresh`:

1. Extrae datos de ambas fuentes.
2. Agrega y transforma en memoria.
3. Limpia las tres tablas del DW.
4. Inserta los resultados finales.

Esto evita tablas de staging dentro del Data Warehouse y mantiene el modelo limpio para consumo gerencial.

## Permisos y aranceles

Como el modelo fuente no tiene una tabla especifica de permisos o aranceles, el ETL aplica `IMPORT_FEE_RATE` sobre el costo de importacion. El valor por defecto es `0.10`, configurable por variable de entorno.
