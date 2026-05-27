# Customer Dashboard - DAX Measures & Implementation

## Customer Data Model Requirements

### Fact Tables

#### 1. Fact_Customer_Metrics
```
Table: dbo.Fact_Customer_Metrics
Refresh: Daily
Import Mode: Import

Columns:
  MetricID          (INT, PK)
  DateKey           (INT, FK → Dim_Date)
  CustomerKey       (INT, FK → Dim_Customer)
  RetentionFlag     (BIT)       -- 1 = retained vs prior period
  IsChurned         (BIT)       -- 1 = churned in this period
  ChurnType         (VARCHAR 20) -- Voluntary / Involuntary / NULL
  IsNewCustomer     (BIT)       -- 1 = first period with transaction
  HealthScore       (DECIMAL 5,2) -- 0-100 composite health score
  ChurnRiskScore    (DECIMAL 5,2) -- 0-100 ML-derived churn risk
  NPS_Score         (INT)       -- -100 to +100 per customer
  SupportTickets    (INT)
  EngagementScore   (DECIMAL 5,2)
  DaysSinceLastPurchase (INT)
  PeriodRevenue     (DECIMAL 18,2)
```

#### 2. Fact_Customer_Behavior
```
Table: dbo.Fact_Customer_Behavior
Refresh: Daily
Import Mode: Import

Columns:
  BehaviorID        (INT, PK)
  DateKey           (INT, FK → Dim_Date)
  CustomerKey       (INT, FK → Dim_Customer)
  EventType         (VARCHAR 50) -- Purchase/Login/EmailOpen/SupportContact/Complaint/CartAdd
  EventCount        (INT)
  SessionDuration   (INT)        -- seconds
  PagesViewed       (INT)
  ProductCategoryKey(INT, FK → Dim_Product_Category)
  ChannelKey        (INT, FK → Dim_Channel)
  DeviceType        (VARCHAR 30) -- Desktop/Mobile/Tablet
```

#### 3. Fact_Sales  (existing — extended usage)
```
Additional columns used for RFM:
  Fact_Sales[OrderDate]         -- for Recency calculation
  Fact_Sales[CustomerKey]       -- for Frequency calculation
  Fact_Sales[ExtendedAmount]    -- for Monetary calculation
  Fact_Sales[SalesOrderNumber]  -- distinct count for order frequency
```

### Dimension Tables

#### Dim_Customer  (existing — columns used)
```
  CustomerKey            (PK)
  CustomerName
  Segment                -- Premium / Standard / Economy
  CustomerType           -- Enterprise / Mid-Market / SMB / Individual
  CountryCode / RegionName
  CustomerAcquisitionDate
  LastTransactionDate
  AnnualContractValue
  IsActive
```

#### Dim_Customer_Segment  (RFM — new)
```
Table: dbo.Dim_Customer_Segment
Columns:
  SegmentKey        (INT, PK)
  SegmentName       (VARCHAR 50) -- Champions/Loyal/Promising/AtRisk/Lost/New/NeedAttention
  RecencyMin        (INT)   -- min recency score for segment
  RecencyMax        (INT)   -- max recency score
  FrequencyMin      (INT)
  FrequencyMax      (INT)
  MonetaryMin       (DECIMAL)
  MonetaryMax       (DECIMAL)
  SegmentColor      (VARCHAR 10) -- hex code for visual
  Priority          (INT)   -- sort order
```

#### Dim_Channel  (new)
```
Table: dbo.Dim_Channel
Columns:
  ChannelKey   (INT, PK)
  ChannelName  (VARCHAR 50) -- Web/Mobile App/Email/Phone/In-Store/Partner
  ChannelType  (VARCHAR 30)
  IsDigital    (BIT)
```

#### Dim_Product_Category  (new)
```
Table: dbo.Dim_Product_Category
Columns:
  CategoryKey  (INT, PK)
  CategoryName (VARCHAR 100)
  CategoryGroup(VARCHAR 50)
```

---

## DAX Measures — Customer Base Metrics

### MEASURE 1: Total Customers
```dax
Total Customers = 
    DISTINCTCOUNT(Dim_Customer[CustomerKey])

Description: All customers in filter context (active + inactive)
Format: #,##0
```

