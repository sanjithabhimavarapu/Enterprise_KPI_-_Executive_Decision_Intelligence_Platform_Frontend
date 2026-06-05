# Presentation-Ready UI Design Standards

**Version**: 1.0  
**Created**: June 2026  
**Audience**: Dashboard designers, stakeholders, executives  

---

## 🎨 Part 1: Design Principles

### The 5 Core Principles

#### 1. **Clarity** - Viewers understand instantly
```
✓ Single primary message per visual
✓ Clean data with no distractions
✓ Clear axis labels and legends
✓ No overlapping elements
✓ Sufficient whitespace

❌ Cluttered with too many metrics
❌ Ambiguous visual hierarchy
❌ Missing labels or titles
❌ Overlapping text or data points
```

#### 2. **Consistency** - Professional, cohesive look
```
✓ Same color scheme throughout
✓ Uniform font sizes and families
✓ Consistent spacing and margins
✓ Same visual style for similar data
✓ Matching border and background styles

❌ Different color palettes per page
❌ Mixed fonts (Calibri + Arial + Times New Roman)
❌ Inconsistent spacing
❌ Varying visual styles
```

#### 3. **Context** - Viewers see the "why"
```
✓ KPI targets displayed with values
✓ Trend indicators (up/down/flat)
✓ Comparison to previous periods
✓ Business thresholds marked
✓ Drill-path breadcrumbs visible

❌ Bare numbers with no context
❌ Isolated metrics with no trend
❌ No comparison period
❌ Unexplained color coding
```

#### 4. **Hierarchy** - Guides viewer's eye
```
✓ Most important metrics at top-left
✓ Largest fonts for primary KPIs
✓ Color emphasizes key data
✓ Supporting details secondary
✓ Logical flow left-to-right, top-to-bottom

❌ Equal visual weight for all metrics
❌ Uniform font sizes
❌ Random element placement
❌ No visual emphasis
```

#### 5. **Accessibility** - Inclusive for all
```
✓ High contrast (text vs background)
✓ Color-blind friendly palette
✓ Readable at any size (≥10pt)
✓ Keyboard navigable
✓ Alt-text for complex visuals

❌ Low contrast text
❌ Red-green only indicators
❌ Tiny fonts
❌ Mouse-only navigation
```

---

## 📐 Part 2: Layout Specifications

### Executive Dashboard Layout (Recommended)

```
┌─────────────────────────────────────────────────────────────────────┐
│ 🔴 AUTOMATION REPORTING DASHBOARD          Last Refresh: 2:35 PM   │ ← Header (60px)
├─────────────────────────────────────────────────────────────────────┤
│ [Pipeline ▼] [Last 24h ▼] [All Severity ▼] [Search...] [Refresh]   │ ← Filters (50px)
├──────────────────┬──────────────────┬──────────────────┬────────────┤
│  Success Rate    │ Failed Execs     │ Avg Duration     │  Quality   │ ← Row 1: KPIs (150px)
│  99.2%           │ 2 failures       │ 12.3 min         │  94.2%     │
│  ↑ +0.3% | ✅   │ ⚠️ Warning       │ ✅ OK            │ ⚠️ Low    │
├──────────────────┴──────────────────┴──────────────────┴────────────┤
│                                                                      │ ← Row 2: Timeline (280px)
│        Pipeline Execution Trend (24h) - Hourly Aggregation         │
│  [Line chart showing 24 hourly data points]                        │
│                                                                      │
├──────────────────┬──────────────────┬──────────────────┬────────────┤
│ TOP 5 FAILED     │ RECENT ALERTS    │ QUALITY ISSUES   │ VALIDATIONS│ ← Row 3: Tables (380px)
│ PIPELINES        │                  │                  │            │
│ 1. Cust... (5)   │ 🔴 CR: Payment   │ 1. NULL fields   │ Pass: 847  │
│ 2. Fin...  (3)   │    failed        │    (150 recs)    │ Fail: 12   │
│ 3. Ven...  (2)   │ 🟠 HI: Order... │ 2. FK integrity  │ Warn: 3    │
│ 4. Prod... (2)   │ 🟡 MD: Validat..│ 3. Business rule │            │
│ 5. Pay...  (1)   │    (See details) │    (42 recs)     │            │
│ [Show More →]    │ [View All →]     │ [Analyze →]      │ [Details →]│
└──────────────────┴──────────────────┴──────────────────┴────────────┘

Total: 1080px width × ~900px height (fits HD screen at 100% zoom)
```

---

### 2-Page Layout (Overview + Detail)

