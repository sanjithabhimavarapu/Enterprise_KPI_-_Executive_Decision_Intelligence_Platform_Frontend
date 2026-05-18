# Visualization Mapping

## Overview
This document defines the mapping between KPIs, data sources, and specific visualization types used in the Enterprise KPI Platform. It serves as a reference for data analysts and developers to ensure consistent representation of metrics across all Power BI dashboards.

---

## Visualization Selection Matrix

### By Metric Type

| Metric Type | Visualization | Primary Use | Secondary Use | Drill-Through |
|---|---|---|---|---|
| Single Value | Card/Gauge | Current status | Mini tile | Detail table |
| Time Series | Line Chart | Trend analysis | Area chart | Daily breakdown |
| Comparison | Bar Chart | Period-to-period | Clustered bars | Segment detail |
| Composition | Pie/Donut | % breakdown | Stacked bar | Category detail |
| Distribution | Histogram | Frequency | Scatter | Outlier analysis |
| Geographic | Map | Regional view | Bubble map | Location detail |
| Correlation | Scatter Plot | Relationship | Bubble chart | Data points |
| Performance | Gauge Chart | vs. Target | KPI card | Variance detail |
| Hierarchy | Treemap | Category breakdown | Sunburst | Leaf level |
| Waterfall | Waterfall | Build-up/break-down | Stacked bar | Component detail |

---

## Dashboard Visualizations

## EXECUTIVE DASHBOARD

### Row 2: Primary KPI Cards

#### 1. Total Revenue
```
Metric: Sum of Revenue
Source: Finance_Revenue_Fact
Visualization Type: KPI Card (Standard)
Dimensions: 250px × 150px

Display Format:
  Primary Value: $XXX,XXX,XXX (currency, 0 decimals)
  Indicator: YoY % change (green/red arrow)
  Comparison: "Target: $XXM | Achievement: XXX%"
  
Color Coding:
  ≥ Target: Green (#4CAF50)
  95-99% of Target: Amber (#FF9800)
  < 95% of Target: Red (#F44336)

Interactions:
  Click → Revenue Breakdown by Product Line
  Drill-Through → Regional Revenue Detail
  Export → Excel with monthly history
```

---

#### 2. Net Profit Margin %
```
Metric: (Net Profit / Total Revenue) × 100
Source: Finance_Income_Statement + Finance_Revenue_Fact
Visualization Type: KPI Card (Standard)
Dimensions: 250px × 150px

Display Format:
  Primary Value: XX.X% (2 decimals)
  Indicator: QoQ % point change
  Comparison: "Avg: XX% | Benchmark: XX%"
  
Color Coding:
  ≥ Target %: Green
  Target ± 2%: Amber
  < Target - 2%: Red

Interactions:
  Click → Profitability Driver Analysis
  Drill → Expense Breakdown Waterfall
```

---

#### 3. Customer Satisfaction (NPS)
```
Metric: ((Promoters - Detractors) / Total Respondents) × 100
Source: Customer_Survey_Response
Visualization Type: KPI Card (Standard) + Gauge Chart
Dimensions: 250px × 150px (Card) | 300px × 250px (Detail)

Display Format:
  Primary Value: XX (0-100 scale)
  Indicator: vs. 12-month average
  Comparison: "Good: > 50 | Excellent: > 70"
  
Gauge Chart Detail:
  Segments: Promoters (Green) | Passives (Gray) | Detractors (Red)
  Scale: 0-100 with zone indicators
  
Interactions:
  Click → NPS Detail by Customer Segment
  Drill → Individual Response Analysis
```

---

#### 4. Market Share %
```
Metric: (Our Revenue / Total Market Revenue) × 100
Source: Finance_Revenue_Fact + Market_Intelligence_DB
Visualization Type: KPI Card + Comparative Pie Chart
Dimensions: 250px × 150px (Card) | 350px × 250px (Detail)

Display Format:
  Primary Value: X.X% (1 decimal)
  Indicator: vs. Same Quarter Prior Year
  Comparison: "Rank: #X of 10 | Gap to Leader: XX%"
  
Pie Chart Detail:
  Segments: Own Company | Competitor A | Competitor B | Others
  Sort: Descending by %
  
Interactions:
  Click → Competitive Positioning Analysis
  Drill → By Geographic Region
```

