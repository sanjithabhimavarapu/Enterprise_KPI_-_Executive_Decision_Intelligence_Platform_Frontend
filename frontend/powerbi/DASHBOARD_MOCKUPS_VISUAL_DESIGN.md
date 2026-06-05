# Dashboard Mockup & Visual Design Guide

**Version**: 1.0  
**Created**: June 2026  
**Purpose**: Create presentation-ready mockups for Automation Reporting and Validation Insights dashboards

---

## Part 1: Automation Reporting Dashboard - Visual Mockup

### Page 1: Executive Overview (2-3 second load)

```
┌────────────────────────────────────────────────────────────────────────────────┐
│ 🔴 AUTOMATION REPORTING DASHBOARD                    Last Refresh: 2:35 PM    │ ← Header
├────────────────────────────────────────────────────────────────────────────────┤
│ [Pipeline ▼ All] [Time ▼ 24h] [Severity ▼ All] [Search...] [Refresh] [⚙️ ]    │ ← Filters
├─────────────────┬──────────────────┬──────────────────┬────────────────────────┤
│  ✅ SUCCESS     │  ⚠️ FAILURES     │  ✅ DURATION     │  ⚠️ DATA QUALITY      │ ← Row 1: KPIs
│  RATE           │  EXECUTIONS      │  (AVG)           │  SCORE                 │
│                 │                  │                  │                        │
│   99.2%         │    2 failures    │   12.3 min       │    94.2%               │
│   ↑ +0.3%      │    ⚠️ Warning    │    ✅ OK         │    ⚠️ Low              │
│   vs Yesterday  │    2026-06-05    │    vs Avg: 11m   │    vs Yd: -2.1%        │
├────────────────┼──────────────────┼──────────────────┼────────────────────────┤
│                                                                                 │ ← Row 2: Timeline
│   PIPELINE EXECUTION TREND (24h) - Hourly Aggregation                         │
│                                                                                 │
│   Success Rate %                                                               │
│   100%  ┌─────────────────────────────────────────────────────────┐           │
│   99%   │    ╭─╮                                                   │           │
│   98%   │   ╱   ╲╱╲╱──╲                                          │           │
│   97%   │  ╱         ╲╱╲╭╮╭╮                                     │           │
│         │ ╱               ╰╯╰╯                                    │           │
│   96%   └─────────────────────────────────────────────────────────┘           │
│         12am 1am 2am 3am ... 10pm 11pm 12am                                   │
│                                                                                 │
│   Status:  ✅ Green (>99%)  ⚠️ Amber (95-99%)  🔴 Red (<95%)                  │
├─────────────────┬──────────────────┬──────────────────┬────────────────────────┤
│ TOP 5 FAILED    │ RECENT ALERTS    │ DATA QUALITY     │ VALIDATION STATUS     │ ← Row 3: Tables
│ PIPELINES       │                  │ ISSUES           │                        │
│                 │                  │                  │                        │
│ 1. Customer... (5) ▼  │ 🔴 CRITICAL:        │ NULL Fields (Required) │ Pass:    847
│ 2. Finance...   (3) ▼  │    Payment Failed   │    150 records         │ Warn:     12
│ 3. Vendor...    (2) ▼  │    2026-06-05       │ FK Integrity Issues    │ Fail:      3
│ 4. Product...   (2) ▼  │    14:32:45         │    42 records          │
│ 5. Payment...   (1) ▼  │                     │ Business Rule Violation│ [Details →]
│                 │ 🟠 HIGH:           │    8 records           │
│ [Show More →]   │    Order Timeout    │                        │
│                 │ 🟡 MEDIUM:         │ [Analyze →]            │
│                 │    Validation... (3)│                        │
│                 │ [View All →]        │                        │
└─────────────────┴──────────────────┴──────────────────┴────────────────────────┘

Dimensions: 1920×1080 (Full HD)
Load Time: ~2 seconds
Refresh: Every 5 minutes
Focus: 4 KPIs + 1 trend + 4 summary tables
```

