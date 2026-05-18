# Power BI Page Structure

## Overview
This document defines the hierarchical page structure and layout standards for all Power BI dashboards in the Enterprise KPI Platform.

## Page Hierarchy

### 1. Executive Dashboard (Primary Page)
**Purpose**: High-level strategic overview for C-suite executives
**Layout Grid**: 4 columns × 4 rows (16 sections)

#### Section Allocation:
- **Row 1 (Header Section)**: Title, filters, refresh controls
- **Row 2 (Critical KPIs)**: 4 large KPI cards (Revenue, Profit, Satisfaction, Market Share)
- **Row 3 (Trend Analysis)**: 2 wide charts (Revenue Growth, Profitability Trend)
- **Row 4 (Strategic Insights)**: Business Health metrics + Alerts panel

---

### 2. Finance Dashboard
**Purpose**: Detailed financial metrics and cash flow analysis
**Layout Grid**: 4 columns × 5 rows (20 sections)

#### Section Allocation:
- **Row 1**: Title, date filters, period selector
- **Row 2**: Financial KPIs (Revenue, EBITDA, Cash Flow, Margin %)
- **Row 3**: Revenue composition (stacked bar), Expense breakdown (pie)
- **Row 4**: Cash flow waterfall, P&L trends (dual row)
- **Row 5**: Financial forecasts, variance analysis

---

### 3. Customer Dashboard
**Purpose**: Customer metrics, retention, and segmentation
**Layout Grid**: 4 columns × 5 rows

#### Section Allocation:
- **Row 1**: Title, customer filter, date range
- **Row 2**: Customer KPIs (Total Customers, Retention Rate, Churn Rate, NPS)
- **Row 3**: Customer acquisition trends, retention cohort analysis
- **Row 4**: Customer segments (geographic, demographic), RFM analysis
- **Row 5**: Customer lifetime value, satisfaction trends

---

### 4. Operations Dashboard
**Purpose**: Operational efficiency and process metrics
**Layout Grid**: 4 columns × 5 rows

#### Section Allocation:
- **Row 1**: Title, department filter, time period selector
- **Row 2**: Operations KPIs (Efficiency Index, Processing Time, Error Rate, Capacity Utilization)
- **Row 3**: Department performance matrix, process efficiency trends
- **Row 4**: Regional operations map, SLA compliance charts
- **Row 5**: Quality metrics, cost per transaction, productivity indices

---

### 5. Governance Dashboard
**Purpose**: Compliance, risk management, and business rules monitoring
**Layout Grid**: 4 columns × 4 rows

#### Section Allocation:
- **Row 1**: Title, governance category filter, date range
- **Row 2**: Governance KPIs (Compliance Score, Risk Level, Audit Status, Policy Adherence)
- **Row 3**: Risk heatmap, compliance violations, audit trail
- **Row 4**: Policy exceptions, remediation status, governance alerts

---

## Standard Page Components

### Navigation Header
```
[Logo] | Dashboard Title | [Slicer: Date Range] [Slicer: Category] [Refresh Icon]
```
- **Height**: 60px
- **Background**: Dark Navy (#1E1E1E)
- **Text Color**: White
- **Font**: Segoe UI, 14px

### Page Margins & Spacing
- **Top Margin**: 10px
- **Bottom Margin**: 10px
- **Left Margin**: 15px
- **Right Margin**: 15px
- **Gap between elements**: 10px

### Grid System
- **Total Width**: Full page (minus margins)
- **Column Width**: 25% each (4-column grid)
- **Row Height**: 150-200px (adjustable based on visualization type)
- **Card Spacing**: 10px

### Standard Dimensions by Visualization Type

#### Large KPI Card
- **Width**: 1 column (25%)
- **Height**: 150px
- **Best for**: Primary metrics requiring immediate attention

#### Wide Chart (2-column)
- **Width**: 2 columns (50%)
- **Height**: 250px
- **Best for**: Trend analysis, comparisons

#### Full-Width Chart
- **Width**: 4 columns (100%)
- **Height**: 300px
- **Best for**: Comprehensive views, detailed analysis

#### Matrix/Table
- **Width**: 2-4 columns
- **Height**: 300-400px (scrollable)
- **Best for**: Detailed breakdowns, drill-through data

---

## Page Interaction Patterns

### Filtering Strategy
1. **Global Filters** (Top of page):
   - Date Range (mandatory on all pages)
   - Primary Category (varies by dashboard)
   
2. **Contextual Filters** (Via slicers):
   - Department/Division
   - Region/Location
   - Customer Segment
   - Business Unit

### Drill-Through Navigation
- Click any KPI card → Opens detailed breakdown page
- Click any data point in charts → Shows supporting details
- Breadcrumb navigation: Dashboard → Detail → Transaction level

### Bookmarks
- **Executive Summary**: Filtered to key metrics only
- **Detailed Analysis**: Full granularity with all slicers
- **Print View**: Optimized for PDF export
- **Mobile View**: Responsive single-column layout

---

## Page Templates

### Template: KPI Summary Page
Used for: All dashboard landing pages
```
[Row 1: Header with filters]
[Row 2: 4 KPI Cards - Landscape orientation]
[Row 3: 2 Wide Charts - Comparative analysis]
[Row 4: Key insights, alerts, recommendations]
```

### Template: Detailed Analysis Page
Used for: Drill-through pages with granular data
```
[Row 1: Header + Breadcrumbs + Filters]
[Row 2: 2 large comparison charts]
[Row 3: Detailed table/matrix with 100+ rows]
[Row 4: Related visualizations or scatter plots]
```

### Template: Trend Analysis Page
Used for: Historical analysis and forecasting
```
[Row 1: Header with time range selector]
[Row 2: Large line/area chart (full width)]
[Row 3: Forecast chart + Statistical summary]
[Row 4: Change drivers breakdown + Variance analysis]
```

---

## Mobile Responsiveness

### Tablet Layout (iPad / 1024px width)
- 3-column grid instead of 4
- KPI cards displayed in 3-2-1 pattern instead of 4
- Chart heights reduced to 200px

### Mobile Layout (Phone / 576px width)
- Single column layout
- All charts stacked vertically
- KPI cards displayed individually
- Filters in collapsible menu

---

## Performance Optimization

### Recommended Page Load Strategy
1. **Critical path** (load first):
   - Header and navigation
   - Primary KPI cards
   
2. **Secondary content** (load after):
   - Trend charts
   - Supporting visualizations
   
3. **Tertiary content** (load on demand):
   - Detail tables
   - Advanced analytics

### Page Refresh Schedule
- **Executive Dashboard**: 5-minute intervals
- **Finance Dashboard**: 15-minute intervals
- **Customer/Operations**: 30-minute intervals
- **Governance**: 1-hour intervals

---

## Accessibility Standards

### Color Contrast
- All text meets WCAG AA standards (4.5:1 ratio minimum)
- Do not rely on color alone for information (use patterns/labels)

### Navigation
- Tab order follows logical flow (left to right, top to bottom)
- All interactive elements keyboard-accessible
- Tooltips provided for abbreviated labels

### Data Labels
- All visualizations include axis labels and legends
- Numbers formatted with consistent precision (2 decimals for percentages)
- Units clearly displayed (currency, %, count, etc.)
