# Scheduled Power BI Refresh & Monitoring Guide

## Overview
This guide provides step-by-step instructions for configuring scheduled data refresh in Power BI Service and setting up comprehensive refresh monitoring for the Enterprise KPI Platform.

---

## Part 1: Scheduled Refresh Configuration

### 1.1 Prerequisites

Before configuring scheduled refresh, ensure:
- ✓ Power BI Premium or Power BI Pro licenses assigned to users
- ✓ Datasets published to Power BI Service
- ✓ Service principal or user account created for automated refresh
- ✓ Data source credentials stored securely
- ✓ Power BI Gateway installed (if using on-premises data sources)
- ✓ Network connectivity and firewall rules configured

### 1.2 Refresh Schedule by Dataset

Based on the Enterprise KPI Platform architecture:

```
EXECUTIVE DASHBOARD DATASET
├── Refresh Frequency: Every 15 minutes
├── Time Windows: 6 AM - 10 PM (business hours)
├── Peak Avoidance: Yes (avoid 8 AM - 9 AM, 12 PM - 1 PM)
├── SLA: 99% availability
└── Timeout: 30 minutes

GOVERNANCE DASHBOARD DATASET
├── Refresh Frequency: Every 5 minutes
├── Time Windows: 24/7 (continuous)
├── Peak Avoidance: No
├── SLA: 99.5% availability
└── Timeout: 15 minutes

VALIDATION DASHBOARD DATASET
├── Refresh Frequency: Every 5 minutes
├── Time Windows: 24/7 (continuous)
├── Peak Avoidance: No
├── SLA: 99.5% availability
└── Timeout: 15 minutes

OPERATIONS/PIPELINE MONITORING DATASET
├── Refresh Frequency: Every 1 minute
├── Time Windows: 24/7 (continuous)
├── Peak Avoidance: No
├── SLA: 99.5% availability
└── Timeout: 5 minutes
```

### 1.3 Step-by-Step: Configure Scheduled Refresh in Power BI Service

#### Step 1: Access Dataset Settings
```
1. Go to Power BI Service (app.powerbi.com)
2. Navigate to Workspace → Datasets tab
3. Select the dataset to configure
4. Click "..." (three dots) → Settings
5. Expand "Scheduled refresh" section
```

#### Step 2: Configure Refresh Schedule

**For Executive Dashboard Dataset (15-minute cadence):**
```
1. Toggle "Scheduled refresh" → ON
2. Select "New scheduled refresh"
3. Set frequency:
   - Frequency: Daily
   - Time: Multiple times per day
4. Add refresh times:
   - 6:00 AM, 6:15 AM, 6:30 AM, ... 10:00 PM
5. Skip peak hours: 8:00-9:00 AM, 12:00-1:00 PM
6. Save
```

**For Governance/Validation Datasets (5-minute cadence):**
```
1. Toggle "Scheduled refresh" → ON
2. Set frequency:
   - Frequency: Daily
   - Time: Multiple times per day
3. Add refresh times:
   - Every 5 minutes starting 12:00 AM
4. No peak hour avoidance
5. Save
```

**For Pipeline Monitoring Dataset (1-minute real-time):**
```
1. Note: 1-minute refresh requires DirectQuery or Direct Refresh
2. If using Import mode:
   - Frequency: Daily
   - Time: Every 1 minute
   - Enable all 24 hours
3. If using DirectQuery:
   - Automatic real-time updates from source
   - No scheduled refresh needed in Power BI
```

#### Step 3: Configure Data Source Credentials

```
1. In Dataset Settings → Data source credentials
2. For each data source:
   a. Click "Edit credentials"
   b. Select Authentication method:
      - Service Principal (Recommended for production)
      - Credentials (Username/Password)
      - OAuth 2.0 (For cloud services)
3. For Service Principal:
   - Service principal ID
   - Service principal password
   - Tenant ID
4. Test connection
5. Save
```

#### Step 4: Set Refresh Timeout

```
1. In Scheduled refresh settings
2. Set "Maximum timeout" for refresh:
   - Executive Dashboard: 30 minutes
   - Governance/Validation: 15 minutes
   - Pipeline Monitoring: 5 minutes
3. This prevents hung refreshes from blocking subsequent schedules
```

### 1.4 Gateway Configuration (For On-Premises Data)

