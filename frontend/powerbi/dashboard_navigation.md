# Dashboard Navigation - Complete Guide

## Overview
This document defines the complete navigation architecture for the Enterprise KPI Platform Power BI dashboards, including page hierarchy, navigation controls, and user flows.

---

## NAVIGATION ARCHITECTURE

### Dashboard Hierarchy (5 Levels)

```
Level 1: Landing Page
    ├─ Welcome / Home
    └─ Quick Links to all dashboards

Level 2: Main Dashboards (4)
    ├─ Executive Dashboard (Strategic Overview)
    ├─ Finance Dashboard (Financial Analysis)
    ├─ Customer Dashboard (Customer Metrics)
    └─ Operations Dashboard (Operational KPIs)

Level 3: Analysis Pages (Sub-sections of main dashboards)
    ├─ Revenue Detail (under Finance)
    ├─ Expense Analysis (under Finance)
    ├─ Customer Segments (under Customer)
    ├─ Process Efficiency (under Operations)
    └─ ... (more detail pages)

Level 4: Drill-Through Pages (Detail focus)
    ├─ Revenue by Product
    ├─ Revenue by Customer
    ├─ Customer Lifetime Value Detail
    ├─ Order Transaction Detail
    └─ ... (more drill pages)

Level 5: Reference/Support Pages
    ├─ KPI Definitions
    ├─ Data Dictionary
    ├─ Help & Troubleshooting
    └─ About / Contact
```

---

## NAVIGATION CONTROLS DESIGN

### 1. Top Navigation Bar (Header - All Pages)

#### Layout
```
┌─────────────────────────────────────────────────────────────────┐
│ Logo    Dashboard Title       Date Filter    Refresh    Help    │
│ [≡]     [Title]              [DD/MM/YYYY]   [↻]        [?]      │
└─────────────────────────────────────────────────────────────────┘
```

#### Components

**Logo & Menu Button (Left)**
```
Image: Company logo (100px × 40px)
Button: Hamburger menu (≡)
  - Click → Toggle sidebar navigation
  - Keyboard: Esc to close
  - Mobile: Always expanded
```

**Dashboard Title (Dynamic)**
```
Formula: SELECTEDVALUE(Dashboard[Name])
Font: 24pt Bold, Primary Color
Examples:
  - "Executive Dashboard"
  - "Financial Dashboard"
  - "Customer Dashboard"
```

**Date/Period Selector (Center)**
```
Type: Dropdown button
Default: Current Period (YTD)
Options: Last Month, YTD, Last Quarter, Last Year, Custom
Format: "Period: May 2026 (YTD)"
Action: Updates all charts on current page
```

**Refresh Button**
```
Type: Icon button (↻)
Position: Right side
Tooltip: "Refresh Data (Last update: HH:MM)"
Action: Manual refresh of data
Color: Green if last < 1hr, Yellow 1-4hr, Red > 4hr
```

**Help Button**
```
Type: Icon button (?)
Action: Opens help sidebar or tooltip
Links to: KPI definitions, FAQ, support
```

---

### 2. Sidebar Navigation (Left - Collapsible)

#### Structure
```
┌──────────────────────────┐
│ ☰ MENU                   │
├──────────────────────────┤
│ 🏠 Home                  │
├──────────────────────────┤
│ 📊 MAIN DASHBOARDS       │
│   ► Executive            │
│   ► Finance              │
│   ► Customer             │
│   ► Operations           │
├──────────────────────────┤
│ 🔍 ANALYSIS PAGES        │
│   ► Revenue Detail       │
│   ► Expense Analysis     │
│   ► Customer Segments    │
│   ► Efficiency Trends    │
├──────────────────────────┤
│ ❓ HELP & SUPPORT        │
│   ► KPI Definitions      │
│   ► Data Dictionary      │
│   ► Troubleshooting      │
│   ► Contact Us           │
└──────────────────────────┘
```

#### Sidebar Configuration (Power BI)

```
Width: Collapsed = 50px | Expanded = 250px
Position: Left side, sticky
Background: Dark (#2C3E50)
Text: Light (#ECEFF1)
Hover: Light gray background (#34495E)

Animation: Smooth slide (300ms)
Mobile: Always full width
```

#### Navigation Items (Buttons)

```
Each Menu Item:
├─ Icon (30×30px)
├─ Label (text, 12pt)
├─ Active state: Bold text + highlight
├─ Hover state: Background color change
└─ Click: Navigate to page

Examples:
┌─────────────────────────────┐
│ 📊 Executive Dashboard      │  ← Current page (highlighted)
│ 💰 Finance Dashboard        │
│ 👥 Customer Dashboard       │
│ ⚙️  Operations Dashboard    │
└─────────────────────────────┘
```

