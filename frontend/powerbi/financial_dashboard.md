# Financial Dashboard Design & Implementation

## Overview
This document defines the complete Financial Dashboard for the Enterprise KPI Platform, including layout, visualizations, interactions, and calculations.

---

## Dashboard Purpose & Audience

### Primary Audience
- CFO & Finance Leadership
- Financial Controllers
- Budget Managers
- Finance Analysts

### Key Objectives
1. Real-time financial performance monitoring
2. P&L variance analysis and forecasting
3. Cash flow tracking and projections
4. Budget vs. Actual comparison
5. Cost breakdown and expense analysis
6. Revenue trend analysis

---

## Dashboard Layout & Structure

### Page Grid: 4 Columns × 5 Rows (20 sections)

```
┌─────────────────────────────────────────────────────────┐
│ Row 1: Header & Controls (Full Width)                   │
│ Title: Financial Dashboard | Period Selector | Filters │
└─────────────────────────────────────────────────────────┘

┌──────────────┬──────────────┬──────────────┬──────────────┐
│  Row 2:      KPI Cards (Four 1x1 blocks)                │
│  Revenue     Gross Profit  OpEx Total    Cash Flow      │
│  (YTD)       (YTD)         (YTD)         (Monthly)      │
└──────────────┴──────────────┴──────────────┴──────────────┘

┌──────────────┬──────────────┬──────────────┬──────────────┐
│  Row 3:      Revenue Analysis (Left) & Expense (Right)  │
│  Revenue     Revenue       Expense       Expense        │
│  Trend       vs Target     Breakdown     Trend          │
│  (Line)      (Gauge)       (Pie)         (Line)         │
└──────────────┴──────────────┴──────────────┴──────────────┘

┌────────────────────────────┬────────────────────────────┐
│  Row 4: P&L Waterfall (Left × 2) | Cash Flow (Right × 2)│
│                             │                            │
│  P&L Build-up              │  Cash Flow Waterfall       │
│  (Waterfall Chart)         │  (Waterfall Chart)         │
│                             │                            │
└────────────────────────────┴────────────────────────────┘

┌──────────────┬──────────────┬──────────────┬──────────────┐
│  Row 5:      Forecast & Variance Analysis               │
│  Revenue     EBITDA        Margin %       Key Drivers   │
│  Forecast    vs Actual     vs Target      Matrix Table  │
│  (Line+Area) (Clustered)   (KPI Card)     (Table)       │
└──────────────┴──────────────┴──────────────┴──────────────┘
```

---

## ROW 1: HEADER & CONTROLS (Full Width)

### Title Section
```
Text Box: "Financial Dashboard"
Font: Bold, 24pt
Format: Company-branded color scheme

Dynamic Subtitle:
= "Financial Performance for " & FORMAT(TODAY(), "MMMM YYYY")
```

### Filter Controls (Left to Right)
1. **Period Selector** - Dropdown
   - Values: Current Month, YTD, Last Quarter, Last Year, Custom Range
   - Default: YTD
   - Syncs with: Dim_Date

2. **Company Filter** - Multi-select
   - Values: All companies in Dim_Company
   - Default: All
   - Type: Dropdown (searchable)

3. **Department Filter** - Multi-select
   - Values: All departments
   - Default: All
   - Type: Dropdown (cascading from company)

4. **Refresh Indicator**
   - Formula: "Last updated: " & FORMAT(NOW(), "HH:MM AM/PM")
   - Color: Green (if < 1 hour), Yellow (1-4 hours), Red (> 4 hours)

---

## ROW 2: FINANCIAL KPI CARDS (4 × 1×1 blocks)

### Card 1: Total Revenue (YTD)
```
Visualization Type: KPI Card + Sparkline
Dimensions: 250px × 150px

Primary Value: [YTD Revenue]
Format: $XXX,XXX,XXX (currency, 0 decimals)

Indicator (Top-Right):
- Formula: [YTD Revenue] - [Prior Year YTD Revenue]
- Format: +XX% or -XX% 
- Color: Green (positive), Red (negative)

Comparison Text (Bottom):
= "Target: $" & FORMAT([Revenue Target], "0,,") & "M" 
= " | Achievement: " & FORMAT([Revenue vs Target], "0%")

Status Color Coding:
✓ Green (#4CAF50): ≥ Target
⚠ Amber (#FF9800): 95-99% of Target
✗ Red (#F44336): < 95% of Target

Interactions:
- Click → Drill to Revenue by Department
- Hover → Show tooltip with monthly breakdown
```

