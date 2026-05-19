# Dashboard Themes & Style Guide

## Overview
This document defines the visual design system, color palettes, typography, and styling conventions for all Power BI dashboards in the Enterprise KPI Platform.

---

## Color Palette

### Primary Brand Colors

#### Executive Suite Theme (Primary)
```
Primary Blue:        #2196F3
Dark Blue:          #1565C0
Light Blue:         #E3F2FD
Accent Blue:        #0D47A1
```

#### Supporting Colors
```
Success Green:      #4CAF50
Dark Green:         #2E7D32
Light Green:        #E8F5E9

Warning Amber:      #FF9800
Dark Amber:         #E65100
Light Amber:        #FFF3E0

Error Red:          #F44336
Dark Red:           #C62828
Light Red:          #FFEBEE

Neutral Gray:       #9E9E9E
Dark Gray:          #424242
Light Gray:         #F5F5F5
```

### Color Usage Matrix

| Element | Color | Hex | Usage |
|---------|-------|-----|-------|
| Primary Background | Dark Navy | #1E1E1E | Page background |
| Secondary Background | Light Gray | #F5F5F5 | Card backgrounds |
| Header Background | Dark Navy | #1E1E1E | Navigation header |
| Text - Primary | White | #FFFFFF | Headers, navigation |
| Text - Secondary | Light Gray | #B0B0B0 | Secondary text |
| Text - Tertiary | Medium Gray | #9E9E9E | Disabled text |
| Border - Primary | Medium Gray | #D3D3D3 | Card borders |
| Border - Secondary | Light Gray | #E8E8E8 | Subtle borders |
| Positive Indicator | Green | #4CAF50 | Up arrows, gains |
| Negative Indicator | Red | #F44336 | Down arrows, losses |
| Warning Indicator | Amber | #FF9800 | Caution, alerts |
| Neutral Indicator | Gray | #9E9E9E | No change |
| Link Color | Light Blue | #64B5F6 | Hyperlinks |
| Hover Color | Lighter Blue | #90CAF9 | Link hover |

---

## Typography

### Font Family Stack
```
Primary: "Segoe UI", "Roboto", "Helvetica Neue", sans-serif
Monospace: "Courier New", monospace
```

### Font Sizes & Weights

#### Headings
| Level | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| H1 | 28px | Bold (700) | 1.3 | Page title |
| H2 | 22px | Bold (700) | 1.3 | Section header |
| H3 | 18px | SemiBold (600) | 1.3 | Subsection |
| H4 | 16px | SemiBold (600) | 1.3 | Card title |

#### Body Text
| Type | Size | Weight | Line Height | Usage |
|------|------|--------|-------------|-------|
| Body Large | 14px | Regular (400) | 1.5 | Main content |
| Body Regular | 12px | Regular (400) | 1.5 | Secondary content |
| Body Small | 11px | Regular (400) | 1.4 | Tertiary content |
| Caption | 10px | Regular (400) | 1.4 | Footnotes, timestamps |

#### Special Elements
| Element | Size | Weight | Usage |
|---------|------|--------|-------|
| KPI Value | 32px | Bold (700) | Large metric display |
| KPI Change | 16px | Regular (400) | Percentage change |
| Button Text | 12px | SemiBold (600) | Interactive elements |
| Table Header | 12px | Bold (700) | Table column headers |
| Table Data | 11px | Regular (400) | Table cells |

### Text Colors by Element

```
Page Titles:       White (#FFFFFF)
Section Headers:   White (#FFFFFF)
Card Titles:       Dark Gray (#333333)
Body Text:         Light Gray (#B0B0B0)
Secondary Text:    Medium Gray (#9E9E9E)
Disabled Text:     Light Gray (#757575)
Links:             Light Blue (#64B5F6)
Link Hover:        Lighter Blue (#90CAF9)
```

---

## Component Styling

### Cards

