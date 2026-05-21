# Data Validation Visuals - Comprehensive Specification

## Overview
Data validation visuals monitor data quality, integrity, and accuracy across all enterprise data pipelines. These are critical for ensuring reliable KPIs and governance compliance.

---

## Validation Dashboard Structure

**Purpose**: Monitor data health, identify anomalies, and track data quality metrics
**Audience**: Data analysts, data engineers, compliance teams
**Refresh Interval**: 15 minutes (near real-time)
**Grid**: 4 columns × 6 rows

---

## Row 1: Header & Data Health Status

### Layout
```
[Data Validation Dashboard] | [Data Source Filter] [Date Range] [Severity Filter] [Refresh]
```

### Data Health Status Panel (Full Width Indicator)
```
Metric: Overall Data Quality Score
Visualization: Status Bar with Segments
Dimensions: Full width × 50px

Layout:
  [Data Completeness XX%] [Data Accuracy XX%] [Data Consistency XX%]
  [Timeliness XX%] [Data Freshness XX%]

Color Coding:
  ≥ 95%: Green
  85-94%: Amber
  < 85%: Red

Interactions:
  Click segment → Detailed metrics for that category
```

---

## Row 2: Key Validation KPIs (4 Cards)

#### KPI 1: Data Completeness Score
```
Metric: (Records with all required fields / Total Records) × 100
Source: Data_Validation_Fact.Completeness_Score
Visualization: KPI Card with Trend
Dimensions: 250px × 150px

Display Format:
  Primary Value: XX.X%
  Indicator: vs. Previous Day
  Status: "Complete" / "Warning" / "Critical"
  
Color Coding:
  ≥ 99%: Green
  95-98%: Amber
  < 95%: Red

Drill Path:
  Click → Completeness Issues by Field
  Show: Field name, % missing, impact score, affected tables
```

#### KPI 2: Data Accuracy Score
```
Metric: (Valid Records / Total Records) × 100
Source: Data_Validation_Fact.Accuracy_Score
Visualization: KPI Card with Gauge
Dimensions: 250px × 150px

Display Format:
  Primary Value: XX.X%
  Indicator: Validation Rules Passed
  Sub-text: "XX validation rules passed"
  
Color Coding:
  ≥ 99%: Green
  95-98%: Amber
  < 95%: Red

Data Elements:
  - Format validation (dates, numbers, patterns)
  - Range validation (values within expected bounds)
  - Referential integrity (foreign keys exist)
  - Business rule validation (domain constraints)

Drill Path:
  Click → Failed Validation Rules
  Show: Rule name, # of failures, % of data affected, rule logic
```

#### KPI 3: Data Consistency Score
```
Metric: (Consistent Cross-Source Records / Total Records) × 100
Source: Data_Validation_Fact.Consistency_Score
Visualization: KPI Card
Dimensions: 250px × 150px

Display Format:
  Primary Value: XX.X%
  Indicator: Reconciliation Status
  Sub-text: "Data consistent across sources"
  
Color Coding:
  ≥ 98%: Green
  90-97%: Amber
  < 90%: Red

Data Elements:
  - Duplicate detection
  - Cross-source reconciliation (matching values across systems)
  - Referential integrity
  - Relationship validation

Drill Path:
  Click → Consistency Issues Detail
  Show: Issue type, affected records, data sources, reconciliation status
```

#### KPI 4: Data Freshness Score
```
Metric: (Records updated within SLA / Total Records) × 100
Source: Data_Validation_Fact.Freshness_Score
Visualization: KPI Card with Alert
Dimensions: 250px × 150px

Display Format:
  Primary Value: XX.F%
  Indicator: Last Refresh Time
  Sub-text: "Updated XX minutes ago"
  
Color Coding:
  Updated today: Green
  Updated < 24hrs: Amber
  Updated > 24hrs: Red

Data Elements:
  - Last update timestamp per table
  - Refresh cycle compliance
  - SLA adherence

Drill Path:
  Click → Data Freshness Timeline
  Show: Table name, last update time, next scheduled update, status
```

---

## Row 3: Data Quality Trend Analysis (2 Charts)

#### Chart 1: Data Quality Score Trends (Line Chart)
```
Metric: Daily Data Quality Scores Over 30 Days
Source: Data_Validation_Fact (Daily aggregation)
Visualization: Line Chart with Shaded Zones
Dimensions: 600px × 280px (2-column wide)

Lines (Multiple):
  1. Completeness Score (Blue)
  2. Accuracy Score (Green)
  3. Consistency Score (Purple)
  4. Freshness Score (Orange)
  5. Overall Score (Bold Black)

Configuration:
  X-axis: Date (Last 30 days)
  Y-axis: Quality Score (0-100%)
  Reference Lines: SLA target (e.g., 95%)
  Grid: Minor gridlines
  
Shaded Zones:
  ≥ 95%: Green background
  85-94%: Yellow background
  < 85%: Red background

Data Labels:
  Show values for overall score
  Hover: All components for that day

Interactions:
  Click data point → Day detail (hourly breakdown)
  Legend toggle → Show/hide individual metrics
  Hover → Tooltip with all scores and trend vs previous day
```