If using on-premises data sources:

#### Configure Personal Gateway (Development)
```
1. Download Power BI Gateway
2. Install on your machine
3. Sign in with Power BI account
4. Add data sources:
   - Name: Enterprise_Data_Warehouse
   - Type: SQL Server
   - Server: [warehouse.server.com]
   - Database: Enterprise_KPI_DataWarehouse
5. Test connection
6. In Power BI Service → Gateway connections:
   - Select the gateway
   - Verify connection status
```

#### Configure Enterprise Gateway (Production)
```
1. Install on dedicated server/VM
2. Register with Power BI admin
3. Add members: Data team admins
4. Configure data sources (same as Personal Gateway)
5. Enable high availability (multiple gateways)
6. Monitor gateway health regularly
```

#### Gateway Health Monitoring
```
Check daily:
- Status: Online/Offline
- Last refresh status
- Number of active connections
- Gateway logs for errors
- Resource utilization (CPU, memory)
```

---

## Part 2: Refresh Monitoring Setup

### 2.1 Refresh Status Monitoring in Power BI Service

#### Monitor Refresh History
```
1. Go to Power BI Service
2. Select Dataset
3. Click "..." → Refresh history
4. View last 60 days of refresh attempts
5. Check:
   - Refresh status (Success/Failed/Cancelled)
   - Start time
   - End time
   - Duration
   - Failure reason (if failed)
```

#### Set Up Refresh Notifications
```
1. Go to Dataset Settings
2. Under "Scheduled refresh"
3. Enable "Failure notifications"
4. Add email addresses for notifications:
   - Data team lead
   - BI admin
   - Operations team
5. Optionally enable "Success notifications"
6. Save
```

### 2.2 Create Health Check Dashboard

Create a Power BI dashboard to monitor all dataset refreshes:

#### Dashboard Structure
```
REFRESH MONITORING DASHBOARD
├── Header Section
│   ├── Last Refresh Timestamp (all datasets)
│   ├── Current Refresh Status (Success/Failed/In Progress)
│   └── Data Staleness Alert (if > SLA)
│
├── KPI Cards
│   ├── Refresh Success Rate (Last 7 days)
│   ├── Avg Refresh Duration
│   ├── Failed Refreshes Count
│   └── Refresh SLA Compliance %
│
├── Refresh Timeline (Last 24 Hours)
│   ├── Timeline chart showing each refresh
│   ├── Color: Green=Success, Red=Failed, Orange=In Progress
│   └── Hover: Show duration, records loaded, errors
│
├── Dataset Performance Table
│   ├── Dataset Name
│   ├── Last Refresh Time
│   ├── Duration (minutes)
│   ├── Status
│   ├── Records Loaded
│   └── Error Message (if failed)
│
└── Failures & Alerts
    ├── Failed Refresh Details (Last 30 days)
    ├── Error Categories
    ├── Affected Datasets
    └── Retry Status
```

#### Data Source for Health Check Dashboard

Create a helper dataset that tracks refresh metadata:

```sql
-- Refresh_Monitoring_Table
CREATE TABLE dbo.RefreshMonitoring (
    RefreshID INT PRIMARY KEY IDENTITY(1,1),
    DatasetName VARCHAR(200),
    RefreshStartTime DATETIME,
    RefreshEndTime DATETIME,
    RefreshDuration INT, -- minutes
    RefreshStatus VARCHAR(50), -- Success, Failed, In Progress
    RecordsLoaded INT,
    ErrorMessage VARCHAR(MAX),
    ErrorCategory VARCHAR(100),
    SourceDataLatency INT, -- minutes (age of data)
    CreatedDate DATETIME DEFAULT GETDATE()
);

-- Insert refresh metadata (automated)
INSERT INTO dbo.RefreshMonitoring
SELECT 
    'Executive_Dashboard' as DatasetName,
    GETDATE() as RefreshStartTime,
    GETDATE() as RefreshEndTime,
    DATEDIFF(MINUTE, @StartTime, @EndTime) as RefreshDuration,
    CASE WHEN @Error IS NULL THEN 'Success' ELSE 'Failed' END,
    @RecordsLoaded,
    @Error,
    @ErrorCategory,
    DATEDIFF(MINUTE, MAX(ModifiedDate), GETDATE()) as SourceDataLatency
FROM dbo.Dim_Customer;
```

