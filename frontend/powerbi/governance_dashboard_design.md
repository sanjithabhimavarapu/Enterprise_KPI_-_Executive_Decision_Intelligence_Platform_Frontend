# Governance Dashboard - Detailed Design Specification

## Overview
The Governance Dashboard provides real-time compliance monitoring, risk assessment, and audit trail tracking. It's designed for compliance officers, internal auditors, and governance teams.

---

## Page Structure & Layout

**Grid**: 4 columns × 6 rows (24 sections)
**Refresh Interval**: 5 minutes (critical compliance data)

### Row 1: Header & Controls
```
[Logo] Governance & Compliance Dashboard | [Compliance Category Filter] [Date Range] [Refresh]
```
- Height: 60px
- Global filters: Regulation type, Audit period, Department

### Row 2: Compliance Status KPIs (4 Cards × 1 Row)

#### KPI 1: Overall Compliance Score
```
Metric: Weighted Compliance Score (0-100)
Source: Governance_Compliance_Fact
Visualization: Large KPI Card with Gauge
Dimensions: 250px × 150px

Display Format:
  Primary Value: XX.X% (1 decimal)
  Indicator: vs. Previous Month
  Status: "Compliant" / "At Risk" / "Non-Compliant"
  
Color Coding:
  ≥ 90%: Green (#4CAF50)
  75-89%: Amber (#FF9800)
  < 75%: Red (#F44336)

Interactions:
  Click → Compliance Score Breakdown by Regulation
  Hover → Components: Controls (30%), Violations (30%), Training (20%), Audit (20%)
```

#### KPI 2: Critical Issues Count
```
Metric: COUNT(Critical Issues)
Source: Governance_Issues_Fact
Visualization: Alert Card with Trend
Dimensions: 250px × 150px

Display Format:
  Primary Value: XX (large red number if > 0)
  Indicator: Change from last period (↑↓)
  Sub-text: "Issues requiring immediate action"
  
Color Coding:
  0 Issues: Green
  1-5 Issues: Amber
  > 5 Issues: Red (Critical)

Data Elements:
  - Critical security breaches
  - Audit failures
  - Compliance violations
  
Interactions:
  Click → Critical Issues Detail Panel
  Drill → Issue details, owner, resolution timeline
```

#### KPI 3: Pending Approvals
```
Metric: COUNT(Pending Approval Items)
Source: Governance_Approval_Queue
Visualization: KPI Card with Counter
Dimensions: 250px × 150px

Display Format:
  Primary Value: XX
  Indicator: "Days pending" (avg & max)
  Sub-text: "Policy changes awaiting sign-off"
  
Color Coding:
  0-3 days: Green
  4-7 days: Amber
  > 7 days: Red

Drill Path:
  Click → Approval Queue Detail
  Show: Item, Requestor, Current Approver, Days Pending, Priority
```

#### KPI 4: Policy Violations
```
Metric: COUNT(Active Policy Violations)
Source: Governance_Violations_Fact
Visualization: Alert Card
Dimensions: 250px × 150px

Display Format:
  Primary Value: XX (violations)
  Indicator: Open / Remediated ratio
  Sub-text: "Active violations in last 30 days"
  
Color Coding:
  0 Violations: Green
  1-10 Violations: Amber
  > 10 Violations: Red

Data Elements:
  - Policy breaches
  - Access violations
  - Data protection violations
  
Interactions:
  Click → Violations List
  Drill → Violation details, responsible party, remediation status
```

---

### Row 3: Compliance Status Overview (2 Charts × 1 Row)

#### Chart 1: Regulation Compliance Status (Clustered Bar)
```
Metric: Compliance % by Regulation Type
Source: Governance_Compliance_Fact
Visualization: Clustered Horizontal Bar Chart
Dimensions: 600px × 250px (2-column wide)

X-axis: Compliance %
Y-axis: Regulation Type (SOX, GDPR, HIPAA, CCPA, PCI-DSS, NIST, ISO27001)

Configuration:
  Bars sorted: Highest compliance first
  Target line: 90% (green threshold)
  Value labels: Show % on bar
  Legend: Compliant / Warning / Non-compliant
  
Color Coding (by bar):
  ≥ 90%: Green
  75-89%: Amber
  < 75%: Red

Tooltip:
  Regulation Name
  Current Compliance %
  Previous Month %
  # of Controls
  # of Violations
  
Interactions:
  Click regulation → Detailed compliance breakdown
  Hover bar → See trend line (6-month)
```

#### Chart 2: Compliance Trend (Line Chart - 12 months)
```
Metric: Overall Compliance Score Over Time
Source: Governance_Compliance_Fact (Daily aggregation)
Visualization: Line Chart with Shaded Zones
Dimensions: 600px × 250px (2-column wide)

X-axis: Month (Last 12 months)
Y-axis: Compliance Score (0-100%)

Lines:
  Line 1: Overall Compliance (Primary Blue #2196F3, thickness 3)
  Reference Zone 1: 90%+ (Green shaded background)
  Reference Zone 2: 75-89% (Amber shaded background)
  Reference Zone 3: <75% (Red shaded background)

Configuration:
  Data points: Show circles at monthly aggregation
  Value labels: Month-end values
  Grid: Minor gridlines for readability
  
Tooltip Format:
  Month: [Month Year]
  Score: [X.X%]
  Trend: [↑↓ X.X% vs previous month]
  Major Changes: [List of incidents/improvements]

Interactions:
  Hover point → Detailed day view for that month
  Click → Drill to daily compliance data
```

