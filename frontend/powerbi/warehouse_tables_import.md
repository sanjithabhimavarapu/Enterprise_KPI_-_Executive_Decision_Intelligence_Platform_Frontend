# Power BI Warehouse Tables Import Specification

## Overview
This document defines all warehouse tables to be imported into Power BI, including transformation rules, data types, and refresh strategies.

---

## Data Warehouse Schema Structure

### Schema: dbo (Default)

---

## DIMENSION TABLES

### 1. Dim_Date (Date Dimension)
```
Table: dbo.Dim_Date
Size: ~10,000 rows (30 years of data)
Refresh: Static (Annual update for future years)
Import Mode: Import (compressed)

Columns:
- DateKey (INT, PK)
- Date (DATE)
- Year (INT)
- Quarter (INT)
- Month (INT)
- MonthName (VARCHAR(20))
- DayOfWeek (INT)
- DayName (VARCHAR(20))
- Week (INT)
- IsWeekday (BIT)
- IsMonthEnd (BIT)
- IsQuarterEnd (BIT)
- IsYearEnd (BIT)
- FiscalYear (INT)
- FiscalQuarter (INT)
- FiscalMonth (INT)

Data Type Configuration:
- DateKey: Whole Number
- Date: Date
- MonthName, DayName: Text
- IsWeekday, IsMonthEnd: True/False

Calculated Columns (In Power BI):
- QuarterName = "Q" & [Quarter] & " " & [Year]
- WeekStartDate = DATE(YEAR([Date]), 1, 1) + (WEEKNUM([Date])-1)*7
```

---

### 2. Dim_Company (Organization)
```
Table: dbo.Dim_Company
Size: ~1,000 rows
Refresh: Weekly
Import Mode: Import

Columns:
- CompanyKey (INT, PK)
- CompanyID (INT)
- CompanyName (VARCHAR(200))
- LegalName (VARCHAR(200))
- IndustryCode (VARCHAR(50))
- IndustryName (VARCHAR(100))
- CountryCode (CHAR(2))
- CountryName (VARCHAR(100))
- RegionID (INT)
- RegionName (VARCHAR(100))
- CompanySize (VARCHAR(20))
- FoundedYear (INT)
- Revenue (DECIMAL(18,2))
- EmployeeCount (INT)
- PrimaryContact (VARCHAR(200))
- Status (VARCHAR(20))
- IsActive (BIT)
- CreatedDate (DATETIME)
- LastModifiedDate (DATETIME)

Data Type Configuration:
- CompanyName: Text
- IndustryCode: Text (format code)
- Revenue: Decimal Number
- EmployeeCount: Whole Number
- IsActive: True/False
```

---

### 3. Dim_Customer (Customer Master)
```
Table: dbo.Dim_Customer
Size: ~500,000 rows
Refresh: Daily
Import Mode: Import (with aggregations for performance)

Columns:
- CustomerKey (INT, PK)
- CustomerID (INT, Natural key)
- CustomerName (VARCHAR(200))
- Segment (VARCHAR(50))
  Values: Premium, Standard, Economy
- SubSegment (VARCHAR(50))
- IndustryCode (VARCHAR(50))
- CountryCode (CHAR(2))
- CountryName (VARCHAR(100))
- RegionCode (VARCHAR(10))
- RegionName (VARCHAR(100))
- CustomerType (VARCHAR(20))
  Values: Enterprise, Mid-Market, SMB, Individual
- Status (VARCHAR(20))
  Values: Active, Inactive, Prospect
- CustomerAcquisitionDate (DATE)
- LastTransactionDate (DATE)
- ContractEndDate (DATE)
- AnnualContractValue (DECIMAL(18,2))
- YTDSpend (DECIMAL(18,2))
- IsActive (BIT)
- CreatedDate (DATETIME)
- LastModifiedDate (DATETIME)

Data Type Configuration:
- Segment, SubSegment: Text (set as Category)
- CustomerType: Text (set as Category)
- AnnualContractValue, YTDSpend: Decimal Number
- Status: Text
```

---

### 4. Dim_Product (Product Catalog)
```
Table: dbo.Dim_Product
Size: ~100,000 rows
Refresh: Weekly
Import Mode: Import

Columns:
- ProductKey (INT, PK)
- ProductID (INT)
- ProductName (VARCHAR(300))
- ProductFamily (VARCHAR(100))
- ProductCategory (VARCHAR(100))
- ProductSubCategory (VARCHAR(100))
- BrandName (VARCHAR(100))
- ManufacturerID (INT)
- ListPrice (DECIMAL(10,2))
- StandardCost (DECIMAL(10,2))
- UnitWeight (DECIMAL(8,3))
- IsActive (BIT)
- LaunchDate (DATE)
- DiscontinueDate (DATE)
- CreatedDate (DATETIME)

Data Type Configuration:
- ProductFamily, Category: Text (set as Category)
- ListPrice, StandardCost: Currency
```

