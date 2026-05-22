# Executive Dashboard - Revenue & Regional DAX Measures

## Executive Data Model Requirements

### Fact Tables
1. **Fact_Sales**: Transaction-level sales data
   - SalesID (Key)
   - Date
   - ProductID
   - CustomerID
   - RegionID
   - ChannelID
   - Quantity
   - UnitPrice
   - Revenue (ExtendedAmount)
   - Cost (Cost of Goods Sold)
   - DiscountAmount
   - TaxAmount

2. **Fact_ProfitLoss**: Aggregated P&L data
   - PLID (Key)
   - Date (Month)
   - Revenue
   - COGS (Cost of Goods Sold)
   - GrossProfit
   - OperatingExpenses (by category)
   - NetIncome
   - EBITDAAmount

3. **Fact_CashFlow**: Cash flow data
   - CashFlowID (Key)
   - Date (Month)
   - OperatingCashFlow
   - InvestingCashFlow
   - FinancingCashFlow
   - NetCashFlow
   - ClosingCashBalance

4. **Fact_CustomerSatisfaction**: NPS and survey data
   - SatisfactionID (Key)
   - SurveyDate
   - Respondents
   - PromotersCount
   - PassivesCount
   - DetractorsCount
   - NPS_Score

5. **Fact_MarketShare**: Market intelligence data
   - MarketShareID (Key)
   - ReportDate
   - CompanyName
   - MarketShare_Percent
   - MarketValue_Dollars
   - Rank

### Dimension Tables
1. **Dim_Product**: Product information
   - ProductID (PK)
   - ProductName
   - ProductLine
   - Category
   - SubCategory

2. **Dim_Customer**: Customer information
   - CustomerID (PK)
   - CustomerName
   - Segment (B2B, B2C, Enterprise, SMB)
   - Industry
   - Region

3. **Dim_Geography**: Geographic information
   - RegionID (PK)
   - Region
   - Country
   - State/Province
   - City

4. **Dim_Channel**: Sales channels
   - ChannelID (PK)
   - ChannelName (Direct, Partner, Online, Retail)
   - ChannelType

5. **Dim_Date**: Standard date dimension

---

## DAX Measures - Executive Dashboard

### REVENUE MEASURES

#### Measure 1: Total Revenue
```dax
Total Revenue = 
    SUM(Fact_Sales[Revenue])

Format: $#,##0.00
Description: Sum of all revenue from sales transactions
Related Filters: Date, Region, Product, Channel, Customer
Drill Path: By product, channel, customer, region
```

#### Measure 2: Revenue YTD
```dax
Revenue YTD = 
    CALCULATE(
        [Total Revenue],
        DATESYTD(Dim_Date[Date])
    )

Format: $#,##0.00
Description: Year-to-date revenue
Context: Automatically adjusts for current year
```

#### Measure 3: Revenue Prior Year
```dax
Revenue Prior Year = 
    CALCULATE(
        [Total Revenue],
        DATEADD(Dim_Date[Date], -1, YEAR)
    )

Format: $#,##0.00
Description: Revenue from same period prior year
Use Case: YoY comparison
```

#### Measure 4: Revenue YoY Growth %
```dax
Revenue YoY Growth % = 
    DIVIDE(
        [Total Revenue] - [Revenue Prior Year],
        [Revenue Prior Year],
        0
    ) * 100

Format: 0.0"%"
Description: Year-over-year growth percentage
Interpretation: Positive = growth, Negative = decline
Status: Green if ≥ 5%, Amber if 0-4%, Red if < 0%
```

#### Measure 5: Revenue MoM Growth %
```dax
Revenue MoM Growth % = 
    DIVIDE(
        [Total Revenue] - [Revenue Previous Month],
        [Revenue Previous Month],
        0
    ) * 100

Format: 0.0"%"
Description: Month-over-month growth
Related: [Revenue Previous Month]
```

#### Measure 6: Revenue Previous Month
```dax
Revenue Previous Month = 
    CALCULATE(
        [Total Revenue],
        DATEADD(Dim_Date[Date], -1, MONTH)
    )

Format: $#,##0.00
Description: Previous month's revenue for MoM calculation
```

#### Measure 7: Revenue Target
```dax
Revenue Target = 
    -- Assumes Fact_Target table with annual targets
    CALCULATE(
        SUM(Fact_Target[Target_Amount]),
        Fact_Target[Metric] = "Revenue",
        YEAR(Dim_Date[Date]) = YEAR(TODAY())
    )

Format: $#,##0.00
Description: Annual revenue target (proration by month)
Assumption: Target data available in source system
```

