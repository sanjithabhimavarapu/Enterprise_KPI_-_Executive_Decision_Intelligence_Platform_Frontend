# Customer Dashboard - Detailed Design Specification

## Overview
The Customer Dashboard delivers customer segmentation analysis, retention cohort tracking, and behavioral analytics for marketing, sales, and customer success teams. Enables drill-down from portfolio-level health to individual customer journeys.

---

## Page Structure & Layout

**Grid**: 4 columns × 7 rows (28 sections)
**Refresh Interval**: Daily (with real-time NPS / support metrics overlay)
**Target Users**: CMO, VP Sales, Customer Success Lead, Marketing Analysts

### Row 1: Header & Controls (Full Width)
```
[Logo] Customer Analytics Dashboard | [Segment Filter] [Region Filter] [Date Range] [Cohort Toggle] [Export]
```
- Height: 60px
- Background: Dark Navy (#1E1E1E)
- Text: White
- Global filters: Segment, CustomerType, Region, Date Range, Acquisition Cohort

---

## Row 2: Primary Customer KPI Cards (4 Cards)

### KPI Card 1: Total Active Customers
```
Metric: Distinct count of active customers in filter context
Source: Dim_Customer, Fact_Customer_Metrics
Visualization: Large KPI Card
Dimensions: 250px × 160px

Display Format:
  Primary Value: XXX,XXX (bold, 48pt)
  
  Secondary Metrics:
    New This Period:  +X,XXX (green)
    Churned:         -XXX   (red)
    Net Change:      ↑/↓ X.X%
  
  Segment Breakdown (inline spark):
    Premium: XX% | Standard: XX% | Economy: XX%

Color Coding:
  YoY Growth ≥ 5%:   Green
  Flat (±2%):         Neutral Gray
  Decline > 2%:       Red

Interactions:
  Click → Customer list filtered to active
  Drill → Segment breakdown table
```

### KPI Card 2: Customer Retention Rate
```
Metric: % of prior-period customers retained in current period
Source: Fact_Customer_Metrics
Visualization: KPI Card with Gauge
Dimensions: 250px × 160px

Display Format:
  Primary Value: XX.X% (bold, 48pt)
  Gauge Arc: 0–100% with zones
  
  Secondary Metrics:
    MoM Change:  ↑/↓ X.X% pts
    Target:      90% (configurable)
    At-Risk Pool: X,XXX customers flagged
  
  Trend Spark: Last 12 months sparkline

Color Coding:
  ≥ 90%:  Green
  80–89%: Amber
  < 80%:  Red

Interactions:
  Click → Cohort retention detail page
  Hover → Monthly retention breakdown tooltip
```

### KPI Card 3: Customer Churn Rate
```
Metric: % of customers lost in current period vs start-of-period base
Source: Fact_Customer_Metrics
Visualization: KPI Card with Trend
Dimensions: 250px × 160px

Display Format:
  Primary Value: X.X% (bold, 48pt)
  
  Secondary Metrics:
    Voluntary Churn:    X.X%
    Involuntary Churn:  X.X%
    Churned Revenue:    $X,XXX,XXX
    Churn vs Target:    ↑/↓ X.X% pts
  
  Risk Alert Badge:
    X customers with Churn Risk Score > 75 (red badge)

Color Coding (inverted — lower is better):
  < 3%:  Green
  3–6%:  Amber
  > 6%:  Red

Interactions:
  Click → Churn risk detail with scored customer list
  Drill → Churn reasons breakdown (waterfall chart)
```

### KPI Card 4: Customer Lifetime Value (CLV)
```
Metric: Predicted total revenue per customer over relationship lifetime
Source: Fact_Sales, Fact_Customer_Metrics
Visualization: KPI Card with Segment Comparison
Dimensions: 250px × 160px

Display Format:
  Primary Value: $XX,XXX (avg CLV, bold 48pt)
  
  Secondary Metrics:
    Premium Avg CLV:    $XXX,XXX
    Standard Avg CLV:   $XX,XXX
    Economy Avg CLV:    $X,XXX
    YoY CLV Change:     ↑/↓ X.X%
  
  Target Indicator:
    CLV Target: $XX,XXX | Achievement: XX%

Color Coding:
  ≥ Target: Green
  90–99% of Target: Amber
  < 90% of Target: Red

Interactions:
  Click → CLV distribution histogram
  Drill → Top 50 customers by CLV
```

---

## Row 3: Customer Segmentation (Full Width)

### RFM Segmentation Matrix (Left — 55%)
```
Metric: Recency × Frequency × Monetary value segmentation
Source: Fact_Sales, Dim_Customer
Visualization: Scatter Plot / Bubble Chart
Dimensions: ~700px × 280px

Axes:
  X-axis: Recency Score (1–5, right = more recent)
  Y-axis: Frequency Score (1–5, up = more frequent)
  Bubble Size: Monetary value (larger = higher spend)
  
Quadrant Labels (overlaid):
  Top-Right:   "Champions"       (High R, High F)
  Top-Left:    "At Risk"         (Low R, High F)
  Bottom-Right:"Promising"       (High R, Low F)
  Bottom-Left: "Lost / Inactive" (Low R, Low F)

Color by Segment:
  Champions:    Green (#4CAF50)
  Loyal:        Blue (#2196F3)
  At Risk:      Amber (#FF9800)
  Need Attention:Orange (#FF5722)
  Lost:         Red (#F44336)
  New Customer: Teal (#009688)
  Promising:    Purple (#9C27B0)

Legend: Right side — segment name + count + % of base

Interactions:
  Click bubble/cluster → Filter all visuals to that segment
  Hover → Tooltip: segment name, count, avg CLV, avg order value
  Lasso select: Draw around group to filter
  Zoom: Pinch/scroll to zoom in
```

### Segment Performance Summary Table (Right — 45%)
```
Metric: KPIs broken down by RFM segment
Source: Fact_Sales, Fact_Customer_Metrics, Dim_Customer
Visualization: Matrix with conditional formatting
Dimensions: ~540px × 280px

Rows: Segment Name (Champions, Loyal, Promising, etc.)
Columns:
  Count | % Base | Avg CLV | Avg Order Value | Retention % | Churn Risk % | Revenue Contribution %

Conditional Formatting:
  Retention %: ≥90% Green | 75-89% Amber | <75% Red
  Churn Risk %: <10% Green | 10-25% Amber | >25% Red
  Revenue %: Top segment → darker green gradient

Interactions:
  Click segment row → Filter scatter plot + all cards
  Sort any column
  Export to Excel
```

---

## Row 4: Retention Cohort Analysis (Full Width)

### Cohort Retention Heatmap (Full Width)
```
Metric: Month-over-month retention rate per acquisition cohort
Source: Fact_Customer_Metrics, Dim_Date, Dim_Customer
Visualization: Cohort Heatmap (Matrix)
Dimensions: Full width × 300px

Rows: Acquisition Cohort (e.g., "Jan 2025", "Feb 2025" … "Apr 2026")
Columns: Months since acquisition (Month 0, Month 1 … Month 24)
Cell Value: Retention % for that cohort × elapsed month

Cell Color Scale (Gradient):
  100%:   Dark Green (#2E7D32)
  80–99%: Green (#4CAF50)
  60–79%: Light Green (#A5D6A7)
  40–59%: Amber (#FFB74D)
  20–39%: Orange (#FF7043)
  0–19%:  Red (#F44336)
  No Data: Light Gray (#E0E0E0)

Row Headers:
  Cohort label | Initial Size | Current Retained | Cohort Retention %

Column Headers:
  M+0 (always 100%) | M+1 | M+2 | … | M+24

Visual Annotations:
  Average retention curve overlaid (white dashed line across each column)
  Best performing cohort: Bold border
  Worst performing cohort: Red border

Interactions:
  Click cell → Filter customer list to that cohort + month
  Click row header → Cohort deep-dive drill-through
  Hover → Tooltip: cohort, month, retained count, lost count, retention %
  Toggle: View as % or as customer count
  Scroll: Horizontal for months > 12
```

---

## Row 5: Churn Risk & Acquisition Trends (2 Charts)

### Chart A: Churn Risk Distribution (Left — 50%)
```
Metric: Distribution of customers across churn risk score tiers
Source: Fact_Customer_Metrics (ChurnRiskScore 0–100)
Visualization: Stacked Horizontal Bar Chart (by segment) + summary
Dimensions: ~600px × 260px

Y-axis: Customer Segment
X-axis: Customer Count (stacked by risk tier)

Risk Tier Stack Colors:
  Low Risk   (0–25):   Green (#4CAF50)
  Medium Risk(26–50):  Amber (#FF9800)
  High Risk  (51–75):  Orange (#FF5722)
  Critical   (76–100): Red (#F44336)

Data Labels:
  Count + % per tier per segment

Right Summary Panel (inline):
  Total At-Risk (>50):   X,XXX
  Total Critical (>75):  XXX
  Avg Risk Score:        XX.X
  Highest-Risk Segment:  [Name]

Interactions:
  Click tier → Filter customer list to that risk band
  Hover → Tooltip: count, avg risk score, top churn signals for tier
  Period selector: Last 30 / 60 / 90 days
```

### Chart B: Customer Acquisition & Churn Trend (Right — 50%)
```
Metric: Monthly new acquisitions vs churn over rolling 18 months
Source: Fact_Customer_Metrics, Dim_Date
Visualization: Grouped Bar Chart + Net Line
Dimensions: ~600px × 260px

X-axis: Month (last 18 months)
Primary Y-axis (Bars):
  New Customers (Green bars)
  Churned Customers (Red bars, below baseline)
Secondary Y-axis (Line):
  Net Customer Change (Blue line)
  Net Zero Reference Line (Gray dashed)

Annotations:
  Mark months with net negative (red triangle marker)
  
Data Labels:
  Net Change value above/below each month group

Interactions:
  Hover → Tooltip: month, new, churned, net, cumulative base
  Click bar → Filter to customers acquired/churned that month
  Toggle: Monthly / Quarterly view
```

---

## Row 6: Behavioral Analytics (2 Panels)

### Panel A: Purchase Behavior Funnel (Left — 45%)
```
Metric: Customer journey stage conversion rates
Source: Fact_Customer_Behavior, Fact_Sales
Visualization: Funnel Chart
Dimensions: ~540px × 280px

Funnel Stages (top → bottom):
  1. Awareness / Site Visit
  2. Product View / Engagement
  3. Add to Cart / Intent Signal
  4. Checkout / Quote Request
  5. Purchase / Contract Signed
  6. Repeat Purchase (2nd transaction)
  7. Loyal (5+ transactions)

Bar Labels:
  Stage name | Count | Conversion from previous stage %
  
Color:
  Each stage progressively darker blue (#E3F2FD → #0D47A1)
  Drop-off annotated in red on right side

Segment Filter:
  Linked to global Segment slicer
  Show: All / Premium / Standard / Economy

Interactions:
  Click stage → Customer list at that stage
  Hover → Tooltip: count, %, avg time in stage, drop-off reasons
  Drill: Click drop-off → drop-off analysis detail
```

### Panel B: Product & Category Affinity Heatmap (Right — 55%)
```
Metric: Cross-purchase patterns across product categories by segment
Source: Fact_Sales, Dim_Product, Dim_Customer
Visualization: Heatmap (Matrix)
Dimensions: ~660px × 280px

Rows: Customer Segment (Premium / Standard / Economy / Enterprise / etc.)
Columns: Product Category (up to 12 categories)
Cell Value: % of segment that purchased from that category

Color Scale:
  0%:    White
  1–25%: Light Blue (#E3F2FD)
  26–50%: Medium Blue (#90CAF9)
  51–75%: Blue (#2196F3)
  76–100%:Dark Blue (#1565C0)

Annotations:
  Top category per segment: Bold border
  Cross-sell opportunities (low penetration high-value): Orange outline

Interactions:
  Click cell → Customer list: segment × category combination
  Hover → Tooltip: count, %, avg order value, top product in cell
  Toggle: View by % penetration / Avg Order Value / Revenue $
```

---

## Row 7: Customer Activity Timeline & Health Score (2 Panels)

### Panel A: Customer Health Score Distribution (Left — 40%)
```
Metric: Distribution of Customer Health Scores (0–100)
Source: Fact_Customer_Metrics (HealthScore)
Visualization: Donut Chart + Score Bands Summary
Dimensions: ~480px × 240px

Segments:
  Healthy   (75–100): Green  — XX% (X,XXX customers)
  Stable    (50–74):  Blue   — XX%
  At Risk   (25–49):  Amber  — XX%
  Critical  (0–24):   Red    — XX%

Center Label:
  Avg Health Score: XX.X

Below Donut — Trend Grid:
  MoM Health Score Change:   ↑/↓ X.X pts
  Healthy → Stable migration: XXX this month
  At Risk → Critical:         XX this month
  Critical rescued:           XX this month

Interactions:
  Click segment → Customer list filtered to health band
  Hover → Tooltip: count, avg CLV for band, dominant churn signals
```

### Panel B: Engagement Activity Timeline (Right — 60%)
```
Metric: Aggregate customer interaction events over time (last 90 days)
Source: Fact_Customer_Behavior
Visualization: Multi-Series Area Chart (stacked)
Dimensions: ~720px × 240px

X-axis: Date (daily, last 90 days)
Y-axis: Event Count
Series (stacked areas):
  Purchases         (Dark Blue)
  Support Contacts  (Amber)
  Login / App Opens (Light Blue)
  Email Opens       (Purple)
  Complaints        (Red, thin line overlay — not stacked)

Reference Lines:
  Campaign launch dates: Vertical markers with labels
  Holiday/seasonal events: Shaded background bands

Interactions:
  Hover → Tooltip: date, breakdown by event type, top segment
  Click area series → Filter customer list to that interaction type
  Brush/zoom: Drag to narrow date range
  Toggle: Absolute count / % of base
```

---

## Drill-Through Pages

### Customer 360 Drill-Through
```
Trigger: Click customer name in any customer list table
Context: Single customer filtered

Layout (4 cols × 4 rows):
  Row 1: Customer header (name, type, segment, health badge), back button
  Row 2: KPIs — CLV, Orders, Avg Order Value, Days Since Last Purchase, Health Score
  Row 3: Purchase history timeline, product category breakdown, support history
  Row 4: Churn risk signals scorecard, recommended actions, contact history
```

### Cohort Deep-Dive Drill-Through
```
Trigger: Click cohort row in retention heatmap
Context: Single acquisition cohort filtered

Layout (4 cols × 3 rows):
  Row 1: Cohort header (acquisition month, initial size), back button
  Row 2: Retention curve (line chart vs platform avg), revenue from cohort over time
  Row 3: Segment mix in cohort, top churn reasons, saved customers list
```

### Segment Deep-Dive Drill-Through
```
Trigger: Click segment in scatter plot or segment table
Context: Single RFM segment filtered

Layout (4 cols × 3 rows):
  Row 1: Segment header (name, count, % of base), key metrics KPIs
  Row 2: Acquisition trend, top products, geographic distribution
  Row 3: Migration flow (Sankey: how customers moved into/out of segment)
```

---

## Tooltip Pages

### Customer Tooltip (hover on customer in table)
```
Size: 320px × 200px
Content: Name, Segment, CLV, Last Purchase, Health Score gauge, Churn Risk badge
```

### Cohort Cell Tooltip (hover on heatmap cell)
```
Size: 280px × 160px
Content: Cohort, month number, retained count, lost count, retention %, vs avg %
```

### Segment Bubble Tooltip (hover on RFM scatter)
```
Size: 300px × 180px
Content: Segment name, customer count, avg CLV, avg frequency, avg recency days
```

---

## Filters & Slicers

| Slicer | Type | Default | Values |
|--------|------|---------|--------|
| Segment | Dropdown (multi) | All | Premium, Standard, Economy, Enterprise, SMB |
| CustomerType | Button slicer | All | Enterprise, Mid-Market, SMB, Individual |
| Region | Dropdown (multi) | All | All regions from Dim_Customer |
| Date Range | Date Picker | Last 12 months | Custom date range |
| Acquisition Cohort | Dropdown | All | Monthly cohorts |
| Churn Risk Band | Button slicer | All | Low, Medium, High, Critical |
| Health Score Band | Button slicer | All | Healthy, Stable, At Risk, Critical |

---

## Design Standards

### Color Palette
```
Page Background:      #1E1E1E  (Dark Navy)
Card Background:      #F5F5F5
Header Text:          #FFFFFF
Card Title:           #333333
Healthy / Positive:   #4CAF50
Warning:              #FF9800
Critical / Churn:     #F44336
Primary Blue:         #2196F3
Secondary Purple:     #9C27B0
Teal (New Customer):  #009688
```

### Canvas
```
Total Width:   1280px
Total Height:  1680px (scrollable, 7 rows)
Row Heights:   160px (KPI) | 280–300px (charts) | 300px (cohort heatmap)
Card Padding:  16px | Border Radius: 8px | Gap: 8px
```

### Typography
```
Dashboard Title:  Segoe UI, 28px, Bold, White
KPI Values:       Segoe UI, 48px, Bold, #333333
Section Headers:  Segoe UI, 18px, SemiBold, White
Table Headers:    Segoe UI, 12px, Bold, #333333
Table Data:       Segoe UI, 11px, Regular, #333333
```
