import calendar
import logging
import os
import time
from collections import defaultdict
from dataclasses import dataclass
from datetime import date, datetime
from decimal import Decimal, InvalidOperation, ROUND_HALF_UP

from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL
from sqlalchemy.exc import OperationalError


BASE_CURRENCY = os.getenv("BASE_CURRENCY", "USD").upper()
IMPORT_FEE_RATE = Decimal(os.getenv("IMPORT_FEE_RATE", "0.10"))
COST_TYPE = os.getenv("ETHERIA_COST_TYPE", "LANDED_COST")
ALLOW_MISSING_RATES = os.getenv("ALLOW_MISSING_RATES", "false").lower() == "true"
ALLOW_MISSING_PRICES = os.getenv("ALLOW_MISSING_PRICES", "false").lower() == "true"

MONEY = Decimal("0.01")
RATIO = Decimal("0.0001")
ZERO = Decimal("0")

logging.basicConfig(
    level=os.getenv("LOG_LEVEL", "INFO").upper(),
    format="%(asctime)s %(levelname)s %(message)s",
)
logger = logging.getLogger("dynamic-brands-etl")


@dataclass(frozen=True)
class CostKey:
    product_category: str
    country_origin: str
    cost_type: str
    month_name: str
    year: int
    week_number: int


@dataclass(frozen=True)
class SalesKey:
    product_category: str
    brand_name: str
    site_name: str
    country_destination: str
    month_name: str
    year: int
    week_number: int


@dataclass(frozen=True)
class PeriodKey:
    product_category: str
    month_name: str
    year: int
    week_number: int


def env(name: str, default: str) -> str:
    return os.getenv(name, default)


def postgres_url(prefix: str, default_host: str, default_port: int, default_db: str) -> URL:
    return URL.create(
        "postgresql+psycopg2",
        username=env(f"{prefix}_USER", "postgres"),
        password=env(f"{prefix}_PASSWORD", "postgres"),
        host=env(f"{prefix}_HOST", default_host),
        port=int(env(f"{prefix}_PORT", str(default_port))),
        database=env(f"{prefix}_DATABASE", default_db),
    )


def mysql_url(prefix: str, default_host: str, default_port: int, default_db: str) -> URL:
    return URL.create(
        "mysql+pymysql",
        username=env(f"{prefix}_USER", "root"),
        password=env(f"{prefix}_PASSWORD", "root"),
        host=env(f"{prefix}_HOST", default_host),
        port=int(env(f"{prefix}_PORT", str(default_port))),
        database=env(f"{prefix}_DATABASE", default_db),
    )


def create_db_engine(url: URL):
    return create_engine(url, pool_pre_ping=True, future=True)


def wait_for_database(engine, name: str) -> None:
    attempts = int(env("ETL_CONNECT_RETRIES", "30"))
    delay = int(env("ETL_CONNECT_DELAY_SECONDS", "2"))

    for attempt in range(1, attempts + 1):
        try:
            with engine.connect() as conn:
                conn.execute(text("SELECT 1"))
            logger.info("%s connection ready", name)
            return
        except OperationalError as exc:
            if attempt == attempts:
                raise
            logger.info(
                "%s connection not ready yet (%s/%s): %s",
                name,
                attempt,
                attempts,
                exc.__class__.__name__,
            )
            time.sleep(delay)


def to_decimal(value) -> Decimal:
    if value is None:
        return ZERO
    if isinstance(value, Decimal):
        return value
    try:
        return Decimal(str(value))
    except (InvalidOperation, ValueError) as exc:
        raise ValueError(f"Cannot convert value to Decimal: {value!r}") from exc


def money(value: Decimal) -> Decimal:
    return to_decimal(value).quantize(MONEY, rounding=ROUND_HALF_UP)


def ratio(value: Decimal) -> Decimal:
    return to_decimal(value).quantize(RATIO, rounding=ROUND_HALF_UP)


def normalize_text(value, fallback: str = "Unknown") -> str:
    if value is None:
        return fallback
    value = str(value).strip()
    return value if value else fallback


def parse_date(value) -> date:
    if isinstance(value, datetime):
        return value.date()
    if isinstance(value, date):
        return value
    if isinstance(value, str):
        return datetime.fromisoformat(value).date()
    raise ValueError(f"Cannot parse date value: {value!r}")


