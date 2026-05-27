# Customer Dashboard - Implementation Checklist

## Overview
Step-by-step build guide for the Customer Segmentation, Retention Analysis, and Behavioral Analytics dashboard in Power BI.

**Reference Files:**
- Design Spec:     `customer_dashboard_design.md`
- DAX Measures:    `customer_dax_measures.md`
- SQL Measures:    `../dax/customer_metrics.sql`
- Wireframe:       `../mockups/dashboard_wireframes/customer_dashboard_wireframe.md`

---

## PHASE 1: Data Model Setup

### 1.1 Import / Connect Tables
- [ ] Import `Dim_Customer` (existing — verify all columns including AcquisitionDate, LastTransactionDate)
- [ ] Import `Fact_Customer_Metrics` (daily refresh — RetentionFlag, IsChurned, ChurnRiskScore, HealthScore, EngagementScore)
- [ ] Import `Fact_Customer_Behavior` (daily — EventType, EventCount, SessionDuration, DeviceType)
- [ ] Import `Dim_Customer_Segment` (RFM segment definitions)
- [ ] Import `Dim_Channel` (IsDigital flag, ChannelType)
- [ ] Import `Dim_Product_Category` (CategoryName, CategoryGroup)
- [ ] Confirm `Fact_Sales` already imported with CustomerKey, SalesOrderNumber, ExtendedAmount, OrderDate
- [ ] Import `Dim_Date` (shared — verify CustomerAcquisitionDate can join via USERELATIONSHIP)

### 1.2 Verify Column Presence
- [ ] `Fact_Customer_Metrics`: `RetentionFlag` (BIT), `IsChurned` (BIT), `IsNewCustomer` (BIT)
- [ ] `Fact_Customer_Metrics`: `ChurnRiskScore` (0–100), `HealthScore` (0–100), `EngagementScore` (0–100)
- [ ] `Fact_Customer_Metrics`: `NPS_Score`, `DaysSinceLastPurchase`, `ChurnType`
- [ ] `Fact_Customer_Behavior`: `EventType` values include: Purchase / ProductView / CartAdd / Login / EmailOpen / SupportContact / Complaint
- [ ] `Dim_Customer`: `CustomerAcquisitionDate`, `LastTransactionDate`, `AnnualContractValue`, `IsActive`
- [ ] `Dim_Customer`: `Segment` values: Premium / Standard / Economy | `CustomerType`: Enterprise / Mid-Market / SMB / Individual

### 1.3 Configure Relationships
- [ ] `Fact_Customer_Metrics[DateKey]` → `Dim_Date[DateKey]` (Many:1, Single)
- [ ] `Fact_Customer_Metrics[CustomerKey]` → `Dim_Customer[CustomerKey]` (Many:1, Single)
- [ ] `Fact_Customer_Behavior[DateKey]` → `Dim_Date[DateKey]` (Many:1, Single)
- [ ] `Fact_Customer_Behavior[CustomerKey]` → `Dim_Customer[CustomerKey]` (Many:1, Single)
- [ ] `Fact_Customer_Behavior[ProductCategoryKey]` → `Dim_Product_Category[CategoryKey]` (Many:1, Single)
- [ ] `Fact_Customer_Behavior[ChannelKey]` → `Dim_Channel[ChannelKey]` (Many:1, Single)
- [ ] `Fact_Sales[CustomerKey]` → `Dim_Customer[CustomerKey]` (Many:1, Single) — confirm active
- [ ] Add inactive relationship: `Dim_Customer[CustomerAcquisitionDate]` → `Dim_Date[Date]` (Many:1, inactive)
  - Note: Activate with `USERELATIONSHIP()` in cohort measures

### 1.4 Calculated Columns
- [ ] Add `RFM Segment` column (Dim_Customer or Fact_Customer_Metrics) — see `customer_dax_measures.md` Column 1
- [ ] Add `Health Score Band` column to `Fact_Customer_Metrics` — Column 2
- [ ] Add `Churn Risk Band` column to `Fact_Customer_Metrics` — Column 3
- [ ] Add `Acquisition Cohort` label column to `Dim_Customer` — Column 4 (e.g., "Jan 2025")
- [ ] Add `Customer Tenure Years` column to `Dim_Customer` — Column 5

---

## PHASE 2: DAX Measures

