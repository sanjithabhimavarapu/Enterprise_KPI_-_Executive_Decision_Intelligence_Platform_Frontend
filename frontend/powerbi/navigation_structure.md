# Navigation Structure

## Overview
This document defines the complete navigation architecture, menu structure, and navigation patterns for the Enterprise KPI Platform, including page hierarchy, breadcrumbs, and drill-through paths.

---

## Navigation Hierarchy

### Top-Level Navigation

#### Main Dashboard Menu
```
Home (Landing Page)
├── Executive Dashboard
├── Finance Dashboard
├── Customer Dashboard
├── Operations Dashboard
└── Governance Dashboard
```

#### User Menu
```
Help & Support
├── Documentation
├── FAQs
├── Contact Support
└── Version Info

Settings
├── Preferences
├── Theme (Dark/Light)
├── Export Settings
└── Refresh Schedule

User Profile
├── My Account
├── Change Password
├── Notification Preferences
└── Sign Out
```

---

## Dashboard Architecture

### Executive Dashboard Navigation

```
EXECUTIVE DASHBOARD (Primary Landing)
│
├── [Row 2] KPI Cards - Click for Detail
│   ├── Revenue → Revenue Detail Page
│   ├── Profit Margin → Profitability Detail Page
│   ├── Customer Satisfaction → NPS Detail Page
│   └── Market Share → Market Position Detail Page
│
├── [Row 3] Trend Charts - Click for Drill-Down
│   ├── Revenue Growth Chart → Monthly Revenue Detail
│   └── Profitability Trend → Quarterly Profit Analysis
│
├── [Row 4] Business Health
│   ├── Department Performance Matrix
│   │   └── Click Row → Department Detail Dashboard
│   ├── Regional Sales Map
│   │   └── Click Region → Regional Detail Dashboard
│   └── Alerts Panel
│       └── Click Alert → Associated Detail Page
│
└── Navigation Breadcrumb: Home > Executive Dashboard
```

---

### Finance Dashboard Navigation

```
FINANCE DASHBOARD
│
├── Financial KPI Cards [Row 2] - Clickable
│   ├── Revenue Card → Revenue Breakdown by Product
│   ├── EBITDA Card → EBITDA Drivers Analysis
│   ├── Cash Flow Card → Cash Flow Waterfall Detail
│   └── Margin Card → Margin Expansion Opportunities
│
├── Revenue Composition Chart [Row 3.1]
│   └── Click Product Segment → Product Revenue Detail Page
│
├── Expense Breakdown Chart [Row 3.2]
│   └── Click Expense Category → Expense Detail by GL Account
│
├── Cash Flow Waterfall [Row 4.1]
│   └── Click Component → Component Detail and Transaction List
│
├── Financial Forecast [Row 4.2]
│   └── Click Forecast Point → Forecast Assumptions Editor
│
└── P&L Comparison Chart [Row 4.3]
    └── Click Metric → Period-Specific Analysis
    
Navigation Breadcrumb: Home > Finance Dashboard > [Current Page]
```

---

### Customer Dashboard Navigation

```
CUSTOMER DASHBOARD
│
├── Customer KPI Cards [Row 2] - Clickable
│   ├── Total Customers → Customer List by Segment
│   ├── Retention Rate → Retention Cohort Heatmap
│   ├── Churn Rate → Churned Customer Analysis
│   └── NPS Score → NPS Response Analysis
│
├── Customer Acquisition Trend [Row 3.1]
│   └── Click Month → New Customer List for Month
│
├── Retention Cohort Heatmap [Row 3.2]
│   └── Click Cell → Customer Cohort Detail
│
├── Customer Segmentation Pie [Row 4.1]
│   └── Click Segment → Customer List for Segment
│
├── CLV Distribution Histogram [Row 4.2]
│   └── Click Bar → Customers in CLV Range
│
└── RFM Analysis Bubble Chart [Row 4.3]
    └── Click Bubble → Individual Customer Analysis
    
Navigation Breadcrumb: Home > Customer Dashboard > [Current Page]
```

---

### Operations Dashboard Navigation