---

### MEASURE 2: Active Customers
```dax
Active Customers = 
    CALCULATE(
        DISTINCTCOUNT(Dim_Customer[CustomerKey]),
        Dim_Customer[IsActive] = TRUE()
    )

Description: Customers with IsActive = TRUE
Format: #,##0
```

---

### MEASURE 3: New Customers (Period)
```dax
New Customers = 
    CALCULATE(
        DISTINCTCOUNT(Fact_Customer_Metrics[CustomerKey]),
        Fact_Customer_Metrics[IsNewCustomer] = TRUE()
    )

Description: First-time customers in current filter period
Format: #,##0
```

---

### MEASURE 4: Churned Customers (Period)
```dax
Churned Customers = 
    CALCULATE(
        DISTINCTCOUNT(Fact_Customer_Metrics[CustomerKey]),
        Fact_Customer_Metrics[IsChurned] = TRUE()
    )

Description: Customers lost in current filter period
Format: #,##0
```

---

### MEASURE 5: Net Customer Change
```dax
Net Customer Change = 
    [New Customers] - [Churned Customers]

Description: Net new customers (acquisitions minus churn)
Format: +#,##0;-#,##0;0
```

---

### MEASURE 6: Customer Retention Rate
```dax
Customer Retention Rate = 
    DIVIDE(
        CALCULATE(
            DISTINCTCOUNT(Fact_Customer_Metrics[CustomerKey]),
            Fact_Customer_Metrics[RetentionFlag] = TRUE()
        ),
        DISTINCTCOUNT(Fact_Customer_Metrics[CustomerKey]),
        0
    ) * 100

Description: % of customers retained vs prior period base
Format: 0.0"%"
Target: 90%
```

---

### MEASURE 7: Customer Churn Rate
```dax
Customer Churn Rate = 
    DIVIDE(
        [Churned Customers],
        [Active Customers] + [Churned Customers],
        0
    ) * 100

Description: Churned customers as % of start-of-period base
Format: 0.0"%"
Target: < 3%  (lower is better)
```

---

### MEASURE 8: Voluntary Churn Rate
```dax
Voluntary Churn Rate = 
    DIVIDE(
        CALCULATE(
            DISTINCTCOUNT(Fact_Customer_Metrics[CustomerKey]),
            Fact_Customer_Metrics[IsChurned] = TRUE(),
            Fact_Customer_Metrics[ChurnType] = "Voluntary"
        ),
        [Active Customers] + [Churned Customers],
        0
    ) * 100

Description: % of customers who left by choice
Format: 0.0"%"
```

---

### MEASURE 9: Net Promoter Score (NPS)
```dax
Net Promoter Score = 
    VAR Promoters = 
        CALCULATE(
            COUNTROWS(Fact_Customer_Metrics),
            Fact_Customer_Metrics[NPS_Score] >= 9
        )
    VAR Detractors = 
        CALCULATE(
            COUNTROWS(Fact_Customer_Metrics),
            Fact_Customer_Metrics[NPS_Score] <= 6
        )
    VAR Total = 
        CALCULATE(
            COUNTROWS(Fact_Customer_Metrics),
            NOT ISBLANK(Fact_Customer_Metrics[NPS_Score])
        )
    RETURN 
        DIVIDE(Promoters - Detractors, Total, 0) * 100

Description: Net Promoter Score (-100 to +100)
Format: #0
Thresholds: < 0 = Poor | 0-30 = Good | 31-70 = Great | > 70 = Excellent
```

---

### MEASURE 10: Average Health Score
```dax
Avg Customer Health Score = 
    AVERAGEX(
        Fact_Customer_Metrics,
        Fact_Customer_Metrics[HealthScore]
    )

Description: Mean customer health score (0-100)
Format: #0.0
```

---

## DAX Measures — CLV & Revenue

