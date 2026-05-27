# Operations Dashboard - Implementation Checklist

## Overview
Step-by-step checklist for building the Operations Dashboard in Power BI, covering data model setup, DAX measures, visualizations, SLA monitoring, and department analysis.

**Reference Files:**
- Design Spec:  `operations_dashboard_design.md`
- DAX Measures: `operations_dax_measures.md`
- SQL Measures: `../dax/sla_measures.sql`
- Wireframe:    `../mockups/dashboard_wireframes/operations_dashboard_wireframe.md`

---

## PHASE 1: Data Model Setup

### 1.1 Import / Connect Tables
- [ ] Connect `Fact_Operational_Metrics` (DirectQuery — real-time)
- [ ] Connect `Fact_SLA_Tracking` (DirectQuery — real-time)
- [ ] Connect `Fact_Resource_Allocation` (Import — hourly refresh)
- [ ] Import `Dim_Department` (includes SLA_Target_Pct, Efficiency_Target columns)
- [ ] Import `Dim_SLA_Category` (SLA_Hours per category/priority)
- [ ] Import `Dim_Shift` (Shift 1/2/3 definitions)
- [ ] Import `Dim_Employee` (EmployeeKey, EmployeeName, DepartmentKey)
- [ ] Import `Dim_Date` (shared with other dashboards)

### 1.2 Verify Column Presence
- [ ] `Fact_SLA_Tracking`: `IsBreached` (BIT), `BreachMinutes` (INT), `ResolutionMinutes` (INT)
- [ ] `Fact_SLA_Tracking`: `Status` values match: Open / AtRisk / Resolved / Breached
- [ ] `Fact_SLA_Tracking`: `Priority` values match: Critical / High / Medium / Low
- [ ] `Fact_Operational_Metrics`: `TasksOnTime`, `TasksOverdue`, `HourKey` (0-23)
- [ ] `Dim_Department`: `SLA_Target_Pct`, `Efficiency_Target` numeric columns present

### 1.3 Configure Relationships
- [ ] `Fact_SLA_Tracking[DateKey]` → `Dim_Date[DateKey]` (Many:1, Single)
- [ ] `Fact_SLA_Tracking[DepartmentKey]` → `Dim_Department[DepartmentKey]` (Many:1, Single)
- [ ] `Fact_SLA_Tracking[OwnerEmployeeKey]` → `Dim_Employee[EmployeeKey]` (Many:1, Single)
- [ ] `Fact_SLA_Tracking[CategoryKey]` → `Dim_SLA_Category[CategoryKey]` (Many:1, Single)
- [ ] `Fact_Operational_Metrics[DateKey]` → `Dim_Date[DateKey]` (Many:1, Single)
- [ ] `Fact_Operational_Metrics[DepartmentKey]` → `Dim_Department[DepartmentKey]` (Many:1, Both)
- [ ] `Fact_Operational_Metrics[EmployeeKey]` → `Dim_Employee[EmployeeKey]` (Many:1, Single)
- [ ] `Fact_Operational_Metrics[ShiftKey]` → `Dim_Shift[ShiftKey]` (Many:1, Single)
- [ ] `Fact_Resource_Allocation[DepartmentKey]` → `Dim_Department[DepartmentKey]` (Many:1, Single)
- [ ] `Fact_Resource_Allocation[EmployeeKey]` → `Dim_Employee[EmployeeKey]` (Many:1, Single)
- [ ] `Fact_Resource_Allocation[ShiftKey]` → `Dim_Shift[ShiftKey]` (Many:1, Single)

### 1.4 Calculated Columns
- [ ] Add `SLA Status Label` column to `Fact_SLA_Tracking` (see `operations_dax_measures.md` Column 1)
- [ ] Add `Priority Sort Order` column to `Fact_SLA_Tracking` (Column 2)
- [ ] Add `Efficiency Band` column to `Fact_Operational_Metrics` (Column 3)

---

## PHASE 2: DAX Measures

### 2.1 Efficiency Measures
- [ ] `Total Tasks Assigned`         (Measure 1)
- [ ] `Total Tasks Completed`        (Measure 2)
- [ ] `Operational Efficiency Index` (Measure 3) — primary KPI card
- [ ] `Efficiency vs Target`         (Measure 4)
- [ ] `Task Completion Rate`         (Measure 5)
- [ ] `Overdue Tasks Count`          (Measure 6)
- [ ] `Overdue Rate`                 (Measure 7)
- [ ] `Avg Processing Time (Min)`    (Measure 8)
- [ ] `Operational Error Rate`       (Measure 9)
- [ ] `WoW Efficiency Change`        (Measure 10)