```
OPERATIONS DASHBOARD
│
├── Operations KPI Cards [Row 2] - Clickable
│   ├── Efficiency Index → Efficiency Driver Analysis
│   ├── Processing Time → Process Benchmark Comparison
│   ├── Error Rate → Error Root Cause Analysis
│   └── Capacity Utilization → Resource Allocation Detail
│
├── Department Performance Matrix [Row 3.1]
│   ├── Click Row → Department Detail Dashboard
│   └── Click Sparkline → Monthly Trend for Metric
│
├── Process Efficiency Trends [Row 3.2]
│   └── Click Metric → Detailed Efficiency Analysis
│
├── Regional Operations Map [Row 4.1]
│   └── Click Region → Regional Performance Detail
│
├── SLA Compliance Chart [Row 4.2]
│   └── Click Segment → SLA Compliance Detail
│
└── Cost Per Transaction Trend [Row 4.3]
    └── Click Point → Cost Breakdown Analysis
    
Navigation Breadcrumb: Home > Operations Dashboard > [Current Page]
```

---

### Governance Dashboard Navigation

```
GOVERNANCE DASHBOARD
│
├── Governance KPI Cards [Row 2] - Clickable
│   ├── Compliance Score → Compliance Detail by Domain
│   ├── Risk Level → Risk Register View
│   ├── Audit Status → Audit Progress Tracking
│   └── Policy Adherence → Policy Exception List
│
├── Risk Heatmap [Row 3.1]
│   └── Click Cell → Risk Details and Mitigation Plans
│
├── Compliance Violations [Row 3.2]
│   └── Click Violation → Incident Detail and Resolution
│
├── Audit Trail Status [Row 4.1]
│   └── Click Node → Audit Details and Schedule
│
├── Policy Exceptions [Row 4.2]
│   └── Click Exception → Approval Workflow
│
└── Remediation Status [Row 4.3]
    └── Click Finding → Remediation Plan and Actions
    
Navigation Breadcrumb: Home > Governance Dashboard > [Current Page]
```

---

## Drill-Through Navigation

### Drill-Through Pattern

```
Level 1: Summary Dashboard
  ↓ (Click visualization)
Level 2: Department/Segment Detail
  ↓ (Click specific item)
Level 3: Product/Customer/Process Detail
  ↓ (Click drill-down button)
Level 4: Transaction Level Data
  ↓ (Click transaction)
Level 5: Transaction Detail with Related Items
```

### Revenue Drill-Through Example
```
Executive Dashboard
  → Total Revenue Card (Click)
  
Revenue Detail Page 1 - By Product Line
  Revenue by Product (Stacked Bar)
  → Click Product A
  
Revenue Detail Page 2 - By Customer Segment
  Revenue by Top 10 Customers
  → Click Top Customer
  
Revenue Detail Page 3 - Transaction List
  Individual Transactions for Customer
  → Click Transaction ID
  
Revenue Detail Page 4 - Transaction Analysis
  Single Transaction Details + Related Orders
```

### Maintaining Filter Context in Drill-Through
```
When drilling through, filters carry forward:
  
Starting filters: Q1 2026 | Region: North America | Division: Sales
  ↓
Detail page automatically filters to:
  Date: Q1 2026
  Region: North America
  Division: Sales
  
User can modify filters on detail page without affecting parent page
```

---

## Page Navigation Menu

### Header Navigation Bar

```
┌───────────────────────────────────────────────────────────────┐
│ [Logo]  Dashboard Title        [Slicer Controls]   [≡ Menu]  │
└───────────────────────────────────────────────────────────────┘
```

#### Menu Structure (Hamburger/Sidebar)
```
Main Navigation Menu (Opens on hamburger icon click)
├── Home / Dashboard Selector
│   ├── Executive Dashboard
│   ├── Finance Dashboard
│   ├── Customer Dashboard
│   ├── Operations Dashboard
│   └── Governance Dashboard
├── Favorites
│   ├── [User-saved pages]
├── Recent Pages
│   ├── [Last 5 viewed pages]
├── Help & Support
│   ├── Documentation
│   ├── FAQs
│   └── Contact Support
├── Settings
│   ├── Preferences
│   ├── Theme
│   └── Data Refresh
└── User Account
    ├── Profile
    └── Sign Out
```

#### Menu Behavior
```
Default:          Collapsed (hamburger icon)
Trigger:          Click hamburger icon (≡)
Animation:        Slide-in from left (250ms)
Overlay:          Semi-transparent background (#000 with 40% opacity)
Close:            Click close button, click overlay, or navigate
Mobile:           Always accessible via hamburger
Desktop:          Hamburger or persistent sidebar option
Width:            Sidebar 280px when expanded
Z-index:          1000 (above all content)
```

---

## Breadcrumb Navigation

### Breadcrumb Display

```
Position:          Below header, above page title
Format:            Home > Dashboard > Page > Section
Separator:         " > " (with spaces)
Background:        #F8F8F8
Padding:           8px 20px
Font Size:         12px
```

### Breadcrumb Example Paths