### MEASURE 11: Average Customer Lifetime Value
```dax
Avg Customer Lifetime Value = 
    VAR AvgOrderValue = 
        DIVIDE(
            SUM(Fact_Sales[ExtendedAmount]),
            DISTINCTCOUNT(Fact_Sales[SalesOrderNumber]),
            0
        )
    VAR AvgOrderFrequency = 
        DIVIDE(
            DISTINCTCOUNT(Fact_Sales[SalesOrderNumber]),
            DISTINCTCOUNT(Fact_Sales[CustomerKey]),
            0
        )
    VAR AvgCustomerLifespan = 
        AVERAGEX(
            VALUES(Dim_Customer[CustomerKey]),
            DATEDIFF(
                CALCULATE(MIN(Dim_Customer[CustomerAcquisitionDate])),
                CALCULATE(MAX(Dim_Customer[LastTransactionDate])),
                MONTH
            ) / 12.0
        )
    RETURN 
        AvgOrderValue * AvgOrderFrequency * AvgCustomerLifespan

Description: Historical CLV using average order value × frequency × lifespan
Format: $#,##0
Note: For ML-predicted CLV use Fact_Customer_Metrics[PredictedCLV] column
```

---

### MEASURE 12: CLV by Segment
```dax
CLV by Segment = 
    CALCULATE(
        [Avg Customer Lifetime Value],
        VALUES(Dim_Customer[Segment])
    )

Description: CLV calculation scoped to each segment
Format: $#,##0
Use: Segment comparison bar chart
```

---

### MEASURE 13: Revenue from Retained Customers
```dax
Revenue from Retained Customers = 
    CALCULATE(
        SUM(Fact_Sales[ExtendedAmount]),
        FILTER(
            Fact_Customer_Metrics,
            Fact_Customer_Metrics[RetentionFlag] = TRUE()
        )
    )

Description: Revenue generated only from retained (non-new, non-churned) customers
Format: $#,##0
```

---

### MEASURE 14: Revenue at Risk (High Churn Risk)
```dax
Revenue at Risk = 
    CALCULATE(
        SUM(Fact_Sales[ExtendedAmount]),
        FILTER(
            Fact_Customer_Metrics,
            Fact_Customer_Metrics[ChurnRiskScore] >= 51
        )
    )

Description: Total revenue from customers with churn risk score > 50
Format: $#,##0
Use: Highlight financial exposure from at-risk customers
```

---

### MEASURE 15: Average Revenue Per Customer
```dax
Avg Revenue Per Customer = 
    DIVIDE(
        SUM(Fact_Sales[ExtendedAmount]),
        DISTINCTCOUNT(Fact_Sales[CustomerKey]),
        0
    )

Description: Mean revenue per transacting customer in current period
Format: $#,##0
```

---

## DAX Measures — RFM Segmentation

### MEASURE 16: Recency Score (Avg Days Since Last Purchase)
```dax
Avg Days Since Last Purchase = 
    AVERAGEX(
        VALUES(Fact_Customer_Metrics[CustomerKey]),
        CALCULATE(
            MAX(Fact_Customer_Metrics[DaysSinceLastPurchase])
        )
    )

Description: Average days since last purchase across filtered customers
Format: #,##0" days"
Lower = better (more recent)
```

---

### MEASURE 17: RFM — Customer Count by Segment
```dax
Customers in Segment = 
    COUNTROWS(
        FILTER(
            Fact_Customer_Metrics,
            NOT ISBLANK(Fact_Customer_Metrics[CustomerKey])
        )
    )

Description: Count of customers in the current RFM segment filter context
Format: #,##0
Use: With segment slicer/filter to show per-segment counts
```

---

### MEASURE 18: Champions Count
```dax
Champions Count = 
    CALCULATE(
        DISTINCTCOUNT(Fact_Customer_Metrics[CustomerKey]),
        FILTER(
            Fact_Customer_Metrics,
            Fact_Customer_Metrics[DaysSinceLastPurchase] <= 30
                && Fact_Customer_Metrics[EngagementScore] >= 75
                && Fact_Customer_Metrics[ChurnRiskScore] < 20
        )
    )

Description: High-recency, high-engagement, low-churn-risk customers
Format: #,##0
```

---

### MEASURE 19: At-Risk Customers Count
```dax
At Risk Customers = 
    CALCULATE(
        DISTINCTCOUNT(Fact_Customer_Metrics[CustomerKey]),
        Fact_Customer_Metrics[ChurnRiskScore] >= 51,
        Fact_Customer_Metrics[ChurnRiskScore] < 76
    )

Description: Customers with churn risk score between 51-75
Format: #,##0
```