### 2.2 Department Analysis Measures
- [ ] `Department Efficiency Rank`        (Measure 11)
- [ ] `Department Composite Score`        (Measure 12)
- [ ] `Department Composite Rank`         (Measure 13)
- [ ] `Department SLA Target`             (Measure 14)
- [ ] `Tasks Per Employee`                (Measure 15)
- [ ] `Departments Below Target Count`    (Measure 16)

### 2.3 SLA Monitoring Measures
- [ ] `Total SLA Tickets`                       (Measure 17)
- [ ] `SLA Compliance Rate`                     (Measure 18)
- [ ] `SLA Compliance Rate (Overall)`           (Measure 19)
- [ ] `SLA Breached Count`                      (Measure 20)
- [ ] `SLA At Risk Count`                       (Measure 21)
- [ ] `SLA Breach Rate`                         (Measure 22)
- [ ] `Avg Resolution Time (Hours)`             (Measure 23)
- [ ] `Median Resolution Time (Hours)`          (Measure 24)
- [ ] `P95 Resolution Time (Hours)`             (Measure 25)
- [ ] `SLA Time Remaining (Min)`                (Measure 26)
- [ ] `Avg Breach Overrun (Hours)`              (Measure 27)
- [ ] `Critical SLA Breaches Today`             (Measure 28)
- [ ] `SLA Compliance Rate - Critical`          (Measure 29)
- [ ] `SLA Compliance Rate - High`              (Measure 30)
- [ ] `WoW SLA Compliance Change`               (Measure 31)
- [ ] `SLA Compliance MTD`                      (Measure 32)

### 2.4 Resource Utilization Measures
- [ ] `Resource Utilization Rate`   (Measure 33)
- [ ] `Overloaded Staff Count`      (Measure 34)
- [ ] `Available Capacity Hours`    (Measure 35)
- [ ] `Capacity Gap`                (Measure 36)

### 2.5 Trend & Time Intelligence Measures
- [ ] `7-Day Rolling Efficiency`         (Measure 37)
- [ ] `30-Day Rolling SLA Rate`          (Measure 38)
- [ ] `Efficiency Forecast (Next 7 Days)`(Measure 39)
- [ ] `Operations Status`               (Measure 40)

---

## PHASE 3: Dashboard Page Build

### 3.1 Row 1 — Header & Controls
- [ ] Add dashboard title text box: "Operations Dashboard" (Segoe UI, 28px, White)
- [ ] Add company logo (top-left, 40px height)
- [ ] Add live status badge (top-right) driven by `Operations Status` measure
- [ ] Add Department slicer (multi-select dropdown)
- [ ] Add Date Range slicer (relative date picker: Last 7 / 30 / 90 days / Custom)
- [ ] Add Priority slicer (button slicer: All / Critical / High / Medium / Low)
- [ ] Add Shift slicer (dropdown: All / Shift 1 / Shift 2 / Shift 3)
- [ ] Add last-refresh timestamp text box (bottom-right of header)

### 3.2 Row 2 — KPI Cards
- [ ] **KPI Card 1: Operational Efficiency Index**
  - [ ] Primary value: `Operational Efficiency Index`
  - [ ] Gauge background (0-100%)
  - [ ] Secondary: `WoW Efficiency Change`, status label
  - [ ] Color: ≥90% Green | 75-89% Amber | <75% Red
  - [ ] Drill-through: department efficiency breakdown

- [ ] **KPI Card 2: SLA Compliance Rate**
  - [ ] Primary value: `SLA Compliance Rate`
  - [ ] Sub-metrics: `SLA Breached Count`, `SLA At Risk Count`
  - [ ] Target line: 95%
  - [ ] Color: ≥95% Green | 85-94% Amber | <85% Red
  - [ ] Drill-through: SLA detail panel

- [ ] **KPI Card 3: Average Resolution Time**
  - [ ] Primary value: `Avg Resolution Time (Hours)`
  - [ ] Secondary: `Median Resolution Time (Hours)`, `P95 Resolution Time (Hours)`
  - [ ] Target comparison by priority tier
  - [ ] Color coding vs SLA target

- [ ] **KPI Card 4: Resource Utilization**
  - [ ] Primary value: `Resource Utilization Rate`
  - [ ] Sub-metrics: `Overloaded Staff Count`, `Available Capacity Hours`
  - [ ] Gauge: 0-120% (overload visible)
  - [ ] Status: <70% Blue | 70-85% Green | 85-95% Amber | >95% Red