#### Executive Dashboard
```
Home > Executive Dashboard
Home > Executive Dashboard > Revenue Analysis
Home > Executive Dashboard > Department Performance > Sales Dept
```

#### Finance Dashboard with Drill-Through
```
Home > Finance Dashboard
Home > Finance Dashboard > Revenue Breakdown
Home > Finance Dashboard > Revenue Breakdown > Product Details
Home > Finance Dashboard > Revenue Breakdown > Product Details > Transaction List
```

#### Customer Dashboard
```
Home > Customer Dashboard
Home > Customer Dashboard > Retention Analysis
Home > Customer Dashboard > Retention Analysis > Premium Segment
Home > Customer Dashboard > Retention Analysis > Premium Segment > Individual Customer
```

### Breadcrumb Interactions

```
Home Link:
  Click → Return to main dashboard selector
  
Dashboard Link:
  Click → Return to main dashboard page
  
Current Page:
  Text only (not clickable)
  Displays current location in hierarchy
  
Intermediate Pages:
  Clickable links to return to that page
  Maintain filter context
```

---

## Bookmark Navigation

### Saved Bookmarks (Preset Filter Views)

Each dashboard includes pre-configured bookmarks:

#### Executive Dashboard Bookmarks
```
Bookmarks Available:
├── All Time (Default)
│   Filters: All regions, all divisions, all time
│   
├── This Month
│   Filters: Current month, all divisions
│   
├── This Quarter
│   Filters: Current quarter, all divisions
│   
├── Year-to-Date
│   Filters: YTD period, all divisions
│   
└── Top Performers
    Filters: Top 10% by KPI achievement
```

#### Finance Dashboard Bookmarks
```
├── Monthly P&L
│   Filters: Current month, all departments
│   
├── Quarterly Summary
│   Filters: Current quarter, revenue/EBITDA focus
│   
├── Variance Analysis
│   Filters: Actual vs. Budget, unfavorable only
│   
├── Cash Flow Focus
│   Filters: Operating/Investing/Financing flows
│   
└── YTD Performance
    Filters: Year-to-date, all GL accounts
```

#### Customer Dashboard Bookmarks
```
├── All Customers
│   Filters: All segments, all regions
│   
├── Premium Segment
│   Filters: Premium customers only
│   
├── At-Risk Retention
│   Filters: Customers with declining retention
│   
├── High CLV Analysis
│   Filters: Top 20% by CLV
│   
└── Recent Acquisitions
    Filters: Last 30 days acquired customers
```

### Bookmark Access
```
Location:        Top-right corner of dashboard or in sidebar
Display:         Dropdown menu with bookmark list
Default:         First bookmark selected on load
Create Custom:   "Save Current View as Bookmark" option
Edit:            Rename, delete, or update bookmarks
Share:           Email link with bookmark preset
```

---

## Search & Discovery

### Global Search

```
Search Box Location:  Header, left of user menu
Placeholder Text:    "Search dashboards, metrics, pages..."
Behavior:            Type to search
Search Scope:        
  - Page names
  - Dashboard names
  - Metric names
  - KPI descriptions
  - Related documentation

Search Results Display:
  ├── Dashboards (if match)
  ├── Pages (if match)
  ├── Metrics (if match)
  └── Help Articles (if match)

Keyboard Shortcut:   Ctrl+K (or Cmd+K)
```

### Filter Search (in slicers)
```
Feature:         Type-ahead search in dropdown slicers
Trigger:         Start typing in slicer
Matching:        Partial string match
Results:         Filter list to matching items
Clear:           Esc key clears search text
```

---

## Navigation Flow Diagrams

### New User Onboarding Path

```
Login Page
  ↓
Dashboard Selector (Home Page)
  "Welcome! Select a dashboard to begin"
  ↓
Selected Dashboard
  Tutorial tooltip on first visit
  "This is [Dashboard Name]. Click [Element] to explore..."
  ↓
Guided Tour (Optional)
  Interactive highlights of key features
  ↓
Main Dashboard View
```

### Power User Advanced Navigation

```
Executive Dashboard (Current)
  [Multi-level drill]
  ↓
Revenue Detail (Page 2)
  [Advanced filters applied]
  ↓
Customer Revenue Analysis (Page 3)
  [Export data]
  → Finance Dashboard (Via search or menu)
  ↓
Customer Profitability (Finance Page 2)
  [Link historical data]
  → Customer Dashboard (Via related links)
  ↓
Customer Lifetime Value Analysis (Customer Page 3)
```

---

## Mobile Navigation

### Mobile Menu Structure