---

### Page 2: Operational Detail (On-demand, paginated)

```
┌────────────────────────────────────────────────────────────────────────────────┐
│ OPERATIONAL DETAIL - DEEP DIVE                        [← Back] [Export] [Print]│
├────────────────────────────────────────────────────────────────────────────────┤
│ Viewing: All Pipelines | Filter: Last 24h | Severity: All                     │
├────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│ SECTION 1: PIPELINE PERFORMANCE BREAKDOWN                                     │
│ ─────────────────────────────────────────────────────────────────────────────  │
│                                                                                 │
│ Pipeline          Executions  Success%  Avg Time  Status    Trend            │
│ ────────────────────────────────────────────────────────────────────────────  │
│ Customer Data        427       99.5%    11.2 min   ✅ OK    ↑ +0.8%           │
│ Finance Ledger       312       98.7%    14.5 min   ⚠️ Warn  ↓ -1.2%           │
│ Vendor Master        189       96.3%    23.4 min   ⚠️ Warn  ↓ -3.1%           │
│ Product Catalog      156       95.8%    9.8 min    🔴 Crit  ↓ -4.5%           │
│ Payment Gateway      98        92.3%    31.2 min   🔴 Crit  ↓ -6.2%           │
│                                                                                 │
│ [Showing 1-5 of 247 pipelines] [< Previous] [Next >]                          │
│                                                                                 │
│ SECTION 2: DATA QUALITY TRENDS (7-day)                                       │
│ ─────────────────────────────────────────────────────────────────────────────  │
│                                                                                 │
│ Quality Score %                                                                │
│ 100%  ┌─────────────────────────────────────────────────────────┐             │
│ 95%   │        ╱╲                                               │             │
│ 90%   │   ╭───╱  ╲──╮                                          │             │
│ 85%   │  ╱  ╭───╮  ╲╭─╮                                        │             │
│ 80%   └─────────────────────────────────────────────────────────┘             │
│       Jun1 Jun2 Jun3 Jun4 Jun5 Jun6 Jun7                                      │
│                                                                                 │
│ Legend: Completeness ─ Accuracy ─ ─ Consistency ─ Freshness ─ ─              │
│                                                                                 │
│ SECTION 3: FAILED RULES ANALYSIS                                             │
│ ─────────────────────────────────────────────────────────────────────────────  │
│                                                                                 │
│ ▶ Data Completeness (3 failures)                                             │
│   ├─ Required Fields Missing (2 failures)                                    │
│   │  ├─ Customer.Email [EXPAND]  Impact: 150 records | Severity: High       │
│   │  └─ Order.ProductID [EXPAND] Impact: 42 records  | Severity: Medium     │
│   └─ NULL Values Found (1 failure)                                           │
│      └─ Transaction.Amount NULL [EXPAND] Impact: 8 records | Severity: Low   │
│                                                                                 │
│ ▶ Data Accuracy (0 failures) [COLLAPSED]                                     │
│                                                                                 │
│ ▶ Referential Integrity (1 failure) [COLLAPSED]                              │
│                                                                                 │
│ ▶ Business Rules (2 failures) [COLLAPSED]                                    │
│                                                                                 │
└────────────────────────────────────────────────────────────────────────────────┘

Dimensions: 1920×1080 (scrollable)
Load Time: 3-5 seconds
Purpose: Troubleshooting and deep analysis
Visibility: On-demand via "View Details" link
```

---

## Part 2: Validation Insights Dashboard

### Page 1: Quality Scorecard (Executive Summary)