def period_from(value) -> tuple[str, int, int]:
    parsed = parse_date(value)
    iso_year, iso_week, _ = parsed.isocalendar()
    return calendar.month_name[parsed.month], int(iso_year), int(iso_week)


def row_to_base_currency(
    amount,
    currency_code,
    exchange_rate,
    exchange_from_code,
    exchange_to_code,
    context: str,
) -> Decimal:
    amount = to_decimal(amount)
    if amount == ZERO:
        return ZERO

    currency = normalize_text(currency_code, BASE_CURRENCY).upper()
    if currency == BASE_CURRENCY:
        return amount

    rate = to_decimal(exchange_rate)
    from_code = normalize_text(exchange_from_code, "").upper()
    to_code = normalize_text(exchange_to_code, "").upper()

    if rate > ZERO:
        if from_code == currency and to_code == BASE_CURRENCY:
            return amount * rate
        if from_code == BASE_CURRENCY and to_code == currency:
            return amount / rate
        if to_code == BASE_CURRENCY:
            return amount * rate

    message = (
        f"Missing or incompatible exchange rate for {context}: "
        f"{amount} {currency} -> {BASE_CURRENCY}"
    )
    if ALLOW_MISSING_RATES:
        logger.warning("%s. Using amount without conversion.", message)
        return amount
    raise ValueError(message)


ETHERIA_IMPORT_QUERY = text(
    """
    SELECT
        pt.producttypename AS product_category,
        COALESCE(origin.countryname, 'Unknown') AS country_origin,
        CAST(io.orderdate AS DATE) AS cost_date,
        p.externalproductid AS external_product_id,
        COALESCE(iod.quantity, 0) AS quantity,
        COALESCE(iod.linetotal, iod.unitcost * iod.quantity, 0) AS amount,
        currency.code AS currency_code,
        er.rate AS exchange_rate,
        er_from.code AS exchange_from_code,
        er_to.code AS exchange_to_code
    FROM importorderdetails iod
    JOIN importorders io
        ON io.importorderid = iod.importorderid
    JOIN products p
        ON p.productid = iod.productid
    JOIN producttypes pt
        ON pt.producttypeid = p.producttypeid
    JOIN suppliers supplier
        ON supplier.supplierid = io.supplierid
    JOIN countries origin
        ON origin.countryid = supplier.countryid
    LEFT JOIN currencies currency
        ON currency.currencyid = iod.currencyid
    LEFT JOIN exchangerates er
        ON er.exchangerateid = iod.exchangerateid
    LEFT JOIN currencies er_from
        ON er_from.currencyid = er.fromcurrencyid
    LEFT JOIN currencies er_to
        ON er_to.currencyid = er.tocurrencyid
    WHERE COALESCE(io.deleted, FALSE) = FALSE
    """
)


ETHERIA_SHIPPING_QUERY = text(
    """
    WITH dispatch_totals AS (
        SELECT
            dispatchorderid,
            SUM(quantitydispatched) AS total_quantity
        FROM dispatchorderdetails
        GROUP BY dispatchorderid
    )
    SELECT
        pt.producttypename AS product_category,
        COALESCE(origin.countryname, 'Unknown') AS country_origin,
        CAST(sh.shipmentdate AS DATE) AS cost_date,
        p.externalproductid AS external_product_id,
        COALESCE(sh.shippingcost, 0)
            * (dod.quantitydispatched / NULLIF(dt.total_quantity, 0)) AS amount,
        currency.code AS currency_code,
        er.rate AS exchange_rate,
        er_from.code AS exchange_from_code,
        er_to.code AS exchange_to_code
    FROM shipments sh
    JOIN dispatchorders dispatch
        ON dispatch.dispatchorderid = sh.dispatchorderid
    JOIN dispatchorderdetails dod
        ON dod.dispatchorderid = dispatch.dispatchorderid
    JOIN dispatch_totals dt
        ON dt.dispatchorderid = dispatch.dispatchorderid
    JOIN batches batch
        ON batch.batchid = dod.batchid
    JOIN importorders io
        ON io.importorderid = batch.importorderid
    JOIN suppliers supplier
        ON supplier.supplierid = io.supplierid
    JOIN countries origin
        ON origin.countryid = supplier.countryid
    JOIN products p
        ON p.productid = batch.productid
    JOIN producttypes pt
        ON pt.producttypeid = p.producttypeid
    LEFT JOIN currencies currency
        ON currency.currencyid = sh.currencyid
    LEFT JOIN exchangerates er
        ON er.exchangerateid = sh.exchangerateid
    LEFT JOIN currencies er_from
        ON er_from.currencyid = er.fromcurrencyid
    LEFT JOIN currencies er_to
        ON er_to.currencyid = er.tocurrencyid
    WHERE COALESCE(sh.deleted, FALSE) = FALSE
      AND COALESCE(dispatch.deleted, FALSE) = FALSE
      AND COALESCE(io.deleted, FALSE) = FALSE
    """
)