#### Standard Card
```
Background:        White (#FFFFFF) or #F8F8F8
Border:            1px solid #D3D3D3
Border-radius:     4px
Box-shadow:        0 2px 4px rgba(0,0,0,0.1)
Padding:           16px
Margin:            10px
```

#### Card Header
```
Background:        #F2F2F2
Padding:           12px 16px
Border-bottom:     1px solid #E0E0E0
Font-weight:       600
Font-size:         14px
Color:             #333333
```

#### Card Content
```
Padding:           16px
Line-height:       1.5
Color:             #4F4F4F
```

#### Card Footer
```
Background:        #FAFAFA
Border-top:        1px solid #E8E8E8
Padding:           8px 16px
Font-size:         11px
Color:             #9E9E9E
```

### KPI Cards - Enhanced

#### Card State: Default
```
Background:        White (#FFFFFF)
Border:            1px solid #E0E0E0
Shadow:            0 2px 8px rgba(0,0,0,0.08)
Hover Shadow:      0 4px 12px rgba(0,0,0,0.12)
Transition:        all 0.2s ease-in-out
```

#### Card State: Warning
```
Left Border:       4px solid #FF9800 (Amber)
Background:        #FFFBF0 (Light Amber)
```

#### Card State: Critical
```
Left Border:       4px solid #F44336 (Red)
Background:        #FFEBEE (Light Red)
```

#### Card State: Success
```
Left Border:       4px solid #4CAF50 (Green)
Background:        #E8F5E9 (Light Green)
```

---

## Buttons & Interactive Elements

### Button Styles

#### Primary Button
```
Background:        #2196F3 (Primary Blue)
Color:             White (#FFFFFF)
Border:            None
Padding:           10px 16px
Border-radius:     4px
Font-weight:       600
Font-size:         12px
Cursor:            pointer
Hover Background:  #1976D2 (Darker Blue)
Active Background: #1565C0 (Dark Blue)
Focus Outline:     2px solid #0D47A1
```

#### Secondary Button
```
Background:        #F5F5F5 (Light Gray)
Color:             #333333 (Dark Gray)
Border:            1px solid #D3D3D3
Padding:           10px 16px
Border-radius:     4px
Font-weight:       600
Font-size:         12px
Hover Background:  #EEEEEE
Active Background: #E0E0E0
```

#### Tertiary/Link Button
```
Background:        Transparent
Color:             #64B5F6 (Light Blue)
Border:            None
Padding:           10px 16px
Font-weight:       600
Font-size:         12px
Cursor:            pointer
Hover Color:       #90CAF9 (Lighter Blue)
Text-decoration:   underline on hover
```

#### Disabled Button
```
Background:        #F5F5F5 (Light Gray)
Color:             #BDBDBD (Disabled Gray)
Border:            1px solid #E0E0E0
Cursor:            not-allowed
Opacity:           0.6
```

### Icons & Indicators

#### Status Icons
```
Up Arrow (↑):      Green (#4CAF50) - Positive trend
Down Arrow (↓):    Red (#F44336) - Negative trend
Neutral Arrow (→): Gray (#9E9E9E) - No change
Alert Icon (⚠):    Amber (#FF9800) - Warning
Error Icon (✕):    Red (#F44336) - Error
Check Icon (✓):    Green (#4CAF50) - Success
Info Icon (ⓘ):     Blue (#2196F3) - Information
```

#### Icon Sizes
```
Small:    16×16px   (Inline with text)
Regular:  24×24px   (Standard usage)
Large:    32×32px   (Prominent displays)
XL:       48×48px   (Header/feature icons)
```

---

## Navigation & Header Styling

### Page Header

```
Layout: Flex row with space-between
Background: #1E1E1E (Dark Navy)
Height: 60px
Padding: 0 20px
Border-bottom: 2px solid #2196F3 (Primary Blue)
```

