# Data Validation Visuals - DAX Measures & Implementation

## Data Validation Data Model Requirements

### Fact Tables
1. **Fact_DataQuality**: Data quality metrics per execution
   - QualityCheckID (Key)
   - ExecutionDate
   - DataSourceID
   - CompletenessScore (0-100)
   - AccuracyScore (0-100)
   - ConsistencyScore (0-100)
   - FreshnessScore (0-100)
   - OverallQualityScore
   - RecordsValidated
   - RecordsFailed

2. **Fact_ValidationRule**: Individual validation rule execution
   - ValidationRuleID (Key)
   - DataSourceID
   - ExecutionDate
   - RuleName
   - RuleStatus (Passed/Failed/Warning)
   - RecordsAffected
   - ImpactScore (0-100)

3. **Fact_DataIssue**: Data quality issues discovered
   - IssueID (Key)
   - DataSourceID
   - IssueType (Completeness/Accuracy/Consistency/Freshness)
   - Severity (Critical/High/Medium/Low)
   - RecordsAffected
   - DateDetected
   - DateResolved
   - Description

4. **Fact_DataAnomaly**: Anomalies detected in data
   - AnomalyID (Key)
   - MetricName
   - DataSourceID
   - DetectionDate
   - AnomalyType (Outlier/Pattern Break/Spike/Dip)
   - Severity (Critical/High/Medium/Low)
   - Context (expected vs actual)

5. **Fact_DataLineage**: Data source connectivity and freshness
   - DataSourceID (Key)
   - LastSuccessfulLoadTime
   - NextScheduledLoadTime
   - CurrentStatus (Connected/Failed/Warning)
   - LoadDurationMinutes
   - RecordsLoaded
   - DataVolumeGB

### Dimension Tables
1. **Dim_DataSource**: Data source definitions
   - DataSourceID
   - SourceName
   - SourceType (Database/API/File/Cloud)
   - Owner
   - SLAMinutes

2. **Dim_Date**: Standard date dimension

---

## DAX Measures - Data Validation

### DATA QUALITY SCORE MEASURES

#### Measure 1: Overall Data Quality Score
```dax
Overall Data Quality Score = 
    AVERAGE(
        CALCULATETABLE(
            Fact_DataQuality[OverallQualityScore],
            ALL(Dim_Date),
            VALUES(Dim_Date)
        )
    )

Format: 0.0"%"
Description: Average of all quality dimensions
Range: 0-100%
Tooltip: Break down by component (Completeness, Accuracy, etc.)
```

#### Measure 2: Data Completeness Score
```dax
Data Completeness Score = 
    AVERAGE(Fact_DataQuality[CompletenessScore])

Format: 0.0"%"
Description: % of required fields populated
Target: ≥ 99%
```

#### Measure 3: Data Accuracy Score
```dax
Data Accuracy Score = 
    AVERAGE(Fact_DataQuality[AccuracyScore])

Format: 0.0"%"
Description: % of records passing validation rules
Target: ≥ 99%
```

#### Measure 4: Data Consistency Score
```dax
Data Consistency Score = 
    AVERAGE(Fact_DataQuality[ConsistencyScore])

Format: 0.0"%"
Description: % of data consistent across sources
Target: ≥ 98%
```

#### Measure 5: Data Freshness Score
```dax
Data Freshness Score = 
    AVERAGE(Fact_DataQuality[FreshnessScore])

Format: 0.0"%"
Description: % of records updated within SLA
Target: ≥ 98%
```

---

### VALIDATION RULE MEASURES

#### Measure 6: Validation Rules Total Count
```dax
Validation Rules Total = 
    DISTINCTCOUNT(Fact_ValidationRule[ValidationRuleID])

Format: #,##0
Description: Total number of validation rules defined
```

#### Measure 7: Validation Rules Passed
```dax
Validation Rules Passed = 
    CALCULATE(
        COUNTROWS(Fact_ValidationRule),
        Fact_ValidationRule[RuleStatus] = "Passed"
    )

Format: #,##0
Description: Number of rules passed in current period
```

#### Measure 8: Validation Rules Failed
```dax
Validation Rules Failed = 
    CALCULATE(
        COUNTROWS(Fact_ValidationRule),
        Fact_ValidationRule[RuleStatus] = "Failed"
    )

Format: #,##0
Description: Number of rules failed in current period
Alert: Red if > 0
```

#### Measure 9: Validation Pass Rate
```dax
Validation Pass Rate = 
    DIVIDE(
        [Validation Rules Passed],
        [Validation Rules Total],
        0
    ) * 100

Format: 0.0"%"
Description: % of validation rules passing
Target: ≥ 95%
```

#### Measure 10: Records Failed Validation
```dax
Records Failed Validation = 
    SUMX(
        Fact_ValidationRule,
        IF(Fact_ValidationRule[RuleStatus] = "Failed",
            Fact_ValidationRule[RecordsAffected],
            0
        )
    )

Format: #,##0
Description: Total records failing validation rules
Related: By rule, by source, by type
```