---

### 5. Dim_Employee (Employee Master)
```
Table: dbo.Dim_Employee
Size: ~50,000 rows
Refresh: Daily
Import Mode: Import

Columns:
- EmployeeKey (INT, PK)
- EmployeeID (INT)
- FirstName (VARCHAR(100))
- LastName (VARCHAR(100))
- FullName (VARCHAR(200))
- EmailAddress (VARCHAR(200))
- JobTitle (VARCHAR(100))
- DepartmentName (VARCHAR(100))
- ManagerEmployeeID (INT, FK to self)
- HireDate (DATE)
- TerminationDate (DATE)
- IsActive (BIT)
- CountryCode (CHAR(2))
- RegionName (VARCHAR(100))
- SalesTerritory (VARCHAR(100))

Data Type Configuration:
- FullName: Text
- JobTitle, DepartmentName: Text (Category)
- IsActive: True/False
```

---

### 6. Dim_Geography (Geographic Hierarchy)
```
Table: dbo.Dim_Geography
Size: ~5,000 rows
Refresh: Quarterly
Import Mode: Import

Columns:
- GeographyKey (INT, PK)
- CountryKey (INT)
- CountryName (VARCHAR(100))
- CountryCode (CHAR(2))
- StateProvinceKey (INT)
- StateProvinceName (VARCHAR(100))
- StateProvinceCode (VARCHAR(5))
- CityKey (INT)
- CityName (VARCHAR(100))
- PostalCode (VARCHAR(10))
- Region (VARCHAR(100))
- Latitude (DECIMAL(9,6))
- Longitude (DECIMAL(9,6))
- SalesRegion (VARCHAR(100))

Data Type Configuration:
- Latitude, Longitude: Decimal Number (for mapping)
- GeographyKey relationship: Used in multiple fact tables
```

---

## FACT TABLES

### 1. Fact_Sales (Transaction Level)
```
Table: dbo.Fact_Sales
Size: ~50 million rows (incremental refresh recommended)
Refresh: Daily (incremental from previous day)
Import Mode: Import with Aggregations

Columns:
- SalesKey (INT, PK)
- SalesOrderNumber (VARCHAR(50), Natural key)
- SalesOrderLineNumber (INT)
- OrderDate (DATE, FK to Dim_Date)
- ShipDate (DATE, FK to Dim_Date)
- DeliveryDate (DATE, FK to Dim_Date)
- CustomerKey (INT, FK to Dim_Customer)
- ProductKey (INT, FK to Dim_Product)
- EmployeeKey (INT, FK to Dim_Employee)
- GeographyKey (INT, FK to Dim_Geography)
- CompanyKey (INT, FK to Dim_Company)
- OrderQuantity (INT)
- UnitPrice (DECIMAL(10,2))
- ExtendedAmount (DECIMAL(15,2))
- DiscountAmount (DECIMAL(15,2))
- TaxAmount (DECIMAL(15,2))
- TotalDue (DECIMAL(15,2))
- OrderStatus (VARCHAR(20))
  Values: Completed, Pending, Cancelled, Refunded
- PaymentMethod (VARCHAR(50))
- ShippingMethod (VARCHAR(50))
- OnTimeDelivery (BIT)
- CreatedDate (DATETIME)

Data Type Configuration:
- OrderQuantity: Whole Number
- UnitPrice, ExtendedAmount: Currency
- OrderStatus: Text (Category)
- OnTimeDelivery: True/False

Aggregations (For Dashboard Performance):
- Sum of TotalDue by CustomerKey, OrderDate
- Sum of OrderQuantity by ProductKey, OrderDate
- Count of Orders by GeographyKey, OrderDate
```

---

### 2. Fact_Finance (Financial Data)
```
Table: dbo.Fact_Finance
Size: ~2 million rows
Refresh: Daily
Import Mode: Import

Columns:
- FinanceKey (INT, PK)
- DateKey (INT, FK to Dim_Date)
- CompanyKey (INT, FK to Dim_Company)
- DepartmentKey (INT, FK to Dim_Department)
- GLAccountKey (INT, FK to Dim_GLAccount)
- CurrencyCode (VARCHAR(3))
- Amount (DECIMAL(18,2))
- AmountLocalCurrency (DECIMAL(18,2))
- Quantity (INT)
- TransactionType (VARCHAR(50))
  Values: Revenue, COGS, OpEx, CapEx, Tax
- FiscalYear (INT)
- FiscalMonth (INT)
- CreatedDate (DATETIME)

Data Type Configuration:
- Amount: Currency
- Quantity: Whole Number
- TransactionType: Text (Category)
```