### 3.3 Row 3 — Department Performance Matrix
- [ ] Insert Matrix visual (full-width)
- [ ] Rows: `Dim_Department[DepartmentName]`
- [ ] Values columns:
  - [ ] `Operational Efficiency Index` (with color rules)
  - [ ] `SLA Compliance Rate` (with color rules)
  - [ ] `Avg Resolution Time (Hours)` (with color rules)
  - [ ] `Overdue Tasks Count`
  - [ ] `SLA Breached Count`
  - [ ] `Resource Utilization Rate` (with color rules)
  - [ ] `Department Composite Score` (with color rules)
- [ ] Apply conditional formatting on each value column:
  - [ ] Efficiency: ≥90% → Green, 75-89% → Amber, <75% → Red
  - [ ] SLA Rate: ≥95% → Green, 85-94% → Amber, <85% → Red
  - [ ] Utilization: 70-85% → Green, others → Amber/Red
- [ ] Enable drill-through on department name rows
- [ ] Sort default: `Department Composite Score` descending

### 3.4 Row 4 — Trend Charts
- [ ] **Chart A: Department Efficiency Trend (Line Chart, left half)**
  - [ ] X-axis: `Dim_Date[Week]`
  - [ ] Y-axis: `7-Day Rolling Efficiency`
  - [ ] Series: `Dim_Department[DepartmentName]` (one line per dept)
  - [ ] Reference line: 85% target (constant line)
  - [ ] Time period selector: 4W / 8W / 12W
  - [ ] Enable legend (bottom, interactive)

- [ ] **Chart B: SLA Compliance + Breach Combo Chart (right half)**
  - [ ] Line: `SLA Compliance Rate` (primary Y-axis, blue)
  - [ ] Reference line: 95% SLA target (gray dashed)
  - [ ] Stacked bar: `SLA Breached Count` by priority (secondary Y-axis)
  - [ ] X-axis: `Dim_Date[Week]`
  - [ ] Enable drill-down to daily view
  - [ ] Priority filter linked to main Priority slicer

### 3.5 Row 5 — SLA Monitoring Detail
- [ ] **SLA Monitoring Table (left 60%)**
  - [ ] Columns: TicketRef, CategoryName, DepartmentName, Priority, CreatedAt, SLADeadline, SLA Time Remaining, SLA Status Label, OwnerName
  - [ ] Conditional formatting on SLA Time Remaining:
    - [ ] >4h: Green background
    - [ ] 1-4h: Amber background
    - [ ] <1h: Orange background
    - [ ] Breached (negative): Red background, bold
  - [ ] Priority badges: Red/Orange/Amber/Gray icon
  - [ ] Default sort: Priority Sort Order ASC, then SLADeadline ASC
  - [ ] Pagination: 20 rows per page
  - [ ] Export button enabled

- [ ] **SLA Status Donut Chart (right 40%)**
  - [ ] Segments: Met SLA / At Risk / Breached / Pending
  - [ ] Colors: Green / Amber / Red / Light Gray
  - [ ] Center label: Total ticket count
  - [ ] Below donut: summary grid (Avg, P50, P95 resolution)
  - [ ] Cross-filter: clicking segment filters the table

### 3.6 Row 6 — Shift & Team Performance
- [ ] **Peak Hours Area Chart (left half)**
  - [ ] X-axis: HourKey (0-23)
  - [ ] Area: task volume (blue, 30% opacity fill)
  - [ ] Line overlay: capacity line (green dashed)
  - [ ] Shift zone shading: Shift 1 / 2 / 3 background bands
  - [ ] Current time vertical marker
  - [ ] Day selector: Mon-Sun / All Days Average

- [ ] **Team Leaderboard Horizontal Bar Chart (right half)**
  - [ ] Bars: `Department Composite Score` per department
  - [ ] Horizontal sorted bars (descending)
  - [ ] Color: ≥85 Green | 70-84 Amber | <70 Red
  - [ ] Reference line: company average score
  - [ ] Toggle: Top 5 / Bottom 5 / All
  - [ ] Click → drill-through to department detail page

---

## PHASE 4: Drill-Through Pages

### 4.1 Department Detail Page
- [ ] Create hidden page: "Dept Detail"
- [ ] Set drill-through field: `Dim_Department[DepartmentName]`
- [ ] Row 1: Back button, Department name header, dept-specific filters
- [ ] Row 2: 4 KPI cards — Efficiency, SLA Rate, Avg Resolution, Headcount
- [ ] Row 3: Task volume daily trend (line), SLA breach history (bar), ticket categories (pie)
- [ ] Row 4: Employee performance table, shift coverage calendar heatmap

### 4.2 SLA Breach Detail Page
- [ ] Create hidden page: "SLA Breach Detail"
- [ ] Set drill-through field: `Fact_SLA_Tracking[TicketRef]`
- [ ] Row 1: Ticket reference, department, priority badge, back button
- [ ] Row 2: Timeline visual (creation → breach point → resolution)
- [ ] Row 3: Breach history for same category, escalation trail, owner details

