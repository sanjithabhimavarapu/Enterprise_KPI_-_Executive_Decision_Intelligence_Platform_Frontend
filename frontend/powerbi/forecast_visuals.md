# Forecast Visuals - Implementation Guide

## Overview
This document provides comprehensive specifications for implementing forecast visualizations in Power BI, including revenue forecasts, expense forecasting, and what-if analysis.

---

## PART 1: FORECAST FUNDAMENTALS

### Forecast Types Supported

#### 1. Time Series Forecasting
```
Type: Extrapolation of historical trends
Method: Exponential Smoothing / ARIMA
Period: 6-12 months ahead
Use Case: Revenue, expense, KPI trends
Accuracy: ±15% typical
```

#### 2. Scenario Analysis (What-If)
```
Type: Parameter-driven scenarios
Method: Multiple forecast paths
Scenarios: Base Case, Upside, Downside
Use Case: Strategic planning, sensitivity analysis
Accuracy: ±25% (depends on assumptions)
```

#### 3. Regression-Based Forecast
```
Type: Driver-based forecasting
Method: Multiple variable regression
Drivers: Pricing, volume, costs
Use Case: Revenue with volume drivers
Accuracy: ±20% typical
```

---

## PART 2: REVENUE FORECAST VISUAL

### Chart Specifications

#### Visual Type
```
Primary: Line Chart with Forecast Area
Alternative: Area Chart with Confidence Bands
Dimensions: 250×150px (1×1 block)
Location: Row 5, Column 1 (Financial Dashboard)
Data Granularity: Monthly
Lookback: 12 months actual
Forecast Period: 12 months ahead
```

---

### Data Structure for Revenue Forecast

```
Period | Actual_Revenue | Forecast_Revenue | Lower_Bound | Upper_Bound
--------|---|---|---|---
Jan 2025 | $40M | NULL | NULL | NULL
Feb 2025 | $42M | NULL | NULL | NULL
...
Apr 2026 | $50M | NULL | NULL | NULL
May 2026 | NULL | $52M | $46.8M | $57.2M (±10%)
Jun 2026 | NULL | $54M | $48.6M | $59.4M
...
Apr 2027 | NULL | $68M | $61.2M | $74.8M
```

#### DAX Forecast Calculation

```dax
// Forecast Revenue Measure
Revenue_Forecast = 
VAR ActualRevenue = [Total Revenue]
VAR HistoricalAvg = CALCULATE(
    AVERAGE(Fact_Finance[Amount]),
    FILTER(
        Dim_Date,
        Dim_Date[Date] >= DATE(YEAR(TODAY())-1, MONTH(TODAY()), 1)
    )
)
VAR GrowthRate = 0.05  // 5% assumed growth
VAR ForecastMonth = MONTH(TODAY()) + 1

RETURN
IF(
    ISBLANK(ActualRevenue),
    HistoricalAvg * POWER(1 + GrowthRate, ForecastMonth),
    ActualRevenue
)

// Confidence Interval (Upper Bound = +10%)
Forecast_Upper_Bound = 
    [Revenue_Forecast] * 1.10

// Confidence Interval (Lower Bound = -10%)
Forecast_Lower_Bound = 
    [Revenue_Forecast] * 0.90

// Forecast Status
Is_Forecast_Period = 
    IF([Total Revenue] = BLANK(), TRUE(), FALSE())
```

---

### Visual Configuration

#### Axes Setup
```
X-Axis: Time (Month-Year)
- Period: Last 12 months + Next 12 months
- Format: "Jan 2025" | "Feb 2025" | ... | "Apr 2027"
- Date Range: Automatic (from data)

Y-Axis: Revenue Amount
- Format: Currency ($M)
- Scale: 0 to Max(Actual) * 1.3
- Gridlines: Every $10M
- Reference Line: Average historical ($45M)
```

#### Line Series Configuration

