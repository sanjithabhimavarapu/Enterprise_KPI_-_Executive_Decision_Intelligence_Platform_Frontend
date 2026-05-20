# Power BI Quick Reference Guide

## 📋 Files Overview

This guide provides quick links and summaries of all Power BI configuration documents.

---

## 🗂️ Core Configuration Files

### 1. [connections_config.md](connections_config.md)
**Purpose**: Database connections and data source setup
**Key Topics**:
- SQL Server connection strings
- Gateway configuration
- Connection security best practices
- Refresh schedules
- Troubleshooting connection issues

**Quick Links**:
- Service Account: `pbi-svc@company.com`
- Connection Timeout: 30 seconds
- Refresh: Daily (1 AM UTC)

---

### 2. [warehouse_tables_import.md](warehouse_tables_import.md)
**Purpose**: Warehouse table structure and import specifications
**Key Topics**:
- Dimension tables (Date, Customer, Product, Employee, Geography)
- Fact tables (Sales, Finance, Customer Metrics, Operational Metrics)
- Incremental refresh strategy
- Data transformation rules
- Refresh schedule by table type

**Quick Reference**:
```
Dimensions: Import full, refresh weekly
Facts: Incremental, refresh daily
Refresh Time: Midnight - 2 AM UTC
```

---

### 3. [data_relationships.md](data_relationships.md)
**Purpose**: Data model relationships configuration
**Key Topics**:
- Primary relationships (18 total)
- Cardinality rules (1:*, 1:1, avoid *:*)
- Cross-filter directions
- Hierarchy setup
- Relationship validation

**Quick Reference**:
```
✓ Always: Dimension → Fact (1:*)
✓ Careful: Dimension ↔ Dimension (Both directions)
✗ Avoid: Many-to-many (*:*) relationships
```

---

### 4. [power_query_m_code.md](power_query_m_code.md)
**Purpose**: Power Query transformation code
**Key Topics**:
- Import queries for each table
- Data quality checks
- Calculated columns
- Incremental refresh patterns
- Performance optimization

**Quick Copy-Paste**:
Find ready-to-use M code for each table:
- Dim_Date, Dim_Customer, Dim_Product, etc.
- Fact_Sales, Fact_Finance, Fact_Customer_Metrics
- Data validation queries

---

### 5. [dax_measures.md](dax_measures.md)
**Purpose**: DAX measure definitions (36+ measures)
**Key Topics**:
- Financial measures (Revenue, Profit, Margins)
- Customer metrics (Retention, Churn, CLV, NPS)
- Operational metrics (On-time delivery, fulfillment)
- Time intelligence (YoY, MoM, QoQ)
- Status/conditional measures

**Quick Copy-Paste**:
Find ready-to-use DAX for:
- Any financial metric
- Customer analysis
- Operational KPIs
- Trend analysis

---

### 6. [implementation_checklist.md](implementation_checklist.md)
**Purpose**: Step-by-step implementation guide
**Key Topics**:
- 8-week implementation timeline
- Phase-by-phase checklist
- Pre-launch and post-launch activities
- Success criteria
- Sign-off documentation

**Timeline**: 8 weeks (Phase 1-8)

---

## 🎯 Quick Start Guide

### For Data Engineers
1. Read: `connections_config.md` → Set up connections
2. Read: `warehouse_tables_import.md` → Create table imports
3. Copy: `power_query_m_code.md` → Paste M code into Power Query
4. Follow: `implementation_checklist.md` → Phase 1-3

### For BI Developers
1. Read: `data_relationships.md` → Understand model
2. Read: `dax_measures.md` → Create measures
3. Follow: `implementation_checklist.md` → Phase 4-5

### For Project Managers
1. Read: `implementation_checklist.md` → Create project plan
2. Assign teams to phases
3. Set up communication and tracking

---

## 📊 Data Model Summary

### Dimensions (6 tables)
| Table | Rows | Refresh | Key Field |
|---|---|---|---|
| Dim_Date | 10K | Annual | DateKey |
| Dim_Company | 1K | Weekly | CompanyKey |
| Dim_Customer | 500K | Daily | CustomerKey |
| Dim_Product | 100K | Weekly | ProductKey |
| Dim_Employee | 50K | Daily | EmployeeKey |
| Dim_Geography | 5K | Quarterly | GeographyKey |

### Facts (4 tables)
| Table | Rows | Refresh | Strategy |
|---|---|---|---|
| Fact_Sales | 50M | Daily | Incremental (90 days) |
| Fact_Finance | 2M | Daily | Import |
| Fact_Customer_Metrics | 5M | Daily | Import (24 months) |
| Fact_Operational_Metrics | 1M | Daily | Import |

---

## 🔑 Key Relationships (18 Total)

### Active Relationships (Required)
```
✓ Dim_Date → Fact_Sales (OrderDate)
✓ Dim_Date → Fact_Finance
✓ Dim_Date → Fact_Customer_Metrics
✓ Dim_Customer → Fact_Sales
✓ Dim_Product → Fact_Sales
✓ Dim_Employee → Fact_Sales
✓ Dim_Geography → Fact_Sales
✓ Dim_Company → Fact_Sales
✓ Dim_Company → Fact_Finance
```

### Inactive Relationships (Context-specific)
```
○ Dim_Date → Fact_Sales (ShipDate)
○ Dim_Date → Fact_Sales (DeliveryDate)
```