---

### MEASURE 20: Critical Risk Customers Count
```dax
Critical Risk Customers = 
    CALCULATE(
        DISTINCTCOUNT(Fact_Customer_Metrics[CustomerKey]),
        Fact_Customer_Metrics[ChurnRiskScore] >= 76
    )

Description: Customers with churn risk score ≥ 76 — immediate intervention needed
Format: #,##0
Alert: Any value > 0 → Red badge on dashboard header
```

---

### MEASURE 21: Segment % of Base
```dax
Segment % of Base = 
    DIVIDE(
        COUNTROWS(Fact_Customer_Metrics),
        CALCULATE(
            COUNTROWS(Fact_Customer_Metrics),
            ALL(Dim_Customer[Segment])
        ),
        0
    ) * 100

Description: Percentage of total customers belonging to current segment
Format: 0.0"%"
```

---

## DAX Measures — Retention Cohort Analysis

### MEASURE 22: Cohort Initial Size
```dax
Cohort Initial Size = 
    CALCULATE(
        DISTINCTCOUNT(Dim_Customer[CustomerKey]),
        DATESINPERIOD(
            Dim_Date[Date],
            MIN(Dim_Date[Date]),
            1,
            MONTH
        )
    )

Description: Number of customers first acquired in the cohort's acquisition month
Format: #,##0
Use: Cohort heatmap row denominator
```

---

### MEASURE 23: Cohort Retained at Month N
```dax
Cohort Retention at Month N = 
    VAR CohortBase = [Cohort Initial Size]
    VAR RetainedNow = 
        CALCULATE(
            DISTINCTCOUNT(Fact_Customer_Metrics[CustomerKey]),
            Fact_Customer_Metrics[RetentionFlag] = TRUE()
        )
    RETURN 
        DIVIDE(RetainedNow, CohortBase, 0) * 100

Description: % of original cohort still active at current month offset
Format: 0.0"%"
Use: Cohort heatmap cell value (combine with cohort × elapsed-month matrix)
```

---

### MEASURE 24: Average Cohort Retention (Platform Avg)
```dax
Platform Avg Cohort Retention = 
    CALCULATE(
        [Cohort Retention at Month N],
        ALL(Dim_Customer[CustomerAcquisitionDate])
    )

Description: Average retention rate across all cohorts for the same month offset
Format: 0.0"%"
Use: Benchmark overlay line on cohort heatmap
```

---

### MEASURE 25: Best Cohort Retention
```dax
Best Cohort Retention = 
    MAXX(
        VALUES(Dim_Customer[CustomerAcquisitionDate]),
        [Cohort Retention at Month N]
    )

Description: Highest retention rate across all cohorts in current month offset
Format: 0.0"%"
```

---

### MEASURE 26: Retention Rate MoM Change
```dax
Retention Rate MoM Change = 
    VAR CurrentMonth = 
        CALCULATE(
            [Customer Retention Rate],
            DATESMTD(Dim_Date[Date])
        )
    VAR PriorMonth = 
        CALCULATE(
            [Customer Retention Rate],
            DATEADD(DATESMTD(Dim_Date[Date]), -1, MONTH)
        )
    RETURN 
        CurrentMonth - PriorMonth

Description: Month-over-month change in retention rate (percentage points)
Format: +0.0"% pts";-0.0"% pts"
```

---

### MEASURE 27: 12-Month Rolling Retention
```dax
12-Month Rolling Retention = 
    CALCULATE(
        [Customer Retention Rate],
        DATESINPERIOD(Dim_Date[Date], LASTDATE(Dim_Date[Date]), -12, MONTH)
    )

Description: Retention rate calculated over the trailing 12-month window
Format: 0.0"%"
```

---

## DAX Measures — Behavioral Analytics

### MEASURE 28: Total Behavioral Events
```dax
Total Events = 
    SUM(Fact_Customer_Behavior[EventCount])

Description: Sum of all customer interaction events in filter context
Format: #,##0
```

---

### MEASURE 29: Purchase Event Count
```dax
Purchase Events = 
    CALCULATE(
        SUM(Fact_Customer_Behavior[EventCount]),
        Fact_Customer_Behavior[EventType] = "Purchase"
    )

Description: Number of purchase events (distinct from SalesOrderNumber)
Format: #,##0
```