#### Measure 8: Revenue Achievement %
```dax
Revenue Achievement % = 
    DIVIDE(
        [Total Revenue],
        [Revenue Target],
        0
    ) * 100

Format: 0.0"%"
Description: Actual revenue as % of target
Interpretation: >100% = exceeds target, <100% = below target
Status: Green ≥100%, Amber 90-99%, Red <90%
```

#### Measure 9: Revenue Shortfall
```dax
Revenue Shortfall = 
    [Revenue Target] - [Total Revenue]

Format: $#,##0.00
Description: Dollar amount below target
Alert: Red if > 0 (i.e., behind target)
```

---

### PROFITABILITY MEASURES

#### Measure 10: Gross Profit
```dax
Gross Profit = 
    SUM(Fact_Sales[Revenue]) - SUM(Fact_Sales[Cost])

Format: $#,##0.00
Description: Revenue minus cost of goods sold
Related: Cost of Goods Sold in Fact_Sales
```

#### Measure 11: Gross Profit Margin %
```dax
Gross Profit Margin % = 
    DIVIDE(
        [Gross Profit],
        [Total Revenue],
        0
    ) * 100

Format: 0.0"%"
Description: Gross profit as percentage of revenue
Range: Typically 20-60% depending on industry
Status: Green ≥40%, Amber 35-39%, Red <35%
Benchmark: Include industry average for comparison
```

#### Measure 12: Net Profit
```dax
Net Profit = 
    SUM(Fact_ProfitLoss[NetIncome])

Format: $#,##0.00
Description: Bottom line profit after all expenses
Related Filters: Date range
```

#### Measure 13: Net Profit Margin %
```dax
Net Profit Margin % = 
    DIVIDE(
        [Net Profit],
        [Total Revenue],
        0
    ) * 100

Format: 0.0"%"
Description: Net profit as percentage of revenue
Range: Typically 5-20% for most industries
Status: Green ≥10%, Amber 5-9%, Red <5%
Alert Threshold: Critical if <2%
```

#### Measure 14: Operating Income
```dax
Operating Income = 
    [Gross Profit] - SUM(Fact_ProfitLoss[OperatingExpenses])

Format: $#,##0.00
Description: Income before interest and taxes
```

#### Measure 15: Operating Margin %
```dax
Operating Margin % = 
    DIVIDE(
        [Operating Income],
        [Total Revenue],
        0
    ) * 100

Format: 0.0"%"
Description: Operating profit margin
Related: [Operating Income], [Total Revenue]
```

#### Measure 16: EBITDA
```dax
EBITDA = 
    SUM(Fact_ProfitLoss[EBITDAAmount])

Format: $#,##0.00
Description: Earnings Before Interest, Taxes, Depreciation, Amortization
Use: Business valuation, comparison
```

#### Measure 17: EBITDA Margin %
```dax
EBITDA Margin % = 
    DIVIDE(
        [EBITDA],
        [Total Revenue],
        0
    ) * 100

Format: 0.0"%"
Description: EBITDA as percentage of revenue
Benchmark: Compare to industry standards
```

#### Measure 18: Cost of Goods Sold
```dax
Cost of Goods Sold = 
    SUM(Fact_Sales[Cost])

Format: $#,##0.00
Description: Direct costs of products sold
Percentage of Revenue: [COGS %]
```

#### Measure 19: COGS as % of Revenue
```dax
COGS % = 
    DIVIDE(
        [Cost of Goods Sold],
        [Total Revenue],
        0
    ) * 100

Format: 0.0"%"
Description: Cost of goods sold as percentage
Relationship: [Gross Profit Margin] = 100% - [COGS %]
```

---

### CASH FLOW MEASURES

#### Measure 20: Operating Cash Flow
```dax
Operating Cash Flow = 
    SUM(Fact_CashFlow[OperatingCashFlow])

Format: $#,##0.00
Description: Cash generated from operations
Status: Green if positive, Red if negative
Related: [Investing Cash Flow], [Financing Cash Flow]
```

#### Measure 21: Investing Cash Flow
```dax
Investing Cash Flow = 
    SUM(Fact_CashFlow[InvestingCashFlow])

Format: $#,##0.00
Description: Cash used for investments
Typical: Negative (outflows for capex)
Related: Capital expenditure tracking
```

#### Measure 22: Financing Cash Flow
```dax
Financing Cash Flow = 
    SUM(Fact_CashFlow[FinancingCashFlow])

Format: $#,##0.00
Description: Cash from financing activities
Related: Debt, equity, dividends
```