---

### DATA QUALITY ISSUES MEASURES

#### Measure 11: Critical Issues Count
```dax
Critical Data Issues = 
    CALCULATE(
        COUNTROWS(Fact_DataIssue),
        Fact_DataIssue[Severity] = "Critical",
        ISBLANK(Fact_DataIssue[DateResolved])
    )

Format: #,##0
Description: Count of unresolved critical data quality issues
Alert: Red if > 0
```

#### Measure 12: Data Issues by Severity
```dax
High Issues Count = 
    CALCULATE(
        COUNTROWS(Fact_DataIssue),
        Fact_DataIssue[Severity] = "High",
        ISBLANK(Fact_DataIssue[DateResolved])
    )

Medium Issues Count = 
    CALCULATE(
        COUNTROWS(Fact_DataIssue),
        Fact_DataIssue[Severity] = "Medium",
        ISBLANK(Fact_DataIssue[DateResolved])
    )

Low Issues Count = 
    CALCULATE(
        COUNTROWS(Fact_DataIssue),
        Fact_DataIssue[Severity] = "Low",
        ISBLANK(Fact_DataIssue[DateResolved])
    )

Format: #,##0
Description: Issues count by severity level
Use: Alert cards, priority queue
```

#### Measure 13: Data Issues Resolved Rate
```dax
Data Issues Resolved % = 
    DIVIDE(
        CALCULATE(
            COUNTROWS(Fact_DataIssue),
            NOT(ISBLANK(Fact_DataIssue[DateResolved]))
        ),
        COUNTROWS(Fact_DataIssue),
        0
    ) * 100

Format: 0.0"%"
Description: % of data issues resolved
Target: ≥ 95% within SLA
```

#### Measure 14: Affected Records Count
```dax
Records Affected by Issues = 
    SUMX(
        Fact_DataIssue,
        Fact_DataIssue[RecordsAffected]
    )

Format: #,##0
Description: Total records impacted by data quality issues
Related: By issue type, by severity, by source
```

---

### DATA ANOMALY MEASURES

#### Measure 15: Anomalies Detected Total
```dax
Total Anomalies = 
    COUNTROWS(Fact_DataAnomaly)

Format: #,##0
Description: Total anomalies detected in current period
Related: By type, by severity
```

#### Measure 16: Critical Anomalies
```dax
Critical Anomalies = 
    CALCULATE(
        COUNTROWS(Fact_DataAnomaly),
        Fact_DataAnomaly[Severity] = "Critical"
    )

High Anomalies = 
    CALCULATE(
        COUNTROWS(Fact_DataAnomaly),
        Fact_DataAnomaly[Severity] = "High"
    )

Format: #,##0
Description: Anomalies by severity classification
Alert: Red if critical > 0
```

#### Measure 17: Anomalies by Type
```dax
Outlier Count = 
    CALCULATE(
        COUNTROWS(Fact_DataAnomaly),
        Fact_DataAnomaly[AnomalyType] = "Outlier"
    )

Pattern Break Count = 
    CALCULATE(
        COUNTROWS(Fact_DataAnomaly),
        Fact_DataAnomaly[AnomalyType] = "Pattern Break"
    )

Spike Dip Count = 
    CALCULATE(
        COUNTROWS(Fact_DataAnomaly),
        Fact_DataAnomaly[AnomalyType] IN {"Spike", "Dip"}
    )

Format: #,##0
Description: Anomalies categorized by type
Use: Anomaly detection dashboard
```

---

### DATA SOURCE HEALTH MEASURES

#### Measure 18: Data Source Uptime
```dax
Data Source Connected = 
    CALCULATE(
        COUNTROWS(Dim_DataSource),
        Dim_DataSource[Status] = "Connected"
    )

Data Source Failed = 
    CALCULATE(
        COUNTROWS(Dim_DataSource),
        Dim_DataSource[Status] = "Failed"
    )

Data Source Uptime % = 
    DIVIDE(
        [Data Source Connected],
        COUNTROWS(Dim_DataSource),
        0
    ) * 100

Format: 0.0"%"
Description: % of data sources currently connected
Target: 100% (all sources connected)
```

#### Measure 19: Average Data Load Time
```dax
Average Load Duration = 
    AVERAGE(Fact_DataLineage[LoadDurationMinutes])

Format: 0.0
Description: Average time to load data (in minutes)
Related: By source, by load frequency
```

#### Measure 20: Last Load Success Rate
```dax
Loads Successful = 
    CALCULATE(
        COUNTROWS(Fact_DataLineage),
        Fact_DataLineage[CurrentStatus] = "Connected"
    )

Loads Successful % = 
    DIVIDE(
        [Loads Successful],
        COUNTROWS(Fact_DataLineage),
        0
    ) * 100

Format: 0.0"%"
Description: % of data loads successful
Target: ≥ 99%
```

#### Measure 21: Data Freshness by Source
```dax
Minutes Since Last Load = 
    INT((NOW() - MAX(Fact_DataLineage[LastSuccessfulLoadTime])) * 24 * 60)

Format: 0
Description: Minutes elapsed since last successful data load
Related: By source
```

