# Power BI Connections Configuration

## Overview
This document defines all data source connections required for the Enterprise KPI Platform Power BI implementation.

---

## 1. Primary Data Warehouse Connection

### Connection Details
```
Name: Enterprise_Data_Warehouse
Type: SQL Server (Native)
Server: [warehouse.server.com] or [localhost\SQLEXPRESS]
Database: Enterprise_KPI_DataWarehouse
Authentication: Windows / SQL Authentication
Import Mode: Direct Query / Import Mode (recommended for performance)
```

### Connection Parameters
- **Encryption**: Enabled (TLS 1.2+)
- **Connection Timeout**: 30 seconds
- **Command Timeout**: 300 seconds (5 minutes)
- **Data Connectivity Mode**: Import (for dashboards)
- **Refresh Frequency**: Daily (configurable)

### Credentials Management
- Use Service Principal for automated refreshes
- Store credentials in Power BI Service
- Enable SSO (Single Sign-On) where available
- Service Account: `pbi-svc@company.com`

---

## 2. Additional Data Sources

### 2.1 HR/Employee Database
```
Name: HR_System_Connection
Type: SQL Server
Server: hr.database.com
Database: HR_Master
Purpose: Employee metrics, Workforce analytics
```

### 2.2 Customer CRM System
```
Name: CRM_Connection
Type: Dynamics 365 / Salesforce (via OData)
Endpoint: https://crm.company.com/api/
Purpose: Customer data, sales pipeline
Authentication: OAuth 2.0
Refresh: Real-time (with 15-min cache)
```

### 2.3 Financial Systems
```
Name: Finance_ERP_Connection
Type: SAP / Oracle (via ODBC/API)
Purpose: General Ledger, AP/AR, Expense data
Refresh: Daily at 1 AM (off-peak)
```

### 2.4 Cloud Storage (Optional)
```
Name: Azure_Blob_Storage
Type: Azure Blob Storage
Container: enterprise-kpi-data
Purpose: Backup data exports, archival
Authentication: Shared Access Key
```

---

## 3. Connection String Examples

### SQL Server (Windows Auth)
```
Server=warehouse.company.com,1433;Database=Enterprise_KPI_DW;Integrated Security=true;Encrypt=true;TrustServerCertificate=false;
```

### SQL Server (SQL Auth)
```
Server=warehouse.company.com,1433;Database=Enterprise_KPI_DW;User Id=pbi_user;Password=[securely stored];Encrypt=true;TrustServerCertificate=false;
```

### Excel/CSV (Share Point)
```
https://company.sharepoint.com/sites/analytics/Shared%20Documents/KPI_Data/
```

---

## 4. Power BI Gateway Setup (For On-Premises Data)

### Gateway Configuration
- **Gateway Type**: Personal Gateway (dev) / Enterprise Gateway (prod)
- **Gateway Name**: EnterpriseKPI-Gateway-East
- **Region**: East US
- **Members**: Data team, BI team admins

### Registered Data Sources
```
1. Enterprise_Data_Warehouse (SQL Server)
2. HR_System (SQL Server)
3. Finance_Reports (Excel)
4. CRM_System (OData)
```

### Gateway Health Monitoring
- Check status: Daily
- Alert on: Connection failures, timeout errors
- Fallback: Retry with exponential backoff

---

## 5. Connection Security Best Practices

✓ **Mandatory**:
- Encrypt all connections (SSL/TLS)
- Use Service Principals instead of personal accounts
- Store credentials in Power BI Service, not in files
- Enable Multi-Factor Authentication for admins
- Audit all connection activities

✓ **Optional but Recommended**:
- Implement VPN tunnel for on-premises connections
- Use Row-Level Security (RLS) for sensitive data
- Enable Power BI Premium capacity for better refresh rates
- Set up disaster recovery connection string

---

## 6. Connection Refresh Schedule

| Data Source | Refresh Frequency | Peak Hours Avoidance | Notes |
|---|---|---|---|
| Finance_Fact Tables | Daily (1 AM) | Yes | Critical for exec reports |
| Customer_Dimension | Daily (2 AM) | Yes | Used across dashboards |
| Sales_Transaction | Hourly (off-peak) | Yes | Real-time data needs |
| HR_Employee | Weekly (Fri 1 AM) | Yes | Org structure data |
| CRM_Opportunity | Daily (3 AM) | Yes | Pipeline tracking |
| External_Benchmark | Monthly (1st, 1 AM) | No | Comparison data |

---

## 7. Connection Monitoring & Alerts

### Power BI Service Notifications
```
Enable alerts for:
- Failed refresh attempts
- Connection timeouts
- Permission/authentication errors
- Refresh duration > 60 minutes
```

### Health Check Dashboard
Create a monitor dashboard tracking:
- Last successful refresh timestamp
- Refresh duration (min/max/avg)
- Data staleness warnings
- Connection availability %

---

## 8. Troubleshooting Connection Issues

### Common Issues & Solutions

| Issue | Cause | Solution |
|---|---|---|
| Connection timeout | Network latency | Increase timeout, check firewall |
| Authentication failed | Wrong credentials | Verify service account, update in PBI Service |
| Gateway error | Gateway offline | Restart gateway, check logs |
| Data not updating | Refresh disabled | Enable refresh, check schedule |
| Performance slow | Large dataset | Implement aggregations, incremental refresh |

---

## 9. Next Steps

1. ✓ Configure SQL Server connection to data warehouse
2. ✓ Set up Power BI Gateway (if on-premises)
3. ✓ Configure service principal for unattended refresh
4. ✓ Test all data source connections
5. ✓ Set up refresh schedules
6. ✓ Create connection health monitor dashboard