---

### Row 4: Risk Assessment (2 Charts × 1 Row)

#### Chart 1: Risk Heat Map (Bubble Matrix)
```
Metric: Risk Assessment (Likelihood vs Impact)
Source: Governance_Risk_Register
Visualization: Scatter Plot / Bubble Chart
Dimensions: 600px × 300px (2-column, tall)

Axes:
  X-axis: Likelihood (Low → High, 1-5 scale)
  Y-axis: Impact (Low → High, 1-5 scale)
  
Bubble Properties:
  Size: Number of affected processes
  Color: Risk priority (Red High, Yellow Medium, Green Low)
  Label: Risk ID & Name
  
Matrix Zones:
  Critical (High Impact × High Likelihood): Red zone
  Major (Med-High × any): Yellow zone
  Minor (Low Impact × Low Likelihood): Green zone

Data Elements:
  Each bubble = One risk item
  Bubble size = Number of business processes affected
  Clicking bubble → Risk detail card

Configuration:
  Quadrant lines: Separate at midpoints
  Gridlines: Show risk zones
  Legend: Risk categories

Interactions:
  Click bubble → Risk Detail Page
  Hover → Risk name, description, owner, mitigation status
  Legend toggle → Filter by risk category
```

#### Chart 2: Mitigation Status (Stacked Bar - Status Progress)
```
Metric: Risk Mitigation Status Distribution
Source: Governance_Risk_Register + Governance_Mitigation_Actions
Visualization: Stacked Horizontal Bar Chart
Dimensions: 600px × 300px (2-column, tall)

Structure (by Risk Level):
  1. Critical Risks (row 1)
  2. Major Risks (row 2)
  3. Medium Risks (row 3)
  4. Low Risks (row 4)

Bar Segments (color-coded status):
  Green: Mitigation Complete
  Blue: In Progress (on schedule)
  Yellow: In Progress (delayed)
  Red: Not Started / Overdue
  Gray: N/A (no mitigation needed)

Values:
  Segment width: % of risks in that status
  Labels: # of risks per segment
  
Configuration:
  Totals: Count of risks per level
  Sort: By # of Critical/Major risks first
  
Tooltip:
  Risk Level
  Total Risks: XX
  Complete: X (X%)
  In Progress: X (X%)
  Delayed: X (X%)
  Not Started: X (X%)
  
Interactions:
  Click segment → List of risks in that status
  Drill → Mitigation action details
```

---

### Row 5: Audit & Controls (2 Charts + 1 Table × 1 Row)

#### Chart 1: Control Effectiveness Score (Gauge)
```
Metric: Average Control Effectiveness %
Source: Governance_Control_Assessment
Visualization: Radial Gauge Chart
Dimensions: 300px × 250px (1-column wide)

Scale: 0-100%
Zones:
  Red: 0-60% (Ineffective)
  Yellow: 60-80% (Partially Effective)
  Green: 80-100% (Effective)

Primary Indicator:
  Value: XX.X%
  Sub-text: "% of controls operating effectively"
  Trend: vs. Previous quarter

Configuration:
  Current needle: Primary color
  Target needle: 85% (reference line)
  Arc: Shaded zones

Interactions:
  Click → Control Assessment Breakdown
  Drill → Individual control details
```

#### Chart 2: Active Audit Schedule (Timeline)
```
Metric: Upcoming & Ongoing Audits
Source: Governance_Audit_Schedule
Visualization: Timeline / Gantt Chart
Dimensions: 600px × 250px (2-column wide)

Rows (Audit Types):
  1. Internal Audits
  2. External Audits
  3. Regulatory Audits
  4. IT Audits
  5. Process Audits

Columns:
  Timeline: Next 6 months (by week)

Bar Elements:
  Bar Color: Audit status (Planned=Blue, In Progress=Orange, Completed=Green)
  Bar Length: Audit duration
  Milestone Markers: Start date, end date
  Labels: Audit name, % complete (if in progress)

Configuration:
  Horizontal: Time flow
  Sort: By start date
  Today marker: Vertical line at current date
  
Tooltip:
  Audit Name
  Audit Type
  Scheduled: [Date range]
  Status: Planned / In Progress / Completed
  Owner
  Scope
  
Interactions:
  Click audit → Audit detail and findings
  Drag (if editable) → Reschedule
  Legend toggle → Filter by audit type
```