```
Series 1: Actual Revenue (Solid Line)
├─ Color: Blue (#2196F3)
├─ Width: 3pt
├─ Marker: Circle (5pt)
├─ Data Points: Only actual values
└─ Format: $XXM

Series 2: Forecasted Revenue (Dashed Line)
├─ Color: Green (#4CAF50)
├─ Width: 2pt (thinner than actual)
├─ Marker: Diamond (4pt) - different from actual
├─ Data Points: Only forecast values
└─ Format: $XXM

Series 3: Historical Trend Line (Dotted)
├─ Color: Gray (#999999)
├─ Width: 1pt
├─ Pattern: Dotted line
├─ Calculation: 3-month moving average
└─ Purpose: Show underlying trend

Forecast Confidence Area:
├─ Upper Bound: +10% band (light green)
├─ Lower Bound: -10% band (light green)
├─ Opacity: 30%
├─ Color: Green tint (#C8E6C9)
└─ Purpose: Show forecast uncertainty range
```

#### Visual Enhancements

```
Reference Line (Today):
├─ Type: Vertical line at TODAY()
├─ Color: Black (#000000)
├─ Style: Dashed (2pt)
├─ Label: "Today" (position: above line)
├─ Purpose: Distinguish actual from forecast

Target Line:
├─ Type: Horizontal line at $55M
├─ Color: Red (#F44336)
├─ Style: Dashed (1.5pt)
├─ Label: "Target" (position: right side)
├─ Purpose: Show revenue target

Annotations:
├─ "Actual Data" label (left side)
├─ "Forecast ±10%" label (right side)
└─ "Last Update: " & NOW() (bottom-right)
```

---

### Data Labels & Legend

#### Data Labels
```
Actual Values:
├─ Show: Last 3 months and first forecast point
├─ Format: $XXM
├─ Position: Above line
├─ Font: 11pt, Bold

Forecast Values:
├─ Show: All forecast points
├─ Format: $XXM
├─ Position: Above line
├─ Font: 11pt, Regular

Confidence Bounds:
├─ Show: Only on hover
├─ Format: "Range: $XXM - $XXM"
└─ Font: 10pt, Gray

Trend Line:
├─ Show: Last point only
├─ Format: "+X.X% growth"
└─ Color: Gray
```

#### Legend
```
Position: Top-right corner
Items:
  ✓ Actual Revenue (Blue line)
  ✓ Forecasted Revenue (Green line)
  ✓ Forecast Range (Green shaded area)
  ✓ Historical Trend (Gray dotted line)
  ✓ Revenue Target (Red line)

Clickable Legend:
├─ Click item to show/hide series
├─ Default: All visible
└─ Remember selection on refresh
```

---

### Tooltip Design

```
Revenue Forecast Tooltip (On Hover):
═════════════════════════════════════════
  REVENUE FORECAST DETAIL
─────────────────────────────────────────
  Period: May 2026
  
  ACTUAL/FORECAST:
  Type: Forecast
  Amount: $52.0M
  
  CONFIDENCE RANGE:
  Upper (90% CI): $57.2M
  Lower (90% CI): $46.8M
  
  VARIANCE TO TARGET:
  Target: $55M
  Variance: -$3.0M (-5.5%)
  
  ASSUMPTIONS:
  Growth Rate: 5.0% YoY
  Seasonality: +3% (typical for May)
  
  HISTORICAL CONTEXT:
  12-Month Average: $45.5M
  Last Month (Apr): $50M
  Change: +$2M (+4%)
═════════════════════════════════════════
```

---

### Forecast Parameters (What-If)

#### Parameter Setup
```
Create Slicers for Forecast Assumptions:

1. Growth Rate Parameter
   ├─ Type: Numeric slider (0% to 15%)
   ├─ Default: 5%
   ├─ Step: 0.5%
   └─ Label: "Assumed Annual Growth Rate"

2. Seasonality Adjustment
   ├─ Type: Dropdown
   ├─ Options: None, Light, Moderate, Strong
   ├─ Default: Moderate
   └─ Impact: ±2 to ±8% adjustment

3. Scenario Selection
   ├─ Type: Buttons (mutually exclusive)
   ├─ Options: Base Case, Upside, Downside
   ├─ Default: Base Case
   └─ Impact: Multiplier on forecast

4. Confidence Level
   ├─ Type: Dropdown
   ├─ Options: 80%, 90%, 95%, 99%
   ├─ Default: 90%
   └─ Impact: Changes uncertainty bands
```

#### DAX Implementation of Parameters