---

### Row 3: Trend Analysis Charts

#### 5. Revenue Growth Chart (12-month Line Chart)
```
Metric: Monthly Revenue (YoY comparison)
Source: Finance_Revenue_Fact (Monthly Aggregation)
Visualization Type: Line Chart (Dual-axis or Overlaid Lines)
Dimensions: 600px × 250px (2-column wide)

Configuration:
  X-axis: Month (Jan - Dec)
  Y-axis: Revenue ($M)
  Line 1: Current Year (Color: Primary Blue #2196F3)
  Line 2: Prior Year (Color: Gray #9E9E9E, Dashed)
  Data Labels: Monthly values on hover
  Grid: Minor gridlines for readability
  
Formatting:
  Value Format: $X.XM (millions)
  Tooltip: Month, Current Year $, Prior Year $, % Change
  
Interactions:
  Hover → Month detail with breakdown
  Click point → Daily view for that month
  Legend → Toggle year visibility
```

---

#### 6. Profitability Trend (Quarterly Bar Chart)
```
Metric: Net Profit Margin by Quarter (Last 8 quarters)
Source: Finance_Income_Statement (Quarterly)
Visualization Type: Clustered Column Chart
Dimensions: 600px × 250px (2-column wide)

Configuration:
  X-axis: Quarter (Q1-Q4 for last 2 years)
  Y-axis: Net Profit Margin (%)
  Bar Color: Gradient (Red to Green based on % value)
  Target Line: Reference line at target margin %
  
Formatting:
  Value Format: XX.X% (on bar)
  Color Scale: <5% Red | 5-7% Amber | >7% Green
  
Interactions:
  Hover → Exact % and absolute profit $
  Click → Monthly breakdown for quarter
  Target Line Label → Edit target %
```

---

### Row 4: Business Health Insights

#### 7. Department Performance Matrix
```
Metric: Department KPIs (Revenue, Margin, Growth, Headcount)
Source: Finance_Dept_KPI_Summary + HR_Dept_Data
Visualization Type: Matrix/Table with Conditional Formatting
Dimensions: 600px × 200px (2-column wide)

Columns:
  Department Name
  Revenue ($M)
  Margin %
  Growth YoY %
  Headcount
  Status (Icon)

Configuration:
  Sort: Revenue descending
  Conditional Formatting:
    - Revenue: Data bars (gradient)
    - Margin %: Red-Yellow-Green scale
    - Growth %: Up/Down arrows with colors
  
Interactions:
  Click row → Department detail dashboard
  Click cell → Drill to transaction level
```

---

#### 8. Regional Sales Distribution Map
```
Metric: Revenue by Geographic Region
Source: Finance_Revenue_Fact + Geographic_Hierarchy
Visualization Type: Filled Map (Choropleth)
Dimensions: 600px × 300px (2-column wide)

Configuration:
  Location Field: Region/Country
  Value Field: Total Revenue ($)
  Color Saturation: Revenue amount (darker = higher)
  
Color Scale:
  Minimum: Light Blue (#E3F2FD) = Lowest revenue
  Maximum: Dark Blue (#0D47A1) = Highest revenue
  
Data Labels:
  On hover: Region name, Revenue $, % of total
  
Interactions:
  Click region → Sales detail for that region
  Drill → City/Branch level sales
  Bubble size → Optional: Customer count per region
```

---