```
┌────────────────────────────────────────────────────────────────────────────────┐
│ 📊 DATA VALIDATION INSIGHTS DASHBOARD              Last Refresh: 2:35 PM      │
├────────────────────────────────────────────────────────────────────────────────┤
│ [Data Source ▼ All] [Time Range ▼ 24h] [Severity ▼ All] [Search...]           │
├────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│ OVERALL DATA QUALITY SCORE                                                    │
│                                                                                 │
│ ┌────────────────────────────────────────────────────────────────────────────┐│
│ │ 94.2% ⚠️                                                                    ││
│ │ ████████████████████████░░░░░░░ [Quality Gauge/Status Bar]                 ││
│ │                                                                             ││
│ │ Status: ⚠️ WARNING (Target: 95%)                                            ││
│ │ Trend: ↓ -2.1% vs Yesterday                                                 ││
│ │ Last Checked: Today 2:35 PM                                                 ││
│ └────────────────────────────────────────────────────────────────────────────┘│
│                                                                                 │
├─────────────────┬──────────────────┬──────────────────┬────────────────────────┤
│  ✅ COMPLETE    │  ✅ ACCURATE     │  ✅ CONSISTENT   │  ⚠️ FRESH              │
│  98.5%          │  99.1%           │  96.2%           │  89.8%                 │
│  (All fields)   │  (Validation     │  (Cross-source)  │  (Last 5m check)       │
│                 │   passed)        │                  │                        │
├─────────────────┴──────────────────┴──────────────────┴────────────────────────┤
│                                                                                 │
│ VALIDATION PASS RATE (24h)                                                    │
│                                                                                 │
│ Pass: 847  (94.2%)   [████████████████░░] ✅                                  │
│ Warn: 12   (1.3%)    [░░░░░░░░░░░░░░░░░░] ⚠️                                  │
│ Fail: 3    (0.3%)    [░░░░░░░░░░░░░░░░░░] 🔴                                  │
│ Skip: 50   (4.2%)    [░░░░░░░░░░░░░░░░░░] ⚪                                  │
│                                                                                 │
├─────────────────┬──────────────────┬──────────────────┬────────────────────────┤
│ QUALITY TREND   │ FAILED RULES     │ AFFECTED DATA    │ REMEDIATION ACTIONS  │
│ (7-day line)    │ BREAKDOWN (pie)  │ (top 5 table)    │ (recommended)        │
│                 │                  │                  │                      │
│ [Line chart     │ [Pie chart:      │ 1. Missing Email │ 1. Backfill 150 cust.│
│  showing trend] │  Completeness,   │    150 recs      │    email addresses   │
│                 │  Accuracy,       │ 2. Invalid Phone │ 2. Reformat 42 phone │
│                 │  Consistency]    │    42 recs       │    numbers           │
│                 │                  │ 3. NULL Amount   │ 3. Investigate NULL  │
│                 │                  │    8 recs        │    transaction amts   │
│                 │                  │ 4. FK Mismatch   │ 4. Fix FK references │
│                 │                  │    5 recs        │ 5. Run revalidation  │
│                 │                  │ 5. Format Error  │                      │
│                 │                  │    3 recs        │ [View All Actions →] │
└─────────────────┴──────────────────┴──────────────────┴────────────────────────┘

Dimensions: 1920×1080
Load Time: <2 seconds
Purpose: Executive view of data health
Audience: All levels
```

---

### Page 2: Detailed Validation Rules