```dax
// User-Selected Growth Rate
Growth_Rate_Selected = 
    SELECTEDVALUE(Parameters[Growth_Rate_Slider], 0.05)

// Dynamic Forecast with User Input
Revenue_Forecast_Dynamic = 
    VAR HistoricalAvg = 45.5  // Last 12-month average
    VAR SelectedGrowth = [Growth_Rate_Selected]
    VAR MonthsAhead = DATEDIFF(TODAY(), SELECTEDVALUE(Dim_Date[Date]), MONTH)
    VAR SeasonalFactor = 1 + SELECTEDVALUE(SeasonalityTable[Adjustment], 0)
    
    RETURN
    IF(
        ISBLANK([Total Revenue]),
        HistoricalAvg * POWER(1 + SelectedGrowth/12, MonthsAhead) * SeasonalFactor,
        [Total Revenue]
    )

// Scenario Multiplier
Scenario_Multiplier = 
    SWITCH(
        SELECTEDVALUE(Scenarios[Scenario_Name]),
        "Base Case", 1.0,
        "Upside", 1.15,
        "Downside", 0.85,
        1.0
    )

// Scenario-Adjusted Forecast
Revenue_Forecast_Scenario = 
    [Revenue_Forecast_Dynamic] * [Scenario_Multiplier]
```

---

### Interactivity & Drill-Down

#### Click Actions
```
Click on Chart Point → Actions:

1. Actual Data Point (Historical)
   ├─ Action: Show monthly revenue components
   ├─ Drill: Sales by Product/Customer/Region
   └─ Navigation: Open detail page

2. Forecast Data Point (Future)
   ├─ Action: Show forecast assumptions
   ├─ Display: Growth rate, seasonality, scenario
   └─ Edit: Adjust parameters

3. Confidence Band (Shaded Area)
   ├─ Action: Show sensitivity analysis
   ├─ Range: From -20% to +20%
   └─ Display: Tornado chart
```

#### Cross-Filtering
```
Slicer Changes → Chart Updates:

Period Selector:
├─ YTD → Shows last 12 months + 6 months forecast
├─ Monthly → Shows current + next 12 months
└─ Quarterly → Shows last 8 quarters + 4 quarters forecast

Company Filter:
├─ Changes forecast to company-specific
├─ Updates growth rate by company
└─ Recalculates confidence intervals

Scenario Selection:
├─ Base Case: Standard forecast
├─ Upside: +15% multiplier
└─ Downside: -15% multiplier
```

---

## PART 3: EXPENSE FORECAST & WHAT-IF ANALYSIS

### Chart Specifications

#### Visual Type
```
Type: Clustered Column Chart (Actual vs Forecast)
Alternative: Combination Chart (Amount + % of Revenue)
Dimensions: 250×150px (1×1 block)
Location: Row 5, Column 2
Data Granularity: Monthly
Period: Last 6 months + Next 6 months
```

---

### Expense Forecast Data Structure

```
Category | Month | Actual_Expense | Budget | Forecast | Variance%
---|---|---|---|---|---
COGS | Apr 2026 | $200M | $195M | - | +2.6%
COGS | May 2026 | - | $200M | $205M | +2.5%
OpEx | Apr 2026 | $150M | $145M | - | +3.4%
OpEx | May 2026 | - | $155M | $160M | +3.2%
```

#### DAX Expense Forecast

```dax
// COGS Forecast (typically % of revenue)
COGS_Forecast = 
VAR RevenueForecasted = [Revenue_Forecast_Dynamic]
VAR COGSPercent = 0.40  // Historical 40% of revenue
RETURN
IF(
    ISBLANK([Total COGS]),
    RevenueForecasted * COGSPercent,
    [Total COGS]
)

// OpEx Forecast (typically step-based or fixed)
OpEx_Forecast = 
VAR BaseOpEx = 145  // Base monthly OpEx in $M
VAR GrowthInflation = 1.02  // 2% annual inflation
VAR MonthsAhead = DATEDIFF(TODAY(), SELECTEDVALUE(Dim_Date[Date]), MONTH)
RETURN
IF(
    ISBLANK([Total OpEx]),
    BaseOpEx * POWER(GrowthInflation, MonthsAhead/12),
    [Total OpEx]
)

// Total Expense Forecast
Total_Expense_Forecast = 
    [COGS_Forecast] + [OpEx_Forecast]

// Expense as % of Revenue (for dual-axis chart)
Expense_Percent_of_Revenue = 
    DIVIDE([Total_Expense_Forecast], [Revenue_Forecast_Dynamic], 0)
```

