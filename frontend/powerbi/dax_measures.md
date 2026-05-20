# Power BI DAX Measures & Calculations

## Overview
This document provides DAX code for creating calculated measures and columns in the Enterprise KPI Platform Power BI model. These leverage the relationships defined in data_relationships.md.

---

## FINANCIAL MEASURES

### 1. Total Revenue
```dax
Total Revenue = 
    SUM(Fact_Sales[Revenue])

Description: Sum of all revenue from sales transactions
Related Column: Fact_Sales[Revenue] (calculated in Power Query)
Filters: Date, Customer, Product, Geography, Company
Format: $#,##0.00
```

---

### 2. Net Profit
```dax
Net Profit = 
    SUMX(
        Fact_Sales,
        (Fact_Sales[ExtendedAmount] + Fact_Sales[TaxAmount] - Fact_Sales[DiscountAmount])
        - (Fact_Sales[Quantity] * RELATED(Dim_Product[StandardCost]))
    )

Description: Revenue minus cost of goods sold
Uses: Relationship between Sales and Product
Format: $#,##0.00
```

---

### 3. Profit Margin %
```dax
Profit Margin % = 
    DIVIDE(
        [Net Profit],
        [Total Revenue],
        0
    ) * 100

Description: Net profit as percentage of revenue
Depends On: [Total Revenue], [Net Profit] measures
Format: 0.0"%"
Range: 0-100%
```

---

### 4. Average Order Value
```dax
Average Order Value = 
    DIVIDE(
        [Total Revenue],
        DISTINCTCOUNT(Fact_Sales[SalesOrderNumber]),
        0
    )

Description: Average revenue per order
Format: $#,##0.00
Note: Uses DISTINCTCOUNT to avoid double-counting line items
```

---

### 5. YTD Revenue
```dax
YTD Revenue = 
    CALCULATE(
        [Total Revenue],
        DATESYTD(Dim_Date[Date])
    )

Description: Revenue year-to-date
Uses: Dim_Date relationship and DATESYTD function
Format: $#,##0.00
Context: Automatically adjusts for current year
```

---

### 6. Prior Year Revenue
```dax
Prior Year Revenue = 
    CALCULATE(
        [Total Revenue],
        DATEADD(Dim_Date[Date], -1, YEAR)
    )

Description: Revenue from same period previous year
Uses: Date relationship and DATEADD function
Format: $#,##0.00
Use Case: YoY comparison
```

---

### 7. Revenue Growth %
```dax
Revenue Growth % = 
    DIVIDE(
        [Total Revenue] - [Prior Year Revenue],
        [Prior Year Revenue],
        0
    ) * 100

Description: Year-over-year revenue growth percentage
Depends On: [Total Revenue], [Prior Year Revenue]
Format: 0.0"%"
Interpretation: Positive = growth, Negative = decline
```

---

### 8. Revenue vs Target
```dax
Revenue vs Target = 
    DIVIDE(
        [Total Revenue],
        [Revenue Target],
        0
    )

Description: Actual revenue divided by target
Format: 0.0%
Interpretation: > 100% = exceeds target, < 100% = below target
```

---

## CUSTOMER METRICS

### 9. Total Customers
```dax
Total Customers = 
    DISTINCTCOUNT(Fact_Sales[CustomerKey])

Description: Count of unique customers with sales
Note: Counts only customers with transactions
Format: #,##0
Alternative: Use Dim_Customer[CustomerKey] to count all customers
```

---

### 10. Active Customers
```dax
Active Customers = 
    CALCULATE(
        DISTINCTCOUNT(Dim_Customer[CustomerKey]),
        FILTER(Dim_Customer, Dim_Customer[IsActive] = TRUE())
    )

Description: Count of active customer records
Uses: Dim_Customer dimension
Format: #,##0
Context-Sensitive: No (always uses all active customers)
```

---

### 11. Customer Retention Rate
```dax
Customer Retention Rate = 
    DIVIDE(
        CALCULATE(
            DISTINCTCOUNT(Fact_Customer_Metrics[CustomerKey]),
            FILTER(
                Fact_Customer_Metrics,
                Fact_Customer_Metrics[RetentionFlag] = TRUE()
            )
        ),
        DISTINCTCOUNT(Fact_Customer_Metrics[CustomerKey]),
        0
    ) * 100

Description: Percentage of customers retained
Uses: Fact_Customer_Metrics[RetentionFlag]
Format: 0.0"%"
Range: 0-100%
```

