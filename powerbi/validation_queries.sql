-- Validation queries for the Power BI dashboard.
-- Run these against database DynamicBrandsDW on localhost:5433.

-- 1. General row count and totals.
SELECT
    COUNT(*) AS dashboard_rows,
    SUM(totalSales) AS total_sales_usd,
    SUM(totalCost) AS total_cost_usd,
    SUM(totalProfit) AS total_profit_usd,
    ROUND(SUM(totalProfit) * 100.0 / NULLIF(SUM(totalSales), 0), 2) AS profit_margin_pct
FROM DashboardProfitability;

-- 2. Profitability by category.
SELECT
    productCategory,
    SUM(totalSales) AS sales_usd,
    SUM(totalCost) AS cost_usd,
    SUM(totalProfit) AS profit_usd,
    ROUND(SUM(totalProfit) * 100.0 / NULLIF(SUM(totalSales), 0), 2) AS margin_pct
FROM DashboardProfitability
GROUP BY productCategory
ORDER BY profit_usd DESC;

-- 3. AI brand effectiveness.
SELECT
    brandName,
    SUM(totalSales) AS sales_usd,
    SUM(importCost) AS import_cost_usd,
    SUM(totalProfit) AS profit_usd,
    ROUND(SUM(totalProfit) / NULLIF(SUM(importCost), 0), 4) AS brand_effectiveness
FROM DashboardProfitability
GROUP BY brandName
ORDER BY brand_effectiveness DESC NULLS LAST;

-- 4. Margin by destination country including product, import, shipping and fee costs.
SELECT
    countryDestination,
    SUM(totalSales) AS sales_usd,
    SUM(productCost + importCost + shippingCost + importFees) AS cost_with_shipping_and_fees_usd,
    SUM(totalProfit) AS profit_usd,
    ROUND(SUM(totalProfit) * 100.0 / NULLIF(SUM(totalSales), 0), 2) AS margin_pct
FROM DashboardProfitability
GROUP BY countryDestination
ORDER BY margin_pct DESC NULLS LAST;

-- 5. Detail by destination and origin country for explaining shipping/import effects.
SELECT
    countryDestination,
    countryOrigin,
    SUM(totalSales) AS sales_usd,
    SUM(productCost) AS product_cost_usd,
    SUM(importCost) AS import_cost_usd,
    SUM(shippingCost) AS shipping_cost_usd,
    SUM(importFees) AS import_fees_usd,
    SUM(totalProfit) AS profit_usd,
    ROUND(SUM(totalProfit) * 100.0 / NULLIF(SUM(totalSales), 0), 2) AS margin_pct
FROM DashboardProfitability
GROUP BY countryDestination, countryOrigin
ORDER BY countryDestination, margin_pct DESC NULLS LAST;
