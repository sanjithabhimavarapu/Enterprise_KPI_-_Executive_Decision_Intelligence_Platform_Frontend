# Operations Dashboard - Detailed Design Specification

## Overview
The Operations Dashboard provides real-time operational efficiency monitoring, department-level performance analysis, and SLA compliance tracking. Designed for operations managers, team leads, and department heads.

---

## Page Structure & Layout

**Grid**: 4 columns × 6 rows (24 sections)
**Refresh Interval**: 30 seconds (real-time operational data)
**Target Users**: COO, Operations Managers, Department Heads, Team Leads

### Row 1: Header & Controls (Full Width)
```
[Logo] Operations Dashboard | [Department Filter] [Shift Filter] [Time Period] [Refresh] [Export]
```
- Height: 60px
- Background: Dark Navy (#1E1E1E)
- Text: White
- Live status badge: LIVE indicator with pulse animation
- Global filters: Department, Shift, Date Range, Priority Level

---

## Row 2: Primary Operations KPI Cards (4 Cards)

### KPI Card 1: Overall Efficiency Index
```
Metric: Weighted average operational efficiency across all departments
Source: Fact_Operational_Metrics
Visualization: Large KPI Card with Gauge Background
Dimensions: 250px × 160px

Display Format:
  Primary Value: XX.X% (bold, 48pt)
  Gauge Arc: 0-100% with colored zones
  
  Secondary Metrics:
    vs Yesterday: ↑/↓ X.X%
    vs Last Week Avg: ↑/↓ X.X%
    Status Label: "Optimal" / "Normal" / "Below Target" / "Critical"
  
  Target Indicator:
    Target: 85% | Current Achievement
    Progress bar: Filled to current %
  
  Calculation:
    Efficiency Index = (Tasks Completed On Time / Total Tasks Assigned) × 100

Color Coding:
  ≥ 90%: Green (#4CAF50)
  75-89%: Amber (#FF9800)
  60-74%: Orange (#FF5722)
  < 60%: Red (#F44336)

Interactions:
  Click → Department efficiency breakdown table
  Hover → Last 7-day efficiency sparkline
  Drill → Task-level detail by department
```

### KPI Card 2: SLA Compliance Rate
```
Metric: % of service tickets / tasks resolved within SLA target window
Source: Fact_SLA_Tracking
Visualization: KPI Card with Gauge + Trend Indicator
Dimensions: 250px × 160px

Display Format:
  Primary Value: XX.X% (bold, 48pt)
  
  SLA Band Breakdown:
    Met SLA:       XX%  (Green)
    At Risk:       XX%  (Amber - within 80% of deadline)
    Breached:      XX%  (Red - past deadline)
  
  Period Selector:
    Today | This Week | This Month | Custom
  
  Target Line: 95% (SLA commitment)

Color Coding:
  ≥ 95%: Green
  85-94%: Amber
  < 85%: Red

Interactions:
  Click → SLA Detail Panel (breach reasons, owner, resolution time)
  Drill → Per-department SLA breakdown
  Hover → SLA trend last 30 days sparkline
```

### KPI Card 3: Average Resolution Time
```
Metric: Mean time from ticket/task creation to resolution
Source: Fact_Operational_Metrics, Fact_SLA_Tracking
Visualization: KPI Card with Target Comparison
Dimensions: 250px × 160px

Display Format:
  Primary Value: Xh XXm (hours and minutes)
  
  Secondary Metrics:
    vs SLA Target: ↑/↓ Xh (over/under target)
    vs Last Period: ↑/↓ XX%
    P50 (Median): Xh XXm
    P95 (Worst 5%): Xh XXm
  
  By Priority:
    Critical: Xh target | Xh actual
    High:     Xh target | Xh actual
    Medium:   Xh target | Xh actual
    Low:      Xh target | Xh actual

Color Coding:
  ≤ Target: Green
  Target to +20%: Amber
  > +20% above Target: Red

Interactions:
  Click → Resolution Time Distribution Histogram
  Drill → Cases beyond SLA with details
```

### KPI Card 4: Resource Utilization
```
Metric: Active resource capacity consumed vs total available
Source: Fact_Resource_Allocation, Dim_Employee
Visualization: KPI Card with Capacity Gauge
Dimensions: 250px × 160px

Display Format:
  Primary Value: XX% (utilization rate, bold 48pt)
  
  Capacity View:
    Allocated:  XX FTE / hours
    Available:  XX FTE / hours
    Overloaded: XX staff members (> 100% capacity)
  
  Status:
    < 70%: "Under-utilized" (Blue)
    70-85%: "Optimal" (Green)
    85-95%: "High Load" (Amber)
    > 95%: "Over-capacity" (Red)

Interactions:
  Click → Resource Allocation by Department
  Drill → Individual employee capacity view
  Export → Resource planning report
```

---

## Row 3: Department Performance Matrix (Full Width)

### Department Performance Heatmap
```
Metric: Multi-KPI performance grid per department
Source: Fact_Operational_Metrics, Dim_Department
Visualization: Matrix / Heatmap (Full Width)
Dimensions: Full width × 200px

Columns:
  Department Name | Efficiency % | SLA Rate % | Avg Resolution | Open Tasks | Overdue | Capacity | Status

Row Coloring (by overall score):
  Green row: All KPIs on target
  Amber row: 1-2 KPIs below target
  Red row: 3+ KPIs below target or any critical breach

Data (Example Row):
  IT Support       | 91% | 97% | 2.4h  | 43  | 2  | 82%  | ✅ On Track
  Customer Ops     | 78% | 88% | 4.1h  | 127 | 18 | 94%  | ⚠ At Risk
  Finance Ops      | 85% | 95% | 3.0h  | 56  | 4  | 79%  | ✅ On Track
  HR Operations    | 70% | 82% | 6.2h  | 38  | 9  | 71%  | 🔴 Below Target
  Logistics        | 88% | 93% | 2.8h  | 201 | 11 | 90%  | ⚠ At Risk
  Procurement      | 82% | 91% | 3.5h  | 74  | 6  | 77%  | ✅ On Track

Interactions:
  Click Department → Drill to department-specific page
  Click SLA Rate → Open SLA detail for that department
  Conditional formatting: Auto-applied per cell threshold
  Sort: Any column header
  Filter: Use header row Department Filter slicer
```

---

## Row 4: Process Efficiency Trends & SLA Analysis (2 Charts)

### Chart A: Department Efficiency Trend (Left - 50% width)
```
Metric: Weekly efficiency % per department over rolling 12 weeks
Source: Fact_Operational_Metrics (weekly aggregation)
Visualization: Multi-Line Chart
Dimensions: ~600px × 280px

X-Axis: Week labels (Week 1 → Week 12)
Y-Axis: Efficiency % (0-100%)
Series: One line per department (max 8 departments)
  Colors: Distinct palette per department
  Line Style: Solid (active), Dashed (target)
  
Target Reference Line:
  85% efficiency target (horizontal dashed line, gray)
  
Legend:
  Position: Bottom
  Interactive: Click to show/hide department lines
  
Data Labels:
  Last data point only (current week value)

Interactions:
  Hover point → Tooltip with department, week, value, vs target
  Click line → Highlight and show department summary panel
  Time period selector → Adjust weeks shown (4W / 8W / 12W / 6M)
  Zoom: Brush selection to zoom into specific weeks
```

### Chart B: SLA Compliance Trend & Breach Analysis (Right - 50% width)
```
Metric: Weekly SLA compliance rate + breach count overlay
Source: Fact_SLA_Tracking (weekly aggregation)
Visualization: Combo Chart (Line + Clustered Bar)
Dimensions: ~600px × 280px

Primary Y-Axis (Line): SLA Compliance % (0-100%)
Secondary Y-Axis (Bar): Number of SLA breaches
X-Axis: Week labels

Series:
  Line: Overall SLA Compliance % (blue, #2196F3)
  Line: SLA Target 95% (gray dashed reference)
  Bars: SLA Breaches by Priority
    - Critical breaches (Red, #F44336)
    - High breaches (Orange, #FF5722)
    - Medium breaches (Amber, #FF9800)
    - Low breaches (Light Gray)

Annotations:
  Flag critical breach spikes with incident reference
  
Interactions:
  Hover bar → Tooltip: breach count, department, avg overdue time
  Click bar → Open Breach Detail Table panel
  Filter: Priority level slicer linked to this chart
```

---

## Row 5: SLA Monitoring Detail Panel (Full Width)

### SLA Monitoring Table (Left - 60% width)
```
Metric: Current open SLAs with status, owner, deadline
Source: Fact_SLA_Tracking, Dim_Employee, Dim_Department
Visualization: Enhanced Data Table with conditional formatting
Dimensions: ~720px × 250px

Columns:
  Ticket ID | Category | Department | Priority | Created | SLA Deadline | Time Remaining | Status | Owner | Resolution %

Conditional Formatting:
  Time Remaining:
    > 4h remaining:  Green background
    1-4h remaining:  Amber background
    < 1h remaining:  Orange background
    0 / Breached:    Red background, bold text
    
  Priority column:
    Critical: Red badge
    High:     Orange badge
    Medium:   Amber badge
    Low:      Gray badge

Sort Default: Priority (Critical first), then Time Remaining ASC

Pagination: 20 rows per page
Filters: Department, Priority, Status (Open / At Risk / Breached)

Interactions:
  Click row → SLA ticket detail panel (right side panel)
  Click Owner → Filter all visuals to that owner
  Export: Excel with all columns
  
Footer: "Showing XX open SLAs | XX at risk | XX breached"
```

### SLA Summary Donut Chart (Right - 40% width)
```
Metric: Distribution of current SLA status across all open tickets
Source: Fact_SLA_Tracking
Visualization: Donut Chart + Summary Stats
Dimensions: ~480px × 250px

Segments:
  Met SLA (completed within window):  XX%  Green
  At Risk (within 80% of deadline):   XX%  Amber
  Breached (past deadline):           XX%  Red
  Pending (not yet started):          XX%  Light Gray

Center Label:
  Total Open: XXX
  
Below Donut - Summary Grid:
  Avg Time to Resolution:  X.X hours
  Fastest Resolution:      XX min
  Slowest (Non-Critical):  XX hours
  SLA Target Met Today:    XX%

Interactions:
  Click segment → Filter SLA table to that status
  Hover → Tooltip with count + department breakdown
```

---

## Row 6: Shift Operations & Capacity Planning (2 Panels)

### Panel A: Peak Hours & Workload Distribution (Left - 50%)
```
Metric: Hourly ticket/task volume vs staff capacity by hour of day
Source: Fact_Operational_Metrics (hourly aggregation)
Visualization: Area Chart (filled) with Capacity Overlay
Dimensions: ~600px × 200px

X-Axis: Hours 00:00 → 23:00
Y-Axis: Volume (tasks / tickets)
Capacity Line: Available staff × avg throughput per hour

Areas:
  Actual Volume: Blue (#2196F3, filled 30% opacity)
  Capacity Line: Green dashed
  
Zones (Shaded background):
  Shift 1 (06:00-14:00): Light blue tint
  Shift 2 (14:00-22:00): Light purple tint
  Shift 3 (22:00-06:00): Light gray tint

Annotations:
  Peak hour marker (arrow + label)
  Current time indicator (vertical line)

Interactions:
  Hover → Tooltip: hour, volume, capacity, utilization %
  Day selector: Mon-Sun or All Days avg
```

### Panel B: Team Performance Leaderboard (Right - 50%)
```
Metric: Top/Bottom performing teams this period
Source: Fact_Operational_Metrics, Dim_Employee, Dim_Department
Visualization: Ranked Bar Chart (horizontal, sorted descending)
Dimensions: ~600px × 200px

Bars: Department teams ranked by composite score
  Composite Score = (Efficiency × 0.4) + (SLA Rate × 0.4) + (Capacity Util × 0.2)
  
Bar Color:
  Score ≥ 85: Green
  Score 70-84: Amber
  Score < 70: Red

Labels: Team name (left), Score % (right of bar)
Reference Line: Company average score (vertical dashed line)

Interactions:
  Click bar → Navigate to department detail view
  Toggle: Top 5 / Bottom 5 / All Teams
  Period: Week / Month / Quarter
```

---

## Drill-Through Pages

### Department Detail Drill-Through Page
```
Trigger: Click on department name anywhere in main dashboard
Context: Filtered to selected department

Layout (4 cols × 4 rows):
  Row 1: Department Header, back button, department-specific filters
  Row 2: Department KPIs (Efficiency %, SLA Rate, Avg Resolution, Headcount)
  Row 3: Task volume trend, SLA breach history, top ticket categories
  Row 4: Team member performance table, capacity calendar
```

### SLA Breach Detail Drill-Through Page
```
Trigger: Click on breach indicator in main dashboard
Context: Filtered to selected ticket / breach period

Layout (4 cols × 3 rows):
  Row 1: Breach context (ticket ID, department, severity)
  Row 2: Timeline from creation to breach, resolution steps
  Row 3: Similar breach history, resolution suggestions, owner details
```

---

## Tooltip Pages

### Department Tooltip
```
Trigger: Hover over department in heatmap
Size: 300px × 200px

Content:
  - Department name + icon
  - Current efficiency % with mini gauge
  - Open tasks count
  - SLA compliance % today
  - Top 3 KPIs this week
```

### SLA Ticket Tooltip
```
Trigger: Hover over SLA table row
Size: 350px × 220px

Content:
  - Ticket details summary
  - Time remaining countdown
  - Owner + escalation path
  - Resolution progress bar
```

---

## Filters & Slicers

| Slicer | Type | Default | Values |
|--------|------|---------|--------|
| Department | Dropdown (multi) | All | All departments from Dim_Department |
| Date Range | Date Picker | Last 30 days | Custom date range |
| Priority | Button slicer | All | Critical, High, Medium, Low |
| Shift | Dropdown | All Shifts | Shift 1, Shift 2, Shift 3, All |
| Status | Button slicer | All | Open, At Risk, Breached, Resolved |
| View Mode | Toggle | Operational | Operational / Strategic |

---

## Design Standards (Matching Platform Theme)

### Color Palette Applied
```
Page Background:     #1E1E1E  (Dark Navy)
Card Background:     #F5F5F5  (Light Gray)
Header Text:         #FFFFFF  (White)
Card Title:          #333333  (Dark Gray)
Positive:            #4CAF50  (Green)
Warning:             #FF9800  (Amber)
Critical:            #F44336  (Red)
Neutral:             #9E9E9E  (Gray)
Primary Blue:        #2196F3
```

### Typography
```
Dashboard Title:    Segoe UI, 28px, Bold, White
Section Headers:    Segoe UI, 18px, SemiBold, White
KPI Values:         Segoe UI, 48px, Bold, #333333
KPI Labels:         Segoe UI, 12px, Regular, #9E9E9E
Table Headers:      Segoe UI, 12px, Bold, #333333
Table Data:         Segoe UI, 11px, Regular, #333333
```

### Layout Dimensions
```
Total Canvas Width:  1280px
Total Canvas Height: 1440px (scrollable)
Header Height:       60px
KPI Row Height:      160px
Chart Row Height:    280px (standard) / 250px (detail)
Table Row Height:    250px
Spacing:             8px between cards
Card Padding:        16px inner
Border Radius:       8px (cards)
```

---

## Real-Time Features

### Auto-Refresh Configuration
```
Dashboard Refresh: Every 30 seconds
SLA Table Refresh: Every 15 seconds (higher priority)
KPI Cards Refresh: Every 30 seconds
Charts Refresh:    Every 60 seconds (aggregated data)

Refresh Indicator:
  Last Refresh Timestamp: Bottom-right corner
  "Data as of: HH:MM:SS"
  Spinning icon when refreshing
```

### Live Status Indicators
```
Global Status Badge (top-right header):
  All Green:  🟢 All Systems Operational
  Any Amber:  🟡 X Departments At Risk
  Any Red:    🔴 X Critical Issues Active

Individual Status Dots:
  Per KPI card, per department row
  Update color with each refresh cycle
```

---

## Accessibility & Mobile

### Responsive Layout
- Tablet (1024px): 2-column KPI row, stacked charts
- Mobile (768px): Single column, swipeable panels
- Always show: Current SLA status, Efficiency index, breach count

### Accessibility Standards
- All charts include alt-text descriptions
- Color-blind safe palette (use shapes + color for status)
- Keyboard navigation enabled for all interactive elements
- Screen reader compatible table headings