---

### MEASURE 30: Avg Session Duration (Minutes)
```dax
Avg Session Duration (Min) = 
    DIVIDE(
        SUM(Fact_Customer_Behavior[SessionDuration]),
        COUNTROWS(Fact_Customer_Behavior),
        0
    ) / 60

Description: Average customer session length in minutes
Format: #0.0" min"
Higher = more engaged
```

---

### MEASURE 31: Avg Pages Per Session
```dax
Avg Pages Per Session = 
    DIVIDE(
        SUM(Fact_Customer_Behavior[PagesViewed]),
        COUNTROWS(Fact_Customer_Behavior),
        0
    )

Description: Average pages/screens viewed per customer session
Format: #0.0
```

---

### MEASURE 32: Engagement Score (Avg)
```dax
Avg Engagement Score = 
    AVERAGEX(
        Fact_Customer_Metrics,
        Fact_Customer_Metrics[EngagementScore]
    )

Description: Mean engagement score (0-100) across filtered customers
Format: #0.0
```

---

### MEASURE 33: Funnel Conversion Rate (Stage N → N+1)
```dax
Funnel Conversion Rate = 
    DIVIDE(
        CALCULATE(
            DISTINCTCOUNT(Fact_Customer_Behavior[CustomerKey]),
            Fact_Customer_Behavior[EventType] = "Purchase"
        ),
        CALCULATE(
            DISTINCTCOUNT(Fact_Customer_Behavior[CustomerKey]),
            Fact_Customer_Behavior[EventType] = "ProductView"
        ),
        0
    ) * 100

Description: % of customers who viewed a product and then purchased (view → purchase)
Format: 0.0"%"
Note: Replicate this pattern for each adjacent funnel stage pair
```

---

### MEASURE 34: Cart Abandonment Rate
```dax
Cart Abandonment Rate = 
    VAR CartAdds = 
        CALCULATE(
            DISTINCTCOUNT(Fact_Customer_Behavior[CustomerKey]),
            Fact_Customer_Behavior[EventType] = "CartAdd"
        )
    VAR Purchases = 
        CALCULATE(
            DISTINCTCOUNT(Fact_Customer_Behavior[CustomerKey]),
            Fact_Customer_Behavior[EventType] = "Purchase"
        )
    RETURN 
        DIVIDE(CartAdds - Purchases, CartAdds, 0) * 100

Description: % of cart-add sessions that did not result in purchase
Format: 0.0"%"
Target: < 65% (industry avg ~70%)
```

---

### MEASURE 35: Digital Channel Share
```dax
Digital Channel Share = 
    DIVIDE(
        CALCULATE(
            SUM(Fact_Customer_Behavior[EventCount]),
            Dim_Channel[IsDigital] = TRUE()
        ),
        [Total Events],
        0
    ) * 100

Description: % of all customer interactions occurring via digital channels
Format: 0.0"%"
```

---

### MEASURE 36: Mobile Engagement Share
```dax
Mobile Engagement Share = 
    DIVIDE(
        CALCULATE(
            SUM(Fact_Customer_Behavior[EventCount]),
            Fact_Customer_Behavior[DeviceType] = "Mobile"
        ),
        [Total Events],
        0
    ) * 100

Description: % of interactions from mobile devices
Format: 0.0"%"
```

---

### MEASURE 37: Category Penetration Rate
```dax
Category Penetration Rate = 
    DIVIDE(
        CALCULATE(
            DISTINCTCOUNT(Fact_Customer_Behavior[CustomerKey]),
            Fact_Customer_Behavior[EventType] = "Purchase"
        ),
        [Active Customers],
        0
    ) * 100

Description: % of active customers who purchased from the category in filter context
Format: 0.0"%"
Use: Affinity heatmap cell value — apply with Dim_Product_Category filter
```

---