DYNAMIC_SALES_QUERY = text(
    """
    SELECT
        category.name AS product_category,
        COALESCE(brand.brandName, 'Unknown') AS brand_name,
        COALESCE(site.name, 'Unknown') AS site_name,
        COALESCE(country.name, 'Unknown') AS country_destination,
        CAST(ord.createdAt AS DATE) AS sale_date,
        product.externalProductId AS external_product_id,
        COALESCE(item.quantity, 0) AS quantity,
        item.unitPriceLocal AS unit_price_local,
        product.baseCost AS base_cost,
        sale_currency.code AS sale_currency_code,
        sale_rate.rate AS sale_exchange_rate,
        sale_from.code AS sale_exchange_from_code,
        sale_to.code AS sale_exchange_to_code,
        cost_currency.code AS cost_currency_code,
        cost_rate.rate AS cost_exchange_rate,
        cost_from.code AS cost_exchange_from_code,
        cost_to.code AS cost_exchange_to_code
    FROM Orders ord
    JOIN OrderItems item
        ON item.orderId = ord.orderId
    JOIN Products product
        ON product.productId = item.productId
    JOIN ProductCategories category
        ON category.categoryId = product.categoryId
    LEFT JOIN Brands brand
        ON brand.brandId = product.brandId
    LEFT JOIN Sites site
        ON site.siteId = ord.siteId
    LEFT JOIN Countries country
        ON country.countryId = site.countryId
    LEFT JOIN Currencies sale_currency
        ON sale_currency.currencyId = ord.currencyId
    LEFT JOIN ExchangeRates sale_rate
        ON sale_rate.exchangeRateId = ord.exchangeRateId
    LEFT JOIN Currencies sale_from
        ON sale_from.currencyId = sale_rate.fromCurrencyId
    LEFT JOIN Currencies sale_to
        ON sale_to.currencyId = sale_rate.toCurrencyId
    LEFT JOIN Currencies cost_currency
        ON cost_currency.currencyId = product.baseCurrencyId
    LEFT JOIN ExchangeRates cost_rate
        ON cost_rate.exchangeRateId = product.exchangeRateId
    LEFT JOIN Currencies cost_from
        ON cost_from.currencyId = cost_rate.fromCurrencyId
    LEFT JOIN Currencies cost_to
        ON cost_to.currencyId = cost_rate.toCurrencyId
    WHERE COALESCE(ord.deleted, FALSE) = FALSE
      AND COALESCE(product.deleted, FALSE) = FALSE
    """
)


def add_cost(costs: dict[CostKey, dict[str, Decimal]], key: CostKey, field: str, amount: Decimal) -> None:
    bucket = costs[key]
    bucket[field] += amount
    bucket["totalSupplyCost"] = (
        bucket["importCost"] + bucket["shippingCost"] + bucket["importFees"]
    )


