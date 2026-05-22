# Executive Dashboard - Complete Design Specification

## Overview
The Executive Dashboard provides a high-level strategic overview for C-suite executives with focus on revenue KPIs, performance scorecards, and regional analysis. Designed for CEOs, CFOs, COOs, and senior leadership.

---

## Page Structure & Layout

**Grid**: 4 columns × 5 rows (20 sections)
**Refresh Interval**: 15 minutes
**Target Users**: C-Suite Executives (CEO, CFO, COO, CMO, CTO)

### Row 1: Header & Navigation (Full Width)
```
[Logo] Executive Dashboard | [Period Selector] [Date Range] [Region Filter] [Refresh] [Export]
```
- Height: 60px
- Background: Dark Navy (#1E1E1E)
- Text: White
- Quick stats: YTD Performance at a glance

---

## Row 2: Primary Revenue KPI Cards (4 Cards × 1 Row)

### KPI Card 1: Total Revenue
```
Metric: SUM(Revenue) - Year-to-date
Source: Finance_Revenue_Fact
Visualization: Large KPI Card with Gauge Background
Dimensions: 250px × 160px

Display Format:
  Primary Value: $XXX,XXX,XXX (currency, 0 decimals)
  Primary Color: Large bold font (48pt)
  
  Secondary Metrics (below divider):
    YoY Growth: ↑ XX.X% (green if positive, red if negative)
    MoM Change: ↓ XX.X%
  
  Target Line:
    Target: $XXM | Achievement: XXX%
    Visual: Progress bar showing % to target
  
  Footer:
    Last Updated: X minutes ago
    Status: On Track / Behind / At Risk (color-coded)

Color Coding (by performance):
  ≥ 110% of target: Green (#4CAF50)
  95-109% of target: Amber (#FF9800)
  < 95% of target: Red (#F44336)

Gauge Background:
  Arc from 0 to 150% of target
  Needle: Current % achievement
  Zones: Red (0-80%), Amber (80-95%), Green (95%+)

Interactions:
  Click → Revenue Breakdown by Product/Channel/Region
  Hover → Detailed month-to-date vs target
  Drill → Multi-level drill-through to transaction detail
```

### KPI Card 2: Gross Profit Margin
```
Metric: (Gross Profit / Revenue) × 100
Source: Finance_Income_Statement + Finance_Revenue_Fact
Visualization: KPI Card with Trend Indicator
Dimensions: 250px × 160px

Display Format:
  Primary Value: XX.X% (2 decimals, bold 48pt)
  
  Secondary Metrics:
    QoQ Change: ↑/↓ X.X% points
    vs Benchmark: XX% (industry average)
    Status: Above / On / Below Benchmark
  
  Historical Trend:
    Spark line: Last 8 quarters
    Show: Quarter labels
  
  Threshold Indicators:
    Warning Level: 35% (amber)
    Critical Level: 30% (red)
    Target: 40% (green)

Color Coding (by margin level):
  ≥ 40%: Green
  35-39%: Amber
  < 35%: Red

Interactions:
  Click → Margin Analysis by Product Line
  Drill → Cost Structure Breakdown
  Hover → Detailed margin components
```

### KPI Card 3: Operating Cash Flow
```
Metric: Operating Cash Inflows - Outflows
Source: Finance_CashFlow_Fact
Visualization: KPI Card with Waterfall Mini Chart
Dimensions: 250px × 160px

Display Format:
  Primary Value: $X,XXX,XXX (currency format, bold)
  Trend: ↑/↓ X.X% vs same period prior year
  
  Status Badge:
    Positive Flow: Green "Healthy"
    Neutral (< $500K change): Gray "Stable"
    Negative Flow: Red "Attention Required"
  
  Period Comparison:
    MTD: $X,XXX,XXX
    QTD: $X,XXX,XXX
    YTD: $X,XXX,XXX
  
  Mini Waterfall (visual):
    Operating: ↑
    Investing: ↓
    Financing: ↑
    Net: [Total]

Interactions:
  Click → Cash Flow Waterfall Detail
  Drill → Component breakdown (operations, investing, financing)
```

### KPI Card 4: Customer Satisfaction (NPS)
```
Metric: ((Promoters - Detractors) / Respondents) × 100
Source: Customer_Satisfaction_Survey
Visualization: KPI Card with Gauge + Segment Breakdown
Dimensions: 250px × 160px

Display Format:
  Primary Value: XX (0-100 scale, bold 48pt)
  Status: "Excellent" / "Good" / "Fair" / "Poor"
  
  Trend vs 12-month average:
    vs Avg: XX (score comparison)
    Change: ↑/↓ X points
  
  Segment Breakdown (pie chart):
    Promoters (Green): XX%
    Passives (Gray): XX%
    Detractors (Red): XX%
    Shows percentages

Color Coding (by NPS):
  ≥ 70: Green "Excellent"
  50-69: Amber "Good"
  30-49: Yellow "Fair"
  < 30: Red "Poor"

Gauge Visual:
  Scale: 0-100
  Current value needle
  Target zone: 70+ (green band)
  Warning zone: 50-69 (yellow band)
  Critical zone: <50 (red band)

Interactions:
  Click → NPS Detail by Customer Segment
  Drill → Segment drill-down (by industry, region, product)
  Hover → Latest survey details
```

---

## Row 3: Revenue Performance Scorecards (2 Charts × 1 Row)

### Chart 1: YTD Revenue vs Target Progress (Waterfall + Line)
```
Metric: Cumulative Revenue (Month-to-Date Breakdown)
Source: Finance_Revenue_Fact (Monthly aggregation)
Visualization: Stacked Column + Line Chart Combo
Dimensions: 600px × 280px (2-column wide)

Layout:
  X-axis: Month (Jan - Current Month)
  Primary Y-axis: Revenue ($M)
  Secondary Y-axis: % of Target
  
Column Segments (stacked, by channel):
  Segment 1: Channel A (Color 1)
  Segment 2: Channel B (Color 2)
  Segment 3: Channel 3 (Color 3)
  Segment 4: Other (Color 4)
  Stack height: Total monthly revenue
  
Line Overlay:
  Line 1: Cumulative Target (Blue, dashed)
  Line 2: Cumulative Actual (Blue, solid)
  Data points: Monthly totals
  
Reference Elements:
  Target line: Total annual target
  YTD Achievement: Show current % of target
  Labels: Month, actual amount, % of target

Color Coding:
  Column (if below target): Lighter shade
  Column (if above target): Darker shade
  Gap visualization between actual and target

Configuration:
  Data labels: Show on bars
  Grid: Show minor gridlines
  Legend: Channel breakdown
  Sort: By calendar order (Jan-Dec)

Tooltip:
  Month: [Month Name]
  Revenue: $X,XXX,XXX
  by Channel:
    - Channel A: $X,XXX
    - Channel B: $X,XXX
    - etc.
  Cumulative: $X,XXX,XXX
  % of Target: XX%
  vs Prior Year: ↑↓ X%
  Gap to Target: $X,XXX

Interactions:
  Click month → Daily breakdown for that month
  Legend toggle → Show/hide channels
  Drill → Product line or customer detail
  Hover → Detailed breakdown
```

### Chart 2: Regional Performance Scorecard (Matrix/Table with Conditional Formatting)
```
Metric: Revenue by Region with Performance Indicators
Source: Finance_Revenue_Fact + Dim_Geography
Visualization: Matrix/KPI Table with Conditional Formatting
Dimensions: 600px × 280px (2-column wide)

Rows (by Region):
  North America
  Europe
  Asia Pacific
  Latin America
  Middle East & Africa
  (or custom regions based on business)

Columns (displayed metrics):
  1. Region Name
  2. YTD Revenue ($M)
  3. % of Total
  4. vs Target (Achievement %)
  5. YoY Growth %
  6. Rank (1-5)
  7. Status (Icon)
  8. Trend (Arrow)

Row Data Example:
  North America | $125M | 42% | 105% | +8.5% | #1 | ✓ | ↑

Column Formatting:
  Column 2 (YTD Revenue):
    Data bars (green gradient, 0-$150M scale)
    Right-aligned numbers
    Bold font for largest value
  
  Column 3 (% of Total):
    Percentage format (XX.X%)
    Color by proportion (larger = darker green)
  
  Column 4 (vs Target):
    Background color:
      ≥ 105% = Green (#4CAF50)
      95-104% = Amber (#FF9800)
      < 95% = Red (#F44336)
    Font: Bold if above/below threshold
  
  Column 5 (YoY Growth):
    Green if positive ↑
    Red if negative ↓
    Format: +X.X% or -X.F%
  
  Column 6 (Rank):
    Numeric ranking (1-5)
    Bold for top performer
  
  Column 7 (Status):
    Icon: ✓ On Track / ⚠ At Risk / ✗ Below Target
    Color-coded
  
  Column 8 (Trend):
    Arrow icon: ↑ Improving / → Stable / ↓ Declining
    Color-coded

Row Colors (by overall status):
  Top performer row: Highlight background light green
  Average performer: White background
  Below target row: Light red background

Sort: By Revenue descending (largest region first)
Totals: Show SUM row at bottom

Subtotals:
  Add subtotal rows by geographic region group (if applicable)
  Show: Total row with all metrics summed

Interactions:
  Click region → Regional performance detail page
  Click value → Drill to city/market level
  Hover → Tooltip with additional context
  Sort: Click column header to sort
```

---

## Row 4: Profit & Financial Health (2 Charts)

### Chart 1: Profitability Trend (Dual-Axis Combo Chart)
```
Metric: Net Profit and Profit Margin Over 8 Quarters
Source: Finance_Income_Statement + Finance_Revenue_Fact
Visualization: Combination Chart (Column + Line)
Dimensions: 600px × 280px (2-column wide)

Primary Y-axis (Left): Net Profit ($M)
  Displayed as: Column chart
  Scale: 0 to max profit (e.g., 0-$50M)
  
Secondary Y-axis (Right): Profit Margin (%)
  Displayed as: Line chart
  Scale: 0-100% (or typical range 0-20%)

X-axis: Quarter (8 quarters = 2 years)
  Labels: Q1 2024, Q2 2024, ... Q4 2025

Columns (Primary metric):
  Color: Green gradient (darker = higher profit)
  Value labels: Show $ amount on bar
  Sorted: Chronologically by quarter
  
Line (Secondary metric):
  Color: Blue
  Data points: Circle markers at each quarter
  Thickness: 2-3px
  Value labels: Show % on line
  
Trend Lines (optional):
  Add trend line through profit values
  Show: Linear regression or moving average

Reference Elements:
  Horizontal line: Average profit margin (dashed)
  Horizontal line: 10% margin target (dashed, different color)
  
Grid:
  Major gridlines: By quarter
  Minor gridlines: Optional for detail

Legend:
  Left legend: Net Profit ($M)
  Right legend: Profit Margin (%)
  Toggle: Click to show/hide each series

Tooltip:
  Quarter: [Q# YYYY]
  Net Profit: $X,XXX,XXX
  Profit Margin: XX.X%
  vs Prior Quarter:
    - Profit: ↑↓ X%
    - Margin: ↑↓ X% points
  Trend: [Improving/Declining]

Interactions:
  Click column → Quarterly detail breakdown
  Hover line point → Detailed margin components
  Drill → Income statement detail
  Legend toggle → Show/hide metric
```

### Chart 2: Expense Breakdown (Pie/Donut Chart)
```
Metric: Operating Expenses by Category (Current Period)
Source: Finance_Expenses_Fact
Visualization: Donut Chart
Dimensions: 300px × 280px (1-column, tall)

Segments (by expense category):
  1. Cost of Goods Sold (COGS)
  2. Sales & Marketing
  3. Research & Development
  4. General & Administrative
  5. Operations
  6. Other

Donut Visual:
  Outer ring: Color-coded by category
  Inner label: Total Expenses = $XXM
  Center: Large number showing percentage increase/decrease vs prior period
  
Segment Colors:
  COGS: Dark Blue (#1976D2)
  S&M: Green (#388E3C)
  R&D: Purple (#7B1FA2)
  G&A: Orange (#F57C00)
  Operations: Gray (#616161)
  Other: Light Gray (#BDBDBD)

Segment Labels:
  Outside segment: Category name
  Segment percentage: XX.F% of total
  Dollar amount: $X,XXX,XXX
  Trend: ↑↓ vs prior period

Legend (Right side):
  Category | Amount | % of Total | Trend

Interactions:
  Click segment → Expense detail for that category
  Drill → Detailed expense transaction list
  Hover → Category detail and YoY comparison

Performance Indicators:
  Top left: Total expenses $ amount
  Below total: MoM change %
  Status badge: On Budget / Over Budget / Under Budget
```

---

## Row 5: Market Position & Strategic Insights (2 Sections)

### Section 1: Market Share & Competitive Position (Pie + Table)
```
Metric: Market Share vs Competitors
Source: Market_Intelligence_DB + Finance_Revenue_Fact
Visualization: Pie Chart + Competitive Ranking Table
Dimensions: 600px × 250px (2-column wide)

Pie Chart (Left half):
  Segments:
    1. Your Company (Color: Primary Brand Color)
    2. Competitor A
    3. Competitor B
    4. Competitor C
    5. Competitor D
    6. Others
  
  Segment size: Market share %
  Labels: Company name + % share
  Center label: "Market Share" + current period
  
  Color coding:
    Your company: Prominent brand color
    Competitors: Gray shades (less prominent)
  
  Visual: Bold border around your company segment

Competitive Ranking Table (Right half):
  Rows (sorted by market share descending):
    Rank | Company | Share % | Growth YoY | Trend
    1    | Your Co | 15.2%   | +2.1%      | ↑
    2    | Comp A  | 14.8%   | +0.5%      | →
    3    | Comp B  | 13.2%   | -1.2%      | ↓
    4    | Comp C  | 11.5%   | +0.8%      | ↑
    5    | Others  | 45.3%   | -1.1%      | ↓
  
  Column formatting:
    Rank: #1-5 (bold)
    Company: Highlight your company row
    Share: Color-coded (green for your co, gray for others)
    Growth: ↑ green, ↓ red, → gray
    Trend: Icon showing direction

Tooltip (on pie segments):
  Company Name
  Market Share: X.X%
  Share Value: $X,XXX,XXM
  QoQ Change: ↑↓ X.X%
  YoY Change: ↑↓ X.X%
  Market Rank: #X

Interactions:
  Click segment → Market analysis detail
  Click competitor row → Competitive analysis
  Drill → Product-line competitive positioning
```

### Section 2: Key Performance Indicators Summary (Mini Tiles Grid)
```
Metric: Executive Dashboard Quick Metrics
Visualization: KPI Mini Tile Grid (2×4 = 8 tiles)
Dimensions: 600px × 250px (2-column wide)

Grid Layout (2 rows × 4 columns):

Row 1:
  Tile 1: Average Order Value
    Value: $XXX
    Trend: ↑ X.X%
    
  Tile 2: Customer Count
    Value: XXX,XXX
    Trend: ↑ X.X%
    
  Tile 3: Revenue per Customer
    Value: $X,XXX
    Trend: ↑ X.F%
    
  Tile 4: Market Growth Rate
    Value: X.X%
    Trend: ↑ X.X% vs market

Row 2:
  Tile 5: Customer Acquisition Cost
    Value: $XXX
    Trend: ↓ X.F% (lower is better)
    
  Tile 6: Customer Lifetime Value
    Value: $X,XXX
    Trend: ↑ X.F%
    
  Tile 7: New Product Revenue %
    Value: XX.X%
    Trend: ↑ X.X%
    
  Tile 8: Geographic Diversification
    Value: XX% (North America)
    Trend: ↓ X.X% (more diversification)

Tile Styling:
  Background: White with light border
  Border: Left border colored by status
  Title: Gray, 10pt
  Value: Bold, 18pt, large
  Trend: Color-coded (Green ↑, Red ↓, Gray →)
  
  Status Color (left border):
    Green: On/Above target
    Amber: Near target
    Red: Below target

Interactions:
  Click tile → Detailed metric page
  Hover → Mini sparkline chart (last 12 periods)
  Drill → Related analytics
```

---

## Regional Analysis Details

### Regional Breakdown Available in All Charts
- All revenue, margin, and growth metrics support drill-down by:
  - Geographic region (North America, Europe, Asia Pacific, etc.)
  - Country
  - State/Province
  - City/Market
  - Sales territory

### Regional Filtering
- **Global Filter**: Region selector (multi-select or dropdown)
- **Context**: All metrics update to show selected region(s)
- **Comparison**: Option to compare multiple regions side-by-side

### Regional Visualizations (on Drill-Through Pages)
1. **Geographic Map**: Regional revenue heat map
2. **Regional Trends**: Revenue/margin/growth by region (line chart)
3. **Regional Rankings**: Scorecard table (similar to Row 3, Chart 2)
4. **Regional Customer Analysis**: Customer metrics by region

---

## Scorecard Features

### Executive Scorecard Elements
1. **KPI Cards** (Row 2): Primary metrics with status indicators
2. **Performance Scorecard** (Row 3, Chart 2): Regional/department/product scorecards
3. **Status Badges**: Visual indicators (✓ On Track, ⚠ At Risk, ✗ Below Target)
4. **Trend Indicators**: Arrows and sparklines showing direction
5. **Progress Bars**: Visual progress toward targets

### Scorecard Design Standards
- **Status Colors**: Green (on/above target), Amber (near target), Red (below target)
- **Icons**: ✓ = Success, ⚠ = Warning, ✗ = Fail
- **Trend Arrows**: ↑ = Improving, → = Stable, ↓ = Declining
- **Bold Highlighting**: Top performers and outliers
- **Data Bars**: For visual comparison within tables

---

## Filtering Strategy

### Global Filters (Top Row)
1. **Period Selector**: Dropdown
   - Options: YTD, MTD, Last Quarter, Last 12 Months, Custom Range
   - Default: YTD

2. **Date Range**: Dual date picker
   - Default: Jan 1 - Today
   - Quick options: This Month, Last Month, This Quarter, etc.

3. **Region Filter**: Multi-select
   - Default: All Regions
   - Options: Based on Dim_Geography

### Contextual Slicers (Page Level)
- **Product Line**: Filter to specific product categories (optional)
- **Customer Segment**: B2B, B2C, Enterprise, SMB, etc. (optional)
- **Channel**: Direct, Partner, Online, Retail, etc. (optional)

### Filter Interactions
- All slicers cross-filter all visualizations
- Filters persist across drill-through pages
- Breadcrumb navigation shows applied filters

---

## Color Palette & Design

### Primary Colors
- **Success/On Target**: Green (#4CAF50)
- **Warning**: Amber (#FF9800)
- **Critical**: Red (#F44336)
- **Info**: Blue (#2196F3)
- **Neutral**: Gray (#9E9E9E)

### UI Elements
- **Header**: Dark Navy (#1E1E1E) with white text
- **Background**: Light Gray (#F5F5F5)
- **Cards**: White (#FFFFFF) with border
- **Text**: Dark Gray (#424242)

### Revenue Visualization
- **Revenue Bars/Lines**: Primary Blue (#2196F3)
- **Target Line**: Dashed Gray (#9E9E9E)
- **Achievement**: Green when above target
- **Shortfall**: Red when below target

### Chart Types by Metric
- **Revenue**: Column, Line, Area, Bar
- **Margin**: Line with zones, Gauge
- **Growth**: Line with trend, Column
- **Market Share**: Pie, Donut
- **Comparisons**: Table with data bars, Matrix

---

## Drill-Through Navigation

1. **Revenue KPI** → Revenue Detail by Product/Channel/Customer
2. **Profit Margin KPI** → Margin Analysis & Cost Breakdown
3. **Cash Flow KPI** → Cash Flow Waterfall Detail
4. **NPS KPI** → Customer Satisfaction Detail & Feedback
5. **Regional Performance** → Regional Detail Page
6. **Monthly Revenue** → Daily Revenue Breakdown
7. **Expense Breakdown** → Detailed Expense List
8. **Market Share** → Competitive Analysis Detail

---

## Mobile Responsiveness

### Tablet Layout (iPad / 1024px)
- 3-column grid (instead of 4)
- KPI cards: 3-2-1 layout
- Charts: Stacked vertically or side-by-side as space allows
- Slicers: Horizontal scroll or accordion
- Height: Auto-adjust for visibility

### Mobile Layout (Phone / 576px)
- Single column layout
- All visualizations stacked vertically
- Slicers in collapsible menu
- KPI cards: Full width, smaller font
- Charts: Simplified (fewer data points)
- Drill-through required for details

---

## Data Refresh & Performance

- **Refresh Schedule**: Every 15 minutes
- **Peak Hours**: Every 5 minutes (8 AM - 6 PM)
- **Data Retention**: 
  - Daily data: 2 years
  - Monthly aggregates: Unlimited
  - Transaction detail: 1 year
- **Caching**: 5-minute incremental refresh

---

## Export & Reporting

### Export Options
- **Format**: PDF, Excel, PowerPoint
- **Content**: Dashboard snapshot or selected visualizations
- **Schedule**: On-demand or scheduled delivery
- **Recipients**: Configured distribution lists

### Report Generation
- **Executive Brief**: 1-page PDF with key metrics
- **Detailed Report**: Full dashboard with drill-down details
- **Regional Report**: Region-specific performance summary
- **Variance Analysis**: Performance vs targets

---

## Accessibility & Mobile

### Accessibility Features
- High contrast mode support
- Color-blind friendly palette
- Keyboard navigation
- Screen reader compatible
- Large text support

### Performance Targets
- Initial load: < 10 seconds
- Slicer interaction: < 2 seconds
- Drill-through: < 3 seconds
- Mobile load: < 8 seconds