### 2.3 Automated Monitoring & Alerts

#### Option A: Power BI Service Alerts

```
1. In Refresh Monitoring Dashboard
2. Select KPI card (e.g., Success Rate)
3. Click "..." → Set alert
4. Alert type: "When value is below"
5. Threshold: 95%
6. Frequency: Daily
7. Recipients: Data team email
```

#### Option B: Microsoft 365 Integration (Advanced)

```
Create Power Automate workflow:
1. Trigger: On schedule (every hour)
2. Action: Query Power BI REST API
   - GET /groups/{workspace-id}/datasets/{dataset-id}/refreshes
3. Condition: Check latest refresh status
4. If Failed:
   a. Send email alert
   b. Create incident ticket
   c. Notify on Teams channel
5. If Delayed (> SLA):
   a. Send warning email
```

#### Option C: Azure Monitor Integration

```
1. Setup Azure Monitor for Power BI
2. Create metrics:
   - Refresh success rate
   - Refresh duration
   - Refresh failures
3. Configure alerts:
   - If Success Rate < 95% → Alert
   - If Duration > 60 min → Warning
   - If Failed > 3 in 1 hour → Critical
4. Send to Teams/Email
```

### 2.4 Refresh Performance Baseline

Establish and track refresh performance:

```
EXECUTIVE DATASET
├── Target Duration: 5-10 minutes
├── Maximum Duration: 30 minutes
├── Records Loaded: ~5 million
├── Data Freshness: 15 minutes
├── Success Rate Target: ≥ 99%
└── Historical Average: 8.5 minutes

GOVERNANCE DATASET
├── Target Duration: 2-3 minutes
├── Maximum Duration: 15 minutes
├── Records Loaded: ~2 million
├── Data Freshness: 5 minutes
├── Success Rate Target: ≥ 99.5%
└── Historical Average: 2.8 minutes

VALIDATION DATASET
├── Target Duration: 1-2 minutes
├── Maximum Duration: 15 minutes
├── Records Loaded: ~1 million
├── Data Freshness: 5 minutes
├── Success Rate Target: ≥ 99.5%
└── Historical Average: 1.5 minutes

PIPELINE MONITORING DATASET
├── Target Duration: 30-60 seconds
├── Maximum Duration: 5 minutes
├── Records Loaded: ~100 thousand
├── Data Freshness: 1 minute
├── Success Rate Target: ≥ 99.5%
└── Historical Average: 45 seconds
```

---

## Part 3: Troubleshooting Refresh Issues

### 3.1 Common Refresh Problems & Solutions

| Problem | Cause | Solution |
|---------|-------|----------|
| Refresh Failed: Connection Timeout | Network latency or firewall | Check network connectivity, increase timeout to 300s |
| Refresh Failed: Invalid Credentials | Expired password or service principal | Update credentials in Power BI Service |
| Refresh Failed: Gateway Offline | Gateway service stopped | Restart gateway, check service status |
| Refresh Failed: Permission Denied | User lacks data source access | Grant permissions to service principal |
| Refresh Delayed: Taking > Max Duration | Large dataset or slow network | Enable incremental refresh, aggregate data |
| Refresh Stuck/Not Completing | Hung process or large operation | Cancel and retry, check for circular dependencies |
| Refresh Success Rate < 95% | Recurring failures | Implement retry logic, add alerting |
| Data Not Updating | Refresh disabled or not scheduled | Enable refresh schedule, verify configuration |

### 3.2 Refresh Troubleshooting Checklist

```
When refresh fails:
1. [ ] Check Power BI Service → Refresh history for error message
2. [ ] Verify data source is online and accessible
3. [ ] Check credentials in Power BI Service → Settings
4. [ ] Review gateway logs (if using on-premises gateway)
5. [ ] Test connection directly from SQL Server
6. [ ] Check firewall rules and network connectivity
7. [ ] Verify service principal has required permissions
8. [ ] Check for data quality issues in source
9. [ ] Review DAX/Power Query for errors
10. [ ] Check available capacity/resources
11. [ ] Increase timeout and retry
12. [ ] If persistent, create support ticket with timestamp and error details
```

### 3.3 Refresh Failure Recovery

