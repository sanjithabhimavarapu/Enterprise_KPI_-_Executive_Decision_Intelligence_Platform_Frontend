# Power BI Data Relationships Configuration

## Overview
This document defines all data relationships, relationship types, cardinality, and cross-filter directions for the Enterprise KPI Platform data model.

---

## Relationship Architecture Overview

```
                    Dim_Date
                       |
        _______________|________________
        |       |       |       |       |
    Fact_Sales Fact_Finance Fact_Customer_Metrics Fact_Operational_Metrics

        |       |       |       |
    Dim_Customer Dim_Product Dim_Employee Dim_Geography
        |       |       |
    Dim_Company Dim_Department Dim_GLAccount

        Geographic Hierarchy:
        Country → State/Province → City
```

---

## PRIMARY RELATIONSHIPS

### 1. Date Relationships

#### Relationship 1.1: Fact_Sales → Dim_Date (OrderDate)
```
Primary Table: Dim_Date
Foreign Table: Fact_Sales
Foreign Key: Fact_Sales[OrderDate]
Primary Key: Dim_Date[DateKey]

Cardinality: One-to-Many (1:*)
  - Dim_Date is singular (1 date = 1 row)
  - Fact_Sales is plural (many sales on same date)

Cross Filter Direction: Single
  - Filters flow: Dim_Date → Fact_Sales
  - Reason: Date selection should filter sales

Active: Yes
Relationship Type: Regular
```

#### Relationship 1.2: Fact_Sales → Dim_Date (ShipDate)
```
Primary Table: Dim_Date
Foreign Table: Fact_Sales
Foreign Key: Fact_Sales[ShipDate]
Primary Key: Dim_Date[DateKey]

Cardinality: One-to-Many (1:*)
Cross Filter Direction: Single
Active: No (inactive - use for specific scenarios)

Note: Activate when analyzing shipment patterns
```

#### Relationship 1.3: Fact_Sales → Dim_Date (DeliveryDate)
```
Primary Table: Dim_Date
Foreign Table: Fact_Sales
Foreign Key: Fact_Sales[DeliveryDate]
Primary Key: Dim_Date[DateKey]

Cardinality: One-to-Many (1:*)
Cross Filter Direction: Single
Active: No (inactive - activate for delivery analysis)
```

#### Relationship 1.4: Fact_Finance → Dim_Date
```
Primary Table: Dim_Date
Foreign Table: Fact_Finance
Foreign Key: Fact_Finance[DateKey]
Primary Key: Dim_Date[DateKey]

Cardinality: One-to-Many (1:*)
Cross Filter Direction: Single
Active: Yes
```

#### Relationship 1.5: Fact_Customer_Metrics → Dim_Date
```
Primary Table: Dim_Date
Foreign Table: Fact_Customer_Metrics
Foreign Key: Fact_Customer_Metrics[DateKey]
Primary Key: Dim_Date[DateKey]

Cardinality: One-to-Many (1:*)
Cross Filter Direction: Single
Active: Yes
```

#### Relationship 1.6: Fact_Operational_Metrics → Dim_Date
```
Primary Table: Dim_Date
Foreign Table: Fact_Operational_Metrics
Foreign Key: Fact_Operational_Metrics[DateKey]
Primary Key: Dim_Date[DateKey]

Cardinality: One-to-Many (1:*)
Cross Filter Direction: Single
Active: Yes
```

---

### 2. Customer Relationships

#### Relationship 2.1: Fact_Sales → Dim_Customer
```
Primary Table: Dim_Customer
Foreign Table: Fact_Sales
Foreign Key: Fact_Sales[CustomerKey]
Primary Key: Dim_Customer[CustomerKey]

Cardinality: One-to-Many (1:*)
Cross Filter Direction: Single
  - Filters: Dim_Customer → Fact_Sales
  - Reason: Customer selection filters their transactions

Active: Yes
Relationship Type: Regular
```

#### Relationship 2.2: Fact_Customer_Metrics → Dim_Customer
```
Primary Table: Dim_Customer
Foreign Table: Fact_Customer_Metrics
Foreign Key: Fact_Customer_Metrics[CustomerKey]
Primary Key: Dim_Customer[CustomerKey]

Cardinality: One-to-Many (1:*)
Cross Filter Direction: Single
Active: Yes
```

