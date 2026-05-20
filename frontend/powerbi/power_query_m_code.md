# Power Query M Code - Data Transformation Guide

## Overview
This document provides Power Query M code examples for importing and transforming warehouse data into Power BI.

---

## DIMENSION TABLE IMPORTS

### 1. Dim_Date Import (Static - Annual Update)
```m
let
    Source = Sql.Database("warehouse.company.com", "Enterprise_KPI_DW"),
    dbo_Dim_Date = Source{[Schema="dbo",Item="Dim_Date"]}[Data],
    #"Changed Type" = Table.TransformColumnTypes(dbo_Dim_Date,{
        {"DateKey", Int64.Type},
        {"Date", type date},
        {"Year", Int64.Type},
        {"Quarter", Int64.Type},
        {"Month", Int64.Type},
        {"MonthName", type text},
        {"DayOfWeek", Int64.Type},
        {"DayName", type text},
        {"Week", Int64.Type},
        {"IsWeekday", type logical},
        {"IsMonthEnd", type logical},
        {"IsQuarterEnd", type logical},
        {"IsYearEnd", type logical},
        {"FiscalYear", Int64.Type},
        {"FiscalQuarter", Int64.Type},
        {"FiscalMonth", Int64.Type}
    }),
    #"Removed Other Columns" = Table.SelectColumns(#"Changed Type",{
        "DateKey", "Date", "Year", "Quarter", "Month", "MonthName", 
        "DayOfWeek", "DayName", "Week", "IsWeekday", "IsMonthEnd", 
        "IsQuarterEnd", "IsYearEnd", "FiscalYear", "FiscalQuarter", "FiscalMonth"
    }),
    #"Sorted Rows" = Table.Sort(#"Removed Other Columns",{{"Date", Order.Ascending}})
in
    #"Sorted Rows"
```

---

### 2. Dim_Customer Import (Daily Refresh - Incremental)
```m
let
    Source = Sql.Database("warehouse.company.com", "Enterprise_KPI_DW"),
    dbo_Dim_Customer = Source{[Schema="dbo",Item="Dim_Customer"]}[Data],
    
    // Filter: Only import ACTIVE customers or recently changed customers
    #"Filtered Rows - Active" = Table.SelectRows(dbo_Dim_Customer, each 
        [IsActive] = true or 
        [LastModifiedDate] >= DateTime.AddDays(DateTime.UtcNow(), -7)
    ),
    
    #"Changed Type" = Table.TransformColumnTypes(#"Filtered Rows - Active",{
        {"CustomerKey", Int64.Type},
        {"CustomerID", Int64.Type},
        {"CustomerName", type text},
        {"Segment", type text},
        {"SubSegment", type text},
        {"IndustryCode", type text},
        {"CountryCode", type text},
        {"CountryName", type text},
        {"RegionCode", type text},
        {"RegionName", type text},
        {"CustomerType", type text},
        {"Status", type text},
        {"CustomerAcquisitionDate", type date},
        {"LastTransactionDate", type date},
        {"ContractEndDate", type date},
        {"AnnualContractValue", type number},
        {"YTDSpend", type number},
        {"IsActive", type logical},
        {"CreatedDate", type datetime},
        {"LastModifiedDate", type datetime}
    }),
    
    // Remove duplicates (keep latest by LastModifiedDate)
    #"Removed Duplicates" = Table.Distinct(#"Changed Type", {"CustomerKey"}),
    
    // Add custom columns for analysis
    #"Added Custom - Days Since Last Purchase" = Table.AddColumn(
        #"Removed Duplicates", 
        "DaysSinceLastPurchase", 
        each if [LastTransactionDate] = null then 999 else Number.Days(Date.Today(), [LastTransactionDate]),
        Int64.Type
    ),
    
    #"Added Custom - Contract Status" = Table.AddColumn(
        #"Added Custom - Days Since Last Purchase",
        "ContractStatus",
        each if [ContractEndDate] < Date.Today() then "Expired" 
             else if [ContractEndDate] < Date.AddDays(Date.Today(), 90) then "Expiring Soon"
             else "Active",
        type text
    ),
    
    #"Sorted Rows" = Table.Sort(#"Added Custom - Contract Status", {{"CustomerKey", Order.Ascending}})
in
    #"Sorted Rows"
```

---