```
┌────────────────────────────────────────────────────────────────────────────────┐
│ VALIDATION RULES DETAILS - RULE-LEVEL ANALYSIS          [← Back] [Export]    │
├────────────────────────────────────────────────────────────────────────────────┤
│ Viewing: All Rules | Show: Failed Only | Sort By: Impact (High → Low)         │
├────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│ DATA COMPLETENESS VALIDATION RULES                                            │
│ ─────────────────────────────────────────────────────────────────────────────  │
│                                                                                 │
│ Rule Name                    Status   Failures  Records  Severity  Last Run   │
│ ────────────────────────────────────────────────────────────────────────────  │
│ Required: Customer.Email     🔴 FAIL  150       10,425   HIGH     2:32 PM    │
│ Required: Order.ProductID    🔴 FAIL  42        3,127    MEDIUM   2:32 PM    │
│ Required: Payment.Amount     ✅ PASS  0         25,000   HIGH     2:32 PM    │
│ Required: Address.PostalCode ⚠️ WARN  5         15,000   LOW      2:32 PM    │
│                                                                                 │
│ DATA ACCURACY VALIDATION RULES                                                │
│ ─────────────────────────────────────────────────────────────────────────────  │
│                                                                                 │
│ Rule Name                        Status   Failures  Impact  Severity  Action   │
│ ────────────────────────────────────────────────────────────────────────────  │
│ Format: Email (RFC 5322)         ✅ PASS  0         0%     MEDIUM   -         │
│ Range: Order Amount (>0)         ✅ PASS  0         0%     HIGH     -         │
│ Format: Phone (E164)             ⚠️ WARN  8         0.08%  LOW      Review    │
│ Format: Date (YYYY-MM-DD)        ✅ PASS  0         0%     MEDIUM   -         │
│                                                                                 │
│ REFERENTIAL INTEGRITY RULES                                                   │
│ ─────────────────────────────────────────────────────────────────────────────  │
│                                                                                 │
│ Rule Name                    Status   FK Failed  Impact   Severity  Action    │
│ ────────────────────────────────────────────────────────────────────────────  │
│ FK: Order.CustomerID         ✅ PASS  0         0%       HIGH     -          │
│ FK: OrderLine.ProductID      🔴 FAIL  5         0.05%    HIGH     Investigate│
│ FK: Invoice.OrderID          ✅ PASS  0         0%       HIGH     -          │
│ FK: Payment.InvoiceID        ✅ PASS  0         0%       MEDIUM   -          │
│                                                                                 │
│ BUSINESS RULES                                                                │
│ ─────────────────────────────────────────────────────────────────────────────  │
│                                                                                 │
│ Rule Name                    Status   Violations  Impact  Severity  Action    │
│ ────────────────────────────────────────────────────────────────────────────  │
│ Order.Amount ≤ Limit         ✅ PASS  0           0%     MEDIUM   -         │
│ Invoice.Date ≥ Order.Date    ⚠️ WARN  3           0.03%  LOW      Monitor   │
│ Payment ≤ Invoice.Amount     ✅ PASS  0           0%     HIGH     -         │
│                                                                                 │
└────────────────────────────────────────────────────────────────────────────────┘

Dimensions: 1920×1080 (scrollable)
Load Time: 3 seconds
Purpose: Rule-level troubleshooting
```

---

## Part 3: Visual Component Examples

### KPI Card Examples

```
STANDARD KPI CARD:
┌──────────────────────┐
│ Success Rate ✅      │
│                      │
│      99.2%           │
│                      │
│ ↑ +0.3% | On Target  │
└──────────────────────┘

ALERT KPI CARD:
┌──────────────────────┐
│ Failed Executions 🔴 │
│                      │
│        2             │
│                      │
│ Actions: [View] [Fix]│
└──────────────────────┘

GAUGE KPI CARD:
┌──────────────────────┐
│ Data Quality ⚠️      │
│                      │
│ 94.2% [████░░░]      │
│                      │
│ Target: 95% Warning  │
└──────────────────────┘
```

---

### Table Examples

```
SORTABLE DATA TABLE:
┌────────────────────────────────────────────────────┐
│ Pipeline          Exec  Success%  Duration  Status │
├────────────────────────────────────────────────────┤
│ Customer Data ↓   427   99.5%    11.2m    ✅      │
│ Finance Ledger    312   98.7%    14.5m    ⚠️      │
│ Vendor Master     189   96.3%    23.4m    ⚠️      │
│ Product Catalog   156   95.8%    9.8m     🔴      │
│ Payment Gateway   98    92.3%    31.2m    🔴      │
│                                                    │
│ Showing 1-5 of 247  [< Prev] [1] [2] [3] [Next >]│
└────────────────────────────────────────────────────┘
```