---

### 3. Breadcrumb Trail (Below Header)

#### Design
```
Home > Finance Dashboard > Revenue Detail > Revenue by Product
└─ Link    └─ Link           └─ Link          └─ Current (not link)

Separator: >
Color: Gray (#999999)
Links: Blue (#2196F3), underline on hover
```

#### DAX Breadcrumb Generation

```dax
Breadcrumb_Path = 
VAR CurrentPage = SELECTEDVALUE(PageMetadata[Page_Name])
VAR ParentPage = RELATED(PageMetadata[Parent_Page])
VAR RootPage = "Home"

RETURN
RootPage & " > " & ParentPage & " > " & CurrentPage
```

---

### 4. Page-Level Navigation Buttons

#### Location & Design
```
Position: Bottom-right of each page
Style: Outline buttons (not filled)
Size: 40×40px (icon only, expand on hover)
Spacing: 10px between buttons
```

#### Button Set

**Back Button**
```
Icon: ← (left arrow)
Tooltip: "Back to Previous Page"
Action: Navigate to parent page
Keyboard: Backspace key
Enabled: Only if parent page exists
```

**Home Button**
```
Icon: 🏠 (house)
Tooltip: "Go to Home"
Action: Navigate to landing page
Keyboard: Ctrl+Home
```

**Next Button**
```
Icon: → (right arrow)
Tooltip: "Go to Next Page"
Action: Navigate to next page in sequence
Keyboard: Right arrow
Enabled: Only if next page exists
```

**Print Button**
```
Icon: 🖨️ (printer)
Tooltip: "Print Current Dashboard"
Action: Opens print view
Keyboard: Ctrl+P
```

---

## NAVIGATION PAGE SPECIFICATIONS

### Home/Landing Page

#### Purpose
```
- Central hub for all dashboards
- Quick links to main reports
- Recent reports access
- Search functionality
- Latest updates/news
```

#### Layout (4×3 Grid)

```
┌────────────────────────────────────────────┐
│  Welcome to Enterprise KPI Platform        │
│  Last updated: May 29, 2026 | 2:30 PM     │
└────────────────────────────────────────────┘

┌─────────────┬─────────────┬─────────────┬──────────────┐
│ Executive   │ Finance     │ Customer    │ Operations   │
│ Dashboard   │ Dashboard   │ Dashboard   │ Dashboard    │
│             │             │             │              │
│ [TILE]      │ [TILE]      │ [TILE]      │ [TILE]       │
│ KPIs: 6     │ KPIs: 8     │ KPIs: 5     │ KPIs: 7      │
│ Updated: 1h │ Updated: 2h │ Updated: 1h │ Updated: 30m │
└─────────────┴─────────────┴─────────────┴──────────────┘

┌─────────────┬─────────────┬─────────────┐
│ Recent      │ Saved       │ Shared      │
│ Reports     │ Reports     │ with Me     │
│             │             │             │
│ Report 1    │ Report 2    │ Report 3    │
│ Report 4    │ Report 5    │ Report 6    │
└─────────────┴─────────────┴─────────────┘

┌──────────────────────────────────────────┐
│ Quick Search: [Search box]               │
│ Type KPI name or dashboard title...      │
└──────────────────────────────────────────┘
```

#### Tile Component Specifications

```
Tile Size: 150×120px
Border: 1px, light gray
Background: White with shadow
Hover: Slight elevation, blue border
Click: Navigate to dashboard

Content:
├─ Icon (32×32px, top-center)
├─ Title (14pt Bold)
├─ Subtitle (count of KPIs)
├─ Last Updated timestamp
└─ Status indicator (green/yellow/red)
```

---

## MAIN DASHBOARD NAVIGATION

### Executive Dashboard (Landing for C-Suite)

#### Quick Actions Menu
```
Visual: Buttons in header area

Action 1: Export to PowerPoint
├─ Icon: 📊
├─ Tooltip: "Export dashboard as PowerPoint"
└─ Action: Generate PPTX with current filters

Action 2: Schedule Email Report
├─ Icon: 📧
├─ Tooltip: "Email this dashboard daily"
└─ Action: Opens email schedule dialog

Action 3: Compare Periods
├─ Icon: 📈
├─ Tooltip: "Compare current vs prior period"
└─ Action: Adds prior period comparison view

Action 4: KPI Details
├─ Icon: ℹ️
├─ Tooltip: "Show KPI definitions"
└─ Action: Opens side panel with definitions
```