#### Relationship 2.3: Dim_Customer → Dim_Company
```
Primary Table: Dim_Company
Foreign Table: Dim_Customer
Foreign Key: Dim_Customer[CompanyKey]
Primary Key: Dim_Company[CompanyKey]

Cardinality: One-to-Many (1:*)
Cross Filter Direction: Both
  - Reason: Company/Customer hierarchy for exploration
  
Active: Yes
Relationship Type: Regular
```

#### Relationship 2.4: Dim_Customer → Dim_Geography
```
Primary Table: Dim_Geography
Foreign Table: Dim_Customer
Foreign Key: Dim_Customer[CountryCode]
Primary Key: Dim_Geography[CountryCode]

Cardinality: One-to-Many (1:*)
Cross Filter Direction: Single
Active: Yes
```

---

### 3. Product Relationships

#### Relationship 3.1: Fact_Sales → Dim_Product
```
Primary Table: Dim_Product
Foreign Table: Fact_Sales
Foreign Key: Fact_Sales[ProductKey]
Primary Key: Dim_Product[ProductKey]

Cardinality: One-to-Many (1:*)
Cross Filter Direction: Single
  - Filters: Dim_Product → Fact_Sales
  - Reason: Product selection filters product sales

Active: Yes
Relationship Type: Regular
```

---

### 4. Employee Relationships

#### Relationship 4.1: Fact_Sales → Dim_Employee
```
Primary Table: Dim_Employee
Foreign Table: Fact_Sales
Foreign Key: Fact_Sales[EmployeeKey]
Primary Key: Dim_Employee[EmployeeKey]

Cardinality: One-to-Many (1:*)
Cross Filter Direction: Single
Active: Yes
Purpose: Sales by employee/salesperson
```

#### Relationship 4.2: Fact_Operational_Metrics → Dim_Employee
```
Primary Table: Dim_Employee
Foreign Table: Fact_Operational_Metrics
Foreign Key: Fact_Operational_Metrics[EmployeeKey]
Primary Key: Dim_Employee[EmployeeKey]

Cardinality: One-to-Many (1:*)
Cross Filter Direction: Single
Active: Yes
```

#### Relationship 4.3: Dim_Employee (Self-Referencing)
```
Primary Table: Dim_Employee
Foreign Table: Dim_Employee (as ManagerTable)
Foreign Key: Dim_Employee[ManagerEmployeeID]
Primary Key: Dim_Employee[EmployeeID]

Cardinality: One-to-Many (1:*)
Cross Filter Direction: Single
Active: Yes
Purpose: Manager-Subordinate hierarchy (organizational reporting)
```

---

### 5. Geography Relationships

#### Relationship 5.1: Fact_Sales → Dim_Geography
```
Primary Table: Dim_Geography
Foreign Table: Fact_Sales
Foreign Key: Fact_Sales[GeographyKey]
Primary Key: Dim_Geography[GeographyKey]

Cardinality: One-to-Many (1:*)
Cross Filter Direction: Single
Active: Yes
Purpose: Geographic analysis of sales
```

#### Relationship 5.2: Fact_Operational_Metrics → Dim_Geography
```
Primary Table: Dim_Geography
Foreign Table: Fact_Operational_Metrics
Foreign Key: Fact_Operational_Metrics[GeographyKey]
Primary Key: Dim_Geography[GeographyKey]

Cardinality: One-to-Many (1:*)
Cross Filter Direction: Single
Active: Yes
```

#### Relationship 5.3: Dim_Geography (Hierarchical - Country-State-City)
```
Internal Hierarchy in Dim_Geography:
Country → StateProvince → City

Used for:
- Geographic drill-down in visualizations
- Regional performance analysis
- Sales territory mapping
```

---

### 6. Company Relationships

#### Relationship 6.1: Fact_Sales → Dim_Company
```
Primary Table: Dim_Company
Foreign Table: Fact_Sales
Foreign Key: Fact_Sales[CompanyKey]
Primary Key: Dim_Company[CompanyKey]

Cardinality: One-to-Many (1:*)
Cross Filter Direction: Single
Active: Yes
Purpose: Multi-company consolidation view
```