#### 9. Customer Retention Rate (Line Chart)
```
Metric: Monthly Retention Rate (%) for Last 12 Months
Source: Customer_Retention_Cohort_Analysis
Visualization Type: Line Chart with Area Fill
Dimensions: 300px × 200px (1-column)

Configuration:
  X-axis: Month
  Y-axis: Retention Rate (%)
  Line Color: Green (#4CAF50)
  Area Fill: Light Green with 30% opacity
  
Reference Lines:
  - Target Retention % (dashed line)
  - Industry Average (dotted line)
  
Formatting:
  Value Format: X.X% (1 decimal)
  Y-axis Range: 70-100%
  
Interactions:
  Hover → Exact rate and # of retained customers
  Click → Cohort-level retention analysis
```

---

#### 10. Operational Efficiency Index (Gauge Chart)
```
Metric: EBITDA / Revenue Ratio (%)
Source: Finance_Income_Statement + Operations_Cost_Data
Visualization Type: Gauge Chart
Dimensions: 300px × 250px (1-column)

Configuration:
  Min Value: 0%
  Max Value: 50%
  Target: 30% (needle position)
  
Zones:
  Red Zone: 0-15% (Critical)
  Yellow Zone: 15-25% (Below Target)
  Green Zone: 25-35% (On Target)
  Bonus Zone: 35%+ (Exceeding Target)
  
Current Needle: Points to actual efficiency
  
Interactions:
  Click → Detailed efficiency breakdown
  Hover → Tooltip with calculation method
```

---

## FINANCE DASHBOARD

### Financial KPI Cards (Row 2)

#### 11. Revenue
```
Type: Comparative KPI Card
Format: $XXX,XXX,XXX | Δ YoY: +X.X%
Interactions: Drill to revenue by product/customer
```

---

#### 12. EBITDA
```
Type: Comparative KPI Card
Format: $XXX,XXX,XXX | Δ QoQ: +X.X%
Status: Compare to Target EBITDA
Interactions: Drill to cost drivers
```

---

#### 13. Operating Cash Flow
```
Type: Comparative KPI Card
Format: $XXX,XXX,XXX | Δ vs. Prior Month: +X.X%
Status: Liquidity indicator
Interactions: Drill to cash flow waterfall
```

---

#### 14. Gross Margin %
```
Type: Comparative KPI Card
Format: XX.X% | Δ: +X.X% points
Benchmark: vs. Industry Average
Interactions: Drill to cost of goods breakdown
```

---

### Financial Charts (Row 3-4)

#### 15. Revenue Composition (Stacked Column Chart)
```
Metric: Revenue by Product Line (Monthly for Last 12 Months)
Source: Finance_Revenue_Fact + Product_Hierarchy
Visualization Type: 100% Stacked Column Chart
Dimensions: 600px × 300px (2-column wide)

Configuration:
  X-axis: Month (12 months)
  Y-axis: Revenue %
  Stacks: Product Line 1 (Blue), Product Line 2 (Green), Product Line 3 (Orange)
  Sort: Product lines by total revenue (descending)
  
Color Scheme:
  Product A: #2196F3 (Blue)
  Product B: #4CAF50 (Green)
  Product C: #FF9800 (Orange)
  
Formatting:
  Data Labels: % of total on each segment
  Total Revenue value on top of bar
  
Interactions:
  Click segment → Product detail page
  Hover → Absolute $ amounts
  Legend → Toggle product visibility
```

---

#### 16. Expense Breakdown (Pie Chart)
```
Metric: Operating Expenses by Category (Current Period)
Source: Finance_Expense_Fact
Visualization Type: Donut Chart
Dimensions: 300px × 300px (1-column)

Categories:
  Personnel Costs (40% - Blue)
  Technology (20% - Green)
  Marketing (15% - Orange)
  Facilities (15% - Red)
  Other (10% - Gray)
  
Formatting:
  Data Labels: Category name + % + $amount
  Outer ring: Donut style
  Center: Total expenses in $
  
Interactions:
  Click slice → Detailed expense category analysis
  Hover → Exact $ and % of total
```

---