#### Navigation to Sub-Pages
```
From Executive Dashboard:

KPI Card Click → Finance Dashboard > Revenue Detail
├─ Trigger: Click on Revenue card
├─ Filter Applied: Same company/period
└─ Chart: Expanded revenue breakdown

Chart Click → Analysis Page
├─ Trigger: Click on trend chart
├─ Filter Applied: Selected month/period
└─ Drill: Product-level detail

Legend Click → Drill-Through
├─ Trigger: Click on legend item
├─ Example: Click "East Region" in geography filter
└─ Navigation: Open "Regional Performance" page
```

---

### Finance Dashboard (Main Analysis Hub)

#### Tab Navigation (Alternative to Pages)
```
Option 1: Page-Based Navigation
├─ Home > Finance > Revenue Detail
├─ Home > Finance > Expense Analysis
└─ Home > Finance > Forecast View

Option 2: Tab-Based Navigation (Same Page)
┌─────────┬────────┬──────────┬──────────┐
│ Overview│Revenue │ Expense  │ Forecast │
└─────────┴────────┴──────────┴──────────┘
└─ Allows faster switching
└─ Maintains filter state
```

#### Drill-Down Sequence
```
Level 1: Finance Dashboard (Summary)
  ↓ Click on Revenue card
Level 2: Revenue Detail Page
  ├─ Revenue by Product
  ├─ Revenue by Customer
  └─ Revenue by Region
  ↓ Click on Product bar
Level 3: Product Revenue Detail
  ├─ Orders for Product
  ├─ Customer distribution
  └─ Margin analysis
  ↓ Click on Order
Level 4: Order Transaction Detail (Drill-Through)
  ├─ Order line items
  ├─ Delivery status
  └─ Financial reconciliation
```

---

## NAVIGATION BOOKMARKS

### Bookmark Concept
```
Bookmarks: Save dashboard state for quick access
- Filter selections
- Slicer positions
- Visible/hidden visuals
- Zoom level
```

### Bookmark List (Executive Dashboard)

| Bookmark | Filters Applied | Use Case |
|---|---|---|
| **This Month** | Period = Current Month | Daily review |
| **YTD Summary** | Period = YTD | Monthly close |
| **vs Prior Year** | Period = YTD + Prior Year | Year-over-year analysis |
| **This Region** | Region = East US | Regional focus |
| **Top Products** | Product = Top 10 | Product analysis |
| **Deep Dive** | Show all detail visuals | Detailed exploration |
| **Print View** | Optimized for printing | Report generation |

#### Bookmark Navigation (Power BI)

```
Button Location: Right side of header
Style: Small square buttons (30×30px each)
Label: On hover, show bookmark name
Click: Load saved state

Example Button Row:
┌──────┬──────┬──────┬──────┬──────┐
│ This │ YTD  │ vs   │ This │ Top  │
│Month │Sum  │Prior │ Reg  │Prod │
└──────┴──────┴──────┴──────┴──────┘
```

#### DAX Bookmark State Tracking

```dax
// Current Bookmark Name
Current_Bookmark = 
    SELECTEDVALUE(Bookmarks[Bookmark_Name], "Custom View")

// Display bookmark in status bar
Bookmark_Status = 
    "View: " & [Current_Bookmark] 
    & " | Last Updated: " & FORMAT(NOW(), "HH:MM AM/PM")
```

---

## SEARCH & DISCOVERY

### Global Search Functionality

#### Search Bar (Top Header)
```
Position: Header, center-left area
Width: 250px
Placeholder: "Search KPIs, dashboards, reports..."
Icon: 🔍 (magnifying glass)
```

#### Search Results
```
Results Displayed:
├─ KPI Definitions (Top)
│  └─ Revenue, Profit Margin, Customer Churn
├─ Dashboards (Second)
│  └─ Financial Dashboard, Executive Dashboard
├─ Reports (Third)
│  └─ Monthly Close, Weekly Sales
└─ Pages (Bottom)
   └─ Revenue Detail, Customer Segments

Each Result:
├─ Name
├─ Description
├─ Type (KPI / Dashboard / Page)
├─ Last Updated
└─ Click to navigate
```

#### DAX Search Implementation

