# Filters & Slicers Configuration

## Overview
This document defines the filter and slicer architecture for all Power BI dashboards, including filter types, placement, data sources, and interaction patterns.

---

## Filter Architecture

### Filter Hierarchy

#### Global Filters (All Dashboards)
Applied universally across all pages:
```
1. Date Range Picker (Mandatory)
   - Default: Current fiscal year
   - Range: 3-year history + 1-year forecast
   
2. Organization Level Filter (Optional)
   - Company/Division selector
   - Default: Logged-in user's division
```

#### Dashboard-Level Filters
Applied to specific dashboard:
```
3. Primary Category Filter
   - Varies by dashboard (see below)
   - Default: All or user preference
   
4. Secondary Filters (As needed)
   - Department/Region
   - Customer Segment
   - Product Line
```

#### Page-Level Filters (Advanced)
Applied to specific page within dashboard:
```
5. Drill-Down Filters
   - Shown when navigating to detail pages
   - Context-sensitive to parent page selection
```

---

## Dashboard-Specific Filters

### EXECUTIVE DASHBOARD

#### Primary Filters
```
1. Date Range Picker
   Type:           Date slicer (standard calendar)
   Position:       Top-right of header
   Default:        Last 12 months + current month
   Range Options:
     - Current Month
     - Current Quarter
     - Current Year
     - Last 12 Months
     - Custom Range (date picker)

2. Business Unit Filter
   Type:           Dropdown/List slicer
   Position:       Header, right of date picker
   Options:        All | Company Division A | Company Division B | Company Division C
   Default:        All (or logged-in user's division)
   Multi-select:   Yes

3. Region Filter (Optional)
   Type:           Dropdown/List slicer
   Position:       Header, right of business unit
   Options:        All | North America | Europe | Asia-Pacific | LATAM
   Default:        All
   Multi-select:   Yes
   Visibility:     Collapsed until needed
```

#### Filter Application
- KPI cards show global metrics or filtered subset
- Charts automatically update based on selected filters
- Time series show 12-month trend for selected period
- Drill-through maintains filter context

#### Filter Reset
```
Reset Button:
  Position:       Top-right next to filters
  Action:         Reset all slicers to default
  Visible:        When any filter is applied
```

---

### FINANCE DASHBOARD

#### Primary Filters
```
1. Date Range Picker
   Type:           Date slicer
   Default:        Current year + prior 2 years
   Presets:
     - Current Quarter
     - Current Fiscal Year
     - Last 12 Months
     - Last 24 Months
     - Custom Range

2. Organization/Department Filter
   Type:           Dropdown/Hierarchy slicer
   Position:       Header, left side
   Hierarchy:      Company > Division > Department
   Default:        All
   Multi-select:   Yes
   Drill-down:     Yes (show sub-departments)

3. GL Account Filter (Optional)
   Type:           Search slicer
   Position:       Header, expandable
   Options:        Search by account name or number
   Default:        All
   Usage:          For P&L analysis and variance investigation
```

#### Financial Period Selection
```
Period Selector:
  Type:           Button group or dropdown
  Options:
    - Monthly
    - Quarterly
    - Annually
  Default:        Monthly
  Affects:        Chart granularity and comparisons
  Position:       Header
```

#### Filter Application
- All financial metrics calculate based on selected period
- Comparative charts show period-over-period analysis
- Variance analysis filters by department and account
- Forecast updates based on selected GL accounts

---

### CUSTOMER DASHBOARD

#### Primary Filters
```
1. Date Range Picker
   Type:           Date slicer
   Default:        Last 12 months
   Presets:
     - Last 3 Months
     - Last 6 Months
     - Last 12 Months
     - Year-to-Date
     - Custom Range

2. Customer Segment Filter
   Type:           Dropdown/List slicer with hierarchy
   Position:       Header, left side
   Hierarchy:      Segment > Sub-segment > Product Line
   Options:        All | Premium | Standard | Basic
   Default:        All
   Multi-select:   Yes
   Expandable:     Yes

3. Region/Geography Filter
   Type:           Map-based slicer or dropdown
   Position:       Header, center
   Options:        All | Country | State/Province | City
   Default:        All
   Multi-select:   Yes
   Visual Feedback: Map highlights selected regions
```

#### Customer-Specific Filters
```
4. Customer Size Filter (Optional)
   Type:           Range slider or list slicer
   Options:        Small | Medium | Large | Enterprise
   Default:        All
   Position:       Secondary filter row (collapsed)

5. Acquisition Source Filter (Optional)
   Type:           Dropdown/List slicer
   Options:        All | Direct | Web | Partner | Referral | Other
   Default:        All
   Position:       Secondary filter row (collapsed)
```

#### Retention Cohort Analysis
```
Cohort Period Filter:
  Type:           Date slicer (months)
  Default:        Last 24 months
  Granularity:    Monthly cohorts
  Shows:          Customers acquired in selected month(s)
  Impact:         Retention heatmap updates to show cohort retention
```