#### Table: Control Assessment Status
```
Metric: Control Assessment Summary
Source: Governance_Control_Assessment + Governance_Controls_Master
Visualization: Matrix/Table with Conditional Formatting
Dimensions: Full width (4 columns) × 200px

Columns:
  1. Control ID (e.g., "CTL-001")
  2. Control Name
  3. Assessment Status (Icon + Text)
  4. Last Assessment Date
  5. Effectiveness %
  6. Owner

Column Details:
  Assessment Status:
    - Tested: Green checkmark
    - Pending Test: Yellow clock
    - Failed: Red X
    - N/A: Gray dash
  
  Effectiveness %:
    - Conditional color scale (Red <60%, Yellow 60-80%, Green >80%)
  
  Last Assessment Date:
    - Show days since (highlight if >90 days)

Sort: By effectiveness % (ascending - show worst first)
Limit: Top 10-15 controls (show "View All" button)

Interactions:
  Click control → Control detail and remediation tracking
  Click owner → Owner's audit dashboard
```

---

### Row 6: Policy & Compliance Actions (2 Sections × 1 Row)

#### Section 1: Remediation Actions (List)
```
Metric: Open Remediation Items
Source: Governance_Remediation_Actions
Visualization: Table/List
Dimensions: 600px × 200px (2-column wide)

Columns:
  1. Action ID
  2. Description
  3. Owner
  4. Due Date (with status indicator)
  5. Progress %
  6. Priority

Row Styling (Priority color coding):
  Critical: Red background
  High: Orange background
  Medium: Yellow background
  Low: White background

Interactions:
  Click row → Action detail and update history
  Click owner → Person's action dashboard
  Filter by: Owner, Department, Due Date
  
Display Logic:
  Sort: By due date (overdue first)
  Show: Overdue items in bold
  Count: "X of Y actions complete"
```

#### Section 2: Policy Exceptions (List)
```
Metric: Active Policy Exceptions
Source: Governance_Policy_Exceptions
Visualization: Table
Dimensions: 600px × 200px (2-column wide)

Columns:
  1. Exception ID
  2. Policy Name
  3. Requested By
  4. Expiration Date
  5. Status (Approved/Pending/Expired)
  6. Action

Row Styling:
  Expired: Red (alert)
  Expiring Soon (<30 days): Yellow (warning)
  Valid: White (normal)

Interactions:
  Click row → Exception detail and audit trail
  Status icon → Change status (if authorized)
  
Display Logic:
  Sort: By expiration date
  Show: Expired/expiring exceptions highlighted
  Count: "X exceptions active"
```

---

## Color Palette

| Category | Color | Hex | Usage |
|---|---|---|---|
| Compliant | Green | #4CAF50 | Positive status, ≥90% compliance |
| Warning | Amber | #FF9800 | Caution, 75-89% compliance |
| Non-Compliant | Red | #F44336 | Alert, <75% compliance |
| Info | Blue | #2196F3 | Neutral information |
| Neutral | Gray | #9E9E9E | Secondary data |
| In Progress | Orange | #FF6F00 | Active process |

---

## Filtering Strategy

### Global Filters (Top Row)
1. **Compliance Category**: Single select
   - Options: All Regulations, SOX, GDPR, HIPAA, CCPA, PCI-DSS, NIST, ISO27001
   - Default: All Regulations

2. **Date Range**: Dual date picker
   - Default: Last 12 months
   - Quick options: Last 30 days, Last Quarter, YTD, Custom

3. **Department**: Multi-select
   - Default: All Departments
   - Options: Based on Dim_Department

### Contextual Slicers
- **Audit Type**: Internal / External / Regulatory
- **Risk Level**: Critical / Major / Medium / Low
- **Status**: Active / Completed / Planned

---

## Drill-Through Navigation

1. **Compliance Score KPI** → Regulation Compliance Detail
2. **Critical Issues Card** → Issues Detail List
3. **Regulation Compliance Bar** → Regulation-Specific Dashboard
4. **Risk Bubble** → Risk Detail & Mitigation Plan
5. **Audit Timeline Item** → Audit Findings & Report
6. **Control Assessment Row** → Control Detail & Test Results

---

## Data Refresh & Performance

- **Refresh Schedule**: Every 5 minutes (compliance data)
- **Data Retention**: 
  - Transaction-level: 3 years
  - Aggregated compliance scores: Unlimited
  - Audit reports: Unlimited
- **Caching**: 15-minute incremental refresh

---

## Mobile Responsiveness

### Tablet View (iPad / 1024px)
- 3-column grid
- KPI cards: 3-2-1 layout instead of 4
- Charts: Stacked vertically
- Height: Auto-adjust

### Mobile View (Phone / 576px)
- Single column layout
- All visualizations stacked vertically
- Filters in collapsible menu
- KPI cards: Full width, smaller text
- Charts: Simplified (fewer data points)

---

## Export & Reporting

### Report Generation
- **Format**: PDF, Excel, PowerPoint
- **Schedule**: Daily, Weekly, Monthly
- **Recipients**: Distribution lists configured per regulation
- **Sections**: Auto-generated based on dashboard state

### Audit Trail
- All user actions logged (view, export, drill-through)
- Access logs: Who viewed what, when
- Change history: Dashboard modifications tracked