#### 17. Cash Flow Waterfall Chart
```
Metric: Operating Cash Flow Components
Source: Finance_Cash_Flow_Statement
Visualization Type: Waterfall Chart
Dimensions: 600px × 300px (2-column wide)

Components:
  Starting Cash: Previous period ending balance
  Operating Cash: +/- by category
  Investing Cash: +/- by category
  Financing Cash: +/- by category
  Ending Cash: Final balance

Formatting:
  Inflows: Green bars
  Outflows: Red bars
  Total: Blue connector
  Connector lines between bars
  
Data Labels: $ amounts on each bar
  
Interactions:
  Click component → Detailed breakdown
  Hover → Component details + timing
```

---

#### 18. Financial Forecast (Line Chart with Projection)
```
Metric: Revenue Forecast vs. Actual (18-month view)
Source: Finance_Revenue_Fact + Forecast_Model_Results
Visualization Type: Line Chart with Confidence Band
Dimensions: 600px × 250px (2-column wide)

Configuration:
  X-axis: Month (past 12 + future 6 months)
  Y-axis: Revenue ($M)
  Actual Line: Solid Blue (#2196F3) - Historical data
  Forecast Line: Dashed Green (#4CAF50) - Future projections
  Confidence Band: Light green shading (±1 std dev)
  
Reference Point: Vertical line separating actual/forecast
  
Formatting:
  Value Format: $X.XM
  Tooltip: Month, Actual or Forecast, Confidence range
  
Interactions:
  Hover forecast → Probability/confidence level
  Click forecast point → Forecast assumptions
  Adjust slider → Recalculate forecast with adjusted assumptions
```

---

#### 19. Period-over-Period Comparison (Clustered Bar Chart)
```
Metric: Key Financial Metrics (Current vs. Prior Period)
Source: Finance_Income_Statement (Period comparison)
Visualization Type: Clustered Bar Chart
Dimensions: 600px × 250px (2-column wide)

Metrics Compared:
  Revenue
  Gross Profit
  Operating Expenses
  Net Income
  
Bar Pairs:
  Current Period: Dark Blue (#1976D2)
  Prior Period: Light Gray (#BDBDBD)
  
Formatting:
  Value labels on bars ($M format)
  % change annotation above bars
  
Color Coding for % change:
  Positive: Green
  Negative: Red
  
Interactions:
  Click metric → Detailed analysis page
  Hover → Exact values and % change
  Toggle → Switch comparison period (YoY, QoQ, MoM)
```

---

## CUSTOMER DASHBOARD

### Customer KPI Cards (Row 2)

#### 20. Total Active Customers
```
Type: Standard KPI Card
Format: XXX,XXX | Δ MoM: +X.X%
Status: Growth indicator
Interactions: Drill to customer list by segment
```

---

#### 21. Customer Retention Rate %
```
Type: Comparative KPI Card
Format: XX.X% | 12-mo Avg: XX.X%
Status: vs. Target retention
Interactions: Drill to retention cohort analysis
```

---

#### 22. Customer Churn Rate %
```
Type: Comparative KPI Card
Format: X.X% | Trend: ↓ (Improving)
Status: Inverse indicator (lower = better)
Interactions: Drill to churned customer analysis
```

---

#### 23. Net Promoter Score (NPS)
```
Type: Comparative KPI Card
Format: XX | Promoters: XX% | Detractors: XX%
Status: vs. 12-month average
Interactions: Drill to NPS by customer segment
```

---

### Customer Charts (Row 3-4)

#### 24. Customer Acquisition Trend (Line Chart)
```
Metric: New Customers Acquired (Monthly, Last 12 Months)
Source: Customer_Master + Customer_Acquisition_Date
Visualization Type: Line Chart with Area Fill
Dimensions: 600px × 250px (2-column wide)

Configuration:
  X-axis: Month
  Y-axis: Number of new customers
  Line Color: Green (#4CAF50)
  Area Fill: Light green with 40% opacity
  Trend Line: Linear regression overlay
  
Reference Line: Monthly target for new customer acquisition
  
Formatting:
  Data Labels: Customer count on hover
  Y-axis: Show in thousands (e.g., 2.5K)
  
Interactions:
  Click month → New customer list for that month
  Hover → Exact count + % vs. target
  Legend → Toggle trend line visibility
```