def extract_etheria_costs(conn) -> dict[CostKey, dict[str, Decimal]]:
    costs = defaultdict(lambda: {
        "importCost": ZERO,
        "shippingCost": ZERO,
        "importFees": ZERO,
        "totalSupplyCost": ZERO,
    })

    import_rows = conn.execute(ETHERIA_IMPORT_QUERY).mappings().all()
    for row in import_rows:
        month_name, year, week_number = period_from(row["cost_date"])
        key = CostKey(
            normalize_text(row["product_category"]),
            normalize_text(row["country_origin"]),
            COST_TYPE,
            month_name,
            year,
            week_number,
        )
        import_cost = row_to_base_currency(
            row["amount"],
            row["currency_code"],
            row["exchange_rate"],
            row["exchange_from_code"],
            row["exchange_to_code"],
            f"Etheria import line product={row['external_product_id']}",
        )
        add_cost(costs, key, "importCost", import_cost)
        add_cost(costs, key, "importFees", import_cost * IMPORT_FEE_RATE)

    shipping_rows = conn.execute(ETHERIA_SHIPPING_QUERY).mappings().all()
    for row in shipping_rows:
        month_name, year, week_number = period_from(row["cost_date"])
        key = CostKey(
            normalize_text(row["product_category"]),
            normalize_text(row["country_origin"]),
            COST_TYPE,
            month_name,
            year,
            week_number,
        )
        shipping_cost = row_to_base_currency(
            row["amount"],
            row["currency_code"],
            row["exchange_rate"],
            row["exchange_from_code"],
            row["exchange_to_code"],
            f"Etheria shipment product={row['external_product_id']}",
        )
        add_cost(costs, key, "shippingCost", shipping_cost)

    logger.info(
        "Extracted %s import rows and %s shipping rows from Etheria",
        len(import_rows),
        len(shipping_rows),
    )
    return dict(costs)


def extract_dynamic_sales(conn) -> dict[SalesKey, dict[str, Decimal]]:
    sales = defaultdict(lambda: {
        "totalSales": ZERO,
        "productCost": ZERO,
        "supplyCost": ZERO,
        "totalCost": ZERO,
        "totalProfit": ZERO,
    })

    rows = conn.execute(DYNAMIC_SALES_QUERY).mappings().all()
    for row in rows:
        month_name, year, week_number = period_from(row["sale_date"])
        key = SalesKey(
            normalize_text(row["product_category"]),
            normalize_text(row["brand_name"]),
            normalize_text(row["site_name"]),
            normalize_text(row["country_destination"]),
            month_name,
            year,
            week_number,
        )
        quantity = to_decimal(row["quantity"])
        unit_price_local = row["unit_price_local"]
        if unit_price_local is None:
            message = (
                "Order item has no unitPriceLocal and cannot be converted into "
                f"sales revenue. Product={row['external_product_id']}"
            )
            if ALLOW_MISSING_PRICES:
                logger.warning("%s. Using zero revenue for this line.", message)
                line_sales = ZERO
            else:
                raise ValueError(message)
        else:
            line_sales = row_to_base_currency(
                to_decimal(unit_price_local) * quantity,
                row["sale_currency_code"],
                row["sale_exchange_rate"],
                row["sale_exchange_from_code"],
                row["sale_exchange_to_code"],
                f"Dynamic sale product={row['external_product_id']}",
            )

        product_cost = row_to_base_currency(
            to_decimal(row["base_cost"]) * quantity,
            row["cost_currency_code"],
            row["cost_exchange_rate"],
            row["cost_exchange_from_code"],
            row["cost_exchange_to_code"],
            f"Dynamic product cost product={row['external_product_id']}",
        )

        sales[key]["totalSales"] += line_sales
        sales[key]["productCost"] += product_cost

    logger.info("Extracted %s order item rows from Dynamic Brands", len(rows))
    return dict(sales)


def period_key_from_cost(key: CostKey) -> PeriodKey:
    return PeriodKey(key.product_category, key.month_name, key.year, key.week_number)


def period_key_from_sales(key: SalesKey) -> PeriodKey:
    return PeriodKey(key.product_category, key.month_name, key.year, key.week_number)


def allocate_dynamic_supply_costs(
    costs: dict[CostKey, dict[str, Decimal]],
    sales: dict[SalesKey, dict[str, Decimal]],
) -> None:
    supply_by_period = defaultdict(lambda: ZERO)
    sales_by_period = defaultdict(lambda: ZERO)

    for key, values in costs.items():
        supply_by_period[period_key_from_cost(key)] += values["totalSupplyCost"]

    for key, values in sales.items():
        sales_by_period[period_key_from_sales(key)] += values["totalSales"]

    for key, values in sales.items():
        period = period_key_from_sales(key)
        period_supply = supply_by_period[period]
        period_sales = sales_by_period[period]
        sales_share = values["totalSales"] / period_sales if period_sales > ZERO else ZERO
        values["supplyCost"] = period_supply * sales_share
        values["totalCost"] = values["productCost"] + values["supplyCost"]
        values["totalProfit"] = values["totalSales"] - values["totalCost"]