#### Measure 23: Net Cash Flow
```dax
Net Cash Flow = 
    [Operating Cash Flow] + [Investing Cash Flow] + [Financing Cash Flow]

Format: $#,##0.00
Description: Total net change in cash
Waterfall component: Sum of three components
```

#### Measure 24: Free Cash Flow
```dax
Free Cash Flow = 
    [Operating Cash Flow] - CALCULATE(
        SUM(Fact_CashFlow[CapitalExpenditure]),
        -- Assumes CapEx tracked in CashFlow table
    )

Format: $#,##0.00
Description: Operating cash available after capex
Interpretation: Positive = can pay dividends, reduce debt
```

#### Measure 25: Cash Balance
```dax
Cash Balance = 
    SUM(Fact_CashFlow[ClosingCashBalance])

Format: $#,##0.00
Description: Ending cash on balance sheet
Related: Previous period cash balance
Change: Cash Balance - Prior Month Cash Balance
```

---

### REGIONAL ANALYSIS MEASURES

#### Measure 26: Revenue by Region
```dax
Revenue by Region = 
    CALCULATE(
        [Total Revenue],
        ALL(Dim_Geography),
        VALUES(Dim_Geography[Region])
    )

Format: $#,##0.00
Description: Revenue grouped by geographic region
Use: In matrix/table for regional breakdown
Related: North America, Europe, Asia Pacific, etc.
```

#### Measure 27: Regional Revenue %
```dax
Regional Revenue % = 
    DIVIDE(
        [Revenue by Region],
        [Total Revenue],
        0
    ) * 100

Format: 0.0"%"
Description: Region's contribution to total revenue
Range: 0-100% (sum = 100% across all regions)
Visualization: Data bar or pie segment
```

#### Measure 28: Regional Growth % YoY
```dax
Regional Growth % YoY = 
    DIVIDE(
        [Revenue by Region] - CALCULATE([Revenue by Region], DATEADD(Dim_Date[Date], -1, YEAR)),
        CALCULATE([Revenue by Region], DATEADD(Dim_Date[Date], -1, YEAR)),
        0
    ) * 100

Format: 0.0"%"
Description: Year-over-year growth by region
Use: Compare growth rates across regions
Related: Top growing regions identification
```

#### Measure 29: Regional Rank
```dax
Regional Rank = 
    RANK(
        [Revenue by Region],
        ALLEXCEPT(Dim_Geography, Dim_Geography[Region]),
        DESC
    )

Format: #
Description: Ranking of regions by revenue (1 = highest)
Related: Used in regional scorecard
```

#### Measure 30: Regional Margin %
```dax
Regional Margin % = 
    DIVIDE(
        CALCULATE([Gross Profit], ALL(Dim_Geography), VALUES(Dim_Geography[Region])),
        [Revenue by Region],
        0
    ) * 100

Format: 0.0"%"
Description: Profit margin by region
Comparison: Region with best/worst margins
```

#### Measure 31: Regional Performance vs Target
```dax
Regional Achievement % = 
    DIVIDE(
        [Revenue by Region],
        CALCULATE([Revenue Target], ALL(Dim_Geography), VALUES(Dim_Geography[Region])),
        0
    ) * 100

Format: 0.0"%"
Description: Regional achievement of target
Status: Green ≥100%, Amber 90-99%, Red <90%
```

---

### CUSTOMER METRICS

#### Measure 32: Total Customers
```dax
Total Customers = 
    DISTINCTCOUNT(Fact_Sales[CustomerID])

Format: #,##0
Description: Count of unique customers with sales
Related: Customer count by region, segment, period
```

#### Measure 33: Average Order Value
```dax
Average Order Value = 
    DIVIDE(
        [Total Revenue],
        DISTINCTCOUNT(Fact_Sales[SalesID]),
        0
    )

Format: $#,##0.00
Description: Average revenue per transaction
Trend: Compare to prior periods
Related: By customer segment, region
```

#### Measure 34: Revenue per Customer
```dax
Revenue per Customer = 
    DIVIDE(
        [Total Revenue],
        [Total Customers],
        0
    )

Format: $#,##0.00
Description: Average revenue per unique customer
Metric: Customer value indicator
Related: Growth in revenue/customer vs growth in customer count
```

#### Measure 35: New Customers
```dax
New Customers = 
    CALCULATE(
        DISTINCTCOUNT(Fact_Sales[CustomerID]),
        Fact_Sales[FirstPurchaseDate] >= [Period Start],
        Fact_Sales[FirstPurchaseDate] <= [Period End]
    )

Format: #,##0
Description: Count of first-time customers in period
Related: Customer acquisition rate
```

