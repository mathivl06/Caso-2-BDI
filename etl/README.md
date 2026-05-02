# Python ETL

Este ETL cruza datos de:

* Etheria Global en PostgreSQL
* Dynamic Brands en MySQL
* DynamicBrandsDW en PostgreSQL

El proceso es `full refresh`: limpia y recarga las tablas analiticas `EtheriaSupplyCosts`, `DynamicSales` y `DashboardProfitability`.

No crea tablas de auditoria, logging, staging ni control dentro del Data Warehouse.

## Ejecucion con Docker

```bash
docker compose -f docker/docker-compose.yml up --build etl
```

## Ejecucion local

```bash
pip install -r etl/requirements.txt
python etl/etl.py
```

## Variables principales

* `BASE_CURRENCY`: moneda base para el dashboard. Default: `USD`.
* `IMPORT_FEE_RATE`: porcentaje usado para permisos/aranceles cuando no existe una tabla fuente de permisos. Default: `0.10`.
* `ALLOW_MISSING_RATES`: si es `true`, no falla cuando falta una tasa de cambio y usa el monto original. Default: `false`.
* `ALLOW_MISSING_PRICES`: si es `true`, no falla cuando una linea de orden no tiene `unitPriceLocal`. Default: `false`.

## Conexiones

El ETL usa estos prefijos de variables:

* `ETHERIA_PG_*`: conexion a PostgreSQL Etheria.
* `DYNAMIC_MYSQL_*`: conexion a MySQL Dynamic Brands.
* `DW_PG_*`: conexion a PostgreSQL Data Warehouse.