---

## PHASE 5: Slicers & Filters Configuration

- [ ] Sync Department slicer across all pages
- [ ] Sync Date Range slicer across all pages
- [ ] Priority slicer: sync to SLA table + SLA trend chart only
- [ ] Shift slicer: sync to peak hours chart + operational metrics only
- [ ] Status slicer: sync to SLA table + donut chart only
- [ ] Configure slicer interactions — prevent unwanted cross-filtering between:
  - [ ] Donut chart and KPI cards (donut should not filter KPIs)
  - [ ] Leaderboard bars and efficiency trend (separate contexts)

---

## PHASE 6: Formatting & Theme

- [ ] Apply platform theme JSON (from `dashboard_themes.md`)
- [ ] Page background: Dark Navy #1E1E1E
- [ ] Card backgrounds: #F5F5F5 with 8px border radius
- [ ] All KPI values: Segoe UI, 48px, Bold
- [ ] Section headers: Segoe UI, 18px, SemiBold, White
- [ ] Status color rules applied globally:
  - [ ] Green = #4CAF50 (on target)
  - [ ] Amber = #FF9800 (at risk)
  - [ ] Red = #F44336 (critical/breach)
- [ ] All cards: 8px padding, subtle shadow
- [ ] Navigation bar consistent with other dashboard pages

---

## PHASE 7: Auto-Refresh & Real-Time Setup

- [ ] Set Fact_SLA_Tracking DirectQuery refresh: 15 seconds
- [ ] Set Fact_Operational_Metrics DirectQuery refresh: 30 seconds
- [ ] Configure Fact_Resource_Allocation incremental refresh: hourly
- [ ] Add refresh timestamp measure: `"Data as of: " & FORMAT(NOW(), "HH:MM:SS")`
- [ ] Display refresh timestamp in footer of header row
- [ ] Add spinning refresh icon (conditional visibility on refresh)

---

## PHASE 8: Tooltip Pages

### 8.1 Department Tooltip Page
- [ ] Create tooltip page: 300px × 200px
- [ ] Trigger: Hover on department matrix row
- [ ] Content: Dept name, efficiency gauge, open tasks, SLA rate today, top 3 KPIs

### 8.2 SLA Ticket Tooltip Page
- [ ] Create tooltip page: 350px × 220px
- [ ] Trigger: Hover on SLA table row
- [ ] Content: Ticket summary, time remaining countdown, owner, escalation path, resolution %

---

## PHASE 9: Accessibility

- [ ] All charts include alt-text (Options → Alt Text)
- [ ] Color-blind safe: use shapes + colors for status (not color alone)
- [ ] Tab order configured for keyboard navigation
- [ ] Table column headers marked as header cells
- [ ] Min font size ≥ 11px across all text elements

---

## PHASE 10: Testing & Validation

### Data Validation
- [ ] SLA Compliance Rate matches SQL query in `sla_measures.sql` Section 1.1
- [ ] Department Composite Score matches SQL query Section 4.2
- [ ] Resource Utilization Rate matches Section 6.1
- [ ] Breach counts validated against source table row counts

### Visual Validation
- [ ] All 4 KPI cards display correctly at 1280px canvas
- [ ] Department matrix shows all active departments
- [ ] SLA table sorts by Priority then deadline correctly
- [ ] Donut chart cross-filters SLA table on click
- [ ] Drill-through to Department Detail works from matrix and leaderboard
- [ ] Drill-through to SLA Breach Detail works from SLA table
- [ ] Refresh timestamp updates every cycle

### SLA Alert Validation
- [ ] `Critical SLA Breaches Today` > 0 → Red header badge shows
- [ ] `SLA At Risk Count` > 0 → Amber header badge shows
- [ ] Time remaining cells re-color correctly as deadline approaches

### Mobile & Tablet
- [ ] Dashboard readable at 1024px (tablet) — KPI cards stack 2×2
- [ ] Critical KPIs visible on mobile at 768px without scroll

---

## Completion Sign-Off

| Section | Owner | Status | Date |
|---------|-------|--------|------|
| Data Model & Relationships | | | |
| All 40 DAX Measures | | | |
| KPI Cards (Row 2) | | | |
| Department Matrix (Row 3) | | | |
| Trend Charts (Row 4) | | | |
| SLA Monitoring Panel (Row 5) | | | |
| Shift & Leaderboard (Row 6) | | | |
| Drill-Through Pages | | | |
| Auto-Refresh Configuration | | | |
| Accessibility Review | | | |
| Data Validation | | | |
| UAT Sign-Off | | | |