### MEASURE 38: Repeat Purchase Rate
```dax
Repeat Purchase Rate = 
    DIVIDE(
        CALCULATE(
            DISTINCTCOUNT(Fact_Sales[CustomerKey]),
            FILTER(
                VALUES(Fact_Sales[CustomerKey]),
                CALCULATE(DISTINCTCOUNT(Fact_Sales[SalesOrderNumber])) >= 2
            )
        ),
        DISTINCTCOUNT(Fact_Sales[CustomerKey]),
        0
    ) * 100

Description: % of customers with 2 or more distinct orders in the period
Format: 0.0"%"
Target: > 40%
```

---

### MEASURE 39: Avg Order Frequency (Per Customer Per Year)
```dax
Avg Order Frequency = 
    DIVIDE(
        DISTINCTCOUNT(Fact_Sales[SalesOrderNumber]),
        DISTINCTCOUNT(Fact_Sales[CustomerKey]),
        0
    )

Description: Average number of orders placed per customer in the filter period
Format: #0.0
```

---

### MEASURE 40: Cross-Sell Index
```dax
Cross-Sell Index = 
    DIVIDE(
        CALCULATE(
            DISTINCTCOUNT(Fact_Sales[CustomerKey]),
            FILTER(
                VALUES(Fact_Sales[CustomerKey]),
                CALCULATE(
                    DISTINCTCOUNT(Dim_Product[ProductCategory])
                ) >= 2
            )
        ),
        DISTINCTCOUNT(Fact_Sales[CustomerKey]),
        0
    ) * 100

Description: % of customers who purchased from 2+ distinct product categories
Format: 0.0"%"
Higher = stronger cross-sell penetration
```

---

## DAX Measures — Churn Risk Analysis

### MEASURE 41: Avg Churn Risk Score
```dax
Avg Churn Risk Score = 
    AVERAGEX(
        Fact_Customer_Metrics,
        Fact_Customer_Metrics[ChurnRiskScore]
    )

Description: Average churn risk score (0-100) across filtered customers
Format: #0.0
```

---

### MEASURE 42: High Risk Customer Revenue %
```dax
High Risk Revenue % = 
    DIVIDE(
        [Revenue at Risk],
        SUM(Fact_Sales[ExtendedAmount]),
        0
    ) * 100

Description: Revenue from high-risk customers as % of total revenue
Format: 0.0"%"
Alert threshold: > 15% → red warning
```

---

### MEASURE 43: Churn Rate WoW Change
```dax
Churn Rate WoW Change = 
    VAR ThisWeek = 
        CALCULATE(
            [Customer Churn Rate],
            DATESINPERIOD(Dim_Date[Date], MAX(Dim_Date[Date]), -7, DAY)
        )
    VAR LastWeek = 
        CALCULATE(
            [Customer Churn Rate],
            DATESINPERIOD(Dim_Date[Date], MAX(Dim_Date[Date]) - 7, -7, DAY)
        )
    RETURN 
        ThisWeek - LastWeek

Description: Week-over-week churn rate change in percentage points
Format: +0.0"% pts";-0.0"% pts"
```

---

### MEASURE 44: Customer Rescue Rate
```dax
Customer Rescue Rate = 
    DIVIDE(
        CALCULATE(
            DISTINCTCOUNT(Fact_Customer_Metrics[CustomerKey]),
            Fact_Customer_Metrics[ChurnRiskScore] < 51,
            CALCULATE(
                MAX(Fact_Customer_Metrics[ChurnRiskScore]),
                DATEADD(Dim_Date[Date], -1, MONTH)
            ) >= 51
        ),
        CALCULATE(
            DISTINCTCOUNT(Fact_Customer_Metrics[CustomerKey]),
            CALCULATE(
                MAX(Fact_Customer_Metrics[ChurnRiskScore]),
                DATEADD(Dim_Date[Date], -1, MONTH)
            ) >= 51
        ),
        0
    ) * 100

Description: % of high-risk customers from last month moved to low risk this month
Format: 0.0"%"
Higher = more effective retention interventions
```

---

## DAX Calculated Columns