#### Measure 36: Customer Retention Rate
```dax
Customer Retention Rate % = 
    DIVIDE(
        CALCULATE(
            DISTINCTCOUNT(Fact_Sales[CustomerID]),
            ALL(Dim_Date),
            DATEADD(Dim_Date[Date], -1, YEAR)
        ) - [Customer Churn],
        CALCULATE(
            DISTINCTCOUNT(Fact_Sales[CustomerID]),
            ALL(Dim_Date),
            DATEADD(Dim_Date[Date], -1, YEAR)
        ),
        0
    ) * 100

Format: 0.0"%"
Description: % of customers retained year-over-year
Target: ≥90%
Related: Churn rate = 100% - Retention %
```

---

### CUSTOMER SATISFACTION MEASURES

#### Measure 37: Net Promoter Score (NPS)
```dax
Net Promoter Score = 
    DIVIDE(
        SUM(Fact_CustomerSatisfaction[PromotersCount]) - 
        SUM(Fact_CustomerSatisfaction[DetractorsCount]),
        SUM(Fact_CustomerSatisfaction[Respondents]),
        0
    ) * 100

Format: 0
Description: NPS score (0-100 scale)
Range: -100 to +100
Status: Green ≥70, Amber 50-69, Red <50
Classification: Excellent >70, Good 50-69, Fair 30-49, Poor <30
```

#### Measure 38: Promoters %
```dax
Promoters % = 
    DIVIDE(
        SUM(Fact_CustomerSatisfaction[PromotersCount]),
        SUM(Fact_CustomerSatisfaction[Respondents]),
        0
    ) * 100

Format: 0.0"%"
Description: Percentage of promoters (9-10 rating)
Target: ≥50%
Related: NPS components breakdown
```

#### Measure 39: Passives %
```dax
Passives % = 
    DIVIDE(
        SUM(Fact_CustomerSatisfaction[PassivesCount]),
        SUM(Fact_CustomerSatisfaction[Respondents]),
        0
    ) * 100

Format: 0.0"%"
Description: Percentage of passives (7-8 rating)
Related: NPS components breakdown
```

#### Measure 40: Detractors %
```dax
Detractors % = 
    DIVIDE(
        SUM(Fact_CustomerSatisfaction[DetractorsCount]),
        SUM(Fact_CustomerSatisfaction[Respondents]),
        0
    ) * 100

Format: 0.0"%"
Description: Percentage of detractors (0-6 rating)
Target: <10%
Related: NPS components breakdown
```

#### Measure 41: NPS vs Target
```dax
NPS Achievement % = 
    DIVIDE(
        [Net Promoter Score],
        75, -- Target NPS is 75
        0
    ) * 100

Format: 0.0"%"
Description: NPS achievement as % of target
Interpretation: >100% = exceeds NPS target
```

---

### MARKET SHARE MEASURES

#### Measure 42: Market Share %
```dax
Market Share % = 
    DIVIDE(
        [Total Revenue],
        CALCULATE(
            SUM(Fact_MarketShare[MarketValue_Dollars]),
            Fact_MarketShare[ReportDate] = MAX(Fact_MarketShare[ReportDate])
        ),
        0
    ) * 100

Format: 0.0"%"
Description: Your company's market share percentage
Related: Market intelligence data
Assumption: Market total comes from Fact_MarketShare
```

#### Measure 43: Market Rank
```dax
Market Rank = 
    RANKX(
        ALLSELECTED(Fact_MarketShare),
        [Market Share %],
        ,
        DESC
    )

Format: #
Description: Your company's rank among competitors
Related: Provided by market intelligence source
Interpretation: #1 = market leader
```

#### Measure 44: Market Growth Rate %
```dax
Market Growth Rate % = 
    -- Assumes market value trending available
    DIVIDE(
        CALCULATE(
            SUM(Fact_MarketShare[MarketValue_Dollars]),
            Fact_MarketShare[ReportDate] = MAX(Fact_MarketShare[ReportDate])
        ) - 
        CALCULATE(
            SUM(Fact_MarketShare[MarketValue_Dollars]),
            DATEADD(Fact_MarketShare[ReportDate], -1, YEAR)
        ),
        CALCULATE(
            SUM(Fact_MarketShare[MarketValue_Dollars]),
            DATEADD(Fact_MarketShare[ReportDate], -1, YEAR)
        ),
        0
    ) * 100

Format: 0.0"%"
Description: Total market growth rate (market + competitors)
Related: Compare company growth to market growth
```