---

## 📈 Key Measures (36 Total)

### Essential Measures
- **[Total Revenue]** - Sum of all sales
- **[Net Profit]** - Revenue minus COGS
- **[Profit Margin %]** - Profitability ratio
- **[Total Customers]** - Unique customers with sales
- **[Customer Retention Rate]** - % customers retained
- **[On-Time Delivery Rate]** - Delivery performance

### Trending Measures
- **[YTD Revenue]** - Year-to-date total
- **[Prior Year Revenue]** - Same period last year
- **[Revenue Growth %]** - YoY growth rate
- **[MoM Change]** - Month-over-month change

### Status Measures
- **[Revenue Status]** - Traffic light indicator
- **[Churn Risk Level]** - Risk category
- **[Top Salesperson]** - Best performer
- **[Best Selling Product]** - Top product

---

## 🔄 Refresh Schedule

```
Midnight - 1 AM UTC:
  • Fact_Sales (Incremental)
  • Fact_Customer_Metrics
  • Fact_Operational_Metrics

2 AM UTC:
  • Dim_Customer
  • Dim_Employee
  • Fact_Finance

Weekly (Sundays, 3 AM UTC):
  • All dimension tables (full refresh)
  • Incremental reset
```

---

## ⚡ Performance Tips

### For Data Models
```
✓ DO:
  - Use INT for foreign keys (faster)
  - Create aggregations for large facts
  - Use RELATED() in measures
  - Enable "Assume Referential Integrity"

✗ DON'T:
  - Use many-to-many relationships
  - Create *bidirectional* relationships excessively
  - Filter in DAX that could be in Power Query
  - Reference calculated columns in measures
```

### For Dashboards
```
✓ DO:
  - Use slicers for drill-down
  - Implement drill-through for detail
  - Cache frequently used measures
  - Limit visuals per page to 6-8

✗ DON'T:
  - Add 20+ visuals per page
  - Use live connections for large models
  - Create circular filter loops
  - Build measures that recalculate from scratch
```

---

## 🛠️ Common Tasks

### Add a New KPI
1. Define business logic
2. Create DAX measure in `[dax_measures.md](dax_measures.md)` format
3. Add to appropriate dashboard
4. Test with sample data
5. Add to documentation

### Fix Calculation Error
1. Check measure in `[dax_measures.md](dax_measures.md)`
2. Verify relationships in `[data_relationships.md](data_relationships.md)`
3. Validate source data in `[warehouse_tables_import.md](warehouse_tables_import.md)`
4. Check Power Query in `[power_query_m_code.md](power_query_m_code.md)`

### Improve Refresh Performance
1. Check refresh times in logs
2. Enable incremental refresh (see `[warehouse_tables_import.md](warehouse_tables_import.md)`)
3. Create aggregations for large fact tables
4. Review and optimize DAX measures
5. Check for circular dependencies

### Troubleshoot Connection Error
1. Refer to `[connections_config.md](connections_config.md)`
2. Verify connection string format
3. Test credentials
4. Check gateway status
5. Review logs for timeout/auth errors

---

## 👥 Team Assignments

### Data Engineer
- **Owns**: connections_config.md, warehouse_tables_import.md, power_query_m_code.md
- **Tasks**: Connections, table imports, Power Query transformations

### BI Developer
- **Owns**: data_relationships.md, dax_measures.md
- **Tasks**: Model design, relationship setup, measure creation

### Report Developer
- **Owns**: Dashboard development
- **Tasks**: Create dashboards using measures from data model

### Project Manager
- **Owns**: implementation_checklist.md
- **Tasks**: Timeline, coordination, phase tracking

---

## 📞 Support & Resources

### Troubleshooting Resources
- **Connection Issues** → See `connections_config.md` Section 8
- **Data Quality** → See `warehouse_tables_import.md` Section 10
- **Relationship Problems** → See `data_relationships.md` Section 8
- **Measure Errors** → See `dax_measures.md` Section 11

### External Resources
- Power BI Documentation: https://docs.microsoft.com/power-bi/
- DAX Function Reference: https://dax.guide/
- Power Query M Reference: https://docs.microsoft.com/power-query/power-query-m-reference
- SQL Server Docs: https://docs.microsoft.com/sql/

---

## ✅ Implementation Checklist Summary

| Phase | Duration | Key Milestones |
|---|---|---|
| Setup & Connections | Week 1 | Connections tested |
| Data Import | Week 2-3 | All tables imported |
| Relationships | Week 3-4 | Model validated |
| DAX Measures | Week 4-5 | All measures created & tested |
| Dashboards | Week 5-6 | All dashboards complete |
| Optimization | Week 6 | Performance targets met |
| Security | Week 6-7 | RLS configured, secure |
| Deployment | Week 7-8 | Live in production |

---

## 📝 Version History

| Version | Date | Changes |
|---|---|---|
| 1.0 | 2026-05-20 | Initial release with all core files |

---

## 🎓 Document Legend

| Icon | Meaning |
|---|---|
| ✓ | Recommended / Best Practice |
| ✗ | Avoid / Anti-pattern |
| ○ | Optional / Conditional |
| ⚠️ | Warning / Important |
| 🔄 | Recurring / Cyclical |

---

**Last Updated**: May 20, 2026
**Status**: Ready for Implementation
**Contact**: BI Team Lead