#### Header Elements
```
Logo:
  Width:    40px
  Height:   40px
  Margin:   10px 0

Title:
  Font-size:     18px
  Font-weight:   700
  Color:         White (#FFFFFF)
  Margin-left:   20px
  Flex:          1

Controls:
  Gap:           10px
  Align:         right
```

### Breadcrumb Navigation
```
Font-size:       12px
Color:           #9E9E9E
Separator:       " > "
Active Item:     White (#FFFFFF)
Link Item:       #64B5F6 (Light Blue)
Hover Item:      #90CAF9 (Lighter Blue)
Padding:         8px 20px
```

---

## Charts & Visualizations

### Chart Color Schemes

#### Single Metric Chart (Line, Bar)
```
Primary Series:    #2196F3 (Primary Blue)
Accent Series:     #FF9800 (Amber)
Axis Lines:        #E8E8E8 (Light Gray)
Grid Lines:        #F5F5F5 (Light Gray)
Data Labels:       #333333 (Dark Gray)
Axis Labels:       #9E9E9E (Medium Gray)
```

#### Multi-Series Chart (Stacked, Grouped)
```
Series 1:          #2196F3 (Blue)
Series 2:          #4CAF50 (Green)
Series 3:          #FF9800 (Amber)
Series 4:          #F44336 (Red)
Series 5:          #9C27B0 (Purple)
Series 6:          #00BCD4 (Cyan)
Overflow:          Gradient/pattern fills
```

#### Status-Based Chart (Red-Yellow-Green)
```
Good/Green Zone:   #4CAF50 with opacity 0.3
Caution/Yellow:    #FF9800 with opacity 0.3
Warning/Red Zone:  #F44336 with opacity 0.3
Threshold Lines:   Dashed, corresponding color
```

#### Geographic/Map Visualization
```
Land Fill:         #FAFAFA (Off-white)
Water:             #E1F5FE (Light blue)
Data Min:          #FFF3E0 (Light amber)
Data Max:          #0D47A1 (Dark blue)
Border:            #BDBDBD (Light gray)
```

### Chart Elements

#### Axis Styling
```
Axis Line:         1px solid #E8E8E8
Axis Ticks:        #E8E8E8
Axis Labels:       12px, #9E9E9E
Axis Title:        14px Bold, #333333
```

#### Grid Lines
```
Major Grid:        1px solid #F0F0F0
Minor Grid:        1px dashed #F5F5F5
Opacity:           0.5
```

#### Legend
```
Background:        White (#FFFFFF) with border
Border:            1px solid #E8E8E8
Padding:           12px
Font-size:         12px
Item Gap:          8px
Marker Size:       12×12px
```

#### Tooltips
```
Background:        #333333 (Dark Gray)
Color:             White (#FFFFFF)
Border:            1px solid #555555
Padding:           8px 12px
Border-radius:     4px
Font-size:         12px
Box-shadow:        0 4px 12px rgba(0,0,0,0.25)
Max-width:         300px
Z-index:           1000
```

---

## Spacing & Layout System

### Margin & Padding Scale
```
xs:    4px
sm:    8px
md:    12px
lg:    16px
xl:    20px
xxl:   24px
xxxl:  32px
```

### Grid & Alignment
```
Page Grid:         4 columns (25% each)
Min Gap:           10px between elements
Page Padding:      20px (horizontal)
Page Margin:       10px (top/bottom)
```

### Responsive Breakpoints
```
Mobile:            0px - 576px     (1 column)
Tablet:            576px - 1024px  (2-3 columns)
Desktop:           1024px - 1920px (4 columns)
Large Desktop:     1920px+         (4 columns + margins)
```

---

## Shadows & Depth

### Shadow Elevation System

```
Elevation 1 (Cards, Tooltips):
  0 2px 4px rgba(0,0,0,0.10)

Elevation 2 (Card Hover, Small Popups):
  0 4px 8px rgba(0,0,0,0.12)

Elevation 3 (Modals, Dropdowns, Menus):
  0 8px 16px rgba(0,0,0,0.15)

Elevation 4 (Floating Action Buttons, High Priority):
  0 12px 24px rgba(0,0,0,0.20)

Elevation 5 (Maximum Depth):
  0 16px 32px rgba(0,0,0,0.25)
```