#### Page 1: Executive Overview
```
Size: Full HD (1920×1080)
Purpose: 30-second snapshot

Focus: 4 KPIs + 2 trend charts + Alert summary
Load time: <2 seconds
Refresh: Every 5 minutes
Audience: C-suite, executives, decision makers
```

#### Page 2: Operational Detail
```
Size: Full HD (1920×1080) 
Purpose: Deep troubleshooting

Focus: Detailed tables, error breakdown, remediation
Load time: 3-5 seconds (on-demand)
Refresh: Every 5 minutes
Audience: Operations team, data engineers, support
```

---

## 🎨 Part 3: Visual Component Specifications

### KPI Card Format

**Physical Size**: 200×120px (minimum)  
**Aspect Ratio**: 5:3 (wider than tall for readability)

```
┌─────────────────────┐
│ Success Rate [icon] │ ← Title: 10pt, bold, dark gray
│                     │
│    99.2%            │ ← Value: 24pt, bold, primary color
│                     │
│ ↑ +0.3% vs Yd | ✅  │ ← Indicator: 8pt, status color
└─────────────────────┘

Color Coding:
✅ Green: ≥ Target (e.g., ≥99%)
⚠️ Amber: 90-99% of target
🔴 Red: < 90% of target
⚪ Gray: No data / N/A

Spacing:
- Title to value: 10px
- Value to indicator: 8px
- Padding (inside border): 10px all
- Border: 1px, light gray
- Border radius: 4px
```

**Badge Styles** (Status Indicator):

```
✅ Green badge:    Background #E6FFED, Border #2CB542, Text green
⚠️ Amber badge:    Background #FFF7E6, Border #FDB815, Text amber
🔴 Red badge:      Background #FFE6E6, Border #E81B23, Text red
```

---

### Chart Specifications

#### Line Chart (Trends)

```
Purpose: Show change over time
Dimensions: Full width × 280px height
Data points: 24 maximum (hourly aggregation)

Styling:
- Line width: 2-3px
- Markers: Circle, 4px diameter
- Axis labels: 10pt
- Gridlines: Light gray, 1px, horizontal only
- Legend: Right-aligned, 9pt
- Data labels: Off (or on critical points only)

Color scheme:
- Success trend: Green line
- Failure trend: Red line
- Average: Gray dashed line
```

#### Bar Chart (Comparison)

```
Purpose: Compare values across categories
Dimensions: 600px width × 240px height
Categories: Maximum 10 (else scroll)

Styling:
- Bar width: 20-30px
- Bar spacing: 5-10px
- Axis labels: 10pt, rotated if needed
- Value labels: On top of bars
- Background: Transparent
- Border: None (or light gray 0.5px)

Color scheme:
- Single series: Primary brand color
- Multiple series: Distinct colors from palette
```

#### Table (Details)

```
Purpose: Show detailed data
Dimensions: Full width × Variable height
Rows per page: 10 (pagination enabled)

Styling:
- Font: 10pt, monospace for numbers
- Row height: 28px
- Header: Bold, background #F3F4F6
- Alternating rows: White and #F9FAFB
- Gridlines: 1px, light gray, both directions
- Padding: 8px L/R, 6px T/B
- Borders: 1px surrounding table

Columns:
- Max 8 columns per table
- Min 80px width per column
- Right-align numbers
- Left-align text
- Center-align icons/status
```

---

## 📊 Part 4: Data Visualization Guidelines

### When to Use Each Visual Type

| Visual | Best For | Avoid When |
|--------|----------|-----------|
| **KPI Card** | Single metric with status | Multiple metrics (use separate cards) |
| **Line Chart** | Trend over time | Discrete categories (use bar) |
| **Bar Chart** | Compare values | More than 10 categories (too crowded) |
| **Pie Chart** | Part-to-whole ratio | More than 5 segments (use table) |
| **Table** | Detail and precision | Large datasets >1000 rows (paginate) |
| **Gauge** | Single metric range | Multiple metrics (use KPI instead) |
| **Card/Text** | Key message or status | Complex data (needs visual) |
| **Heat Map** | Multi-dimensional patterns | Single dimension (use simpler chart) |

---

### Number Formatting Standards