### 2.1 Customer Base Metrics
- [ ] `Total Customers`              (Measure 1)
- [ ] `Active Customers`             (Measure 2)
- [ ] `New Customers`                (Measure 3)
- [ ] `Churned Customers`            (Measure 4)
- [ ] `Net Customer Change`          (Measure 5)
- [ ] `Customer Retention Rate`      (Measure 6)
- [ ] `Customer Churn Rate`          (Measure 7)
- [ ] `Voluntary Churn Rate`         (Measure 8)
- [ ] `Net Promoter Score`           (Measure 9)
- [ ] `Avg Customer Health Score`    (Measure 10)

### 2.2 CLV & Revenue Measures
- [ ] `Avg Customer Lifetime Value`         (Measure 11)
- [ ] `CLV by Segment`                      (Measure 12)
- [ ] `Revenue from Retained Customers`     (Measure 13)
- [ ] `Revenue at Risk`                     (Measure 14)
- [ ] `Avg Revenue Per Customer`            (Measure 15)

### 2.3 RFM Segmentation Measures
- [ ] `Avg Days Since Last Purchase`  (Measure 16)
- [ ] `Customers in Segment`          (Measure 17)
- [ ] `Champions Count`               (Measure 18)
- [ ] `At Risk Customers`             (Measure 19)
- [ ] `Critical Risk Customers`       (Measure 20)
- [ ] `Segment % of Base`             (Measure 21)

### 2.4 Retention Cohort Measures
- [ ] `Cohort Initial Size`                   (Measure 22)
- [ ] `Cohort Retained at Month N`            (Measure 23)
- [ ] `Platform Avg Cohort Retention`         (Measure 24)
- [ ] `Best Cohort Retention`                 (Measure 25)
- [ ] `Retention Rate MoM Change`             (Measure 26)
- [ ] `12-Month Rolling Retention`            (Measure 27)

### 2.5 Behavioral Analytics Measures
- [ ] `Total Events`                    (Measure 28)
- [ ] `Purchase Events`                 (Measure 29)
- [ ] `Avg Session Duration (Min)`      (Measure 30)
- [ ] `Avg Pages Per Session`           (Measure 31)
- [ ] `Avg Engagement Score`            (Measure 32)
- [ ] `Funnel Conversion Rate`          (Measure 33)
- [ ] `Cart Abandonment Rate`           (Measure 34)
- [ ] `Digital Channel Share`           (Measure 35)
- [ ] `Mobile Engagement Share`         (Measure 36)
- [ ] `Category Penetration Rate`       (Measure 37)
- [ ] `Repeat Purchase Rate`            (Measure 38)
- [ ] `Avg Order Frequency`             (Measure 39)
- [ ] `Cross-Sell Index`                (Measure 40)

### 2.6 Churn Risk Measures
- [ ] `Avg Churn Risk Score`            (Measure 41)
- [ ] `High Risk Revenue %`             (Measure 42)
- [ ] `Churn Rate WoW Change`           (Measure 43)
- [ ] `Customer Rescue Rate`            (Measure 44)

---

## PHASE 3: Dashboard Page Build