#### Chart 2: Validation Rules Status (Stacked Bar)
```
Metric: Data Validation Rules - Pass/Fail Distribution
Source: Data_Validation_Rule_Execution
Visualization: Stacked Horizontal Bar Chart
Dimensions: 600px × 280px (2-column wide)

Rows (by Data Source):
  1. Finance System
  2. CRM System
  3. ERP System
  4. HR System
  5. Inventory System
  ... (configurable)

Bar Segments (color-coded):
  Green: Passed (XX rules)
  Yellow: Warning (XX rules - minor issues)
  Red: Failed (XX rules - critical issues)
  Gray: Not Applicable (XX rules)

Configuration:
  Total width: 100% of validation rules
  Segment width: % of rules passing/failing
  Labels: Show count in each segment
  Sort: By # of failed rules (descending)
  
Tooltip:
  Data Source Name
  Total Rules: XX
  Passed: XX (XX%)
  Warning: XX (XX%)
  Failed: XX (XX%)
  Last Check: [timestamp]

Interactions:
  Click bar → Validation rules detail for that source
  Click segment → Failed rules detail
  Drill → Individual rule failures and remediation
```

---

## Row 4: Data Quality Issues & Anomalies (2 Sections)

#### Section 1: Top Data Quality Issues (Table)
```
Metric: Most Critical Data Quality Issues
Source: Data_Validation_Issues
Visualization: Table with Severity Coloring
Dimensions: 600px × 300px (2-column wide, tall)

Columns:
  1. Issue ID
  2. Data Source
  3. Issue Type (Completeness, Accuracy, Consistency, Freshness)
  4. Severity (Critical/High/Medium/Low)
  5. Affected Records
  6. Impact Score
  7. Days Open
  8. Owner
  9. Status

Row Styling (by Severity):
  Critical: Red background
  High: Orange background
  Medium: Yellow background
  Low: White background

Configuration:
  Sort: By impact score (descending)
  Show: Top 10 issues (with pagination)
  Date filter: Show issues from last X days
  
Additional Indicators:
  Overdue icon: If open > SLA days
  Trend arrow: Growing/shrinking issue
  
Tooltip:
  Issue details
  Root cause (if documented)
  Remediation plan
  
Interactions:
  Click row → Issue detail page with remediation history
  Click owner → Owner's issue queue
  Filter: By severity, data source, status, days open
```

#### Section 2: Anomaly Detection & Outliers (Card Grid)
```
Metric: Data Anomalies Detected
Source: Data_Anomaly_Detection
Visualization: Alert Cards Grid
Dimensions: 600px × 300px (2-column wide, tall)

Card Layout (3 cards displayed):

Card 1: Statistical Outliers
  Icon: Scatter plot icon
  Title: "Outliers Detected"
  Count: "XX values out of range"
  Severity: Red/Yellow/Green
  Data: Field name, # outliers, % of records
  
Card 2: Pattern Breaks
  Icon: Line break icon
  Title: "Pattern Changes"
  Count: "XX anomalies in sequences"
  Severity: Red/Yellow/Green
  Data: Metric name, pattern, deviation
  
Card 3: Unexpected Spikes/Dips
  Icon: Chart icon
  Title: "Sudden Changes"
  Count: "XX metrics with unusual changes"
  Severity: Red/Yellow/Green
  Data: Metric name, % change, date detected

Interactions:
  Click card → Anomaly details and analysis
  See: Time series view, affected records, context
```

---

## Row 5: Data Source Health (2 Charts)

#### Chart 1: Data Source Connectivity Status (Gauge Set)
```
Metric: Data Source Connection Health
Source: Data_Pipeline_Health
Visualization: Multiple Small Gauges
Dimensions: Full width (600px × 250px, 2-column wide)

Layout: Grid of gauges (2 rows × 3 columns = 6 sources)

Per Gauge:
  Source: [System Name]
  Status: Connected/Failed/Warning
  Uptime %: [XX.X%]
  Last Successful Load: [timestamp]
  Data Latency: [XX minutes]
  
Color:
  Green: Connected, normal latency
  Yellow: Connected, high latency
  Red: Connection failed

Gauge Visual:
  Arc: 0-100% uptime
  Needle: Current uptime %
  Status icon: Circle indicator (green/yellow/red)

Interactions:
  Click gauge → Data source detail and connection logs
  Show: Historical uptime, incident history, SLAs
```