### 3. Dim_Product Import
```m
let
    Source = Sql.Database("warehouse.company.com", "Enterprise_KPI_DW"),
    dbo_Dim_Product = Source{[Schema="dbo",Item="Dim_Product"]}[Data],
    
    #"Changed Type" = Table.TransformColumnTypes(dbo_Dim_Product,{
        {"ProductKey", Int64.Type},
        {"ProductID", Int64.Type},
        {"ProductName", type text},
        {"ProductFamily", type text},
        {"ProductCategory", type text},
        {"ProductSubCategory", type text},
        {"BrandName", type text},
        {"ManufacturerID", Int64.Type},
        {"ListPrice", type number},
        {"StandardCost", type number},
        {"UnitWeight", type number},
        {"IsActive", type logical},
        {"LaunchDate", type date},
        {"DiscontinueDate", type date},
        {"CreatedDate", type datetime}
    }),
    
    // Filter out discontinued products (optional)
    #"Filtered Active Products" = Table.SelectRows(#"Changed Type", each [IsActive] = true or [DiscontinueDate] = null),
    
    // Add margin calculation
    #"Added Margin %" = Table.AddColumn(
        #"Filtered Active Products",
        "GrossMarginPercent",
        each if [ListPrice] = 0 then 0 else ([ListPrice] - [StandardCost]) / [ListPrice] * 100,
        type number
    ),
    
    #"Sorted" = Table.Sort(#"Added Margin %", {{"ProductKey", Order.Ascending}})
in
    #"Sorted"
```

---

## FACT TABLE IMPORTS

### 4. Fact_Sales Import (Incremental Refresh - Last 90 Days)
```m
let
    Source = Sql.Database("warehouse.company.com", "Enterprise_KPI_DW"),
    dbo_Fact_Sales = Source{[Schema="dbo",Item="Fact_Sales"]}[Data],
    
    // Incremental: Import last 90 days of data
    #"Filtered Rows - Last 90 Days" = Table.SelectRows(dbo_Fact_Sales, each 
        [OrderDate] >= Date.AddDays(Date.Today(), -90)
    ),
    
    #"Changed Type" = Table.TransformColumnTypes(#"Filtered Rows - Last 90 Days",{
        {"SalesKey", Int64.Type},
        {"SalesOrderNumber", type text},
        {"SalesOrderLineNumber", Int64.Type},
        {"OrderDate", type date},
        {"ShipDate", type date},
        {"DeliveryDate", type date},
        {"CustomerKey", Int64.Type},
        {"ProductKey", Int64.Type},
        {"EmployeeKey", Int64.Type},
        {"GeographyKey", Int64.Type},
        {"CompanyKey", Int64.Type},
        {"OrderQuantity", Int64.Type},
        {"UnitPrice", type number},
        {"ExtendedAmount", type number},
        {"DiscountAmount", type number},
        {"TaxAmount", type number},
        {"TotalDue", type number},
        {"OrderStatus", type text},
        {"PaymentMethod", type text},
        {"ShippingMethod", type text},
        {"OnTimeDelivery", type logical},
        {"CreatedDate", type datetime}
    }),
    
    // Add calculated columns
    #"Added Revenue" = Table.AddColumn(
        #"Changed Type",
        "Revenue",
        each [ExtendedAmount] + [TaxAmount] - [DiscountAmount],
        type number
    ),
    
    #"Added Days to Deliver" = Table.AddColumn(
        #"Added Revenue",
        "DaysToDeliver",
        each if [DeliveryDate] = null or [OrderDate] = null then null 
             else Number.Days([OrderDate], [DeliveryDate]),
        Int64.Type
    ),
    
    #"Added Discount %" = Table.AddColumn(
        #"Added Days to Deliver",
        "DiscountPercent",
        each if [ExtendedAmount] = 0 then 0 else [DiscountAmount] / [ExtendedAmount] * 100,
        type number
    ),
    
    // Remove test/sample data
    #"Filtered Rows - No Test Data" = Table.SelectRows(#"Added Discount %", each 
        [CustomerKey] > 0 and [ProductKey] > 0
    ),
    
    #"Sorted Rows" = Table.Sort(#"Filtered Rows - No Test Data", {{"OrderDate", Order.Descending}})
in
    #"Sorted Rows"
```

---

