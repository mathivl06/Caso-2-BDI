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

## ExchangeRateHistory

## IntermediariosBancarios
- intermediarioBancarioId (PK)

## CurrenciesPorIntermediario

## TipoProducto
- tipoProductoId (PK)
- nombreTipoProducto varchar(30)

## Producto
- productoId (PK)
- nombre varchar(40)
- tipoProductoId (FK)
- currencyId (FK)
- precio float

##