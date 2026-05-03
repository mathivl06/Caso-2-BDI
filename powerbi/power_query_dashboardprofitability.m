let
    Source = PostgreSQL.Database("localhost:5433", "DynamicBrandsDW"),
    DashboardRaw = Source{[Schema = "public", Item = "dashboardprofitability"]}[Data],
    RenamedColumns = Table.RenameColumns(
        DashboardRaw,
        {
            {"productcategory", "productCategory"},
            {"brandname", "brandName"},
            {"sitename", "siteName"},
            {"countryorigin", "countryOrigin"},
            {"countrydestination", "countryDestination"},
            {"totalsales", "totalSales"},
            {"importcost", "importCost"},
            {"shippingcost", "shippingCost"},
            {"importfees", "importFees"},
            {"productcost", "productCost"},
            {"totalcost", "totalCost"},
            {"totalprofit", "totalProfit"},
            {"profitmargin", "profitMargin"},
            {"monthname", "monthName"},
            {"year", "year"},
            {"weeknumber", "weekNumber"}
        },
        MissingField.Ignore
    ),
    ChangedTypes = Table.TransformColumnTypes(
        RenamedColumns,
        {
            {"productCategory", type text},
            {"brandName", type text},
            {"siteName", type text},
            {"countryOrigin", type text},
            {"countryDestination", type text},
            {"totalSales", type number},
            {"importCost", type number},
            {"shippingCost", type number},
            {"importFees", type number},
            {"productCost", type number},
            {"totalCost", type number},
            {"totalProfit", type number},
            {"profitMargin", type number},
            {"monthName", type text},
            {"year", Int64.Type},
            {"weekNumber", Int64.Type}
        }
    )
in
    ChangedTypes