---

### Card 2: Gross Profit (YTD)
```
Visualization Type: KPI Card + Gauge (Small)
Dimensions: 250px × 150px

Primary Value: [YTD Gross Profit]
Format: $XXX,XXX,XXX (0 decimals)

Gauge (Background):
- Min: 0
- Max: [Revenue Target] × 0.4 (40% margin target)
- Current: [YTD Gross Profit]
- Color Gradient: Red → Yellow → Green

Indicator:
= DIVIDE([YTD Gross Profit], [YTD Revenue], 0) * 100
Format: XX.X% (Gross Margin %)

Comparison:
= "vs LY: " & FORMAT([Gross Profit vs Prior Year], "+0%")

Status Color:
✓ Green: > 38% margin
⚠ Amber: 35-38% margin
✗ Red: < 35% margin
```

---

### Card 3: Operating Expense (YTD)
```
Visualization Type: KPI Card + Progress Bar
Dimensions: 250px × 150px

Primary Value: [YTD OpEx]
Format: $XXX,XXX,XXX (0 decimals)

Progress Bar (Bottom):
- Total: [OpEx Budget]
- Current: [YTD OpEx]
- Percentage: DIVIDE([YTD OpEx], [OpEx Budget], 0)
- Color: Green if < 100%, Red if > 100%

Indicator:
= "vs Budget: " & FORMAT(DIVIDE([YTD OpEx], [OpEx Budget], 0), "0%")

Comparison:
= "vs LY: " & FORMAT([OpEx vs Prior Year], "+0%")

Status Color:
✓ Green: < 95% of budget
⚠ Amber: 95-100% of budget
✗ Red: > 100% of budget
```

---

### Card 4: Cash Flow (Monthly)
```
Visualization Type: KPI Card + Trend Arrow
Dimensions: 250px × 150px

Primary Value: [Current Month Cash Flow]
Format: $XXX,XXX,XXX (0 decimals)

Trend Arrow:
= IF([Current Month Cash Flow] > [Prior Month Cash Flow], 
     "↑ Improving", 
     "↓ Declining")

Indicator:
= [Current Month Cash Flow] - [Prior Month Cash Flow]
Format: +$XXX,XXX or -$XXX,XXX
Color: Green (positive), Red (negative)

Comparison:
= "Forecast: $" & FORMAT([Next Month Forecast], "0,,") & "M"

Status Color:
✓ Green: Positive cash flow
⚠ Amber: Cash flow in range (±10%)
✗ Red: Negative cash flow

Note: This card updates daily for real-time cash tracking
```

---

## ROW 3: REVENUE & EXPENSE ANALYSIS

### Chart 1: Revenue Trend (Line Chart)
```
Visualization Type: Line Chart with Area Fill
Position: 250×150px (1×1 block)
Dimensions: 150%

X-Axis: 
- Field: Dim_Date[MonthName] + Dim_Date[Year]
- Period: Last 12 months
- Format: "Jan 2025" | "Feb 2025" | ... | "May 2026"

Y-Axis:
- Measure 1 (Primary): [Monthly Revenue]
- Measure 2 (Secondary): [Revenue Target] (dashed line)
- Format: Currency ($M)

Line Properties:
- Actual Revenue: Solid line, Blue (#2196F3), 3pt
- Target Revenue: Dashed line, Gray (#999999), 2pt
- Area Fill: Light blue with 20% opacity

Data Labels:
- Actual: Show on max/min points
- Format: $XXM (millions)

Interactions:
- Hover → Show tooltip with actual, target, variance
- Click → Filter other visuals by month
- Drill-down: Month → Week → Day (if data available)

Formatting:
- Legend: Top-right, show/hide toggle
- Title: "Revenue Trend (Last 12 Months)"
```

---

### Chart 2: Revenue vs Target (Gauge Chart)
```
Visualization Type: Gauge Chart (Semi-circle)
Position: 250×150px (1×1 block)

Gauge Settings:
- Minimum: 0
- Maximum: 150% (allows overage visibility)
- Current Value: [Revenue vs Target]
- Format: 0.0%

Color Zones:
- 0-80%: Red (#F44336) - Below target
- 80-100%: Amber (#FF9800) - Warning zone
- 100-115%: Light Green (#8BC34A) - Target achieved
- 115-150%: Green (#4CAF50) - Exceeds target

Callout Value:
- Format: "XX.X%"
- Display: Center of gauge
- Color: Changes with zone color

Target Line:
- Position: 100% mark
- Marker: Black vertical line

Tooltip:
= "Achievement: " & FORMAT([Revenue vs Target], "0.0%")
& " | Actual: $" & FORMAT([Total Revenue], "$#,##0")
& " | Target: $" & FORMAT([Revenue Target], "$#,##0")

Interactions:
- Click → Show variance detail page
```