---

#### 25. Customer Retention Cohort Analysis (Heatmap)
```
Metric: Retention by Acquisition Cohort
Source: Customer_Cohort_Retention_Matrix
Visualization Type: Heatmap / Heat Table
Dimensions: 600px × 350px (2-column wide)

Configuration:
  Rows: Acquisition Cohort (by month/quarter)
  Columns: Months Since Acquisition (0, 3, 6, 9, 12, 18, 24)
  Cell Values: Retention % (0-100%)
  
Color Scale:
  0% Retention: Red (#F44336)
  50% Retention: Yellow (#FFD54F)
  100% Retention: Green (#4CAF50)
  
Data Labels: Retention % in each cell
  
Interactions:
  Click cell → Customer list for that cohort/period
  Hover → Exact retention rate + customer count
  Tooltip → Cohort characteristics (size, acquisition source)
```

---

#### 26. Customer Segmentation (Pie or Treemap)
```
Metric: Customers by Segment (Premium, Standard, Basic)
Source: Customer_Master + Customer_Segment
Visualization Type: Pie Chart or Treemap
Dimensions: 300px × 300px (1-column) or 600px × 250px (Treemap)

Segments & Colors:
  Premium: #2196F3 (Blue) - 30%
  Standard: #4CAF50 (Green) - 50%
  Basic: #FF9800 (Orange) - 20%
  
Pie Chart Labels:
  Segment Name + % + Customer Count
  
Treemap Layout:
  Box size: Customer count
  Box color: Revenue per segment
  
Interactions:
  Click segment → Customer list for segment
  Hover → Segment details (size, revenue, churn rate)
  Drill → Individual customer analysis
```

---

#### 27. Customer Lifetime Value (CLV) Distribution (Histogram)
```
Metric: Customer Count by CLV Range
Source: Customer_Lifetime_Value_Model
Visualization Type: Histogram / Column Chart
Dimensions: 600px × 250px (2-column wide)

Configuration:
  X-axis: CLV Range ($0-10K, $10-25K, $25-50K, $50K+)
  Y-axis: Number of customers
  Column Color: Blue (#2196F3)
  
Reference Line: Average CLV (red dashed line)
Reference Line: Median CLV (blue dashed line)
  
Data Labels: Customer count on bars
  
Formatting:
  Value Format: Currency for CLV ranges
  Y-axis: Count format
  
Interactions:
  Click bar → Customer list for that CLV range
  Hover → Exact count + % of total customers
  Compare segments → Toggle view by customer segment
```

---

#### 28. RFM Analysis Matrix (Scatter Plot or Bubble Chart)
```
Metric: Customer Recency vs. Frequency vs. Monetary
Source: Customer_RFM_Analysis
Visualization Type: Bubble Chart
Dimensions: 600px × 350px (2-column wide)

Configuration:
  X-axis: Recency (days since last purchase)
  Y-axis: Frequency (total purchases)
  Bubble Size: Monetary (total $ spent)
  Bubble Color: Segment (Premium=Blue, Standard=Green, Basic=Orange)
  
Quadrant Reference Lines:
  High-value customers (top-right)
  At-risk customers (left side)
  
Data Labels: Hover shows customer segment + RFM values
  
Interactions:
  Click bubble → Individual customer detail
  Hover → Segment + RFM values
  Select quadrant → Filter to customer group
  
Legend: Segment colors
```

---

## OPERATIONS DASHBOARD

### Operations KPI Cards (Row 2)

#### 29. Operational Efficiency Index
```
Type: Standard KPI Card
Format: XX.X | Target: XX.X | Gap: -X.X
Status: vs. Industry benchmark
Interactions: Drill to efficiency drivers
```