---

### 12. Customer Churn Rate
```dax
Customer Churn Rate = 
    DIVIDE(
        CALCULATE(
            DISTINCTCOUNT(Fact_Customer_Metrics[CustomerKey]),
            FILTER(
                Fact_Customer_Metrics,
                Fact_Customer_Metrics[IsChurned] = TRUE()
            )
        ),
        DISTINCTCOUNT(Fact_Customer_Metrics[CustomerKey]),
        0
    ) * 100

Description: Percentage of customers lost
Uses: Fact_Customer_Metrics[IsChurned]
Format: 0.0"%"
Range: 0-100%
Complement: 100% - Retention Rate
```

---

### 13. Customer Lifetime Value
```dax
Customer Lifetime Value = 
    AVERAGEX(
        VALUES(Fact_Customer_Metrics[CustomerKey]),
        CALCULATE(
            SUM(Fact_Customer_Metrics[CustomerLifetimeValue])
        )
    )

Description: Average CLV across all customers
Uses: Fact_Customer_Metrics dimension
Format: $#,##0.00
Context: Changes with customer or date filters
```

---

### 14. NPS Score
```dax
NPS Score = 
    CALCULATE(
        AVERAGE(Fact_Customer_Metrics[NPS_Score])
    )

Description: Average Net Promoter Score
Format: 0
Range: -100 to 100
Scale: Positive = good, Negative = poor, 0 = neutral
```

---

### 15. Customers at Risk
```dax
Customers at Risk = 
    CALCULATE(
        DISTINCTCOUNT(Fact_Customer_Metrics[CustomerKey]),
        FILTER(
            Fact_Customer_Metrics,
            Fact_Customer_Metrics[ChurnRiskScore] > 70
        )
    )

Description: Count of customers with high churn risk
Uses: Fact_Customer_Metrics[ChurnRiskScore]
Format: #,##0
Risk Level: Score > 70
Action: Proactive retention campaigns
```

---

## OPERATIONAL METRICS

### 16. On-Time Delivery Rate
```dax
On-Time Delivery Rate = 
    DIVIDE(
        CALCULATE(
            DISTINCTCOUNT(Fact_Sales[SalesOrderNumber]),
            FILTER(Fact_Sales, Fact_Sales[OnTimeDelivery] = TRUE())
        ),
        DISTINCTCOUNT(Fact_Sales[SalesOrderNumber]),
        0
    ) * 100

Description: Percentage of orders delivered on time
Uses: Fact_Sales[OnTimeDelivery]
Format: 0.0"%"
Range: 0-100%
Target: Typically 95%+
```

---

### 17. Average Days to Deliver
```dax
Average Days to Deliver = 
    AVERAGE(Fact_Sales[DaysToDeliver])

Description: Average number of days from order to delivery
Uses: Calculated column DaysToDeliver in Fact_Sales
Format: 0.0
Units: Days
Context: Filters by customer, product, geography
```

---

### 18. Order Fulfillment Rate
```dax
Order Fulfillment Rate = 
    DIVIDE(
        CALCULATE(
            DISTINCTCOUNT(Fact_Sales[SalesOrderNumber]),
            FILTER(Fact_Sales, Fact_Sales[OrderStatus] = "Completed")
        ),
        DISTINCTCOUNT(Fact_Sales[SalesOrderNumber]),
        0
    ) * 100

Description: Percentage of orders successfully completed
Uses: Fact_Sales[OrderStatus]
Format: 0.0"%"
Statuses: Completed, Pending, Cancelled, Refunded
```

---

### 19. Average Discount %
```dax
Average Discount % = 
    CALCULATE(
        AVERAGE(Fact_Sales[DiscountPercent])
    )

Description: Average discount applied to orders
Uses: DiscountPercent calculated in Power Query
Format: 0.0"%"
Analysis: Higher discounts may indicate promotional activity
```

---

