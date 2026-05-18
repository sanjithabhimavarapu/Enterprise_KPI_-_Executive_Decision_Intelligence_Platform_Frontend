# KPI Card Layout Specification

## Overview
Defines the standardized KPI card design, layout patterns, and interaction behaviors for all Power BI dashboards.

---

## Card Design System

### Card Types

#### Type 1: Standard KPI Card (Single Metric)
**Use Case**: Primary performance indicators requiring quick visual scan
**Dimensions**: 250px width × 150px height

```
┌──────────────────────────────────────┐
│ [Icon] Metric Name        [⋯ More]  │  ← Header (30px)
├──────────────────────────────────────┤
│                                      │
│ $2,450,000                 ↑ 12.5%  │  ← Main value (40px) + Indicator (16px)
│ Current Period             YoY Δ    │
│                                      │
├──────────────────────────────────────┤
│ Target: $2,300,000 | Achievement: 109% │  ← Context line (14px)
│ Updated: 2 minutes ago               │  ← Timestamp (12px)
└──────────────────────────────────────┘
```

**Color Scheme**:
- **Header Background**: #F2F2F2
- **Main Content Background**: White
- **Border**: #D3D3D3 (1px)
- **Accent**: Primary color (blue, green, red based on status)

---

#### Type 2: Comparative KPI Card (Dual Metric)
**Use Case**: Comparing current period against baseline/target
**Dimensions**: 250px width × 150px height

```
┌──────────────────────────────────────┐
│ [Icon] Revenue             [⋯ More]  │
├──────────────────────────────────────┤
│ Current:  $2,450,000   Target: $2,300K│
│ YoY: +12.5% ↑         Status: On Track│
├──────────────────────────────────────┤
│ Achievement: 109%                    │
│ Last: 2 min ago                      │
└──────────────────────────────────────┘
```

---

#### Type 3: Mini KPI Tile (Compact)
**Use Case**: Secondary metrics in limited space or mobile views
**Dimensions**: 160px width × 100px height

```
┌──────────────────────┐
│ 87.5%                │
│ Retention Rate       │
│ ↑ 3.2%              │
└──────────────────────┘
```

---

#### Type 4: Status Card (Multi-Status)
**Use Case**: Showing distributed metrics across categories
**Dimensions**: 250px width × 150px height

```
┌──────────────────────────────────────┐
│ [Icon] Customer Segments   [⋯ More]  │
├──────────────────────────────────────┤
│ Premium:  2,450 (42%)  ● Green      │
│ Standard: 2,100 (35%)  ● Yellow     │
│ Basic:    1,450 (23%)  ● Blue       │
├──────────────────────────────────────┤
│ Total: 6,000 Customers               │
└──────────────────────────────────────┘
```

---

## Core Elements

### 1. Header Section (30px)
**Components**:
- **Icon** (16×16px): Visual indicator of metric category
- **Title** (14px, Bold): Metric name (max 25 characters)
- **More Menu** (⋯): Optional drill-down or settings access