```dax
// Search Index Table
Search_Index = 
UNION(
    SELECTCOLUMNS(KPI_List, "Object_Name", [KPI_Name], "Type", "KPI", "Page", [Page_Name]),
    SELECTCOLUMNS(Dashboard_List, "Object_Name", [Dashboard_Name], "Type", "Dashboard", "Page", [Landing_Page]),
    SELECTCOLUMNS(Page_List, "Object_Name", [Page_Name], "Type", "Page", "Page", [Page_Name])
)

// Search Filter Measure
Search_Results = 
VAR SearchTerm = SELECTEDVALUE(Search[Input_Term])
RETURN
FILTER(
    Search_Index,
    CONTAINSSTRING([Object_Name], SearchTerm, TRUE())
)
```

---

## NAVIGATION PERMISSIONS & SECURITY

### Role-Based Navigation

#### Executive Role
```
Accessible Dashboards:
✓ Executive Dashboard (full)
✓ Finance Dashboard (summary only)
✓ Operations Dashboard (summary only)
✓ Home Page

Restricted:
✗ Detailed cost breakdowns
✗ Individual employee metrics
✗ Sensitive customer data
```

#### Finance Role
```
Accessible Dashboards:
✓ Executive Dashboard (view only)
✓ Finance Dashboard (full access)
✓ Analysis pages (all)
✓ Drill-through pages (all)

Restrictions:
✗ Customer confidential data
✗ Employee compensation
```

#### Analyst Role
```
Accessible:
✓ All dashboards (full access)
✓ All analysis pages
✓ All drill-through pages
✓ Data definition pages
```

#### DAX Row-Level Security (RLS)

```dax
// Filter visible data by user role
User_Role = USERPRINCIPALNAME()

// Allow access based on role
RLS_Filter = 
    IF(
        User_Role = "executive@company.com",
        [Dashboard_Type] = "Executive",
        IF(
            User_Role = "finance@company.com",
            [Dashboard_Type] IN {"Executive", "Finance"},
            TRUE()  -- Analysts see all
        )
    )
```

---

## MOBILE NAVIGATION

### Responsive Design

#### Mobile Layout Changes
```
Desktop (1920px):
├─ Sidebar navigation (250px)
├─ Main content area (full width)
└─ Multiple columns per row

Tablet (768px):
├─ Hamburger menu (sidebar hidden)
├─ Single column layout
├─ Larger touch targets (48×48px)
└─ Collapsible sections

Mobile (375px):
├─ Full-screen menu button (top-left)
├─ Vertical scrolling only
├─ Single column, no sidebars
├─ Large buttons (60×60px minimum)
└─ Simplified charts
```

#### Mobile Navigation Menu
```
Layout: Bottom sheet or full-screen overlay

Menu Items (Reordered by importance):
├─ My Dashboard (personalized)
├─ Alerts (if any)
├─ Executive Summary
├─ Recent Reports
├─ Finance Dashboard
├─ Customer Dashboard
├─ Operations Dashboard
├─ Search
└─ Help
```

---

## NAVIGATION BEST PRACTICES

### ✓ DO:
```
✓ Keep navigation consistent across all pages
✓ Show current location (breadcrumb/active state)
✓ Use clear, descriptive page titles
✓ Limit drill-down depth to 4 levels
✓ Provide "Back" button on detail pages
✓ Use bookmarks for common views
✓ Test on mobile devices
✓ Document navigation structure for users
✓ Include help/FAQ for complex navigation
✓ Track user navigation patterns
```

### ✗ DON'T:
```
✗ Don't hide main navigation controls
✗ Don't use unclear page names
✗ Don't allow endless drill-down
✗ Don't navigate without preserving filters
✗ Don't make navigation elements too small
✗ Don't change navigation structure frequently
✗ Don't disable back/home buttons
✗ Don't use auto-navigation on page load
✗ Don't create circular navigation loops
✗ Don't require multiple clicks for common actions
```

---

## TESTING NAVIGATION

### Navigation Test Plan

- [ ] All menu items navigate to correct page
- [ ] Breadcrumb shows correct path
- [ ] Back button returns to previous page
- [ ] Filters persist when navigating
- [ ] Bookmarks save and load correctly
- [ ] Search finds all relevant items
- [ ] Navigation works on mobile devices
- [ ] Active page highlighted in menu
- [ ] Page titles update dynamically
- [ ] Performance: page load < 3 seconds
- [ ] Keyboard shortcuts work
- [ ] Links and buttons are accessible
- [ ] Mobile touch targets 48×48px minimum

---

## NEXT STEPS

1. Design page hierarchy in Power BI
2. Create navigation buttons and menus
3. Set up bookmark save/load functionality
4. Implement search index and search visuals
5. Configure drill-through pages
6. Test navigation on desktop and mobile
7. Document user navigation guide
8. Gather feedback from test users