---

## Transitions & Animations

### Standard Durations
```
Fast:      150ms   (Micro-interactions)
Regular:   250ms   (Standard transitions)
Slow:      350ms   (Emphasized transitions)
```

### Animation Types

#### Fade
```
Opacity:   0 → 1
Duration:  250ms
Easing:    ease-in-out
```

#### Slide
```
Transform: translateX(-10px) → 0
Duration:  250ms
Easing:    ease-out
```

#### Scale
```
Transform: scale(0.95) → scale(1)
Duration:  200ms
Easing:    ease-out
```

#### Hover Effects
```
All Properties:    transition all 250ms ease-in-out
Common Changes:
  - Background color shift
  - Shadow elevation increase
  - Scale 1 → 1.02
  - Border color change
```

---

## Dark Theme (Optional)

For night-mode or reduced-light environments:

```
Background:        #121212 (Very Dark Gray)
Card Background:   #1E1E1E (Dark Gray)
Text Primary:      #FFFFFF (White)
Text Secondary:    #B3B3B3 (Light Gray)
Border:            #2C2C2C (Medium Dark Gray)
Accent:            #64B5F6 (Light Blue - brighter for contrast)
Green:             #66BB6A (Slightly brighter)
Red:               #EF5350 (Slightly brighter)
Amber:             #FFA726 (Slightly brighter)
```

---

## Accessibility in Theme

### Contrast Ratios (WCAG AA Minimum)
```
Primary Text on Background:    4.5:1
Large Text on Background:      3:1
Interactive Elements:          4.5:1
Disabled Text:                 3:1
```

### Color Blindness
- Do not rely on color alone to convey information
- Use patterns, labels, and icons alongside color
- Avoid red-green combinations without additional context
- Test visualizations with color blindness simulation tools

### Focus Indicators
```
Focus Outline:     2px solid #0D47A1 (Dark Blue)
Outline Offset:    2px
Visible on all:    Buttons, links, form fields, interactive cards
```

---

## Brand Applications

### Executive Dashboard Theme
- **Primary Color**: Dark Navy (#1E1E1E) background with Blue accents
- **Mood**: Professional, authoritative, trustworthy
- **Font Weight**: Bold headers (700), regular body (400)

### Finance Dashboard Theme
- **Primary Color**: Dark Navy with Green/Red status indicators
- **Mood**: Analytical, precise, urgent alerts
- **Data Visualization**: Green for gains, Red for losses

### Customer Dashboard Theme
- **Primary Color**: Dark Navy with vibrant accent colors
- **Mood**: Engaging, segmented, relationship-focused
- **Color Use**: Distinct colors for each customer segment

### Operations Dashboard Theme
- **Primary Color**: Dark Navy with Amber warnings
- **Mood**: Active, performance-driven, real-time focus
- **Status Display**: Traffic light colors (Red/Amber/Green)

### Governance Dashboard Theme
- **Primary Color**: Dark Navy with Red alerts
- **Mood**: Formal, compliance-focused, risk-aware
- **Indicators**: Red for violations, Green for compliant

---

## Implementation Checklist

- [ ] Primary color palette applied to all dashboards
- [ ] Typography scales implemented consistently
- [ ] Card styling templates created in Power BI
- [ ] Button styles defined and applied
- [ ] Icon set downloaded and configured
- [ ] Spacing scale used throughout layouts
- [ ] Shadow system applied to depth hierarchy
- [ ] Transitions/animations implemented smoothly
- [ ] Contrast ratios verified for accessibility
- [ ] Dark mode tested (if applicable)
- [ ] Color scheme tested with color blindness simulator
- [ ] All fonts embedded or system-safe