---

#### 30. Average Processing Time
```
Type: Standard KPI Card
Format: X.X hours | Δ vs. Target: +X.X hrs
Status: Trend indicator
Interactions: Drill to process breakdown
```

---

#### 31. Error Rate %
```
Type: Standard KPI Card
Format: X.X% | Trend: ↓ (Improving)
Status: Lower is better
Interactions: Drill to error categorization
```

---

#### 32. Capacity Utilization %
```
Type: Standard KPI Card
Format: XX.X% | Available Capacity: XX.X%
Status: Resource adequacy indicator
Interactions: Drill to resource allocation
```

---

### Operations Charts (Row 3-4)

#### 33. Department Performance Matrix (Table with Sparklines)
```
Metric: Multi-metric performance by department
Source: Operations_Dept_Performance + Finance_Dept_Costs
Visualization Type: Matrix/Table with Sparklines
Dimensions: 800px × 250px (Full width)

Columns:
  Department
  Processing Volume (with sparkline trend)
  Avg Processing Time (minutes)
  Error Rate %
  Efficiency Score
  Status (indicator)

Row Sort: Efficiency score descending

Conditional Formatting:
  Processing Volume: Data bars (green = high volume)
  Avg Time: Color scale (green = fast, red = slow)
  Error Rate: Color scale (green = low, red = high)
  Efficiency: Traffic light (green/yellow/red)

Sparklines: Mini trend charts for last 12 months

Interactions:
  Click row → Department detail dashboard
  Click sparkline → Monthly trend for that metric
  Sort by column → Reorder departments
```

---

#### 34. Process Efficiency Trends (Multi-line Chart)
```
Metric: Efficiency Metrics Over Time (Last 12 Months)
Source: Operations_Daily_Performance (Monthly aggregation)
Visualization Type: Multi-line Chart
Dimensions: 600px × 300px (2-column wide)

Metrics Tracked:
  Line 1: Efficiency Index (Blue, thick)
  Line 2: Processing Speed (Green)
  Line 3: Quality Score (Orange)
  
Target Line: Target efficiency (red dashed)

Configuration:
  X-axis: Month
  Y-axis: Index Score (0-100)
  
Formatting:
  Data Labels: Values on hover
  Grid: Minor gridlines for precision
  
Interactions:
  Hover → Month detail with all three metrics
  Click metric → Detailed breakdown
  Legend → Toggle metric visibility
```

---

#### 35. Regional Operations Map (Filled Map with Bubbles)
```
Metric: Processing Volume and Performance by Region
Source: Operations_Regional_Data + Geographic_Hierarchy
Visualization Type: Filled Map with Bubble Overlay
Dimensions: 600px × 400px (2-column wide)

Configuration:
  Map: Country/Region shading by efficiency %
  Bubbles: Overlay showing processing volume
    - Bubble size: Volume
    - Bubble color: Performance (Red=Poor, Yellow=Fair, Green=Good)
  
Color Scales:
  Map shading: Light (low efficiency) to Dark (high efficiency)
  Bubble colors: Red → Yellow → Green
  
Data Labels: On hover - Region name, volume, efficiency %

Interactions:
  Click region → Regional detail operations dashboard
  Click bubble → Specific location performance
  Drill → City/branch level data
```

---

#### 36. SLA Compliance Trends (Stacked Bar Chart)
```
Metric: SLA Compliance by Service Level (Last 12 Months)
Source: Operations_SLA_Compliance
Visualization Type: 100% Stacked Column Chart
Dimensions: 600px × 250px (2-column wide)

Configuration:
  X-axis: Month
  Y-axis: Compliance %
  Stacks:
    - Compliant (Green #4CAF50)
    - At Risk (Yellow #FF9800)
    - Non-compliant (Red #F44336)
  
Reference Line: Target compliance % (typically 95%)

Data Labels: % for each stack segment

Formatting:
  Value labels in/on bars
  
Interactions:
  Click compliant section → Compliant transaction list
  Click at-risk section → At-risk transaction list
  Click non-compliant section → Failed SLA analysis
  Hover → Exact count and % of transactions
```