### 20. Total Orders
```dax
Total Orders = 
    DISTINCTCOUNT(Fact_Sales[SalesOrderNumber])

Description: Count of unique orders
Format: #,##0
Note: Counts each order once even with multiple line items
```

---

## GEOGRAPHIC METRICS

### 21. Revenue by Region
```dax
Revenue by Region = 
    CALCULATE(
        [Total Revenue],
        VALUES(Dim_Geography[Region])
    )

Description: Revenue filtered by geography context
Uses: Dim_Geography relationship
Format: $#,##0.00
Context: Auto-filters by selected region
```

---

### 22. Top Revenue Country
```dax
Top Revenue Country = 
    TOPN(
        1,
        VALUES(Dim_Geography[CountryName]),
        [Total Revenue]
    )

Description: Country with highest revenue
Returns: Text (country name)
Use Case: Executive dashboard insight
```

---

### 23. Country Count
```dax
Country Count = 
    DISTINCTCOUNT(Fact_Sales[GeographyKey])

Description: Number of countries with sales
Format: #,##0
Context: Changes based on date/product/customer filters
```

---

## PRODUCT METRICS

### 24. Best Selling Product
```dax
Best Selling Product = 
    TOPN(
        1,
        VALUES(Dim_Product[ProductName]),
        COUNTA(Fact_Sales[Quantity])
    )

Description: Product with most units sold
Returns: Text (product name)
Use Case: Product performance analysis
```

---

### 25. Average Product Price
```dax
Average Product Price = 
    AVERAGE(Dim_Product[ListPrice])

Description: Mean list price across products
Format: $#,##0.00
Scope: All products (not filtered by sales)
```

---

### 26. Product Margin
```dax
Product Margin = 
    DIVIDE(
        SUM(Dim_Product[ListPrice]) - SUM(Dim_Product[StandardCost]),
        SUM(Dim_Product[ListPrice]),
        0
    ) * 100

Description: Average gross margin across products
Format: 0.0"%"
Range: 0-100%
Calculation: (ListPrice - StandardCost) / ListPrice
```

---

## EMPLOYEE METRICS

### 27. Sales by Employee
```dax
Sales by Employee = 
    CALCULATE(
        [Total Revenue],
        VALUES(Dim_Employee[FullName])
    )

Description: Revenue attributed to each employee
Uses: Fact_Sales[EmployeeKey] → Dim_Employee relationship
Format: $#,##0.00
Context: Filters by selected employee
```

---

### 28. Top Salesperson
```dax
Top Salesperson = 
    TOPN(
        1,
        VALUES(Dim_Employee[FullName]),
        [Total Revenue]
    )

Description: Employee with highest revenue
Returns: Text (employee name)
Use Case: Sales performance recognition
```

---

### 29. Average Sales per Employee
```dax
Average Sales per Employee = 
    DIVIDE(
        [Total Revenue],
        DISTINCTCOUNT(Fact_Sales[EmployeeKey]),
        0
    )

Description: Revenue per active sales employee
Format: $#,##0.00
Calculation: Total Revenue / Distinct Employee Count
```

---

## FINANCIAL ANALYSIS MEASURES

### 30. EBITDA Calculation
```dax
EBITDA = 
    SUMX(
        Fact_Finance,
        IF(
            Fact_Finance[TransactionType] IN {"Revenue", "COGS", "OpEx"},
            Fact_Finance[Amount],
            0
        )
    )

Description: Earnings Before Interest, Taxes, Depreciation, Amortization
Uses: Fact_Finance[TransactionType] categories
Format: $#,##0.00
Note: Requires proper GL account mapping
```

---

### 31. Cash Flow Analysis
```dax
Cash Flow = 
    CALCULATE(
        SUM(Fact_Finance[Amount]),
        FILTER(
            Fact_Finance,
            Fact_Finance[TransactionType] IN {"Revenue", "COGS", "OpEx"}
        )
    )

Description: Inflows minus outflows
Uses: Fact_Finance dimension
Format: $#,##0.00
Context: Month or period-based analysis
```

---

## TIME INTELLIGENCE MEASURES

### 32. Month-over-Month Change
```dax
MoM Change = 
    DIVIDE(
        [Total Revenue],
        CALCULATE(
            [Total Revenue],
            DATEADD(Dim_Date[Date], -1, MONTH)
        ),
        0
    ) - 1

Description: Month-over-month growth rate
Format: 0.0%
Use Case: Trend analysis
```