---

### Visual Configuration for Expense Chart

#### Column Configuration
```
Primary Y-Axis (Amount in $M):
├─ Columns - Actual (Blue #2196F3)
├─ Columns - Budget (Gray #BDBDBD)
├─ Columns - Forecast (Green #4CAF50)
└─ Scale: 0 to $250M

Secondary Y-Axis (Percentage):
├─ Line - % of Revenue (Orange #FF9800)
├─ Scale: 0% to 60%
└─ Line Width: 2pt

Variance Highlighting:
├─ If Forecast > Budget: Red column border
├─ If Forecast = Budget: Green column
├─ If Forecast < Budget: Blue column
└─ Border Width: 2pt
```

#### Data Labels
```
Columns:
├─ Show: All values
├─ Format: $XXM
├─ Position: Top of columns
└─ Font: 11pt

Line (Percentage):
├─ Show: All points
├─ Format: XX.X%
├─ Position: Above line
└─ Font: 10pt, Orange
```

---

### What-If Analysis Interface

#### Expense Driver Parameters

```
1. COGS as % of Revenue
   ├─ Type: Slider (30% to 50%)
   ├─ Default: 40%
   ├─ Step: 1%
   └─ Impact: Direct impact on COGS forecast

2. Labor Cost Inflation
   ├─ Type: Slider (0% to 10%)
   ├─ Default: 3%
   ├─ Step: 0.5%
   └─ Impact: Increases OpEx

3. Headcount Change
   ├─ Type: Numeric input (-5 to +20 people)
   ├─ Default: 0
   ├─ Cost per person: $100K
   └─ Impact: Direct OpEx adjustment

4. Volume Growth Assumption
   ├─ Type: Slider (-10% to +30%)
   ├─ Default: 5%
   ├─ Step: 1%
   └─ Impact: Scales COGS and some OpEx
```

#### DAX What-If Implementation

```dax
// Parameter Table for What-If
WhatIf_Parameters = 
DATATABLE(
    "Parameter_Name", STRING,
    "Current_Value", DOUBLE,
    "Min_Value", DOUBLE,
    "Max_Value", DOUBLE,
    {
        {"COGS_%_of_Revenue", 0.40, 0.30, 0.50},
        {"Labor_Inflation_%", 0.03, 0.00, 0.10},
        {"Headcount_Change", 0, -5, 20},
        {"Volume_Growth_%", 0.05, -0.10, 0.30}
    }
)

// Scenario-Adjusted COGS
COGS_WhatIf_Adjusted = 
VAR COGSPercent = SELECTEDVALUE(WhatIf_Parameters[COGS_%_of_Revenue], 0.40)
VAR VolumeGrowth = SELECTEDVALUE(WhatIf_Parameters[Volume_Growth_%], 0.05)
VAR AdjustedRevenue = [Revenue_Forecast_Dynamic] * (1 + VolumeGrowth)
RETURN
AdjustedRevenue * COGSPercent

// Scenario-Adjusted OpEx
OpEx_WhatIf_Adjusted = 
VAR BaseOpEx = 145
VAR LaborInflation = SELECTEDVALUE(WhatIf_Parameters[Labor_Inflation_%], 0.03)
VAR HeadcountChange = SELECTEDVALUE(WhatIf_Parameters[Headcount_Change], 0)
VAR HeadcountCost = HeadcountChange * 0.1  // $100K per person = $0.1M
VAR InflationAdjustment = BaseOpEx * LaborInflation
RETURN
BaseOpEx + InflationAdjustment + HeadcountCost

// Total Impact
Total_WhatIf_Impact = 
    ([COGS_WhatIf_Adjusted] + [OpEx_WhatIf_Adjusted]) 
    - ([COGS_Forecast] + [OpEx_Forecast])
```

---

## PART 4: FORECAST ACCURACY TRACKING

### Forecast vs Actual Comparison

#### Visual Type
```
Type: Scatter Plot or Actual vs Forecast Line
Purpose: Track forecast accuracy over time
Granularity: Monthly comparisons
Historical Period: Last 12 months
```