#### Filter Application
- Customer count cards filter by segment and region
- Retention charts show cohort-specific retention rates
- RFM analysis filters to relevant customer groups
- Churn analysis filters to at-risk segments

---

### OPERATIONS DASHBOARD

#### Primary Filters
```
1. Date Range Picker
   Type:           Date slicer
   Default:        Current month + prior 3 months
   Presets:
     - Current Month
     - Current Quarter
     - Last 3 Months
     - Last 12 Months
     - Custom Range

2. Department/Team Filter
   Type:           Dropdown/Hierarchy slicer
   Position:       Header, left
   Hierarchy:      Department > Team > Individual
   Default:        All
   Multi-select:   Yes
   Expandable:     Yes
   Impact:         All metrics filter to selected departments

3. Process Type Filter
   Type:           Dropdown/List slicer
   Position:       Header, center
   Options:        All | [Specific Processes]
   Default:        All
   Multi-select:   Yes
   Usage:          Filter efficiency and SLA metrics by process
```

#### Location/Regional Filters
```
4. Region Filter
   Type:           Map-based slicer
   Position:       Header, right
   Default:        All
   Multi-select:   Yes
   Visual:         Map highlights selected locations
   
5. Facility/Office Filter
   Type:           Dropdown/Hierarchy slicer
   Hierarchy:      Region > City > Facility
   Default:        All
   Multi-select:   Yes
   Dependent:      Sub-filters based on region selection
```

#### Performance Level Filter
```
6. SLA Tier Filter (Optional)
   Type:           Dropdown/List slicer
   Options:        All | Tier 1 (Critical) | Tier 2 (High) | Tier 3 (Standard)
   Default:        All
   Usage:          Filter to specific SLA service levels
```

#### Filter Application
- Performance metrics aggregate by department selection
- Processing time benchmarks compare across departments
- Error rates drill-down by team and process
- SLA compliance shows by tier and region
- Cost metrics adjust based on facility/location

---

### GOVERNANCE DASHBOARD

#### Primary Filters
```
1. Date Range Picker
   Type:           Date slicer
   Default:        Current year + prior year
   Presets:
     - Current Quarter
     - Current Year
     - Year-to-Date
     - Last 12 Months
     - Last 24 Months

2. Governance Domain Filter
   Type:           Dropdown/List slicer
   Position:       Header, left
   Options:        All | Regulatory | Operational | Financial | Data Privacy | IT Security
   Default:        All
   Multi-select:   Yes
   Impact:         All compliance and risk metrics filter to selected domains
```

#### Risk & Compliance Filters
```
3. Risk Category Filter
   Type:           Dropdown/List slicer
   Options:        All | Operational Risk | Financial Risk | Compliance Risk | Strategic Risk
   Default:        All
   Multi-select:   Yes

4. Risk Level Filter (Status)
   Type:           Dropdown/List slicer
   Options:        All | High | Medium | Low | Resolved
   Default:        All (or exclude Resolved)
   Multi-select:   Yes
   Impact:         Risk heatmap filters to selected risk levels
```

#### Audit & Controls Filters
```
5. Audit Type Filter
   Type:           Dropdown/List slicer
   Options:        All | Internal Audit | External Audit | SOX Audit | Regulatory Audit | Management Review
   Default:        All
   Multi-select:   Yes

6. Audit Status Filter
   Type:           Dropdown/List slicer
   Options:        All | Planned | In Progress | Completed | Reported | Closed
   Default:        In Progress | Completed
   Multi-select:   Yes
   Visibility:     Show in-progress and recently completed
```

#### Remediation Filters
```
7. Finding Status Filter
   Type:           Dropdown/List slicer
   Options:        All | Open | In Remediation | Resolved | Deferred
   Default:        Open | In Remediation
   Multi-select:   Yes
   Impact:         Remediation status chart updates accordingly
```

#### Filter Application
- Compliance score filters by governance domain
- Risk register filters by category and level
- Audit findings filter by type and status
- Remediation actions filter by finding status and age
- Policy exceptions filter by exception type and approval status

---

## Slicer Design Specifications

### Slicer Dimensions
```
Header Slicer (Date, Primary):
  Width:        200-250px
  Height:       36px
  Font Size:    12px

Dropdown/List Slicer (Secondary):
  Width:        150-200px
  Height:       36px
  Font Size:    11px
  
Range Slider:
  Width:        250-300px
  Height:       40px
  
Map Slicer:
  Width:        Full width or 400px
  Height:       300-400px
```

### Slicer Styling

#### Default State
```
Background:       White (#FFFFFF)
Border:           1px solid #D3D3D3
Border-radius:    4px
Padding:          8px 12px
Font Color:       #333333
Font Weight:      Regular (400)
Cursor:           pointer
```

#### Hover State
```
Background:       #F5F5F5 (Light Gray)
Border:           1px solid #B3B3B3
Shadow:           0 2px 4px rgba(0,0,0,0.1)
Cursor:           pointer
```