```
Quick Recovery Steps:
1. Manual Retry:
   - Go to Dataset → "..." → Refresh now
   - Wait for completion
   
2. Staggered Retries:
   - Setup Power Automate to retry failed refreshes
   - Exponential backoff: 1 min, 5 min, 15 min, 30 min
   
3. Cascade Recovery:
   - If parent dataset fails, dependent datasets won't refresh
   - Manually trigger parent, then dependencies
   
4. Fallback Data:
   - Keep snapshot of last successful refresh
   - Restore if current refresh fails
   
5. Escalation:
   - If fails 3+ times, escalate to data engineer
   - Check for underlying data issues
```

---

## Part 4: Refresh Optimization

### 4.1 Performance Tuning

```
REDUCE REFRESH DURATION:
1. Enable Incremental Refresh
   - Only load changed data
   - Typical savings: 60-80% faster
   
2. Implement Aggregations
   - Pre-aggregate fact tables
   - Query aggregations instead of fact
   
3. Optimize Power Query
   - Remove unnecessary columns before import
   - Filter data at source, not in Power BI
   - Avoid complex transformations
   
4. Partition Large Datasets
   - Split into multiple datasets by dimension
   - Refresh independently
   
5. Archive Old Data
   - Move 2+ year old data to archive table
   - Keep active data smaller
```

### 4.2 Capacity Planning

```
REFRESH CAPACITY CALCULATOR:

For 4 Datasets with these characteristics:
├── Executive: 5M rows, 15 min refresh, 8 min duration
├── Governance: 2M rows, 5 min refresh, 2 min duration
├── Validation: 1M rows, 5 min refresh, 1.5 min duration
└── Pipeline: 100K rows, 1 min refresh, 45 sec duration

Required Capacity:
- Peak concurrent refreshes: 4 (assuming all overlap)
- Total refresh time: 8 + 2 + 1.5 + 0.75 = 12.25 minutes
- Power BI Premium required: P2 or higher
- Recommended: P3 for production with headroom
```

### 4.3 Cost Optimization

```
REDUCE REFRESH COSTS:

Current Model:
├── Executive: Every 15 min × 24 hours = 96 refreshes/day
├── Governance: Every 5 min × 24 hours = 288 refreshes/day
├── Validation: Every 5 min × 24 hours = 288 refreshes/day
└── Pipeline: Every 1 min × 24 hours = 1,440 refreshes/day
Total: 2,112 refreshes/day

Cost Optimization:
1. Reduce off-business hours refresh frequency
   - Governance: Every 30 min (10 PM - 6 AM) = 24 refreshes
   - Validation: Every 30 min (10 PM - 6 AM) = 24 refreshes
   - Savings: ~264 refreshes/day
   
2. Implement DirectQuery for streaming data
   - Pipeline Monitoring: Real-time from source
   - No scheduled refresh needed
   - Savings: ~1,440 refreshes/day
   
3. Use dataflows for shared transformations
   - Reduces dataset-level refresh work
   - Amortizes cost across datasets
   
Total Savings: ~1,704 refreshes/day (80% reduction)
```

---

## Part 5: Monitoring Checklist & Maintenance

### 5.1 Daily Tasks

```
☐ Check refresh status in Power BI Service
☐ Review Health Check Dashboard
☐ Verify all 4 datasets refreshed successfully
☐ Check for any error emails
☐ Confirm data freshness is within SLA
☐ Monitor refresh duration (no significant increases)
```

### 5.2 Weekly Tasks

```
☐ Review 7-day refresh success rate (target: ≥ 99%)
☐ Analyze refresh duration trends
☐ Check for recurring failure patterns
☐ Review gateway health (if using on-premises)
☐ Validate data quality metrics from Validation dashboard
☐ Check capacity utilization
☐ Review alert logs and false positives
```

### 5.3 Monthly Tasks

```
☐ Performance optimization review
☐ Update refresh baselines if needed
☐ Capacity planning review
☐ Cost analysis (refreshes/cost per refresh)
☐ Security credentials rotation
☐ Disaster recovery test (failover scenarios)
☐ Documentation updates
☐ Stakeholder reporting on refresh SLA compliance
```

### 5.4 Quarterly Tasks

```
☐ Major performance optimization pass
☐ Review and update refresh schedules
☐ Capacity/cost forecast for next quarter
☐ Security audit of service principals
☐ Training/documentation updates
☐ Platform upgrade planning
☐ Cost-benefit analysis of optimizations
```