#### DAX Measures for Accuracy

```dax
// Mean Absolute Percentage Error (MAPE)
Forecast_MAPE = 
CALCULATE(
    AVERAGEX(
        Fact_Finance,
        DIVIDE(
            ABS([Total Revenue] - [Prior Forecast Revenue]),
            [Total Revenue],
            0
        )
    ),
    DATERANGE(DATE(YEAR(TODAY())-1, 1, 1), TODAY())
)

// Forecast Bias (Over/Under estimation)
Forecast_Bias = 
CALCULATE(
    SUMX(
        Fact_Finance,
        ([Total Revenue] - [Prior Forecast Revenue])
    ),
    DATERANGE(DATE(YEAR(TODAY())-1, 1, 1), TODAY())
) / [Total Revenue]

// Accuracy Score (0-100)
Forecast_Accuracy_Score = 
MAX(0, 100 - ([Forecast_MAPE] * 100))
```

#### Accuracy Visualization

```
Dashboard KPI:
├─ MAPE: 8.5% (target < 10%)
├─ Bias: -2.1% (underpredicting by 2.1%)
├─ Accuracy Score: 91.5% (target > 90%)
└─ Confidence: High (MAPE < 10%)

Status Indicators:
✓ Green: MAPE < 10%
⚠ Amber: MAPE 10-15%
✗ Red: MAPE > 15%
```

---

## PART 5: FORECAST VISUALIZATION BEST PRACTICES

### ✓ DO:
```
✓ Use different line styles for actual vs forecast
✓ Show confidence intervals/bands
✓ Include reference line for "today"
✓ Add assumptions to tooltip
✓ Refresh forecasts monthly
✓ Track forecast accuracy
✓ Allow parameter adjustments
✓ Show scenario comparisons
✓ Use consistent color coding
✓ Document forecast methodology
```

### ✗ DON'T:
```
✗ Don't forecast beyond 12 months without careful review
✗ Don't hide forecast assumptions
✗ Don't mix too many forecast scenarios on one chart
✗ Don't update forecast without documentation
✗ Don't ignore forecast accuracy tracking
✗ Don't use overly complex statistical models
✗ Don't forget to update drivers/parameters
✗ Don't display forecasts as certainties
✗ Don't make confidence intervals too narrow
✗ Don't forecast for highly volatile metrics without caution
```

---

## FORECAST MODEL SELECTION GUIDE

| Metric | Recommended Method | Seasonality | Drivers | Accuracy |
|---|---|---|---|---|
| Revenue | Exponential Smoothing + Volume | Yes | Price × Volume | ±15% |
| COGS | % of Revenue | Moderate | Revenue | ±12% |
| OpEx | Base + Growth Rate | Low | Inflation | ±8% |
| Cash Flow | Drivers-based | High | AR, AP, Inventory | ±20% |
| Headcount | Step-based | None | Hires/Attrition | ±5% |

---

## PERFORMANCE CONSIDERATIONS

### Query Optimization
```
✓ Pre-calculate forecast values in Power Query
✓ Use aggregated tables for confidence intervals
✓ Cache forecast parameters
✓ Avoid complex DAX in tooltips
✓ Limit forecast period to 24 months max
```

### Visual Performance
```
✓ Line chart render time: < 2 seconds
✓ What-If parameter change: < 1 second
✓ Tooltip display: < 500ms
✓ Drill-through: < 3 seconds
```

---

## TESTING CHECKLIST

- [ ] Forecast values are reasonable (within 30% of actual)
- [ ] Confidence intervals are symmetric
- [ ] Parameters update forecast correctly
- [ ] Scenarios produce expected results
- [ ] What-If changes propagate correctly
- [ ] Accuracy metrics calculate correctly
- [ ] Tooltips display complete information
- [ ] Drill-through navigation works
- [ ] Performance acceptable with full data
- [ ] Forecast refreshes on schedule

---

## NEXT STEPS

1. Define forecast methodology and drivers
2. Create forecast parameter table
3. Implement forecast DAX measures
4. Design forecast visualizations
5. Set up What-If analysis interface
6. Create accuracy tracking dashboard
7. Document forecast assumptions
8. Train users on forecast capabilities