```
Menu Button (Hamburger) at Top-Left
  ↓
Collapsible Sidebar (Full Height)
  Dashboard Selector (Scrollable)
  ├── Executive Dashboard
  ├── Finance Dashboard
  ├── Customer Dashboard
  ├── Operations Dashboard
  └── Governance Dashboard
  
  Recent Pages
  └── [List of recent]
  
  Help & Settings
  ├── Help
  ├── Settings
  └── Sign Out
```

### Mobile Drill-Through
```
Tap visualization
  ↓
Navigation Options Dialog
  "Select an option:"
  ├── View Details
  ├── Drill Down
  └── Cancel
  ↓
Detail Page (Full Screen)
  Back button (← ) at top-left
  Can swipe back to return
```

### Mobile Tabs/Scrolling
```
Dashboard pages: Horizontal scrolling or tab navigation
Charts: Swipe left/right to compare
Tables: Horizontal scroll for columns
Slicers: Collapsed by default (tap to expand)
```

---

## Accessibility Navigation

### Keyboard Navigation

#### Tab Order
```
Focus sequence (logical flow):
1. Logo/Home button
2. Page title
3. Date range slicer
4. Primary filters (left to right)
5. Reset button
6. Visualization 1
7. Visualization 2
8. ... (remaining visualizations)
9. User menu
```

#### Keyboard Shortcuts
```
Ctrl+K (Cmd+K):    Open global search
Ctrl+B:            Toggle sidebar
Ctrl+H:            Open help
Esc:               Close menus/dialogs
Enter:             Select focused item
Arrow Keys:        Navigate slicer options
Tab:               Next focusable element
Shift+Tab:         Previous focusable element
```

### Screen Reader Navigation
```
Page Regions (Aria-landmarks):
  <header> → Page header with navigation
  <nav> → Main navigation menu
  <main> → Primary content
  <aside> → Sidebar filters (if present)
  <footer> → Footer with timestamp

Labels & Descriptions:
  All navigation items labeled
  Breadcrumbs announced as navigation
  Current page highlighted in menu
  Links include context (e.g., "Revenue Analysis" not "Click here")
```

---

## Navigation Performance

### Page Load Strategy
```
Priority 1 (Load Immediately):
  - Navigation header
  - Breadcrumbs
  - Filter controls
  
Priority 2 (Load Next):
  - Above-fold visualizations
  - KPI cards
  
Priority 3 (Load After):
  - Below-fold charts
  - Detail tables
  
Priority 4 (Load on Demand):
  - Related visualizations
  - Drill-through pages
```

### Navigation Caching
```
Cache Navigation State:  Session (persist during user session)
Cache Page Data:         5-15 minutes (varies)
Back Button Behavior:    Restore previous state and filters
Forward Button:          Return to cached state if available
Hard Refresh (F5):       Clear cache and reload
```

---

## Navigation Implementation Checklist

**Dashboard Navigation:**
- [ ] Main menu with all 5 dashboards created
- [ ] Dashboard selector landing page functional
- [ ] Quick access buttons for recent dashboards
- [ ] Navigation header consistent across all pages

**Drill-Through Navigation:**
- [ ] Drill-through paths configured for all KPI cards
- [ ] Drill-through maintains filter context
- [ ] Back button returns to parent page with filters
- [ ] Breadcrumbs update correctly on drill-through

**Breadcrumb Navigation:**
- [ ] Breadcrumbs display correct hierarchy
- [ ] All breadcrumb links clickable and functional
- [ ] Intermediate pages accessible from breadcrumbs
- [ ] Current page highlighted (not clickable)

**Bookmark Navigation:**
- [ ] Bookmarks created per dashboard
- [ ] Bookmarks load correct filter combinations
- [ ] Create/save bookmark functionality working
- [ ] Bookmark sharing via URL working

**Mobile Navigation:**
- [ ] Hamburger menu responsive on mobile
- [ ] Touch targets minimum 44px × 44px
- [ ] Menu closes when item selected
- [ ] Back navigation intuitive on mobile

**Accessibility:**
- [ ] Tab order logical and complete
- [ ] Keyboard shortcuts functional
- [ ] Screen reader navigation tested
- [ ] Focus indicators visible on all elements
- [ ] ARIA labels applied to all navigation items

**Search & Discovery:**
- [ ] Global search functional
- [ ] Search results relevant
- [ ] Keyboard shortcut (Ctrl+K) working
- [ ] Slicer search (type-ahead) working

**Performance:**
- [ ] Page transitions smooth (< 500ms)
- [ ] Navigation state persists correctly
- [ ] Back/forward buttons work reliably
- [ ] Cache strategy optimized