---

### Chart 3: Expense Breakdown (Pie Chart)
```
Visualization Type: Pie Chart with Explode
Position: 250×150px (1×1 block)

Data:
- Legend: Fact_Finance[TransactionType]
  Values: COGS, OpEx, Tax, CapEx
- Values: [YTD Amount by Type]
- Format: Currency

Pie Segments (Colors):
- COGS: Red (#EF5350) - largest segment
- OpEx: Orange (#FF9800)
- Tax: Yellow (#FDD835)
- CapEx: Blue (#42A5F5)

Data Labels:
- Show: Percentage only
- Format: X.X%
- Outside labels: Yes
- Lines: Yes (pointing to segments)

Explode Segments:
- Largest segment (COGS): Explode 10%
- Others: No explode

Legend:
- Position: Bottom
- Format: Type | Value ($XXM)

Tooltip:
= CONCATENATE(
    "Category: ", [TransactionType], CHAR(10),
    "Amount: $", FORMAT([YTD Amount], "#,##0"), CHAR(10),
    "Percent: ", FORMAT([Percent of Total], "0.0%")
  )

Interactions:
- Click → Drill to expense detail
- Hover → Highlight segment
```

---

### Chart 4: Expense Trend (Line Chart - Dual Axis)
```
Visualization Type: Line + Clustered Column Combo Chart
Position: 250×150px (1×1 block)

X-Axis:
- Field: Dim_Date[MonthName] & Year
- Period: Last 12 months

Primary Y-Axis (Column):
- Measure: [Monthly COGS]
- Color: Red (#EF5350)
- Format: Currency ($M)

Secondary Y-Axis (Line):
- Measure: [COGS as % of Revenue]
- Format: Percentage (X.X%)
- Color: Dark Red (#C62828)
- Line: 2pt, no fill

Data Labels:
- Columns: Show value ($XXM)
- Line: Show percentage (XX.X%)

Legend:
- Position: Top
- Items: "COGS (Amount)" | "COGS % of Revenue"

Tooltip:
= "Month: " & [Month]
& CHAR(10) & "COGS: $" & FORMAT([Monthly COGS], "#,##0")
& CHAR(10) & "% of Revenue: " & FORMAT([COGS %], "0.0%")

Interactions:
- Click → Show expense detail by department
- Trend arrow: If current > prior month = Red arrow ↑
```

---

## ROW 4: P&L AND CASH FLOW WATERFALL CHARTS

### Chart 1: P&L Waterfall (2×1 block - Full Detail)
See detailed specification in [waterfall_charts.md](waterfall_charts.md) Section 1

### Chart 2: Cash Flow Waterfall (2×1 block - Full Detail)
See detailed specification in [waterfall_charts.md](waterfall_charts.md) Section 2

---

## ROW 5: FORECAST & VARIANCE ANALYSIS

### Chart 1: Revenue Forecast (Line + Area)
```
Visualization Type: Line Chart with Forecast Area
Position: 250×150px (1×1 block)

X-Axis:
- Period: Last 6 months actual + Next 6 months forecast
- Format: Month-Year

Y-Axis:
- Measure: [Monthly Revenue] and [Forecasted Revenue]
- Format: Currency ($M)

Data Series:
1. Actual Revenue (Solid Line)
   - Color: Blue (#2196F3)
   - Width: 3pt
   - Marker: Circle (5pt)

2. Forecasted Revenue (Dashed Line)
   - Color: Green (#4CAF50)
   - Width: 2pt
   - Marker: Diamond (4pt)
   - Start: Current month + 1

3. Forecast Confidence Interval (Area)
   - Color: Light green with 30% opacity
   - Upper Bound: Forecast + 10%
   - Lower Bound: Forecast - 10%

Trend Line:
- Underlying trend (3-month moving average)
- Color: Gray (#999999), dotted

Data Labels:
- Actual: Show for last 3 months
- Forecast: Show all forecasted values
- Format: $XXM

Vertical Reference Line:
- Position: Today
- Color: Black (#000000)
- Style: Dashed
- Label: "Today"

Tooltip:
= "Period: " & [Month] & CHAR(10)
& "Actual: $" & FORMAT([Revenue], "$#,##0") & CHAR(10)
& "Forecast: $" & FORMAT([Forecast], "$#,##0") & CHAR(10)
& "Variance: " & FORMAT([Variance %], "+0.0%")

Interactions:
- Click on forecast point → Show assumptions
- Hover → Show confidence bounds
```