#### Relationship 6.2: Fact_Finance → Dim_Company
```
Primary Table: Dim_Company
Foreign Table: Fact_Finance
Foreign Key: Fact_Finance[CompanyKey]
Primary Key: Dim_Company[CompanyKey]

Cardinality: One-to-Many (1:*)
Cross Filter Direction: Single
Active: Yes
```

---

## RELATIONSHIP SUMMARY TABLE

| # | From Table | To Table | Cardinality | Cross-Filter | Active | Purpose |
|---|---|---|---|---|---|---|
| 1.1 | Dim_Date | Fact_Sales (OrderDate) | 1:* | Single | Yes | Sales date filtering |
| 1.2 | Dim_Date | Fact_Sales (ShipDate) | 1:* | Single | No | Shipment analysis |
| 1.3 | Dim_Date | Fact_Sales (DeliveryDate) | 1:* | Single | No | Delivery tracking |
| 1.4 | Dim_Date | Fact_Finance | 1:* | Single | Yes | Financial date filtering |
| 1.5 | Dim_Date | Fact_Customer_Metrics | 1:* | Single | Yes | Customer date filtering |
| 1.6 | Dim_Date | Fact_Operational_Metrics | 1:* | Single | Yes | Operational date filtering |
| 2.1 | Dim_Customer | Fact_Sales | 1:* | Single | Yes | Sales by customer |
| 2.2 | Dim_Customer | Fact_Customer_Metrics | 1:* | Single | Yes | Customer metrics |
| 2.3 | Dim_Company | Dim_Customer | 1:* | Both | Yes | Company-Customer hierarchy |
| 2.4 | Dim_Geography | Dim_Customer | 1:* | Single | Yes | Customer by geography |
| 3.1 | Dim_Product | Fact_Sales | 1:* | Single | Yes | Sales by product |
| 4.1 | Dim_Employee | Fact_Sales | 1:* | Single | Yes | Sales by employee |
| 4.2 | Dim_Employee | Fact_Operational_Metrics | 1:* | Single | Yes | Ops metrics by employee |
| 4.3 | Dim_Employee | Dim_Employee | 1:* | Single | Yes | Manager hierarchy |
| 5.1 | Dim_Geography | Fact_Sales | 1:* | Single | Yes | Sales by geography |
| 5.2 | Dim_Geography | Fact_Operational_Metrics | 1:* | Single | Yes | Ops by geography |
| 6.1 | Dim_Company | Fact_Sales | 1:* | Single | Yes | Multi-company sales |
| 6.2 | Dim_Company | Fact_Finance | 1:* | Single | Yes | Multi-company finance |

---

## CROSS-FILTER DIRECTION DETAILS

### Single Direction (Recommended)
```
When to use:
- Dimension to Fact: Always single
- Hierarchy within dimension: Carefully evaluate

Example:
- Dim_Customer → Fact_Sales (Yes)
  Selecting customer filters their sales

- Fact_Sales → Dim_Customer (No)
  Selecting sales should NOT limit available customers
```

### Both Directions (Use Sparingly)
```
When to use:
- Dimensional hierarchies (Company → Customer)
- Related dimensions at same grain
- Only when business logic requires it

Example:
- Dim_Company ↔ Dim_Customer (Both)
  User can select company and see customers
  User can select customer and see company

⚠️ WARNING: Both directions can cause filter ambiguity and performance issues
```

---

## CARDINALITY RULES

### One-to-Many (1:*)
```
✓ Used for: Dimension → Fact relationships
✓ Used for: Dimension hierarchies
✓ Used for: Dimension → Dimension hierarchies

Example:
- One Product → Many Sales
- One Customer → Many Transactions
- One Manager → Many Employees
```

### Many-to-One (*:1)
```
This is inverse of 1:*
Not explicitly created; Power BI auto-detects based on direction
```

### Many-to-Many (*:*)
```
⚠️ AVOID in Power BI (causes ambiguity)

Solution: Create bridge table if needed
Example:
  Product ←→ Bridge_Product_Promotion ←→ Promotion
  (1:*)                                 (*:1)
```

### One-to-One (1:1)
```
✓ Used for: Extended attributes of dimension
✓ Used for: Denormalized columns

Example:
- Dim_Customer (1) ←→ Dim_Customer_Extended (1)
  (CustomerKey) ←→ (CustomerKey)
```