```
Percentages:
- Format: 99.2% (1 decimal, always show %)
- Alignment: Right in tables
- Example: Success Rate: 99.2%

Whole Numbers:
- Format: 1,234 (comma separator)
- Alignment: Right in tables
- Example: Failed Executions: 2

Decimals:
- Duration: 12.3 minutes (1 decimal max)
- Volume: 2.5 GB (1 decimal max)
- Rate: 0.8% (1 decimal max)

Time Formats:
- Duration: 12m 30s (minutes + seconds if <1 hour)
- Timestamp: 2:35 PM (12-hour, no seconds)
- Date: Jun 5, 2026 (abbreviated month)
- Time range: Jun 5 2:00 PM - 3:00 PM

Large Numbers:
- 1K+ use abbreviation: 1.2K, 150K, 2.3M, 4.5B
- Never show: 1,200,000 (use 1.2M instead)
```

---

## 🎯 Part 5: Annotation & Labeling

### Title Standards

```
Dashboard Title:
- Format: "🔴 AUTOMATION REPORTING DASHBOARD"
- Font: 20pt, bold, brand color
- Position: Top-left, 20px margin
- Subtext: "Real-time pipeline monitoring & validation"

Page Title:
- Format: "Executive Overview"
- Font: 16pt, bold
- Position: Under main title, 10px margin

Visual Title:
- Format: "Pipeline Execution Trend (24h)"
- Font: 12pt, bold
- Position: Top-left of visual
- Include time period in title
```

### Data Labels

```
On KPI Cards:
✓ Value label (always visible)
✓ Trend indicator (↑/↓/→)
✓ Status badge (✅/⚠️/🔴)
✓ Previous period comparison

On Charts:
✓ Key data points only (not every point)
✓ Labels positioned above bar/point
✓ Font: 9pt, dark gray
✓ Rotation: Only if necessary

On Tables:
✓ Column headers (always)
✓ Row labels (category names)
✓ Totals row (bold, background color)
✓ Pagination indicator (1-10 of 347)
```

### Tooltips (Hover Text)

```
Content:
- Primary metric name + value
- Secondary metric if relevant
- Timestamp of data
- Data source if not obvious
- Action hint if applicable

Example tooltip on KPI:
"Success Rate (24h): 99.2%
Target: 99.5%
Trend: ↑ +0.3% vs yesterday
Last refresh: 2:35 PM"

Format:
- Font: 9pt
- Background: Dark semi-transparent
- Text: White
- Padding: 8px
- Border radius: 4px
- Max width: 300px
```

---

## ✨ Part 6: Visual Enhancements

### Icons & Indicators

```
Status Indicators:
✅ Success / OK / Green     → Green circle or checkmark
⚠️ Warning / Caution        → Amber triangle or exclamation
🔴 Critical / Error         → Red circle or X mark
⏳ Processing / Running     → Gray spinner or clock

Trend Indicators:
📈 Increasing / Improving   → Up arrow, green
📉 Decreasing / Worsening   → Down arrow, red
➡️ Flat / No change         → Horizontal arrow, gray
❓ Unknown / N/A            → Question mark, gray

Directional Indicators:
→ Navigate / Open drill-path → Right arrow
← Back / Return             → Left arrow
↑ Expand / Show more        → Up arrow
↓ Collapse / Hide           → Down arrow

Icon Size:
- KPI cards: 16px
- Inline: 12px
- Badges: 20px
```

### Conditional Formatting

```
Status-Based Coloring:
- Success (≥99%): Green background, white text
- Warning (90-98%): Amber background, dark text
- Critical (<90%): Red background, white text

Trend-Based Coloring:
- Improving: Green text with ↑ arrow
- Declining: Red text with ↓ arrow
- Flat: Gray text with → arrow

Data Quality:
- Complete data: Green highlight
- Partial data: Amber highlight
- Missing data: Red highlight / faded
- Estimated: Italic + gray border
```

---

## 📋 Part 7: Responsive Design (Mobile/Tablet)

### Breakpoints

```
Desktop (1920×1080):
- Full 4-column layout
- All visuals visible at once
- No scrolling needed

Tablet (1024×768):
- 2-column layout
- Adaptive sizing
- Vertical scroll allowed
- Slicer on collapsible side panel

Mobile (375×667):
- Single column
- Stacked layout
- Slicer in dropdown
- Charts may need rotation
- Tables become vertical layout (flipped)
```

### Mobile Optimization

```
Text Size:
- Minimum 12pt (not 10pt)
- More line height (1.6x instead of 1.5x)

Touch Targets:
- Buttons/slicers: Minimum 44×44px
- Click areas: 48px recommended

Spacing:
- Larger margins: 20px instead of 10px
- Larger gaps: 15px instead of 10px

Charts:
- Rotate bar charts to horizontal
- Reduce complexity (max 5 data points)
- Larger fonts (12pt minimum)

Tables:
- Show 3-4 columns max
- Use horizontal scroll if needed
- Larger row height (32px)
```

