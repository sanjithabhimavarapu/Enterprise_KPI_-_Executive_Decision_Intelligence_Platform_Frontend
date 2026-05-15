# Executive KPI Layout Specification

## Executive Dashboard KPI Structure

### Primary KPIs (Above the Fold)

#### 1. Revenue KPI
- **Metric**: Total Revenue
- **Display**: Large numeric display with currency symbol
- **Time Period**: Current period vs Previous period
- **Indicators**: 
  - YoY growth percentage
  - Month-over-Month comparison
  - Trend arrow (Up/Down/Neutral)
- **Color Coding**: Green (positive growth), Red (decline), Gray (neutral)
- **Target Line**: Display annual/quarterly target with achievement %

#### 2. Profitability KPI
- **Metric**: Net Profit Margin %
- **Display**: Percentage with decimal precision
- **Time Period**: Current quarter vs Same quarter previous year
- **Indicators**:
  - Absolute profit amount
  - Industry benchmark comparison
  - 3-year trend line
- **Alert Thresholds**: Warning (below 5%), Critical (below 2%)

#### 3. Customer Satisfaction KPI
- **Metric**: Net Promoter Score (NPS)
- **Display**: Gauge chart (0-100)
- **Segments**: Promoters/Passives/Detractors breakdown
- **Time Period**: Current month vs 12-month average
- **Action Items**: Customer feedback summary

#### 4. Market Position KPI
- **Metric**: Market Share %
- **Display**: Comparative pie chart with competitors
- **Time Period**: Current quarter vs 4 quarters trailing
- **Indicators**: 
  - Rank among competitors
  - Growth rate vs market
  - Regional breakdowns

### Secondary KPIs (Supporting Metrics)

#### 5. Growth Rate
- **Metric**: Revenue Growth % YoY
- **Display**: Trend chart (12-month rolling)
- **Targets**: Growth target with achievement indicator

#### 6. Customer Retention
- **Metric**: Customer Retention Rate %
- **Display**: Line chart with cohort analysis
- **Segments**: By customer segment and region

#### 7. Operational Efficiency
- **Metric**: EBITDA / Revenue Ratio
- **Display**: Benchmark comparison
- **Trend**: 8-quarter view

#### 8. Cash Flow
- **Metric**: Operating Cash Flow
- **Display**: Waterfall chart
- **Components**: Inflows, Outflows, Net position

## KPI Card Design Specifications

### Standard Card Layout
```
┌─────────────────────────────────────┐
│ [Icon] KPI Name          [⋯ More]  │
├─────────────────────────────────────┤
│ $2.5M                   ↑ 12.5%    │
│ Current Value           YoY Change  │
├─────────────────────────────────────┤
│ Target: $2.3M | Achievement: 109%  │
│ Last Updated: 2 minutes ago         │
└─────────────────────────────────────┘
```

### Mini KPI Tile
```
┌─────────────────┐
│ 87.5%           │
│ Metric Name     │
│ ↑ 5.2%          │
└─────────────────┘
```

## Interactive Features

### Drill-Down Capability
- Click any KPI to view detailed breakdown
- Time-series analysis
- Comparative analysis tools
- Export data functionality

### Filtering Options
- Date range selector
- Department/Region filter
- Customer segment filter
- Product category filter

### Refresh Strategy
- Executive dashboard: 15-minute auto-refresh
- Manual refresh button available
- Last updated timestamp visible

## Mobile Layout Adaptation
- Single column layout for tablets
- Simplified card display
- Essential KPIs prioritized
- Swipe navigation between sections
