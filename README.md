# Caso-2-BDI

Repositorio para el caso #2 del curso Bases de Datos I con el profesor Rodrigo Nunez. de los estudiantes: Mathias Viquez Leiva y Sebastián de Jesús Padilla Escalante.

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

## Dashboard Power BI

La guia para construir el dashboard del Data Warehouse en Power BI esta en:

```text
powerbi/README.md
```

Incluye:

* Pasos de conexion a PostgreSQL (`localhost:5433`, base `DynamicBrandsDW`).
* Consulta Power Query para importar `DashboardProfitability` con nombres y tipos correctos.
* Medidas DAX para ventas, costos, utilidad, margen y efectividad de marca.
* Visuales recomendados para responder las preguntas del caso.
* Consultas SQL de validacion contra `DashboardProfitability`.