---

### DATA VOLUME MEASURES

#### Measure 22: Total Records Validated
```dax
Total Records Validated = 
    SUMX(
        Fact_DataQuality,
        Fact_DataQuality[RecordsValidated]
    )

Format: #,##0
Description: Total records processed in validation
Related: By source, by date
```

#### Measure 23: Total Data Volume GB
```dax
Total Data Volume GB = 
    SUMX(
        Fact_DataLineage,
        Fact_DataLineage[DataVolumeGB]
    )

Format: 0.0" GB"
Description: Total data volume processed
Related: By source, trend over time
```

#### Measure 24: Failed vs Passed Records
```dax
Records Passed = 
    [Total Records Validated] - [Records Failed Validation]

Pass Rate = 
    DIVIDE(
        [Records Passed],
        [Total Records Validated],
        0
    ) * 100

Format: 0.0"%"
Description: % of records passing all validations
Target: ≥ 99%
```

---

### QUALITY TREND MEASURES

#### Measure 25: Quality Score Previous Day
```dax
Quality Score Previous Day = 
    CALCULATE(
        [Overall Data Quality Score],
        DATEADD(Dim_Date[Date], -1, DAY)
    )

Format: 0.0"%"
Description: Previous day's quality score for trend
Use: Trend arrow indicator
```

#### Measure 26: Quality Score Trend
```dax
Quality Score Change = 
    [Overall Data Quality Score] - [Quality Score Previous Day]

Quality Score Change % = 
    DIVIDE(
        [Quality Score Change],
        [Quality Score Previous Day],
        0
    ) * 100

Format: 0.0"%"
Description: Day-over-day quality change
Positive: Improvement, Negative: Decline
```

#### Measure 27: Issues Resolved Trend
```dax
Issues Resolved This Week = 
    CALCULATE(
        COUNTROWS(Fact_DataIssue),
        NOT(ISBLANK(Fact_DataIssue[DateResolved])),
        Fact_DataIssue[DateResolved] >= TODAY() - 7,
        Fact_DataIssue[DateResolved] <= TODAY()
    )

Format: #,##0
Description: Issues resolved in last 7 days
Use: Trend tracking, SLA monitoring
```

---

## HELPER MEASURES & CLASSIFICATIONS

#### Quality Level Classification
```dax
[Quality Level] = 
    IF([Overall Data Quality Score] >= 95, "Excellent",
        IF([Overall Data Quality Score] >= 85, "Good",
            IF([Overall Data Quality Score] >= 75, "Fair",
                "Poor"
            )
        )
    )
```

#### SLA Compliance
```dax
[Load Time vs SLA] = 
    DIVIDE(
        [Average Load Duration],
        MAX(Dim_DataSource[SLAMinutes]),
        0
    ) * 100

[SLA Met] = 
    IF([Load Time vs SLA] <= 100, TRUE, FALSE)
```

#### Data Quality Score Components
```dax
[Quality Component Count] = 4  -- Completeness, Accuracy, Consistency, Freshness
[Average Component Score] = 
    ([Data Completeness Score] + [Data Accuracy Score] + 
     [Data Consistency Score] + [Data Freshness Score]) / 4
```

---

## Dashboard-Specific Measure Collections

### For Data Quality Score KPI Card
- Overall Data Quality Score
- Quality Score Previous Day
- Quality Score Change
- Quality Level Classification

### For Quality Trend Chart
- Overall Data Quality Score
- Data Completeness Score
- Data Accuracy Score
- Data Consistency Score
- Data Freshness Score

### For Validation Rules Status
- Validation Rules Total
- Validation Rules Passed
- Validation Rules Failed
- Validation Pass Rate

### For Data Issues Table
- Critical Data Issues
- High / Medium / Low Issues
- Records Affected by Issues
- Data Issues Resolved %

### For Anomaly Detection
- Total Anomalies
- Critical / High Anomalies
- Outlier / Pattern Break / Spike counts
- Anomalies by source

### For Data Source Health
- Data Source Uptime %
- Average Load Duration
- Data Freshness by Source
- Total Data Volume GB

---

## Performance Optimization

1. **Incremental Fact Tables**: Load only new validation results daily
2. **Aggregated Tables**: Pre-aggregate daily quality scores
3. **Measure Caching**: Store calculated values for previous periods
4. **Partitioning**: Partition large fact tables by date
5. **Index Strategy**: Index on DataSourceID, ExecutionDate for fast filtering

---

## Testing Checklist

- [ ] All quality scores range 0-100%
- [ ] Failed record counts don't exceed total records
- [ ] Pass rates calculate correctly
- [ ] Trend measures work with date slicers
- [ ] Issue counts include only open/active items
- [ ] Anomaly detection captures all severity levels
- [ ] Data freshness calculates correctly for all sources
- [ ] Volume measures match source system counts
- [ ] All measures perform < 1 second
- [ ] Drill-down details match summary KPIs