---

### Chart 2: EBITDA Actual vs Forecast (Clustered Bar)
```
Visualization Type: Clustered Column Chart
Position: 250×150px (1×1 block)

X-Axis:
- Field: Dim_Date[MonthName] + Year
- Period: Last 6 months + Next 6 months forecast

Y-Axis:
- Format: Currency ($M)
- Scale: -$XX to +$XXM

Data Series:
1. Actual EBITDA (Columns)
   - Color: Blue (#2196F3)
   - Position: Left

2. Forecasted EBITDA (Columns)
   - Color: Green (#4CAF50)
   - Position: Right

3. EBITDA Target (Line overlay)
   - Color: Red (#F44336)
   - Style: Dashed line at budget level
   - Width: 2pt

Data Labels:
- Show: Value for columns, % for line
- Format: $XXM and X.X%
- Position: Top of columns

Variance Highlighting:
- If Actual < Forecast AND < Target: Red background
- If Actual ≥ Forecast OR ≥ Target: Green background

Interactions:
- Click → Show component breakdown (Revenue - COGS - OpEx)
- Hover → Show variance to forecast
```

---

### Chart 3: Margin % vs Target (KPI Card)
```
Visualization Type: KPI Card + Multi-ring Gauge
Position: 250×150px (1×1 block)

Primary Value: [Gross Margin %]
Format: XX.X%

Ring Gauge (Background):
- Inner Ring: Actual margin (current %)
- Outer Ring: Target margin (40%)
- Colors: Green if actual > target, Red otherwise

Comparison Text:
= "vs Target: " & IF([Gross Margin %] > 40, "+", "") 
& FORMAT([Gross Margin %] - 40, "0.0%")

Secondary Value (Below):
= "EBITDA Margin: " & FORMAT([EBITDA Margin %], "0.0%")

Trend:
= IF([Current Month Margin] > [Prior Month Margin], 
     "↑ Improving +" & FORMAT([Margin Trend], "0.0%"),
     "↓ Declining " & FORMAT([Margin Trend], "0.0%"))

Status Color:
✓ Green: > 40% target
⚠ Amber: 38-40% target
✗ Red: < 38% target

Tooltip:
= "Gross Margin: " & FORMAT([Gross Margin %], "0.0%")
& CHAR(10) & "EBITDA Margin: " & FORMAT([EBITDA Margin %], "0.0%")
& CHAR(10) & "Operating Margin: " & FORMAT([Operating Margin %], "0.0%")
```

---

### Chart 4: Key Drivers Analysis (Matrix Table)
```
Visualization Type: Table (Sortable/Filterable)
Position: 250×150px (1×1 block)

Columns (Left to Right):
1. Metric Name (Text)
   - Examples: Revenue, COGS, OpEx, EBITDA, Tax

2. Current Month (Currency)
   - Format: $#,##0
   - Conditional formatting: Red < Budget, Green ≥ Budget

3. YTD (Currency)
   - Format: $#,##0

4. Budget (Currency)
   - Format: $#,##0
   - Color: Light gray background

5. Variance (Currency + %)
   - Format: +$#,##0 (+0.0%)
   - Color: Red (negative), Green (positive)

6. vs LY (Currency + %)
   - Format: +$#,##0 (+0.0%)
   - Color: Red (negative), Green (positive)

Rows:
- Revenue
- COGS
- Gross Profit
- Operating Expenses
  - Sales & Marketing
  - General & Administrative
  - Depreciation
- EBITDA
- Interest & Tax
- Net Income

Conditional Formatting:
- Variance > +10%: Light green background
- Variance < -10%: Light red background
- Current row: Bold text

Sorting:
- Default: By metric order (Revenue → Net Income)
- Clickable: Any column header to sort

Interactions:
- Click row → Drill to department/cost center breakdown
- Right-click → Export to Excel
- Sort ascending/descending by any column

Tooltip (Hover):
= [Metric Name] & CHAR(10)
& "This Month: " & FORMAT([Current Month], "$#,##0") & CHAR(10)
& "Budget: " & FORMAT([Budget], "$#,##0") & CHAR(10)
& "Variance: " & FORMAT([Variance %], "+0.0%")
```