---

### 3. Fact_Customer_Metrics (Customer KPIs)
```
Table: dbo.Fact_Customer_Metrics
Size: ~5 million rows (Monthly snapshot)
Refresh: Daily
Import Mode: Import

Columns:
- MetricKey (INT, PK)
- DateKey (INT, FK to Dim_Date)
- CustomerKey (INT, FK to Dim_Customer)
- TotalPurchases (INT)
- TotalSpend (DECIMAL(15,2))
- AverageOrderValue (DECIMAL(10,2))
- PurchaseFrequency (INT)
- DaysSinceLastPurchase (INT)
- CustomerLifetimeValue (DECIMAL(15,2))
- IsChurned (BIT)
- ChurnRiskScore (DECIMAL(5,2))
  Range: 0-100
- NPS_Score (INT)
  Range: -100 to 100
- RetentionFlag (BIT)
- CreatedDate (DATETIME)

Data Type Configuration:
- TotalSpend: Currency
- NPS_Score: Whole Number
- ChurnRiskScore: Decimal Number
- IsChurned, RetentionFlag: True/False
```

---

### 4. Fact_Operational_Metrics (Operations KPIs)
```
Table: dbo.Fact_Operational_Metrics
Size: ~1 million rows
Refresh: Daily
Import Mode: Import

Columns:
- MetricKey (INT, PK)
- DateKey (INT, FK to Dim_Date)
- ProcessName (VARCHAR(200))
- ProcessID (INT)
- MetricName (VARCHAR(200))
- MetricValue (DECIMAL(15,4))
- MetricTarget (DECIMAL(15,4))
- UnitOfMeasure (VARCHAR(50))
- Status (VARCHAR(20))
  Values: OnTrack, AtRisk, Failed
- EmployeeKey (INT, FK to Dim_Employee)
- GeographyKey (INT, FK to Dim_Geography)
- CreatedDate (DATETIME)

Data Type Configuration:
- MetricValue, MetricTarget: Decimal Number
- Status: Text (Category)
```

---

## IMPORT STRATEGY

### Full Import Tables
- Dim_Date
- Dim_Company
- Dim_Product
- Dim_Geography
- Dim_Employee

### Incremental Refresh Tables (Recommended)
- Fact_Sales (Import last 90 days, keep last 3 years)
- Fact_Finance (Import last 36 months)
- Fact_Customer_Metrics (Import last 24 months)

### Refresh Schedule
```
Midnight - 1 AM UTC:
- Fact_Sales (Incremental)
- Fact_Customer_Metrics
- Fact_Operational_Metrics

2 AM UTC:
- Dim_Customer
- Dim_Employee
- Fact_Finance

Weekly (Sundays, 3 AM UTC):
- All dimension tables (full refresh)
- Incremental reset/rebuild
```

---

## DATA TRANSFORMATION RULES (Power Query)

### Rule 1: Remove Test Data
```
Filter out all records where CompanyID < 0 or CustomerID < 0
```

### Rule 2: Handle Nulls
```
- DiscountAmount: Replace null with 0
- DaysSinceLastPurchase: Replace null with 999
- ChurnRiskScore: Replace null with 0
```

### Rule 3: Data Type Conversions
```
- Dates: Ensure all date columns are DATE format
- Amounts: Ensure decimal precision (15,2)
- Flags: Ensure bit columns are TRUE/FALSE
```

### Rule 4: Derived Columns (Power Query)
```
- Revenue = ExtendedAmount + TaxAmount - DiscountAmount
- Profit = Revenue - StandardCost
- MarginPercentage = Profit / Revenue * 100
```

---

## MEMORY OPTIMIZATION

### Compression Settings
- Enable: Data compression for text columns
- Strategy: Use category/group by for repetitive values
- Targeted compression: Status, Type, Category columns

### Aggregation Tables (for large datasets)
```
Daily Aggregation:
- Sales aggregated by Customer × Product × Date
- Finance aggregated by Department × GLAccount × Month
```

---

## VALIDATION CHECKS

After import, verify:
```
✓ Row count matches source
✓ No unexpected nulls in key columns
✓ Date ranges are correct
✓ Foreign key references are intact
✓ Numeric fields within expected ranges
✓ Refresh logs show no errors
```

---

## Next Steps

1. ✓ Verify source table structure in warehouse
2. ✓ Create Power Query transformations
3. ✓ Configure incremental refresh policies
4. ✓ Set up import schedule
5. ✓ Validate data quality post-import
6. ✓ Monitor refresh performance