---

### 33. Quarter-over-Quarter Change
```dax
QoQ Change = 
    DIVIDE(
        [Total Revenue],
        CALCULATE(
            [Total Revenue],
            DATEADD(Dim_Date[Date], -1, QUARTER)
        ),
        0
    ) - 1

Description: Quarter-over-quarter growth rate
Format: 0.0%
Use Case: Seasonal pattern detection
```

---

### 34. Days Since Refresh
```dax
Days Since Refresh = 
    INT(NOW() - MAX(Fact_Sales[CreatedDate]))

Description: Data freshness indicator
Format: 0
Units: Days
Use Case: Dashboard health monitoring
```

---

## CONDITIONAL/STATUS MEASURES

### 35. Revenue Status (Traffic Light)
```dax
Revenue Status = 
    IF(
        [Revenue vs Target] >= 1,
        "✓ On Target",
        IF(
            [Revenue vs Target] >= 0.95,
            "⚠ At Risk",
            "✗ Below Target"
        )
    )

Description: Status indicator for revenue performance
Format: Text
Values: "✓ On Target", "⚠ At Risk", "✗ Below Target"
Use Case: Executive KPI card background color
```

---

### 36. Churn Risk Level
```dax
Churn Risk Level = 
    IF(
        AVERAGE(Fact_Customer_Metrics[ChurnRiskScore]) > 70,
        "High Risk",
        IF(
            AVERAGE(Fact_Customer_Metrics[ChurnRiskScore]) > 40,
            "Medium Risk",
            "Healthy"
        )
    )

Description: Customer portfolio churn risk category
Format: Text
Use Case: Risk assessment dashboard
```

---

## MEASURE DESIGN BEST PRACTICES

### ✓ DO:
- Use `RELATED()` to reference dimension columns
- Use `ALL()` to override context when needed
- Use `DIVIDE()` for safe division (handles zero)
- Use `CALCULATE()` for context manipulation
- Use `DISTINCTCOUNT()` for unique values
- Format measures appropriately (currency, %, etc.)

### ✗ DON'T:
- Use `SUMPRODUCT()` (use `SUMX()` instead)
- Reference calculated columns in measures (inefficient)
- Create circular dependencies
- Use hardcoded numbers (create parameters instead)
- Mix implicit and explicit measures (be consistent)

---

## MEASURE ORGANIZATION

### Recommended Naming Convention
```
[Calculation Type]_[Metric]_[Dimension]

Examples:
- [Sum_Revenue_by_Customer]
- [Count_Distinct_Orders]
- [Avg_Order_Value]
- [Pct_Growth_YoY]
```

### Organizing in Model
1. **Financial Measures** folder
   - Revenue, Profit, Margin, EBITDA
   
2. **Customer Metrics** folder
   - Retention, Churn, CLV, NPS
   
3. **Operational Metrics** folder
   - On-Time Delivery, Fulfillment, Efficiency
   
4. **Analysis Measures** folder
   - YoY, MoM, Variance, Comparisons

---

## TESTING MEASURES

### Validation Checklist
```
✓ Does measure return expected values?
✓ Does measure respond to slicers correctly?
✓ Is measure performance acceptable (< 100ms)?
✓ Are calculations correct for edge cases?
✓ Is measure formatting appropriate?
✓ Is measure documented with comment?
✓ Does measure pass unit tests?
```

### Sample Unit Tests
```dax
// Test: Total Revenue should be positive
Test_Revenue_Positive = IF([Total Revenue] > 0, "PASS", "FAIL")

// Test: Margin should be between 0-100%
Test_Margin_Valid_Range = IF(AND([Profit Margin %] >= 0, [Profit Margin %] <= 100), "PASS", "FAIL")

// Test: Retention + Churn should equal ~100%
Test_Retention_Churn_Sum = [Customer Retention Rate] + [Customer Churn Rate]
```

---

## NEXT STEPS

1. Create measure table in Power BI model
2. Implement measures by category
3. Test each measure with sample data
4. Validate calculations against source system
5. Add measures to dashboards
6. Monitor measure performance
7. Document any complex business logic