#### Chart 2: Data Pipeline Load Times (Column Chart)
```
Metric: Average Data Load Duration by Source
Source: Data_Pipeline_Execution
Visualization: Clustered Column Chart
Dimensions: Full width (600px × 250px, 2-column wide)

X-axis: Data Source (Finance, CRM, ERP, HR, Inventory, etc.)
Y-axis: Load Time (minutes)

Bars (Dual):
  Blue: Average load time
  Target line: SLA threshold (e.g., 30 minutes)

Color Coding (by bar height vs SLA):
  Green: Within SLA
  Yellow: 90-110% of SLA
  Red: > 110% of SLA

Data Labels:
  Show average time on bar
  Show SLA time as reference line
  
Configuration:
  Sort: By load time (longest first)
  Grid: Show minor gridlines
  
Tooltip:
  Source Name
  Avg Load Time: XX min
  Min/Max: XX-XX min
  SLA: XX min
  # Loads (period): XX
  SLA Compliance: XX%

Interactions:
  Click bar → Load history (daily trend)
  Drill → Individual load execution details
  Show: Data volume, record count, success rate
```

---

## Row 6: Data Quality Actions & Metrics (2 Sections)

#### Section 1: Remediation Queue (List)
```
Metric: Data Quality Remediation Actions
Source: Data_Quality_Remediation
Visualization: Table
Dimensions: 600px × 200px (2-column wide)

Columns:
  1. Remediation ID
  2. Issue
  3. Data Source
  4. Owner
  5. Priority
  6. Due Date
  7. Status (Not Started / In Progress / Complete)
  8. % Complete

Row Styling (Priority):
  Critical: Red
  High: Orange
  Medium: Yellow
  Low: White

Sort: By due date (overdue first)

Interactions:
  Click row → Remediation detail and activity history
  Status dropdown → Update status
  Owner link → Assign to person
```

#### Section 2: Data Quality Metrics Summary (KPI Set)
```
Metric: Key Data Metrics
Visualization: Mini KPI Tiles (2×2 grid)
Dimensions: 600px × 200px (2-column wide)

Tile 1: Total Records Validated
  Value: XXX,XXX,XXX
  Trend: vs yesterday
  
Tile 2: Validation Rules
  Value: XXX rules
  Status: XX% passing
  
Tile 3: Data Issues Resolved
  Value: XX%
  Period: This month
  
Tile 4: Data Quality Score
  Value: XX.X%
  Status: vs target

Interactions:
  Click tile → Detailed metrics
```

---

## Data Validation Rules Reference

| Rule Type | Description | Trigger | Impact |
|---|---|---|---|
| Null Check | Required fields populated | Empty value | Completeness |
| Format Validation | Dates, emails, phone numbers | Invalid pattern | Accuracy |
| Range Check | Values within min/max | Out of bounds | Accuracy |
| Uniqueness | No duplicates in unique fields | Duplicate found | Consistency |
| Referential Integrity | FK exists in parent table | Orphaned record | Consistency |
| Cross-Source Match | Values match across systems | Mismatch found | Consistency |
| Business Rules | Domain-specific logic | Logic violation | Accuracy |
| Data Freshness | Updated within SLA | Stale data | Freshness |
| Record Completeness | All required fields present | Missing fields | Completeness |
| Statistical Outlier | Beyond ±3 std dev | Outlier detected | Accuracy |

---

## Severity Levels & SLAs

| Severity | Issue Count SLA | Remediation SLA | Escalation |
|---|---|---|---|
| Critical | 0 tolerance | < 24 hours | Immediate to IT Director |
| High | < 100 records | < 48 hours | Next business day |
| Medium | < 1,000 records | < 5 business days | Weekly |
| Low | < 10,000 records | < 2 weeks | Monthly review |

---

## Performance & Optimization

- **Validation Frequency**: Every 15 minutes
- **Anomaly Detection**: Runs on hourly schedule
- **Issue Detection**: Real-time monitoring with alerts
- **Data Retention**: Issues tracked for 1 year (archived after)
- **Caching**: 5-minute incremental cache

---

## Alert Configuration

### Critical Alerts (Immediate Notification)
- Data quality score < 85%
- Validation rule failure > 1% of records
- Data source connectivity failure
- Data not loaded within 2x SLA
- > 100 high-severity issues

### High Alerts (Hourly Digest)
- Data quality score 85-90%
- Validation rule failure 0.5-1% of records
- Data latency > 1.5x SLA
- 10-100 high-severity issues

### Medium Alerts (Daily Digest)
- Minor completeness issues
- Individual anomalies detected
- Remediation overdue > 3 days

---

## Drill-Through Capabilities

1. **Quality Score** → Components breakdown
2. **Validation Rule** → Failed record details
3. **Data Issue** → Affected records and context
4. **Anomaly** → Time series and similar anomalies
5. **Data Source** → Connection logs and performance
6. **Remediation Item** → Action history and resolution path