---

## Part 6: Reference Links & Related Documentation

### Quick Navigation
- [Connections Configuration](./connections_config.md)
- [Warehouse Tables Import](./warehouse_tables_import.md)
- [Executive Dashboard Design](./executive_dashboard_design.md)
- [Governance Dashboard Design](./governance_dashboard_design.md)
- [Validation Pipeline Implementation](./VALIDATION_PIPELINE_IMPLEMENTATION.md)
- [Pipeline Monitoring Specification](./pipeline_monitoring_specification.md)

### Key Contacts
- **Data Engineer**: [Name] - Data refresh issues
- **BI Admin**: [Name] - Power BI Service configuration
- **IT Operations**: [Name] - Gateway and infrastructure
- **Business Owner**: [Name] - Refresh schedule approvals

---

## Appendix A: Power BI REST API for Monitoring

Monitor refreshes programmatically:

```powershell
# Get refresh history for dataset
$datasetId = "your-dataset-id"
$workspaceId = "your-workspace-id"
$token = Get-PowerBIAccessToken

$refreshUrl = "https://api.powerbi.com/v1.0/myorg/groups/$workspaceId/datasets/$datasetId/refreshes"

$refreshes = Invoke-RestMethod -Uri $refreshUrl `
  -Headers @{ Authorization = "Bearer $token" } `
  -Method Get

# Display last 10 refreshes
$refreshes.value | Select-Object -First 10 | 
  Select-Object refreshType, startTime, endTime, status, serviceExceptionJson
```

---

## Appendix B: Service Principal Setup

Create service principal for automated refresh:

```powershell
# In Azure AD
1. Go to Azure Portal → App registrations
2. Create new application: "PowerBI-Automated-Refresh"
3. Create client secret (copy value)
4. Note: Application ID, Tenant ID, Client Secret

# In Power BI Admin
1. Enable Service Principal authentication
2. Add service principal to Power BI
3. Grant permissions to datasets/workspaces

# In Power BI Dataset
1. Go to Dataset Settings
2. Data source credentials
3. Select Service Principal
4. Enter: Client ID, Client Secret, Tenant ID
5. Test connection
6. Save
```

---

## Appendix C: Sample Monitoring Scripts

### Script 1: Daily Refresh Report

```python
import requests
import json
from datetime import datetime, timedelta

# Configuration
POWER_BI_API = "https://api.powerbi.com/v1.0/myorg"
WORKSPACE_ID = "your-workspace-id"
DATASETS = [
    "Executive_Dashboard",
    "Governance_Dashboard",
    "Validation_Dashboard",
    "Pipeline_Monitoring"
]

def get_refresh_history(dataset_id):
    url = f"{POWER_BI_API}/groups/{WORKSPACE_ID}/datasets/{dataset_id}/refreshes"
    response = requests.get(
        url,
        headers={"Authorization": f"Bearer {TOKEN}"}
    )
    return response.json()['value']

def generate_report():
    report = []
    for dataset in DATASETS:
        refreshes = get_refresh_history(dataset)
        last_24h = [r for r in refreshes 
                   if datetime.fromisoformat(r['startTime']) > datetime.now() - timedelta(days=1)]
        
        success_count = sum(1 for r in last_24h if r['status'] == 'Completed')
        failed_count = sum(1 for r in last_24h if r['status'] == 'Failed')
        avg_duration = sum(
            (datetime.fromisoformat(r['endTime']) - 
             datetime.fromisoformat(r['startTime'])).total_seconds() 
            for r in last_24h if r['status'] == 'Completed'
        ) / max(success_count, 1)
        
        report.append({
            'Dataset': dataset,
            'Last 24h Refreshes': len(last_24h),
            'Successful': success_count,
            'Failed': failed_count,
            'Success Rate': f"{success_count/len(last_24h)*100:.1f}%" if last_24h else "N/A",
            'Avg Duration (min)': f"{avg_duration/60:.1f}" if success_count > 0 else "N/A"
        })
    
    return report

# Execute
report = generate_report()
for row in report:
    print(json.dumps(row, indent=2))
```

---

**Last Updated**: June 1, 2026
**Version**: 1.0
**Status**: Ready for Implementation