---

## RELATIONSHIP PROPERTIES (Power BI Settings)

### General Properties
```
✓ Assume Referential Integrity: 
  - Enable if warehouse has constraints
  - Improves query performance
  - Default: Disabled (safe)

✓ Hide Relationship:
  - Enable for internal relationships
  - Keeps model clean for end users
  - Used for hidden calculations
```

### Cross-Filter Direction
```
Options:
1. Single (From Primary to Foreign)
   - Most common, default
   - 95% of relationships use this

2. Both (Bidirectional)
   - Allows filtering both ways
   - Use sparingly (performance impact)
   - Document usage reasons

3. Both (Limited to this visual) - Context specific
   - Advanced: Used in some measures
```

---

## RELATIONSHIP VALIDATION CHECKLIST

✓ **Primary Key Integrity**
- Primary table key is unique
- No null values in primary key
- Foreign key references are valid

✓ **Data Type Matching**
- Foreign key data type = Primary key data type
- Both are INT, VARCHAR, etc. (consistent)

✓ **Cardinality Accuracy**
- Relationship cardinality matches data
- Verify with SELECT COUNT(DISTINCT) queries

✓ **Cross-Filter Logic**
- Direction makes business sense
- No circular references
- Filters propagate correctly

✓ **Performance**
- No *:* (many-to-many) relationships
- Relationship columns indexed in source
- Relationships don't create calculation loops

---

## RELATIONSHIP OPTIMIZATION TIPS

### 1. Indexing Strategy
```
Create indexes on all foreign key columns in fact tables:
CREATE INDEX idx_Sales_CustomerKey ON Fact_Sales(CustomerKey)
CREATE INDEX idx_Sales_ProductKey ON Fact_Sales(ProductKey)
CREATE INDEX idx_Sales_EmployeeKey ON Fact_Sales(EmployeeKey)
CREATE INDEX idx_Sales_DateKey ON Fact_Sales(DateKey)
```

### 2. Relationship Performance Considerations
```
- Join on INT keys (faster than VARCHAR)
- Avoid *:* relationships (use bridge tables)
- Limit bidirectional relationships
- Use "Assume Referential Integrity" when safe
```

### 3. Hierarchy Design
```
Use Built-in Hierarchies:
Geography: Country → State → City
Employee: Company → Department → Employee → Manager

Benefits:
- Drill-down capability
- Consistent grouping
- Better visualization support
```

---

## TROUBLESHOOTING RELATIONSHIP ISSUES

### Issue: Unexpected Results in Aggregations
```
Cause: Missing relationship or wrong cardinality
Solution: 
- Verify relationship exists
- Check cardinality matches data
- Validate foreign key values exist in primary table
```

### Issue: Performance Degradation
```
Cause: Too many bidirectional relationships
Solution:
- Change to single-direction where possible
- Remove inactive relationships
- Use "Assume Referential Integrity"
```

### Issue: Blank Values in Visualizations
```
Cause: Unmatched foreign key values (no corresponding dimension record)
Solution:
- Add "Unknown" or "Unassigned" records to dimension table
- Check data quality in source
- Implement ETL validation
```

---

## IMPLEMENTATION CHECKLIST

- [ ] Verify all source tables structure and data quality
- [ ] Create all dimension tables first
- [ ] Import all dimension tables into Power BI
- [ ] Create relationships from Dim_Date first (most critical)
- [ ] Create customer and product relationships
- [ ] Create employee and geography relationships
- [ ] Create company relationships
- [ ] Validate all relationships are correct
- [ ] Test filter propagation across dashboards
- [ ] Enable "Assume Referential Integrity" if applicable
- [ ] Hide internal/bridge relationships from users
- [ ] Document any inactive relationships and activation criteria
- [ ] Create relationship diagram documentation
- [ ] Validate performance before deployment

---

## Next Steps

1. ✓ Review relationship architecture with data architect
2. ✓ Implement all relationships in Power BI model
3. ✓ Create visual relationship diagram in Power BI
4. ✓ Validate data quality and relationships
5. ✓ Test filter flow in sample visualizations
6. ✓ Document any custom relationship logic