def build_dashboard_rows(
    costs: dict[CostKey, dict[str, Decimal]],
    sales: dict[SalesKey, dict[str, Decimal]],
) -> list[dict[str, Decimal | str | int]]:
    costs_by_period = defaultdict(list)
    supply_by_period = defaultdict(lambda: ZERO)
    sales_by_period = defaultdict(lambda: ZERO)

    for cost_key, cost_values in costs.items():
        period = period_key_from_cost(cost_key)
        costs_by_period[period].append((cost_key, cost_values))
        supply_by_period[period] += cost_values["totalSupplyCost"]

    for sales_key, sales_values in sales.items():
        sales_by_period[period_key_from_sales(sales_key)] += sales_values["totalSales"]

    rows = []
    for sales_key, sales_values in sales.items():
        period = period_key_from_sales(sales_key)
        period_costs = costs_by_period.get(period, [])
        period_sales = sales_by_period[period]
        sales_share = (
            sales_values["totalSales"] / period_sales
            if period_sales > ZERO
            else ZERO
        )

        if not period_costs:
            total_cost = sales_values["productCost"]
            total_profit = sales_values["totalSales"] - total_cost
            rows.append(
                dashboard_row(
                    sales_key,
                    "Unknown",
                    sales_values["totalSales"],
                    ZERO,
                    ZERO,
                    ZERO,
                    sales_values["productCost"],
                    total_cost,
                    total_profit,
                )
            )
            continue

        period_supply = supply_by_period[period]
        equal_origin_share = Decimal("1") / Decimal(len(period_costs))

        for cost_key, cost_values in period_costs:
            origin_share = (
                cost_values["totalSupplyCost"] / period_supply
                if period_supply > ZERO
                else equal_origin_share
            )
            sales_alloc = sales_values["totalSales"] * origin_share
            product_cost_alloc = sales_values["productCost"] * origin_share
            import_cost_alloc = cost_values["importCost"] * sales_share
            shipping_cost_alloc = cost_values["shippingCost"] * sales_share
            import_fees_alloc = cost_values["importFees"] * sales_share
            total_cost = (
                product_cost_alloc
                + import_cost_alloc
                + shipping_cost_alloc
                + import_fees_alloc
            )
            total_profit = sales_alloc - total_cost

            rows.append(
                dashboard_row(
                    sales_key,
                    cost_key.country_origin,
                    sales_alloc,
                    import_cost_alloc,
                    shipping_cost_alloc,
                    import_fees_alloc,
                    product_cost_alloc,
                    total_cost,
                    total_profit,
                )
            )

    return rows


def dashboard_row(
    sales_key: SalesKey,
    country_origin: str,
    total_sales: Decimal,
    import_cost: Decimal,
    shipping_cost: Decimal,
    import_fees: Decimal,
    product_cost: Decimal,
    total_cost: Decimal,
    total_profit: Decimal,
) -> dict[str, Decimal | str | int]:
    margin = total_profit / total_sales if total_sales > ZERO else ZERO
    return {
        "productCategory": sales_key.product_category,
        "brandName": sales_key.brand_name,
        "siteName": sales_key.site_name,
        "countryOrigin": country_origin,
        "countryDestination": sales_key.country_destination,
        "totalSales": money(total_sales),
        "importCost": money(import_cost),
        "shippingCost": money(shipping_cost),
        "importFees": money(import_fees),
        "productCost": money(product_cost),
        "totalCost": money(total_cost),
        "totalProfit": money(total_profit),
        "profitMargin": ratio(margin),
        "monthName": sales_key.month_name,
        "year": sales_key.year,
        "weekNumber": sales_key.week_number,
    }