### 5. Fact_Finance Import
```m
let
    Source = Sql.Database("warehouse.company.com", "Enterprise_KPI_DW"),
    dbo_Fact_Finance = Source{[Schema="dbo",Item="Fact_Finance"]}[Data],
    
    // Import current fiscal year + prior year for comparison
    #"Filtered Rows - Prior 24 Months" = Table.SelectRows(dbo_Fact_Finance, each
        [FiscalYear] >= (Date.Year(Date.Today()) - 1)
    ),
    
    #"Changed Type" = Table.TransformColumnTypes(#"Filtered Rows - Prior 24 Months",{
        {"FinanceKey", Int64.Type},
        {"DateKey", Int64.Type},
        {"CompanyKey", Int64.Type},
        {"DepartmentKey", Int64.Type},
        {"GLAccountKey", Int64.Type},
        {"CurrencyCode", type text},
        {"Amount", type number},
        {"AmountLocalCurrency", type number},
        {"Quantity", Int64.Type},
        {"TransactionType", type text},
        {"FiscalYear", Int64.Type},
        {"FiscalMonth", Int64.Type},
        {"CreatedDate", type datetime}
    }),
    
    // Add transaction category hierarchy
    #"Added Category" = Table.AddColumn(
        #"Changed Type",
        "FinanceCategory",
        each if [TransactionType] = "Revenue" then "Revenue"
             else if [TransactionType] = "COGS" then "Cost of Goods"
             else if List.Contains({"OpEx", "CapEx"}, [TransactionType]) then "Expenses"
             else "Other",
        type text
    ),
    
    #"Sorted Rows" = Table.Sort(#"Added Category", {{"FiscalYear", Order.Descending}, {"FiscalMonth", Order.Descending}})
in
    #"Sorted Rows"
```

---

### 6. Fact_Customer_Metrics Import
```m
let
    Source = Sql.Database("warehouse.company.com", "Enterprise_KPI_DW"),
    dbo_Fact_Customer_Metrics = Source{[Schema="dbo",Item="Fact_Customer_Metrics"]}[Data],
    
    // Import last 24 months of metrics
    #"Filtered Rows" = Table.SelectRows(dbo_Fact_Customer_Metrics, each
        [DateKey] >= Number.Round(Number.From(Date.AddMonths(Date.Today(), -24)) / 100) * 100
    ),
    
    #"Changed Type" = Table.TransformColumnTypes(#"Filtered Rows",{
        {"MetricKey", Int64.Type},
        {"DateKey", Int64.Type},
        {"CustomerKey", Int64.Type},
        {"TotalPurchases", Int64.Type},
        {"TotalSpend", type number},
        {"AverageOrderValue", type number},
        {"PurchaseFrequency", Int64.Type},
        {"DaysSinceLastPurchase", Int64.Type},
        {"CustomerLifetimeValue", type number},
        {"IsChurned", type logical},
        {"ChurnRiskScore", type number},
        {"NPS_Score", Int64.Type},
        {"RetentionFlag", type logical},
        {"CreatedDate", type datetime}
    }),
    
    // Add churn category
    #"Added Churn Category" = Table.AddColumn(
        #"Changed Type",
        "ChurnCategory",
        each if [IsChurned] = true then "Churned"
             else if [ChurnRiskScore] > 70 then "High Risk"
             else if [ChurnRiskScore] > 40 then "Medium Risk"
             else "Healthy",
        type text
    ),
    
    // Add NPS Category
    #"Added NPS Category" = Table.AddColumn(
        #"Added Churn Category",
        "NPSCategory",
        each if [NPS_Score] > 50 then "Promoter"
             else if [NPS_Score] > 0 then "Passive"
             else "Detractor",
        type text
    ),
    
    #"Sorted Rows" = Table.Sort(#"Added NPS Category", {{"DateKey", Order.Descending}})
in
    #"Sorted Rows"
```

---

## DATA QUALITY & VALIDATION

### 7. Data Validation Query
```m
let
    // After importing all tables, add this as a reference query
    // to validate data quality
    
    Sales = #"Fact_Sales",
    
    // Check for orphaned keys (sales with no matching customer)
    CustomersInSales = Table.Distinct(Sales, {"CustomerKey"}),
    AllCustomers = Table.SelectColumns(Dim_Customer, {"CustomerKey"}),
    OrphanedCustomers = Table.NestedJoin(CustomersInSales, {"CustomerKey"}, AllCustomers, {"CustomerKey"}, "Match", JoinKind.LeftAnti),
    
    // Check for null values in critical columns
    SalesWithNulls = Table.SelectRows(Sales, each 
        [CustomerKey] = null or 
        [ProductKey] = null or 
        [OrderDate] = null or
        [TotalDue] = null
    ),
    
    // Check for negative amounts (should be returned separately)
    SalesWithNegativeAmounts = Table.SelectRows(Sales, each [TotalDue] < -100),
    
    ValidationSummary = {
        [Check = "Orphaned Customer Keys", Count = Table.RowCount(OrphanedCustomers), Status = if Table.RowCount(OrphanedCustomers) = 0 then "PASS" else "FAIL"],
        [Check = "Null Critical Values", Count = Table.RowCount(SalesWithNulls), Status = if Table.RowCount(SalesWithNulls) = 0 then "PASS" else "FAIL"],
        [Check = "Negative Amounts", Count = Table.RowCount(SalesWithNegativeAmounts), Status = if Table.RowCount(SalesWithNegativeAmounts) = 0 then "PASS" else "WARNING"]
    }
in
    Table.FromRecords(ValidationSummary)
```

