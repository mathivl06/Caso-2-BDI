# Dashboard Power BI - DashboardProfitability

Esta guia implementa el dashboard gerencial del Data Warehouse usando la tabla `DashboardProfitability`.

El objetivo es responder:

* Cual es la rentabilidad real de una categoria cuando los costos y ventas vienen de monedas distintas.
* Que marca generada por IA es mas efectiva comparada con los costos de importacion.
* Cual es el margen por pais considerando envio y permisos.

## 1. Preparar el Data Warehouse

Desde la raiz del proyecto:

```bash
docker compose -f docker/docker-compose.yml up -d postgres mysql datawarehouse
docker compose -f docker/docker-compose.yml up --build etl
```

El ETL debe terminar con un mensaje similar a:

```text
ETL finished successfully
```

## 2. Conectar Power BI Desktop

Usa Power BI Desktop en Windows para crear el archivo `.pbix`.

1. Abre Power BI Desktop.
2. Selecciona `Get data`.
3. Selecciona `PostgreSQL database`.
4. Usa esta conexion:

| Campo | Valor |
| --- | --- |
| Server | `localhost:5433` |
| Database | `DynamicBrandsDW` |
| Data Connectivity mode | `Import` |
| User | `postgres` |
| Password | `postgres` |

5. Selecciona `Transform Data`.
6. En Power Query, crea una consulta en blanco llamada `DashboardProfitability`.
7. Abre `Advanced Editor` y pega el contenido de:

```text
powerbi/power_query_dashboardprofitability.m
```

8. Aplica los cambios con `Close & Apply`.

La consulta renombra las columnas que PostgreSQL expone en minusculas y fija los tipos esperados:

| Columnas | Tipo |
| --- | --- |
| `productCategory`, `brandName`, `siteName`, `countryOrigin`, `countryDestination`, `monthName` | Text |
| `totalSales`, `importCost`, `shippingCost`, `importFees`, `productCost`, `totalCost`, `totalProfit`, `profitMargin` | Decimal number |
| `year`, `weekNumber` | Whole number |

## 3. Crear medidas y columna calculada

Crea las medidas DAX del archivo:

```text
powerbi/dashboard_measures.dax
```

Tambien crea la columna calculada `Period` incluida en ese archivo.

Formato recomendado:

| Medida | Formato |
| --- | --- |
| `Total Sales USD` | Currency, USD |
| `Total Cost USD` | Currency, USD |
| `Total Profit USD` | Currency, USD |
| `Import Cost USD` | Currency, USD |
| `Shipping Cost USD` | Currency, USD |
| `Import Fees USD` | Currency, USD |
| `Product Cost USD` | Currency, USD |
| `Cost With Shipping And Fees USD` | Currency, USD |
| `Profit Margin %` | Percentage |
| `Brand Effectiveness` | Decimal number |

## 4. Paginas del reporte

### Pagina 1: Resumen Ejecutivo

Cards:

* `Total Sales USD`
* `Total Cost USD`
* `Total Profit USD`
* `Profit Margin %`

Slicers:

* `productCategory`
* `brandName`
* `countryDestination`
* `year`
* `weekNumber`

### Pagina 2: Rentabilidad por Categoria

Pregunta que responde:

> Cual es la rentabilidad real de una categoria si el costo es en USD y la venta en Pesos Colombianos o Soles Peruanos?

Visual 1: clustered bar chart

* Axis: `productCategory`
* Values: `Total Sales USD`, `Total Cost USD`, `Total Profit USD`

Visual 2: table o matrix

* Rows: `productCategory`
* Values: `Total Sales USD`, `Total Cost USD`, `Total Profit USD`, `Profit Margin %`

Para explicar el caso de Aceites, aplica un filtro `productCategory = Aceites` si existe esa categoria en los datos.

### Pagina 3: Efectividad de Marca IA

Pregunta que responde:

> Que marca generada por IA es mas efectiva comparada con los costos de importacion?

Visual 1: bar chart ordenado descendente

* Axis: `brandName`
* Values: `Brand Effectiveness`

Visual 2: scatter chart

* X-axis: `Import Cost USD`
* Y-axis: `Total Profit USD`
* Size: `Total Sales USD`
* Legend: `brandName`
* Tooltip: `Profit Margin %`

Interpretacion: la marca mas efectiva es la que genera mas utilidad por cada dolar de importacion.

### Pagina 4: Margen por Pais

Pregunta que responde:

> Cual es el margen por pais considerando los gastos de envio y permisos?

Visual 1: bar chart

* Axis: `countryDestination`
* Values: `Profit Margin %`

Visual 2: stacked column chart

* Axis: `countryDestination`
* Values: `Product Cost USD`, `Import Cost USD`, `Shipping Cost USD`, `Import Fees USD`

Visual 3: table

* Rows: `countryDestination`
* Values: `Total Sales USD`, `Cost With Shipping And Fees USD`, `Total Profit USD`, `Profit Margin %`

## 5. Validacion

Para validar los numeros de Power BI contra PostgreSQL, ejecuta las consultas de:

```text
powerbi/validation_queries.sql
```

Las sumas por categoria, marca y pais deben coincidir con los totales del dashboard cuando no hay filtros activos.

## 6. Entrega

Guarda el archivo como:

```text
DashboardProfitability.pbix
```

Si necesitas compartirlo, publicalo desde Power BI Desktop hacia Power BI Service.