---

#### 37. Quality Metrics (Multi-metric Gauge or KPI Cards)
```
Metric: Quality-related KPIs
Source: Operations_Quality_Metrics
Visualization Type: Multiple Gauge Charts or KPI Cards
Dimensions: 4 cards × (200px × 180px) per row

Metrics:
  1. Defect Rate % (Gauge: target 2%, current XXX%)
  2. First-time Pass Rate (Gauge: target 98%, current XX%)
  3. Customer Satisfaction (Gauge: target 8.5/10, current X.X)
  4. Rework Rate % (Gauge: target 5%, current XX%)

Configuration:
  Each gauge:
    - Red zone: Below minimum acceptable
    - Yellow zone: Below target
    - Green zone: At/above target
    - Needle: Current value

Interactions:
  Click gauge → Detailed quality analysis
  Hover → Current vs. historical average
```

---

#### 38. Cost Per Transaction (Trend Chart)
```
Metric: Average Cost per Transaction (Monthly)
Source: Operations_Cost_Data + Operations_Volume
Visualization Type: Line or Area Chart
Dimensions: 600px × 250px (2-column wide)

Configuration:
  X-axis: Month (Last 12 months)
  Y-axis: Cost per transaction ($)
  Line: Actual cost (Blue)
  Area fill: Light blue (30% opacity)
  Reference line: Target cost (red dashed)
  Reference line: Industry average (gray dashed)

Formatting:
  Value format: $X.XX per transaction
  
Interactions:
  Hover → Exact cost + volume processed
  Click point → Cost breakdown (labor, materials, overhead)
  Compare → Toggle industry average visibility
```

---

## GOVERNANCE DASHBOARD

### Governance KPI Cards (Row 2)

#### 39. Compliance Score %
```
Type: Standard KPI Card
Format: XX.X% | Status: On Track
Status: Weighted compliance metrics
Interactions: Drill to compliance by regulation
```

---

#### 40. Risk Level
```
Type: Status Card (Multi-Status)
Format: Risk: [High/Medium/Low] | Trend: [↑/→/↓]
Status: Enterprise risk rating
Interactions: Drill to risk register
```

---

#### 41. Audit Status
```
Type: Standard KPI Card
Format: X items | Overdue: X | In Progress: X
Status: Audit tracking
Interactions: Drill to audit details
```

---

#### 42. Policy Adherence %
```
Type: Comparative KPI Card
Format: XX.X% | Exceptions: X | Waivers: X
Status: Policy compliance
Interactions: Drill to policy exceptions
```

---

### Governance Charts (Row 3-4)

#### 43. Risk Heatmap (Matrix)
```
Metric: Risk by Impact × Likelihood
Source: Risk_Register + Risk_Assessment_Data
Visualization Type: Heatmap / Heat Table
Dimensions: 400px × 400px (1-column)

Configuration:
  Rows: Risk categories (Operational, Financial, Compliance, Strategic)
  Columns: Likelihood (Low → High)
  Cell values: Impact rating
  Cell colors: Severity (Green → Yellow → Red)
  
Data Labels: Risk count in each cell

Interactions:
  Click cell → Risk details for that category/likelihood
  Hover → Risk examples + mitigation status
```

---

#### 44. Compliance Violations Timeline (Bar Chart)
```
Metric: Compliance violations by type (Last 12 Months)
Source: Compliance_Violations_Log
Visualization Type: Column Chart
Dimensions: 600px × 250px (2-column wide)

Configuration:
  X-axis: Month
  Y-axis: Violation count
  Bars: Stacked by violation type
    - Regulatory (Red #F44336)
    - Policy (Orange #FF9800)
    - Process (Yellow #FFD54F)
    - Other (Gray #9E9E9E)
  
Reference Line: Zero violations target

Data Labels: Count on bars

Interactions:
  Click bar segment → Violation details for that type/month
  Hover → Exact count + severity level
  Trend → Show month-over-month change
```