---

### PERFORMANCE INDICATOR MEASURES

#### Measure 45: Performance Status
```dax
Performance Status = 
    IF([Revenue Achievement %] >= 100, "On Track",
        IF([Revenue Achievement %] >= 95, "At Risk",
            "Below Target"
        )
    )

Format: Text
Description: Status classification based on revenue achievement
Values: "On Track" / "At Risk" / "Below Target"
Related: Used for status badges in KPI cards
```

#### Measure 46: Profitability Health
```dax
Profitability Health = 
    IF([Net Profit Margin %] >= 10, "Healthy",
        IF([Net Profit Margin %] >= 5, "Acceptable",
            "Concerning"
        )
    )

Format: Text
Description: Classification of profit health
Values: "Healthy" / "Acceptable" / "Concerning"
```

#### Measure 47: Cash Position
```dax
Cash Position = 
    IF([Operating Cash Flow] > 0, "Positive",
        IF([Operating Cash Flow] > [Total Revenue] * -0.1, "Manageable",
            "Critical"
        )
    )

Format: Text
Description: Assessment of cash flow health
Values: "Positive" / "Manageable" / "Critical"
```

---

### HELPER/SUPPORT MEASURES

#### Measure 48: Current Month
```dax
Current Month = 
    FORMAT(MAX(Dim_Date[Date]), "MMMM")

Format: Text
Description: Name of current month for labels
Use: Dynamic header labels
```

#### Measure 49: Days in Period
```dax
Days in Period = 
    INT(MAX(Dim_Date[Date]) - MIN(Dim_Date[Date])) + 1

Format: #
Description: Number of days in selected date range
Use: Daily average calculations
```

#### Measure 50: Last Updated
```dax
Last Updated = 
    MAX(Fact_Sales[Date])

Format: Date
Description: Most recent transaction date
Display: "Last Updated: [Date]"
```

---

## Dashboard-Specific Measure Collections

### For Row 2: Primary KPI Cards
- Total Revenue / Revenue Achievement % / Revenue YoY Growth %
- Gross Profit Margin / Profit Margin QoQ Change / vs Benchmark
- Operating Cash Flow / vs Prior Year / Status
- NPS / vs 12-month Average / Promoters %

### For Row 3, Chart 1: Revenue Progress
- Total Revenue / Revenue Previous Month / Revenue Target
- Revenue by Month (for stacked columns)
- Revenue Cumulative vs Target Cumulative
- Revenue YoY (for comparison line)

### For Row 3, Chart 2: Regional Scorecard
- Revenue by Region / Regional Revenue % / Regional Achievement %
- Regional Growth % YoY / Regional Rank / Regional Margin %

### For Row 4, Chart 1: Profitability Trend
- Net Profit by Quarter / Profit Margin by Quarter
- Prior Quarter comparison / Trend line

### For Row 4, Chart 2: Expense Breakdown
- COGS % / S&M % / R&D % / G&A % / Operating % / Other %
- Total Expenses (for center label)
- MoM Change % (for trend)

### For Row 5, Section 1: Market Share
- Market Share % / Your Company Segment %
- Competitor A/B/C/D Segments (from Fact_MarketShare)
- Market Rank / Competitors Ranking Table

### For Row 5, Section 2: Mini Tiles
- Average Order Value / Customer Count / Revenue per Customer
- Customer Acquisition Cost / Customer Lifetime Value / New Product Revenue %
- Geographic Diversification Metric

---

## Measure Performance Optimization

1. **Reuse Base Measures**: Build complex measures on foundation measures
2. **CALCULATE Efficiency**: Use context-aware formulas vs complex filters
3. **Pre-Aggregation**: For historical data, use aggregation tables
4. **Materialization**: Pre-calculate slow measures (quarterly lookups)
5. **Query Folding**: Optimize Power Query M code for source queries

---

## Testing Checklist

- [ ] All revenue measures sum to expected totals
- [ ] Percentages range 0-100% (or -100 to +100 for NPS)
- [ ] Growth calculations accurate (compare manually to source)
- [ ] YoY/MoM comparisons work with all date slicers
- [ ] Regional measures total to company total
- [ ] Target achievement realistic (validated against business)
- [ ] All measures perform < 1 second in typical use
- [ ] NPS components (Promoters + Passives + Detractors) = 100%
- [ ] Market share % matches source data validation
- [ ] Cash flow components sum to net cash flow
- [ ] Margins calculated correctly (profit / revenue)