**Design**:
- Background: Light gray (#F2F2F2)
- Text Color: Dark Gray (#333333)
- Border-bottom: 1px solid #D3D3D3

### 2. Main Value Display (40px)
**Components**:
- **Primary Metric**: Large, bold number (32px font)
- **Currency/Unit Symbol**: Prepended or appended (14px)
- **Formatting**:
  - Currency: $XXX,XXX.XX (max 2 decimals)
  - Percentage: XX.X% (1 decimal)
  - Count: X,XXX,XXX (comma-separated)
  - Ratio: X:X or X.XX

**Examples**:
```
$2,450,000
87.5%
1,250,000 units
23.4:1
```

### 3. Change Indicator (16px)
**Components**:
- **Arrow Symbol**: ↑ (increase), ↓ (decrease), → (no change)
- **Percentage Value**: Change amount (1 decimal)
- **Color Coding**:
  - Green (#4CAF50): Positive/desired direction
  - Red (#F44336): Negative/concerning
  - Gray (#9E9E9E): Neutral or no change
  - Amber (#FF9800): Warning (approaching threshold)

**Positioning**: Right-aligned next to main metric

**Examples**:
```
↑ 12.5%     (Revenue increase - Green)
↓ 3.2%      (Churn increase - Red)
→ 0.0%      (No change - Gray)
↑ 1.5%      (Below target growth - Amber)
```

### 4. Context/Comparison Row (14px)
**Components**:
- **Label**: Comparison period or context
- **Value**: Comparison value
- **Format**: "Label: Value | Label: Value"

**Examples**:
```
Target: $2.3M | Achievement: 109%
Previous Month: $2,180K | QoQ: +5.2%
Industry Avg: 78% | Rank: #2 of 15
```

### 5. Metadata Footer (12px)
**Components**:
- **Update Timestamp**: "Updated X minutes/hours ago"
- **Optional**: Data source attribution, warning indicators

**Example**:
```
Updated: 2 minutes ago | Source: SAP ERP
```

---

## Color & Status Indicators

### Status Badge Colors

| Status | Color | Usage |
|--------|-------|-------|
| On Track | Green (#4CAF50) | Metric meeting/exceeding target |
| Warning | Amber (#FF9800) | Metric approaching threshold |
| Critical | Red (#F44336) | Metric below minimum acceptable |
| Neutral | Gray (#9E9E9E) | No action needed, informational |
| Pending | Blue (#2196F3) | Awaiting data/processing |

### Threshold Visualization

**Standard Thresholds**:
```
Performance Achievement:
> 110%  = Green (Excellent)
100-110% = Green (On Target)
90-100% = Amber (Below Target)
< 90%  = Red (Critical)
```

---

## Interactive Behaviors

### Hover Effects
- **Background Change**: Light highlight (#F0F0F0)
- **Border Highlight**: 2px solid accent color
- **Shadow**: Drop shadow (0 2px 8px rgba(0,0,0,0.1))
- **Cursor**: Pointer to indicate interactivity

### Click Actions
1. **Primary Click**: Navigate to detailed page for metric
2. **Right-Click**: Context menu with export/drill options
3. **Double-Click**: Edit or view in full-screen mode

### Tooltip on Hover
```
Tooltip (250px max width):
┌────────────────────────────────────┐
│ Revenue (Current Period)           │
│ $2,450,000                         │
│                                    │
│ Target: $2,300,000                 │
│ Achievement: 109%                  │
│ YoY Growth: +12.5%                 │
│ MoM Growth: +3.8%                  │
│                                    │
│ Last 12 Months Trend: ↗ Increasing│
│ Click to drill down for details    │
└────────────────────────────────────┘
```

---

## Responsive Sizing

### Desktop (Full Size)
- **Large Card**: 250px × 150px (1 column)
- **Mini Tile**: 160px × 100px (compact)
- **4 KPIs per row** (4-column grid)

### Tablet Layout (Landscape)
- **Large Card**: 220px × 140px
- **Mini Tile**: 140px × 90px
- **3 KPIs per row** (3-column grid)

### Tablet Layout (Portrait)
- **Large Card**: 170px × 120px
- **2 KPIs per row** (2-column grid)

### Mobile (Phone)
- **Large Card**: Full width (minus margins)
- **Height**: 120px
- **1 KPI per row** (single column)
- **Stacked layout**

---

## Accessibility & Best Practices

### Typography
- **Card Title**: Segoe UI, 14px, Bold, Dark Gray
- **Main Value**: Segoe UI, 32px, Bold, Primary color
- **Secondary Text**: Segoe UI, 12px, Regular, Medium Gray
- **Footer**: Segoe UI, 11px, Light, Light Gray

### Contrast Ratios
- Title vs. Background: 7:1 (AAA)
- Main Value vs. Background: 8:1 (AAA)
- Indicator Symbol: High contrast colors only

### Data Formatting Standards
- **Currency**: Always display with symbol ($, €, £)
- **Percentages**: Use % symbol; show 1-2 decimals
- **Large Numbers**: Use K (thousands), M (millions), B (billions)
- **Time Periods**: Explicit labels (Current Month, YoY, QoQ, MoM)

### Accessibility Features
- Alt text for icons: "{Metric Name} {Status} icon"
- Keyboard navigation: Tab order top-to-bottom, left-to-right
- Screen reader support: Full context provided in metadata
- Focus indicator: 2px blue outline when tabbed

---

## Card Variants by Dashboard

### Executive Dashboard Cards
- **Type**: Standard KPI Card
- **Emphasis**: Large primary metrics
- **Features**: Status badge, achievement %
- **Examples**: Revenue, Profit Margin, NPS, Market Share

### Finance Dashboard Cards
- **Type**: Comparative KPI Card
- **Emphasis**: Period-over-period comparison
- **Features**: Target achievement, forecast
- **Examples**: Revenue, EBITDA, Cash Flow, Margin

### Customer Dashboard Cards
- **Type**: Multi-Status Card or Standard KPI
- **Emphasis**: Segment breakdown
- **Features**: Cohort analysis ready
- **Examples**: Total Customers, Retention Rate, NPS, Churn Rate

### Operations Dashboard Cards
- **Type**: Standard KPI Card
- **Emphasis**: Efficiency metrics
- **Features**: Process vs. target comparison
- **Examples**: Efficiency Index, Error Rate, SLA Compliance

---

## Example: Complete KPI Card Specification

**Metric**: Total Revenue

| Property | Value |
|----------|-------|
| Card Type | Standard KPI Card |
| Dimensions | 250px × 150px |
| Primary Value | $2,450,000 |
| Indicator | ↑ 12.5% (Green) |
| Comparison | Target: $2.3M \| Achievement: 109% |
| Status | On Track (Green Badge) |
| Updated | 2 minutes ago |
| Interaction | Click to see revenue breakdown by region |
| Mobile Height | 120px (responsive) |
| Accessibility | "Total Revenue, 2 million 450 thousand dollars, 12.5 percent increase year-over-year, 109 percent achievement" |

---

## Implementation Checklist

- [ ] All cards use consistent spacing (10px margins)
- [ ] Color scheme matches brand guidelines
- [ ] Data formatting follows standard conventions
- [ ] Hover effects and tooltips implemented
- [ ] Responsive sizes tested on all breakpoints
- [ ] Accessibility features (alt text, contrast) verified
- [ ] Click handlers and drill-through navigation configured
- [ ] Performance optimized (lazy loading for cards below fold)
- [ ] Time zone handling for update timestamps
- [ ] Error states defined for missing/delayed data