---

#### 45. Audit Trail Status (Sankey or Waterfall)
```
Metric: Audit progression through stages
Source: Audit_Tracking_Data
Visualization Type: Sankey Diagram or Waterfall
Dimensions: 600px × 300px (2-column wide)

Configuration:
  Flow stages:
    Planned → Scheduled → In Progress → Completed → Reported
  Node sizes: Audit count at each stage
  Node colors: Status (Blue=Planned, Orange=In Progress, Green=Completed)
  Flow width: Represents audit count

Data Labels: Audit count on flows

Interactions:
  Click node → Audit list for that stage
  Hover → Details (start date, schedule, responsible party)
  Filter → By audit type or department
```

---

#### 46. Policy Exceptions (Bubble Chart)
```
Metric: Policy exceptions by policy type and status
Source: Policy_Exception_Requests
Visualization Type: Bubble Chart
Dimensions: 600px × 300px (2-column wide)

Configuration:
  X-axis: Policy category
  Y-axis: Exception severity (scale 1-5)
  Bubble size: Days outstanding
  Bubble color: Status (Green=Approved, Yellow=Pending, Red=Overdue)
  
Each bubble: One exception or aggregated by policy

Interactions:
  Click bubble → Exception detail + approval workflow
  Hover → Policy name, exception reason, requester
  Filter → By status or age
```

---

#### 47. Remediation Status (Progress Bars or Waterfall)
```
Metric: Remediation action completion by finding
Source: Audit_Findings + Remediation_Actions
Visualization Type: Horizontal Bar Chart or Progress Indicator
Dimensions: 600px × 250px (2-column wide)

Configuration:
  Rows: Finding ID / Description
  Bar segments:
    - Completed (Green)
    - In Progress (Blue)
    - Planned (Gray)
    - Overdue (Red)
  
Percentage labels: % completion per finding

Interactions:
  Click bar → Finding details + action plan
  Click segment → Action list for that status
  Hover → Due date, responsible party, notes
```

---

## Data Source Reference

| Visualization | Data Source | Refresh Frequency | Records |
|---|---|---|---|
| Revenue Cards/Charts | Finance_Revenue_Fact | Daily | 1M+ |
| Profit Metrics | Finance_Income_Statement | Daily | 50K |
| Cash Flow | Finance_Cash_Flow_Statement | Daily | 10K |
| Customer Data | Customer_Master | Daily | 500K |
| Retention/Churn | Customer_Cohort_Retention_Matrix | Weekly | 50K |
| NPS Data | Customer_Survey_Response | Monthly | 5K |
| Operations KPIs | Operations_Daily_Performance | Daily | 100K |
| SLA Data | Operations_SLA_Compliance | Daily | 50K |
| Risk Register | Risk_Register | Weekly | 1K |
| Compliance Violations | Compliance_Violations_Log | Daily | 10K |
| Audit Findings | Audit_Tracking_Data | As-needed | 500 |

---

## Implementation Checklist

**Before Creating Visualizations:**
- [ ] Data source confirmed and mapped
- [ ] DAX measures created and tested
- [ ] Refresh schedule defined
- [ ] Performance optimization verified (query < 5 seconds)

**For Each Visualization:**
- [ ] Visualization type selected from this mapping
- [ ] Dimensions set per specification
- [ ] Color scheme applied per dashboard guidelines
- [ ] Data labels/formatting implemented
- [ ] Interactions (drill-through, tooltips) configured
- [ ] Accessibility features verified
- [ ] Performance benchmarked

**Before Publishing:**
- [ ] Testing on all device types (desktop, tablet, mobile)
- [ ] Data validation (values match source systems)
- [ ] Drill-through paths verified
- [ ] Export/sharing options configured
- [ ] Documentation updated for end users