### 3.1 Row 1 — Header & Controls
- [ ] Dashboard title: "Customer Analytics Dashboard" (Segoe UI, 28px, Bold, White)
- [ ] Company logo (top-left)
- [ ] Segment slicer (dropdown, multi-select: Premium / Standard / Economy / Enterprise / SMB)
- [ ] CustomerType slicer (button: All / Enterprise / Mid-Market / SMB / Individual)
- [ ] Region slicer (dropdown, multi-select)
- [ ] Date Range slicer (relative: Last 12 months default, custom option)
- [ ] Acquisition Cohort slicer (dropdown)
- [ ] Churn Risk Band slicer (button: All / Low / Medium / High / Critical)
- [ ] Header background: Dark Navy (#1E1E1E)

### 3.2 Row 2 — KPI Cards
- [ ] **Card 1: Total Active Customers**
  - [ ] Primary: `Active Customers`
  - [ ] Secondary: `New Customers` (+, green), `Churned Customers` (-, red), `Net Customer Change`
  - [ ] Segment spark bars inline (Premium/Standard/Economy %)
  - [ ] Color: YoY growth threshold

- [ ] **Card 2: Customer Retention Rate**
  - [ ] Primary: `Customer Retention Rate`
  - [ ] Gauge arc with 90% target line
  - [ ] Secondary: `Retention Rate MoM Change`, `At Risk Customers` count badge
  - [ ] 12-month sparkline (using `12-Month Rolling Retention`)
  - [ ] Color: ≥90% Green | 80-89% Amber | <80% Red

- [ ] **Card 3: Customer Churn Rate**
  - [ ] Primary: `Customer Churn Rate`
  - [ ] Secondary: `Voluntary Churn Rate`, churned revenue ($ value)
  - [ ] `Critical Risk Customers` red badge (alert if > 0)
  - [ ] Color: <3% Green | 3-6% Amber | >6% Red (inverted logic)

- [ ] **Card 4: Customer Lifetime Value**
  - [ ] Primary: `Avg Customer Lifetime Value`
  - [ ] Secondary by segment: `CLV by Segment` for Premium/Standard/Economy
  - [ ] Progress bar: CLV vs target
  - [ ] Color: ≥ target Green | 90-99% Amber | <90% Red

### 3.3 Row 3 — Customer Segmentation
- [ ] **RFM Scatter Plot (left 55%)**
  - [ ] X-axis: Recency Score (1–5), Y-axis: Frequency Score (1–5), Bubble: Monetary Value
  - [ ] Color series: `RFM Segment` column (7 segment colors from design spec)
  - [ ] Quadrant labels: Champions / At Risk / Promising / Lost (overlaid text boxes)
  - [ ] Legend: right side, interactive click to filter
  - [ ] Tooltips: segment, count, avg CLV, avg order value
  - [ ] Enable cross-filter with segment summary table

- [ ] **Segment Performance Matrix (right 45%)**
  - [ ] Rows: `Dim_Customer[RFM Segment]`
  - [ ] Columns: `Customers in Segment`, `Segment % of Base`, `Avg Customer Lifetime Value`, `Avg Revenue Per Customer`, `Customer Retention Rate`, `Avg Churn Risk Score`, `Revenue at Risk`
  - [ ] Conditional formatting on Retention % and Churn Risk %
  - [ ] Sort by Revenue Contribution descending
  - [ ] Cross-filter with scatter plot

### 3.4 Row 4 — Cohort Retention Heatmap
- [ ] Insert Matrix visual (full width)
- [ ] Rows: `Dim_Customer[Acquisition Cohort]` (sorted chronologically)
- [ ] Columns: MonthOffset (M+0 through M+23, use custom measure + date calculation)
- [ ] Values: `Cohort Retained at Month N`
- [ ] Row header: show `Cohort Initial Size` and current retained count
- [ ] Conditional formatting — full gradient:
  - [ ] 100%: #2E7D32 | 80-99%: #4CAF50 | 60-79%: #A5D6A7 | 40-59%: #FFB74D | 20-39%: #FF7043 | 0-19%: #F44336
- [ ] Add `Platform Avg Cohort Retention` as reference row or column overlay
- [ ] Bold best-performing cohort row border
- [ ] Enable drill-through on row header → Cohort Deep-Dive page
- [ ] Toggle: show as % / show as customer count

### 3.5 Row 5 — Churn Risk & Acquisition Trend
- [ ] **Churn Risk Stacked Bar (left 50%)**
  - [ ] Y-axis: Segment names
  - [ ] X-axis: Customer count
  - [ ] Stacked by: `Churn Risk Band` (Low Green / Medium Amber / High Orange / Critical Red)
  - [ ] Data labels: count + %
  - [ ] Right panel: Total At-Risk, Total Critical, Avg Risk Score, Highest-Risk Segment
  - [ ] Cross-filter: Click risk band → filter customer list

- [ ] **Acquisition & Churn Trend Combo (right 50%)**
  - [ ] X-axis: Month (last 18 months)
  - [ ] Bars: `New Customers` (Green) above zero, `Churned Customers` (Red) below zero
  - [ ] Line: `Net Customer Change` (blue, secondary Y-axis)
  - [ ] Reference line: Net zero (gray dashed)
  - [ ] Mark net-negative months (red triangle)
  - [ ] Toggle: Monthly / Quarterly

### 3.6 Row 6 — Behavioral Analytics
- [ ] **Purchase Behavior Funnel (left 45%)**
  - [ ] Funnel visual with 7 stages: Awareness → ProductView → CartAdd → Checkout → Purchase → Repeat → Loyal
  - [ ] Values: `Customers in Segment` scoped per EventType filter
  - [ ] Bar labels: stage name, customer count, conversion % to next stage
  - [ ] Shading: progressive dark blue gradient per stage
  - [ ] Right-side drop-off annotations in red
  - [ ] Linked to Segment slicer

- [ ] **Product Category Affinity Heatmap (right 55%)**
  - [ ] Rows: Customer Segment
  - [ ] Columns: Product Category (up to 12)
  - [ ] Values: `Category Penetration Rate`
  - [ ] Color gradient: White (#FFFFFF) → Dark Blue (#1565C0) by penetration %
  - [ ] Bold border: top category per segment
  - [ ] Orange outline: low-penetration high-CLV cells (cross-sell opportunities)
  - [ ] Toggle: Penetration % / Avg Order Value / Revenue $
  - [ ] Drill-through on cell → customer list for that segment × category

### 3.7 Row 7 — Health Score & Engagement Timeline
- [ ] **Health Score Donut (left 40%)**
  - [ ] Segments: Healthy (Green) / Stable (Blue) / At Risk (Amber) / Critical (Red)
  - [ ] Center: `Avg Customer Health Score`
  - [ ] Below: trend grid (MoM change, migration counts: Healthy→Stable, AtRisk→Critical, Rescued)
  - [ ] Cross-filter: click segment → filter all customer visuals

- [ ] **Engagement Activity Timeline (right 60%)**
  - [ ] X-axis: Date (last 90 days, daily)
  - [ ] Stacked area series: Purchases (Dark Blue) / Support (Amber) / Login (Light Blue) / Email (Purple)
  - [ ] Thin line overlay: Complaints (Red, not stacked)
  - [ ] Vertical markers: Campaign launch dates
  - [ ] Shaded bands: Seasonal/holiday events
  - [ ] Brush zoom: drag to narrow date range
  - [ ] Toggle: Absolute count / % of base

---

## PHASE 4: Drill-Through Pages

### 4.1 Customer 360 Page
- [ ] Create hidden page: "Customer 360"
- [ ] Drill-through field: Customer name or CustomerKey
- [ ] Row 1: Customer header + back button (name, type, segment badge, health badge)
- [ ] Row 2: CLV, Total Orders, Avg Order Value, Days Since Last Purchase, Health Score, Churn Risk Score
- [ ] Row 3: Purchase history timeline (line), category breakdown (bar), support ticket history (table)
- [ ] Row 4: Churn risk signal scorecard (which signals driving risk), recommended next actions, contact history table

### 4.2 Cohort Deep-Dive Page
- [ ] Create hidden page: "Cohort Detail"
- [ ] Drill-through field: Acquisition Cohort label
- [ ] Row 1: Cohort header + back button (month, initial size)
- [ ] Row 2: Retention curve line chart (vs platform average dashed), revenue from cohort over time
- [ ] Row 3: Segment mix donut, top churn reasons bar chart, retained customer list table

### 4.3 Segment Deep-Dive Page
- [ ] Create hidden page: "Segment Detail"
- [ ] Drill-through field: RFM Segment name
- [ ] Row 1: Segment header + back button (count, % of base, key KPIs)
- [ ] Row 2: Monthly acquisition trend (line), top 5 product categories (bar), geographic map
- [ ] Row 3: Customer migration Sankey chart (inflow/outflow to other segments)

---

## PHASE 5: Tooltip Pages

### 5.1 Customer Tooltip
- [ ] Create tooltip page: 320px × 200px
- [ ] Trigger: Hover on customer name in any table
- [ ] Content: name, segment, CLV, last purchase, health score gauge, churn risk badge

### 5.2 Cohort Cell Tooltip
- [ ] Create tooltip page: 280px × 160px
- [ ] Trigger: Hover on cohort heatmap cell
- [ ] Content: cohort label, month offset, retained count, lost count, retention %, vs platform avg

### 5.3 RFM Bubble Tooltip
- [ ] Create tooltip page: 300px × 180px
- [ ] Trigger: Hover on bubble in RFM scatter
- [ ] Content: segment name, customer count, avg CLV, avg frequency, avg recency days

---

## PHASE 6: Slicers & Filter Interactions

- [ ] Sync Segment slicer across all 3 drill-through pages
- [ ] Sync Date Range slicer across main page + all sub-pages
- [ ] Configure slicer interactions:
  - [ ] Churn Risk Band slicer → filters: KPI cards, churn distribution chart, customer list
  - [ ] Health Score Band slicer → filters: health donut, engagement timeline, customer list
  - [ ] Donut charts should NOT filter KPI cards (turn off interaction)
  - [ ] RFM scatter ↔ segment matrix: bidirectional cross-filter (both directions)
  - [ ] Cohort heatmap: row click filters customer list below (if added)

---

## PHASE 7: Formatting & Theme

- [ ] Apply platform theme JSON (from `dashboard_themes.md`)
- [ ] Page background: #1E1E1E (Dark Navy)
- [ ] Card backgrounds: #F5F5F5, 8px border radius
- [ ] RFM segment colors applied consistently:
  - [ ] Champions: #4CAF50 | Loyal: #2196F3 | At Risk: #FF9800
  - [ ] Need Attention: #FF5722 | Lost: #F44336 | New: #009688 | Promising: #9C27B0
- [ ] Cohort heatmap gradient correctly configured (5-color diverging scale)
- [ ] Funnel bars: sequential blue gradient (#E3F2FD → #0D47A1)
- [ ] KPI cards: 48px bold values, consistent Segoe UI typography

---

## PHASE 8: Data Validation

- [ ] `Customer Retention Rate` matches SQL query in `customer_metrics.sql` Section 3.1
- [ ] RFM segment assignments match Section 2.1 NTILE-based scoring
- [ ] Cohort retention % matches Section 3.2 CohortBase CTE
- [ ] Cart abandonment rate matches Section 5.5 formula
- [ ] CLV avg matches Section 6.1 formula
- [ ] NPS score matches Section 1.2 Promoter/Detractor logic
- [ ] Cross-validate `Critical Risk Customers` count against Section 4.2 WHERE ChurnRiskScore >= 76

---

## PHASE 9: Testing & UAT

### Visual Testing
- [ ] All 4 KPI cards display at 1280px canvas without overflow
- [ ] RFM scatter plots renders with ≥ 7 segments visible
- [ ] Cohort heatmap scrolls horizontally for M+12 to M+23
- [ ] Funnel chart shows all 7 stages with drop-off annotations
- [ ] Heatmap gradient applies correctly across all cells
- [ ] Drill-through works: scatter → segment detail, heatmap row → cohort detail, table row → customer 360

### Filter Testing
- [ ] Segment slicer filters all visuals correctly
- [ ] Date range change updates cohort heatmap rows
- [ ] Churn Risk Band slicer filters churn chart and customer tables only
- [ ] Donut segment click filters the customer table but NOT the KPI cards

### Performance Testing
- [ ] Page load time < 5 seconds on Import mode data
- [ ] Cohort heatmap loads within 10 seconds (aggregated data)
- [ ] RFM scatter renders within 5 seconds (may need aggregation table)

---

## PHASE 10: Accessibility

- [ ] All charts: add alt-text descriptions (Options → Alt Text)
- [ ] RFM scatter: add accessible legend with distinct shapes per segment (not color only)
- [ ] Cohort heatmap: add data label option for accessibility view
- [ ] Minimum font size ≥ 11px
- [ ] Tab order configured for header → KPIs → Charts → Tables

---

## Completion Sign-Off

| Section | Owner | Status | Date |
|---------|-------|--------|------|
| Data Model & Relationships | | | |
| Calculated Columns (5) | | | |
| DAX Measures 1-10 (Base) | | | |
| DAX Measures 11-21 (CLV + RFM) | | | |
| DAX Measures 22-27 (Cohort) | | | |
| DAX Measures 28-44 (Behavior + Churn) | | | |
| KPI Cards Row 2 | | | |
| RFM Scatter + Segment Matrix Row 3 | | | |
| Cohort Retention Heatmap Row 4 | | | |
| Churn Risk + Acquisition Trend Row 5 | | | |
| Behavioral Analytics Row 6 | | | |
| Health + Engagement Row 7 | | | |
| Customer 360 Drill-Through | | | |
| Cohort & Segment Drill-Throughs | | | |
| Tooltip Pages (3) | | | |
| Filter & Slicer Interactions | | | |
| SQL Validation (8 queries) | | | |
| UAT Sign-Off | | | |