---

## 🎬 Part 8: Animation & Transitions

### When to Use Animation

```
✓ Page load: Fade in or slide from left
✓ Data update: Smooth number transition
✓ Filter change: Charts redraw smoothly
✓ Drill-path: Slide transition to detail page

❌ Don't use: Excessive animations
❌ Don't use: Rotating charts
❌ Don't use: Bouncing elements
❌ Don't use: Auto-playing transitions
```

### Animation Settings

```
Duration: 300-500ms (fast, not jarring)
Easing: Ease-in-out (natural)
Trigger: On data change or interaction
Effect: Fade or slide (subtle)

Power BI Settings:
Visual → Format → Animation
- Enable: Yes
- Type: Appear/Fade/Fly In
- Duration: 0.5 seconds
- Delay: 0 seconds (no delay)
```

---

## 📱 Part 9: Export Optimization Checklist

Before exporting for presentation, verify:

**Visual Checks**:
- [ ] All text readable (no fuzzy fonts)
- [ ] Colors accurate (no banding)
- [ ] Numbers correctly formatted
- [ ] No overlapping elements
- [ ] Icons properly sized
- [ ] Borders crisp and clean

**Data Checks**:
- [ ] All metrics current
- [ ] Calculations verified
- [ ] No errors or warnings
- [ ] Trends visible and correct
- [ ] Comparisons make sense

**Presentation Checks**:
- [ ] File size reasonable (<5MB PNG)
- [ ] Resolution correct (1920×1080 minimum)
- [ ] Color space: sRGB
- [ ] Format: PNG 24-bit (presentation)
- [ ] Metadata: Title, date, author

**Accessibility Checks**:
- [ ] High contrast (4.5:1 ratio)
- [ ] Not relying on color alone
- [ ] Alt text provided
- [ ] Text minimum 10pt
- [ ] No animated GIFs (if printing)

---

## 🎨 Part 10: Brand Compliance

### Logo & Branding

```
Company Logo:
- Placement: Top-right or top-left
- Size: 40-50px height
- Margin: 15px from edge
- No distortion (maintain aspect ratio)

Dashboard Watermark (optional):
- Text: "CONFIDENTIAL" or "DRAFT"
- Position: Diagonal across dashboard
- Opacity: 10-15% (very light)
- Font: Bold sans-serif
- Rotation: -45 degrees

Footer:
- Text: "Refresh: [Date/Time] | Data Source: [System]"
- Font: 8pt, light gray
- Position: Bottom-right
- Alignment: Right
```

### Compliance Elements

```
Required for Presentation:
- [ ] Company name/logo
- [ ] Date and time of refresh
- [ ] Data source attribution
- [ ] Confidentiality marking (if needed)
- [ ] Contact person for questions
- [ ] Version number (v1.0, v1.1, etc.)

Optional but Recommended:
- [ ] Page number
- [ ] URL to dashboard (if online)
- [ ] Disclaimer or caveats
- [ ] Update frequency
- [ ] File name with date
```

---

## ✅ Quick Checklist: Presentation-Ready Dashboard

```
FUNCTIONALITY
☑ All filters working
☑ Drill-paths functional
☑ Data refreshed (last 30 min)
☑ No error messages visible
☑ Performance acceptable (<3s load)

VISUAL DESIGN
☑ Color palette consistent
☑ Fonts uniform and readable
☑ Spacing balanced and clean
☑ Layout organized logically
☑ No overlapping elements

DATA & ACCURACY
☑ Numbers correct and verified
☑ Calculations match expectations
☑ Comparisons meaningful
☑ Trends visible and accurate
☑ Benchmarks/targets shown

CLARITY & CONTEXT
☑ Title clearly states purpose
☑ All metrics labeled
☑ Units shown (%, m, GB)
☑ Trend indicators present
☑ Status colors applied correctly

ACCESSIBILITY
☑ High contrast (4.5:1+)
☑ Not color-only indication
☑ Text minimum 10pt
☑ Icons meaningful
☑ Keyboard navigable

EXPORT & PRESENTATION
☑ File size <5MB
☑ Resolution 1920×1080 minimum
☑ Format PNG (presentation)
☑ Metadata complete
☑ Filename with date

STATUS: ✅ READY FOR PRESENTATION
```

---

**Ready to export?** Use [DASHBOARD_EXPORT_FINALIZATION_GUIDE.md](DASHBOARD_EXPORT_FINALIZATION_GUIDE.md) for step-by-step instructions.