#### Selected State
```
Background:       #E3F2FD (Light Blue)
Border:           1px solid #2196F3
Font Color:       #1565C0
Font Weight:      SemiBold (600)
Left Border:      4px solid #2196F3
```

#### Expanded/Open State
```
Border:           1px solid #2196F3
Shadow:           0 4px 12px rgba(0,0,0,0.12)
Z-index:          100
Dropdown:         Slides down with 200ms animation
```

### Slicer Placement Standards

#### Header Row (Fixed Position)
```
Height:           50px
Background:       #F8F8F8
Border-bottom:    1px solid #E0E0E0
Padding:          8px 20px
Alignment:        Flex row, space-between

Left Section:     Date + Primary filters
Right Section:    Secondary filters + Reset button
Gap:              15px between slicers
```

#### Secondary Row (Collapsible)
```
Background:       #FAFAFA
Border-bottom:    1px solid #E8E8E8
Padding:          8px 20px
Visible:          When "Show More Filters" clicked
Collapse/Expand:  Smooth transition (250ms)
```

---

## Filter Interactions

### Multi-Select Behavior
```
Default:           Multi-select enabled
Display:           "X items selected" when multiple
Expand List:       Show all options on click
Search:            Type to filter option list
Clear All:         Button to deselect all items
Select All:        Button to select all items (if not default)
Maintain State:    Selections persist during session
```

### Dependent Filters (Cascading)
```
Pattern: Region → City → Facility

When Region Selected:
  - City filter auto-populates with cities in region
  - Facility filter shows facilities in selected cities
  - Other fields lock to maintain data consistency

When Department Selected (Operations):
  - Team filter shows teams within department
  - Process filter shows processes handled by team
  - Disabled fields reset to "All"
```

### Date Picker Behavior
```
Default Display:  Calendar with preset ranges
Presets Shown:    Quick-select buttons (Today, This Month, etc.)
Range Selection:  Click start date, then end date
Custom Range:     Text input or calendar picker
Validation:       End date must be after start date
Apply Button:     Explicit "Apply" or auto-apply on selection
Clear Button:     Reset date filter to default
```

### Filter State Persistence
```
Session Level:    Filters persist during user session
Load Filters:     Save current filter state
Export:           Include filter selections in exports
Share:            Pass filter state in shared link
Bookmarks:        Save named filter combinations
  Example: "Monthly Summary", "Quarterly Deep Dive", "YTD Analysis"
```

---

## Filter Performance Optimization

### Query Optimization
```
Filter Order (for performance):
  1. Date range (most selective)
  2. Organization/Department
  3. Category/Segment
  4. Status/Type
  5. Other attributes

Index Strategy:
  - Pre-aggregate fact tables by common filter combinations
  - Create dimension tables with filter hierarchies
  - Index on key filter columns
```

### Lazy Loading
```
Slicer Lists:
  - Initially load top 20-50 values
  - Search triggers full list load
  - Scroll loads next batch (if >100 items)

Visualizations:
  - Load above-fold visualizations first
  - Below-fold visualizations load on scroll
  - Detail pages load on demand
```

### Caching Strategy
```
Cache Filter Selections:  30 minutes
Cache Query Results:      5-15 minutes (varies by dashboard)
Invalidate Cache:         On data refresh
Manual Refresh:           "Refresh Data" button available
```

---

## Filter Best Practices

### User Experience
- [ ] Keep primary filters to 3 or fewer (header row)
- [ ] Secondary filters in collapsible panel
- [ ] Always provide "All" option as default
- [ ] Show selected filter count visually
- [ ] Enable type-ahead search for long lists
- [ ] Disable unavailable options (not grayed out)
- [ ] Show loading indicator during filter application
- [ ] Provide undo/reset option

### Accessibility
- [ ] All slicers keyboard-navigable (Tab, Enter, Arrow keys)
- [ ] Label each slicer clearly
- [ ] Aria-labels for screen readers
- [ ] Contrast ratios meet WCAG AA
- [ ] Focus indicator visible on all interactive elements
- [ ] Date picker supports text input (YYYY-MM-DD format)

### Data Quality
- [ ] Filter lists sorted alphabetically or by frequency
- [ ] No duplicate values in filter lists
- [ ] Handle null/missing values explicitly
- [ ] Show count of records per filter option
- [ ] Warn users if filter results in empty dataset
- [ ] Log filter selections for analysis

---

## Filter Implementation Checklist

- [ ] Date range picker created for all dashboards
- [ ] Primary filters configured per dashboard spec
- [ ] Secondary filters in collapsible panels
- [ ] Dependent filters (cascading) configured
- [ ] Filter styling applied consistently
- [ ] Hover/selected states working
- [ ] Multi-select tested
- [ ] Filter persistence working
- [ ] Bookmarks created for common filter combinations
- [ ] Performance tested with full datasets
- [ ] Accessibility verified (keyboard navigation, screen reader)
- [ ] Error handling for empty results
- [ ] Reset button working and visible when needed
- [ ] Drill-through maintains filter context