DW_SCHEMA_SQL = """
CREATE TABLE IF NOT EXISTS EtheriaSupplyCosts (
    productCategory VARCHAR(100) NOT NULL,
    countryOrigin VARCHAR(50) NOT NULL,
    costType VARCHAR(50) NOT NULL,
    importCost DECIMAL(14,2) NOT NULL DEFAULT 0,
    shippingCost DECIMAL(14,2) NOT NULL DEFAULT 0,
    importFees DECIMAL(14,2) NOT NULL DEFAULT 0,
    totalSupplyCost DECIMAL(14,2) NOT NULL DEFAULT 0,
    monthName VARCHAR(20) NOT NULL,
    year INT NOT NULL,
    weekNumber INT NOT NULL,
    PRIMARY KEY (productCategory, countryOrigin, costType, year, monthName, weekNumber)
);

CREATE TABLE IF NOT EXISTS DynamicSales (
    productCategory VARCHAR(100) NOT NULL,
    brandName VARCHAR(100) NOT NULL,
    siteName VARCHAR(100) NOT NULL,
    countryDestination VARCHAR(50) NOT NULL,
    totalSales DECIMAL(14,2) NOT NULL DEFAULT 0,
    productCost DECIMAL(14,2) NOT NULL DEFAULT 0,
    supplyCost DECIMAL(14,2) NOT NULL DEFAULT 0,
    totalCost DECIMAL(14,2) NOT NULL DEFAULT 0,
    totalProfit DECIMAL(14,2) NOT NULL DEFAULT 0,
    monthName VARCHAR(20) NOT NULL,
    year INT NOT NULL,
    weekNumber INT NOT NULL,
    PRIMARY KEY (
        productCategory,
        brandName,
        siteName,
        countryDestination,
        year,
        monthName,
        weekNumber
    )
);

CREATE TABLE IF NOT EXISTS DashboardProfitability (
    productCategory VARCHAR(100) NOT NULL,
    brandName VARCHAR(100) NOT NULL,
    siteName VARCHAR(100) NOT NULL,
    countryOrigin VARCHAR(50) NOT NULL,
    countryDestination VARCHAR(50) NOT NULL,
    totalSales DECIMAL(14,2) NOT NULL DEFAULT 0,
    importCost DECIMAL(14,2) NOT NULL DEFAULT 0,
    shippingCost DECIMAL(14,2) NOT NULL DEFAULT 0,
    importFees DECIMAL(14,2) NOT NULL DEFAULT 0,
    productCost DECIMAL(14,2) NOT NULL DEFAULT 0,
    totalCost DECIMAL(14,2) NOT NULL DEFAULT 0,
    totalProfit DECIMAL(14,2) NOT NULL DEFAULT 0,
    profitMargin DECIMAL(8,4) NOT NULL DEFAULT 0,
    monthName VARCHAR(20) NOT NULL,
    year INT NOT NULL,
    weekNumber INT NOT NULL,
    PRIMARY KEY (
        productCategory,
        brandName,
        siteName,
        countryOrigin,
        countryDestination,
        year,
        monthName,
        weekNumber
    )
);

CREATE INDEX IF NOT EXISTS idx_etheria_time
ON EtheriaSupplyCosts (year, monthName, weekNumber);

CREATE INDEX IF NOT EXISTS idx_dynamic_time
ON DynamicSales (year, monthName, weekNumber);

CREATE INDEX IF NOT EXISTS idx_dashboard_category
ON DashboardProfitability (productCategory, year, weekNumber);

CREATE INDEX IF NOT EXISTS idx_dashboard_brand
ON DashboardProfitability (brandName, year, weekNumber);

CREATE INDEX IF NOT EXISTS idx_dashboard_country
ON DashboardProfitability (countryDestination, year, weekNumber);
"""


INSERT_ETHERIA_SQL = text(
    """
    INSERT INTO EtheriaSupplyCosts (
        productCategory,
        countryOrigin,
        costType,
        importCost,
        shippingCost,
        importFees,
        totalSupplyCost,
        monthName,
        year,
        weekNumber
    )
    VALUES (
        :productCategory,
        :countryOrigin,
        :costType,
        :importCost,
        :shippingCost,
        :importFees,
        :totalSupplyCost,
        :monthName,
        :year,
        :weekNumber
    )
    """
)


INSERT_DYNAMIC_SQL = text(
    """
    INSERT INTO DynamicSales (
        productCategory,
        brandName,
        siteName,
        countryDestination,
        totalSales,
        productCost,
        supplyCost,
        totalCost,
        totalProfit,
        monthName,
        year,
        weekNumber
    )
    VALUES (
        :productCategory,
        :brandName,
        :siteName,
        :countryDestination,
        :totalSales,
        :productCost,
        :supplyCost,
        :totalCost,
        :totalProfit,
        :monthName,
        :year,
        :weekNumber
    )
    """
)


