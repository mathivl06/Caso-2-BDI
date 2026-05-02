# Caso-2-BDI

Repositorio para el caso #2 del curso Bases de Datos I con el profesor Rodrigo Nunez.

Estudiantes: Sebastian Padilla Escalante y Mathias Viquez Leiva.

## Ejecucion ETL

El Data Warehouse usa PostgreSQL y contiene solo tablas analiticas para dashboard:

* `EtheriaSupplyCosts`
* `DynamicSales`
* `DashboardProfitability`

El ETL esta implementado en Python para cruzar Etheria Global (PostgreSQL) con Dynamic Brands (MySQL):

```bash
docker compose -f docker/docker-compose.yml up --build etl
```

El proceso hace `full refresh` de las tablas analiticas y no crea tablas de auditoria, staging, logs ni control dentro del Data Warehouse.
