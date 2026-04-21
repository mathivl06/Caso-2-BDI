- Database engine: PostgreSQL 18
- Database name: Etheria Global: Sourcing & Logistics DB
- Context: Esta empresa se encarga de la cadena de suministro. Importan productos naturales y curativos exóticos de todo el mundo (bebidas, alimentos, cosmética dermatológica, capilar, aromaterapia, jabones y aceites esenciales). Todos los productos son de gama alta y poseen propiedades medicinales/saludables. Se importan en "bulk" (cajas sin marca ni etiquetado) en dólares (USD). Todo llega a un centro logístico en la costa Caribe de Nicaragua.

# Table definitions

## Countries
- countryId (PK)
- countryName varchar(30)
- enabled boolean

## States
- stateId (PK)
- stateName varchar(30)
- countryId (FK)

## Cities
- cityId (PK)
- cityName varchar(40)
- stateId (FK)

## Addresses
- addressId (PK)
- address1 varchar(40)
- address2 varchar(40)
- zipCode integer
- cityId (FK)

## Currencies
- currencyId (PK)
- currencySymbol varchar(5)
- currencyName varchar(20)
- enabled boolean
- countryId (FK)

## ExchangeRates
- exchangeRateId (PK)
- firstCurrencyId (FK)
- secondCurrencyId (FK)
- exchangeRate DECIMAL

## ExchangeRateHistory
- exchangeRateHistoryId (PK)
- firstCurrencyId (FK)
- secondCurrencyId (FK)
- exchangeRate DECIMAL
- startDate TIMESTAMP
- endDate TIMESTAMP

## BankingIntermediaries
- bankingIntermediaryId (PK)
- bankingIntermediaryName varchar(50)
- headquartersAddress (FK)

## CurrenciesPerBankingIntermediary
- bankingIntermediaryId (FK) (CK)
- currencyId (FK) (CK)

## ProductTypes
- productTypeId (PK)
- productTypeName varchar(30)

## Products
- productId (PK)
- productName varchar(40)
- productTypeId (FK)
- description varchar(255)
- enabled boolean

## Suppliers
- supplierId (PK)
- supplierName varchar(50)
- addressId (FK)
- countryId (FK)
- enabled boolean

## ImportOrders
- importOrderId (PK)
- supplierId (FK)
- orderDate TIMESTAMP
- arrivalDate TIMESTAMP
- totalCostUSD DECIMAL
- status varchar(20)

## ImportOrderDetails
- importOrderDetailId (PK)
- importOrderId (FK)
- productId (FK)
- quantity INTEGER
- unitCostUSD DECIMAL

## Batches -- Para transportar en bulk.
- batchId (PK)
- productId (FK)
- importOrderId (FK)
- arrivalDate TIMESTAMP
- quantityReceived INTEGER
- quantityAvailable INTEGER
- unitCostUSD DECIMAL

## Warehouses
- warehouseId (PK)
- warehouseName varchar(50)
- addressId (FK)

## Inventory
- inventoryId (PK)
- batchId (FK)
- warehouseId (FK)
- quantity INTEGER

## DispatchOrders
- dispatchOrderId (PK)
- dispatchDate TIMESTAMP
- destinationCountryId (FK)
- status varchar(20)

## DispatchOrderDetails
- dispatchOrderDetailId (PK)
- dispatchOrderId (FK)
- batchId (FK)
- quantity INTEGER

## CourierServices
- courierServiceId (PK)
- courierName varchar(50)
- contactInfo varchar(100)

## Shipments
- shipmentId (PK)
- dispatchOrderId (FK)
- courierServiceId (FK)
- shipmentDate TIMESTAMP
- deliveryDate TIMESTAMP
- shippingCostUSD DECIMAL

## Logs
- logId (PK)
- procedureName varchar(50)
- message varchar(255)
- logDate TIMESTAMP
- status varchar(20)