INSERT_DASHBOARD_SQL = text(
    """
    INSERT INTO DashboardProfitability (
        productCategory,
        brandName,
        siteName,
        countryOrigin,
        countryDestination,
        totalSales,
        importCost,
        shippingCost,
        importFees,
        productCost,
        totalCost,
        totalProfit,
        profitMargin,
        monthName,
        year,
        weekNumber
    )
    VALUES (
        :productCategory,
        :brandName,
        :siteName,
        :countryOrigin,
        :countryDestination,
        :totalSales,
        :importCost,
        :shippingCost,
        :importFees,
        :productCost,
        :totalCost,
        :totalProfit,
        :profitMargin,
        :monthName,
        :year,
        :weekNumber
    )
    """
)


def etheria_rows(costs: dict[CostKey, dict[str, Decimal]]) -> list[dict[str, Decimal | str | int]]:
    rows = []
    for key, values in costs.items():
        rows.append({
            "productCategory": key.product_category,
            "countryOrigin": key.country_origin,
            "costType": key.cost_type,
            "importCost": money(values["importCost"]),
            "shippingCost": money(values["shippingCost"]),
            "importFees": money(values["importFees"]),
            "totalSupplyCost": money(values["totalSupplyCost"]),
            "monthName": key.month_name,
            "year": key.year,
            "weekNumber": key.week_number,
        })
    return rows


def dynamic_rows(sales: dict[SalesKey, dict[str, Decimal]]) -> list[dict[str, Decimal | str | int]]:
    rows = []
    for key, values in sales.items():
        rows.append({
            "productCategory": key.product_category,
            "brandName": key.brand_name,
            "siteName": key.site_name,
            "countryDestination": key.country_destination,
            "totalSales": money(values["totalSales"]),
            "productCost": money(values["productCost"]),
            "supplyCost": money(values["supplyCost"]),
            "totalCost": money(values["totalCost"]),
            "totalProfit": money(values["totalProfit"]),
            "monthName": key.month_name,
            "year": key.year,
            "weekNumber": key.week_number,
        })
    return rows


def execute_schema(conn) -> None:
    for statement in DW_SCHEMA_SQL.split(";"):
        statement = statement.strip()
        if statement:
            conn.execute(text(statement))


def load_datawarehouse(
    conn,
    costs: dict[CostKey, dict[str, Decimal]],
    sales: dict[SalesKey, dict[str, Decimal]],
) -> None:
    execute_schema(conn)
    conn.execute(text("TRUNCATE TABLE DashboardProfitability, DynamicSales, EtheriaSupplyCosts"))

    cost_rows = etheria_rows(costs)
    sales_rows = dynamic_rows(sales)
    dashboard_rows = build_dashboard_rows(costs, sales)

    if cost_rows:
        conn.execute(INSERT_ETHERIA_SQL, cost_rows)
    if sales_rows:
        conn.execute(INSERT_DYNAMIC_SQL, sales_rows)
    if dashboard_rows:
        conn.execute(INSERT_DASHBOARD_SQL, dashboard_rows)

    logger.info(
        "Loaded DW: %s EtheriaSupplyCosts rows, %s DynamicSales rows, %s DashboardProfitability rows",
        len(cost_rows),
        len(sales_rows),
        len(dashboard_rows),
    )


def main() -> None:
    etheria_engine = create_db_engine(
        postgres_url("ETHERIA_PG", "localhost", 5432, "etheria_db")
    )
    dynamic_engine = create_db_engine(
        mysql_url("DYNAMIC_MYSQL", "localhost", 3306, "DynamicBrandsDB")
    )
    dw_engine = create_db_engine(
        postgres_url("DW_PG", "localhost", 5433, "DynamicBrandsDW")
    )

    wait_for_database(etheria_engine, "Etheria PostgreSQL")
    wait_for_database(dynamic_engine, "Dynamic Brands MySQL")
    wait_for_database(dw_engine, "Data Warehouse PostgreSQL")

    with etheria_engine.connect() as etheria_conn:
        costs = extract_etheria_costs(etheria_conn)

    with dynamic_engine.connect() as dynamic_conn:
        sales = extract_dynamic_sales(dynamic_conn)

    allocate_dynamic_supply_costs(costs, sales)

    with dw_engine.begin() as dw_conn:
        load_datawarehouse(dw_conn, costs, sales)

    logger.info("ETL finished successfully")


if __name__ == "__main__":
    main()