---

## PAGE INTERACTIONS & FILTERING

### Slicer Sync Behavior
```
Period Slicer:
→ Filters all charts and cards on this page
→ Cascades to other Finance pages
→ Updates KPI cards values

Company Slicer:
→ Filters all data by selected company
→ Shows company-specific forecast
→ Updates variance calculations

Department Slicer:
→ Filters expense breakdown by department
→ Updates COGS, OpEx, and P&L waterfall
→ Shows department-specific forecast
```

### Cross-Visual Filters
```
Chart Click Actions:
1. Revenue Trend (Click bar) → Filter by month
   → Updates all other row charts for that month

2. Expense Breakdown (Click slice) → Filter by expense type
   → Shows details of that expense category

3. Waterfall (Click component) → Drill to that line item
   → Shows sub-components and drivers

4. Table (Click row) → Filter related charts
   → Shows that metric's detailed breakdown
```

### Drill-Through Navigation
```
Click any card/chart → Drill to:
1. Revenue Trend → Revenue by Department page
2. Expense Breakdown → Expense Detail page
3. P&L Waterfall → Line Item Detail page
4. Forecast → Forecast Assumptions page
5. Variance → Variance Analysis page
```

---

## DAX MEASURES REQUIRED

### Core Measures (See dax_measures.md for full definitions)
```
Financial Measures:
- [Total Revenue]
- [Gross Profit]
- [Gross Profit %]
- [Operating Expense]
- [EBITDA]
- [EBITDA Margin %]
- [Net Income]
- [Operating Margin %]

YTD Measures:
- [YTD Revenue]
- [YTD Gross Profit]
- [YTD OpEx]
- [YTD EBITDA]

Comparison Measures:
- [Prior Year Revenue]
- [Revenue vs Target]
- [Revenue Growth %]
- [Gross Profit vs Prior Year]
- [OpEx vs Prior Year]

Forecast Measures:
- [Next Month Revenue Forecast]
- [Next Month EBITDA Forecast]
- [Forecasted Margin %]
```

---

## VISUAL FORMATTING & STYLING

### Color Scheme
```
Primary Colors:
- Revenue: Blue (#2196F3)
- Profit: Green (#4CAF50)
- Expense/Cost: Red (#F44336)
- Target/Budget: Gray (#999999)
- Forecast: Teal (#009688)

Status Colors:
- Positive/Good: Green (#4CAF50)
- Warning/Caution: Amber (#FF9800)
- Negative/Poor: Red (#F44336)

Neutral: Light gray (#F5F5F5)
```

### Typography
```
Title: 24pt, Bold, Dark Gray
Subtitle: 14pt, Regular, Medium Gray
Labels: 12pt, Regular, Dark Gray
Values: 16pt, Bold, Dark Gray
Legend: 11pt, Regular, Dark Gray
```

### Spacing
```
Margins: 20px from page edges
Padding: 10px within visuals
Gap between charts: 15px
Row spacing: 20px
```

---

## DASHBOARD REFRESH & PERFORMANCE

### Refresh Schedule
```
Daily Refresh: 2 AM UTC
- Loads overnight when warehouse updates
- Completes by 6 AM for morning review

On-Demand Refresh: Available via button
- Users can refresh if needed
- Manual refresh < 2 minutes

Auto-Refresh (Cloud):
- Every 15 minutes during business hours (8 AM - 6 PM)
- Every 60 minutes off-hours
```

### Performance Targets
```
- Dashboard load time: < 5 seconds
- Slicer filter response: < 2 seconds
- Drill-through navigation: < 3 seconds
- Forecast calculation: < 1 second
```

---

## NEXT STEPS

1. ✓ Review layout and chart specifications
2. ✓ Gather required data (P&L, cash flow, forecasts)
3. ✓ Implement waterfall charts (see waterfall_charts.md)
4. ✓ Implement forecast visuals (see forecast_visuals.md)
5. ✓ Create all required DAX measures
6. ✓ Set up slicers and interactions
7. ✓ Test dashboard with real data
8. ✓ Gather user feedback for refinement