### Column 1: RFM Segment Label (Dim_Customer or Fact_Customer_Metrics)
```dax
RFM Segment = 
    VAR RecencyDays = 
        DATEDIFF(
            RELATED(Dim_Customer[LastTransactionDate]),
            TODAY(),
            DAY
        )
    VAR Frequency = 
        CALCULATE(
            DISTINCTCOUNT(Fact_Sales[SalesOrderNumber]),
            ALLEXCEPT(Fact_Sales, Fact_Sales[CustomerKey])
        )
    VAR Monetary = 
        CALCULATE(
            SUM(Fact_Sales[ExtendedAmount]),
            ALLEXCEPT(Fact_Sales, Fact_Sales[CustomerKey])
        )
    VAR RecencyScore = 
        SWITCH(
            TRUE(),
            RecencyDays <=  30, 5,
            RecencyDays <=  60, 4,
            RecencyDays <= 120, 3,
            RecencyDays <= 180, 2,
            1
        )
    VAR FreqScore = 
        SWITCH(
            TRUE(),
            Frequency >= 20, 5,
            Frequency >= 10, 4,
            Frequency >=  5, 3,
            Frequency >=  2, 2,
            1
        )
    RETURN 
        SWITCH(
            TRUE(),
            RecencyScore >= 4 && FreqScore >= 4,   "Champions",
            RecencyScore >= 3 && FreqScore >= 3,   "Loyal",
            RecencyScore >= 4 && FreqScore <= 2,   "Promising",
            RecencyScore >= 3 && FreqScore <= 2,   "New Customer",
            RecencyScore <= 2 && FreqScore >= 3,   "At Risk",
            RecencyScore <= 2 && FreqScore >= 4,   "Cant Lose Them",
            RecencyScore <= 2 && FreqScore <= 2,   "Lost",
            "Need Attention"
        )

Description: RFM segment label per customer for segmentation scatter plot
```

---

### Column 2: Health Score Band (Fact_Customer_Metrics)
```dax
Health Score Band = 
    SWITCH(
        TRUE(),
        Fact_Customer_Metrics[HealthScore] >= 75, "Healthy",
        Fact_Customer_Metrics[HealthScore] >= 50, "Stable",
        Fact_Customer_Metrics[HealthScore] >= 25, "At Risk",
        "Critical"
    )

Description: Categorical label for health score grouping
Use: Health score donut chart, slicer, conditional formatting
```

---

### Column 3: Churn Risk Band (Fact_Customer_Metrics)
```dax
Churn Risk Band = 
    SWITCH(
        TRUE(),
        Fact_Customer_Metrics[ChurnRiskScore] >= 76, "Critical",
        Fact_Customer_Metrics[ChurnRiskScore] >= 51, "High",
        Fact_Customer_Metrics[ChurnRiskScore] >= 26, "Medium",
        "Low"
    )

Description: Risk tier label for churn risk distribution chart
```

---

### Column 4: Acquisition Cohort Label (Dim_Customer)
```dax
Acquisition Cohort = 
    FORMAT(Dim_Customer[CustomerAcquisitionDate], "MMM YYYY")

Description: Month-year label for cohort analysis rows (e.g., "Jan 2025")
Use: Cohort retention heatmap row axis
```

---

### Column 5: Customer Tenure (Years) (Dim_Customer)
```dax
Customer Tenure Years = 
    DATEDIFF(
        Dim_Customer[CustomerAcquisitionDate],
        TODAY(),
        YEAR
    )

Description: How many years since the customer was acquired
Use: Segmentation by tenure, retention analysis
```

---

## Relationships to Add in Power BI

```
Fact_Customer_Metrics[DateKey]           → Dim_Date[DateKey]              (Many:1, Single)
Fact_Customer_Metrics[CustomerKey]       → Dim_Customer[CustomerKey]      (Many:1, Single)

Fact_Customer_Behavior[DateKey]          → Dim_Date[DateKey]              (Many:1, Single)
Fact_Customer_Behavior[CustomerKey]      → Dim_Customer[CustomerKey]      (Many:1, Single)
Fact_Customer_Behavior[ProductCategoryKey] → Dim_Product_Category[CategoryKey] (Many:1, Single)
Fact_Customer_Behavior[ChannelKey]       → Dim_Channel[ChannelKey]        (Many:1, Single)

Fact_Sales[CustomerKey]                  → Dim_Customer[CustomerKey]      (Many:1, Single) [existing]

Dim_Customer[CustomerAcquisitionDate]    → Dim_Date[Date]                 (Many:1, Single, inactive)
  Note: Activate with USERELATIONSHIP() in cohort measures
```