---

### Chart Examples

```
LINE CHART (Trend):
┌──────────────────────────────────┐
│ Success Rate Trend (24h)         │
│ 100%  ┌────────────────────────┐ │
│ 99%   │  ╱╲  ╭─╮╭─╮            │ │
│ 98%   │ ╱  ╲╱  ╰─╰─╮           │ │
│ 97%   │            ╰─╮         │ │
│ 96%   └────────────────────────┘ │
│       0  4  8 12 16 20    24 hrs│
└──────────────────────────────────┘

BAR CHART (Comparison):
┌──────────────────────────────────┐
│ Failed Rules by Category         │
│                                  │
│ Completeness  ████████ 8         │
│ Accuracy      ██ 2                │
│ Consistency   ████ 4              │
│ Business      ██ 2                │
│                                  │
│ Total: 16 failed rules           │
└──────────────────────────────────┘

PIE CHART (Distribution):
┌──────────────────────────────────┐
│ Validation Status (24h)          │
│                                  │
│        ██ Pass                   │
│       ███ Warn (1.3%)            │
│      ████ Fail (0.3%)            │
│     █████ Skip (4.2%)            │
│                                  │
│ Pass: 847 | Warn: 12 | Fail: 3  │
└──────────────────────────────────┘
```

---

## Part 4: Design Specifications Summary

### Automation Reporting Dashboard

| Element | Specification |
|---------|---------------|
| **Dimensions** | 1920×1080 (Full HD) |
| **Grid** | 4 columns × 7 rows |
| **Visuals** | 16 (Overview: 5 | Detail: 11) |
| **Load Time** | <2s (Overview), <5s (Detail) |
| **Refresh** | Every 5 minutes |
| **Color Scheme** | Green/Amber/Red status |
| **Font** | Segoe UI, 10-14pt |
| **Key Metrics** | 4 KPIs + Trend + Alerts |

### Validation Insights Dashboard

| Element | Specification |
|---------|---------------|
| **Dimensions** | 1920×1080 (Full HD) |
| **Grid** | 4 columns × 6 rows |
| **Visuals** | 14 (Overview: 6 | Detail: 8) |
| **Load Time** | <2s (Overview), <3s (Detail) |
| **Refresh** | Every 15 minutes |
| **Color Scheme** | Quality scorecard (0-100%) |
| **Font** | Segoe UI, 10-14pt |
| **Key Metrics** | 5 Quality dimensions + Trends |

---

## Part 5: Implementation Checklist

Before finalizing dashboards:

### Design Validation
- [ ] Layout approved by stakeholders
- [ ] Color scheme accessible (color-blind tested)
- [ ] Typography consistent and readable
- [ ] All icons and indicators defined
- [ ] Responsive design tested (desktop/tablet/mobile)

### Content Validation
- [ ] All required metrics included
- [ ] KPI definitions documented
- [ ] Data sources identified
- [ ] Calculation logic verified
- [ ] Drill-through paths mapped

### Visual Validation
- [ ] Charts display correctly
- [ ] Tables sort and filter
- [ ] Formatting consistent
- [ ] No overlapping elements
- [ ] Performance acceptable

### Accessibility Validation
- [ ] Contrast ratio ≥ 4.5:1
- [ ] Color-blind friendly
- [ ] Text minimum 10pt
- [ ] Keyboard navigation works
- [ ] Alt text added

### Export Validation
- [ ] Screenshots at 300 DPI
- [ ] File naming consistent
- [ ] File sizes reasonable
- [ ] Metadata complete
- [ ] Quality approved

---

**Status**: Design mockups complete  
**Next Step**: Export screenshots using [DASHBOARD_EXPORT_FINALIZATION_GUIDE.md](DASHBOARD_EXPORT_FINALIZATION_GUIDE.md)