---

## TRANSFORMATION PATTERNS

### Pattern 1: Hierarchical Group By
```m
// Used when you need to create totals at each level of hierarchy

let
    Sales = #"Fact_Sales",
    WithHierarchy = Table.AddColumn(Sales, "SalesHierarchy",
        each [GeographyKey] & "|" & [CustomerKey] & "|" & [ProductKey],
        type text
    )
in
    WithHierarchy
```

### Pattern 2: Date Intelligence
```m
// Add fiscal period intelligence to any fact table

let
    Data = #"Source Table",
    DateLookup = #"Dim_Date",
    MergedWithDate = Table.NestedJoin(Data, {"DateKey"}, DateLookup, {"DateKey"}, "DateInfo"),
    ExpandedDate = Table.ExpandTableColumn(MergedWithDate, "DateInfo", 
        {"FiscalYear", "FiscalQuarter", "FiscalMonth"}, 
        {"FiscalYear", "FiscalQuarter", "FiscalMonth"}
    )
in
    ExpandedDate
```

### Pattern 3: Slowly Changing Dimension (Type II)
```m
// Handle dimensional changes over time

let
    Source = Sql.Database("warehouse.company.com", "Enterprise_KPI_DW"),
    // Include EffectiveDate and ExpirationDate columns
    Dim_Customer_SCD = Source{[Schema="dbo",Item="Dim_Customer_SCD"]}[Data],
    
    #"Filtered Current" = Table.SelectRows(Dim_Customer_SCD, each
        [ExpirationDate] = null  // Only current records
    )
in
    #"Filtered Current"
```

---

## PERFORMANCE OPTIMIZATION

### M Code Best Practices
```m
// ✓ DO: Filter early in the query
#"Filtered Rows - Early" = Table.SelectRows(Source, each [IsActive] = true)

// ✗ DON'T: Apply functions to columns before filtering
// Avoid: Table.SelectRows(Source, each Int64.From([Amount]) > 1000)
// Better: Filter first, then transform types

// ✓ DO: Remove unnecessary columns
#"Kept Relevant Cols" = Table.SelectColumns(Data, {"Key1", "Key2", "Value"})

// ✓ DO: Use native database functions when possible
// Use SQL Server queries in M, don't import and transform

// ✓ DO: Cache queries that are used multiple times
let
    SourceData = #"Source Query",
    Transform1 = Table.TransformColumnTypes(SourceData, {...}),
    UseMultipleTimes = Transform1,  // Reference cached result
    FinalOutput = Table.SelectRows(UseMultipleTimes, ...)
in
    FinalOutput
```

---

## COMMON TRANSFORMATIONS REFERENCE

| Transformation | M Code | Use Case |
|---|---|---|
| Replace Nulls | `Table.ReplaceValue(table, null, 0, {"column"})` | Fill missing values |
| Remove Blanks | `Table.SelectRows(table, each [column] <> "")` | Clean text data |
| Add Custom | `Table.AddColumn(table, "name", each formula, type)` | Calculated columns |
| Merge Tables | `Table.NestedJoin(t1, {k1}, t2, {k2}, "name")` | Joins |
| Group By | `Table.Group(table, {"col1"}, {{"Total", each List.Sum([col2])}})` | Aggregations |
| Unpivot | `Table.Unpivot(table, cols, "Attribute", "Value")` | Normalize wide tables |

---

## Next Steps

1. Create database user with SELECT permissions on warehouse tables
2. Update server/database connection strings in queries
3. Test each query in Power Query individually
4. Validate data type conversions
5. Configure refresh schedule in Power BI Service
6. Monitor refresh performance and adjust filters/incremental refresh as needed
