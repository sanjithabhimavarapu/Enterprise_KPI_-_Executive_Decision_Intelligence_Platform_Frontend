# Automation Reporting Dashboard - DAX Measures Library

## Overview
Comprehensive DAX measure library for pipeline automation status, validation metrics, and operational intelligence. These measures power the Automation Reporting Dashboard focusing on pipeline health, performance, and reliability.

---

## Data Model Prerequisites

### Fact Tables Required
```
Fact_PipelineExecution
├── ExecutionID (Key)
├── PipelineID (FK)
├── StartTime
├── EndTime
├── Duration (minutes)
├── Status (Success, Failed, Running, Timeout)
├── RecordsProcessed
├── DataVolume (GB)
├── ErrorCode
└── IsRetry

Fact_ValidationRule
├── ValidationID (Key)
├── RuleID (FK)
├── ExecutionTime
├── RecordsValidated
├── PassedCount
├── FailedCount
├── WarningCount
├── Status (Passed, Warning, Failed)
└── SeverityLevel

Fact_DataQuality
├── QualityCheckID (Key)
├── DataSourceID (FK)
├── CheckDate
├── CompletenessScore (0-100)
├── AccuracyScore (0-100)
├── ConsistencyScore (0-100)
├── FreshnessScore (0-100)
└── OverallScore (0-100)
```

### Dimension Tables Required
```
Dim_Pipeline
├── PipelineID (Key)
├── PipelineName
├── Owner
├── Category
├── CriticalFlag
└── SLAThreshold (minutes)

Dim_Date
├── DateKey
├── FullDate
├── Year, Quarter, Month, Day
├── WeekNumber
└── IsWorkday
```

---

## Section 1: Pipeline Execution Metrics

### 1.1 Pipeline Uptime & Success Rates

#### Measure: Pipeline Success Rate (24h)
```dax
Pipeline Success Rate (24h) = 
VAR Last24h = NOW() - 1
RETURN
CALCULATE(
    DIVIDE(
        COUNTIF(Fact_PipelineExecution, [Status] = "Success"),
        COUNTA(Fact_PipelineExecution[ExecutionID]),
        0
    ),
    Fact_PipelineExecution[StartTime] >= Last24h
) * 100
```

**Usage**: KPI card showing 24-hour rolling success percentage
**Target**: 99%
**Color Coding**: Green ≥99%, Amber 95-98%, Red <95%

---

#### Measure: Pipeline Uptime Percentage
```dax
Pipeline Uptime = 
VAR SuccessfulExecutions = 
    CALCULATE(
        COUNTROWS(Fact_PipelineExecution),
        Fact_PipelineExecution[Status] = "Success"
    )
VAR TotalExecutions = COUNTROWS(Fact_PipelineExecution)
RETURN
DIVIDE(SuccessfulExecutions, TotalExecutions, 0) * 100
```

**Usage**: Shows overall system reliability
**Format**: Percentage with 1 decimal place

---

#### Measure: Failed Pipeline Executions (24h)
```dax
Failed Executions (24h) = 
VAR Last24h = NOW() - 1
RETURN
CALCULATE(
    COUNTROWS(Fact_PipelineExecution),
    Fact_PipelineExecution[Status] = "Failed",
    Fact_PipelineExecution[StartTime] >= Last24h
)
```

**Usage**: Alert metric - triggers warning if > 0
**Format**: Integer count

---

#### Measure: Failed Pipelines List
```dax
Failed Pipelines = 
CALCULATE(
    CONCATENATEX(
        FILTER(
            VALUES(Dim_Pipeline[PipelineName]),
            CALCULATE(
                COUNTIF(Fact_PipelineExecution, [Status] = "Failed")
            ) > 0
        ),
        Dim_Pipeline[PipelineName],
        ", "
    )
)
```

**Usage**: Detail view listing all failed pipelines
**Format**: Comma-separated text

---

### 1.2 Pipeline Performance Metrics

#### Measure: Average Pipeline Duration
```dax
Avg Pipeline Duration (min) = 
AVERAGEX(
    Fact_PipelineExecution,
    Fact_PipelineExecution[Duration]
)
```

**Usage**: KPI card showing average execution time
**Format**: Minutes with 1 decimal place

---

#### Measure: Pipeline Duration vs SLA
```dax
Duration vs SLA % = 
VAR AvgDuration = [Avg Pipeline Duration (min)]
VAR SLAThreshold = 
    CALCULATE(
        VALUES(Dim_Pipeline[SLAThreshold]),
        ALLEXCEPT(Dim_Pipeline, Dim_Pipeline[PipelineID])
    )
RETURN
IF(
    ISBLANK(SLAThreshold),
    BLANK(),
    DIVIDE(AvgDuration, SLAThreshold, 0) * 100
)
```

**Usage**: Tracks SLA compliance
**Format**: Percentage (100% = on SLA, >100% = exceeds SLA)

---

#### Measure: Slowest Pipeline (24h)
```dax
Slowest Pipeline (24h) = 
VAR Last24h = NOW() - 1
VAR SlowPipeline = 
    MAXX(
        FILTER(
            ADDCOLUMNS(
                VALUES(Dim_Pipeline[PipelineID]),
                "AvgDuration", CALCULATE(
                    AVERAGEX(Fact_PipelineExecution, 
                        Fact_PipelineExecution[Duration]),
                    Fact_PipelineExecution[StartTime] >= Last24h
                )
            ),
            [AvgDuration] > 0
        ),
        [AvgDuration]
    )
RETURN
SlowPipeline
```

**Usage**: Identifies performance bottlenecks
**Format**: Pipeline name or duration value

---

#### Measure: Peak Load (Max Concurrent Pipelines)
```dax
Peak Concurrent Pipelines = 
MAXX(
    DISTINCT(Fact_PipelineExecution[StartTime]),
    CALCULATE(
        COUNTROWS(Fact_PipelineExecution),
        Fact_PipelineExecution[StartTime] <= EARLIER(Fact_PipelineExecution[EndTime]),
        Fact_PipelineExecution[EndTime] >= EARLIER(Fact_PipelineExecution[StartTime])
    )
)
```

**Usage**: Capacity planning and resource allocation
**Format**: Integer count

---

### 1.3 Data Throughput Metrics

#### Measure: Total Data Processed (24h)
```dax
Data Processed (24h) GB = 
VAR Last24h = NOW() - 1
RETURN
CALCULATE(
    SUMX(Fact_PipelineExecution, Fact_PipelineExecution[DataVolume]),
    Fact_PipelineExecution[StartTime] >= Last24h
)
```

**Usage**: Monitoring data volume trends
**Format**: GB with 1 decimal place

---

#### Measure: Total Records Processed (24h)
```dax
Records Processed (24h) = 
VAR Last24h = NOW() - 1
RETURN
CALCULATE(
    SUMX(Fact_PipelineExecution, Fact_PipelineExecution[RecordsProcessed]),
    Fact_PipelineExecution[StartTime] >= Last24h
)
```

**Usage**: Transaction volume tracking
**Format**: Number with thousands separator

---

#### Measure: Avg Data Volume per Pipeline
```dax
Avg Volume per Pipeline (GB) = 
AVERAGEX(
    Fact_PipelineExecution,
    Fact_PipelineExecution[DataVolume]
)
```

**Usage**: Baseline for anomaly detection
**Format**: GB with 1 decimal place

---

#### Measure: Throughput Rate (GB/hour)
```dax
Throughput Rate (GB/hr) = 
VAR TotalVolume = [Data Processed (24h) GB]
RETURN
DIVIDE(TotalVolume, 24, 0)
```

**Usage**: Performance benchmark
**Format**: GB/hour with 1 decimal place

---

## Section 2: Automation Reliability Metrics

### 2.1 Retry & Failure Analysis

#### Measure: Retry Count (24h)
```dax
Retry Executions (24h) = 
VAR Last24h = NOW() - 1
RETURN
CALCULATE(
    COUNTROWS(Fact_PipelineExecution),
    Fact_PipelineExecution[IsRetry] = TRUE(),
    Fact_PipelineExecution[StartTime] >= Last24h
)
```

**Usage**: Identifies unstable pipelines
**Format**: Integer count

---

#### Measure: Retry Success Rate
```dax
Retry Success Rate % = 
VAR RetryAttempts = 
    CALCULATE(
        COUNTROWS(Fact_PipelineExecution),
        Fact_PipelineExecution[IsRetry] = TRUE()
    )
VAR SuccessfulRetries = 
    CALCULATE(
        COUNTROWS(Fact_PipelineExecution),
        Fact_PipelineExecution[IsRetry] = TRUE(),
        Fact_PipelineExecution[Status] = "Success"
    )
RETURN
DIVIDE(SuccessfulRetries, RetryAttempts, 0) * 100
```

**Usage**: Reliability indicator for automation logic
**Format**: Percentage with 1 decimal place

---

#### Measure: Most Common Error
```dax
Top Error Code = 
TOPN(
    1,
    DISTINCT(Fact_PipelineExecution[ErrorCode]),
    CALCULATE(
        COUNTROWS(Fact_PipelineExecution),
        Fact_PipelineExecution[ErrorCode] <> BLANK()
    ),
    DESC
)
```

**Usage**: Root cause analysis
**Format**: Error code or description

---

#### Measure: Critical Pipeline Failures
```dax
Critical Pipeline Failures = 
CALCULATE(
    COUNTROWS(Fact_PipelineExecution),
    Fact_PipelineExecution[Status] = "Failed",
    RELATED(Dim_Pipeline[CriticalFlag]) = TRUE()
)
```

**Usage**: High-priority alerts
**Format**: Integer count (trigger alert if > 0)

---

### 2.2 Scheduled vs Actual Execution

#### Measure: Pipelines Scheduled (today)
```dax
Pipelines Scheduled = 
CALCULATE(
    COUNTROWS(Fact_PipelineExecution),
    Fact_PipelineExecution[Status] <> "Pending"
)
```

**Usage**: Capacity tracking
**Format**: Integer count

---

#### Measure: Pipelines Completed (today)
```dax
Pipelines Completed = 
CALCULATE(
    COUNTROWS(Fact_PipelineExecution),
    Fact_PipelineExecution[Status] = "Success"
)
```

**Usage**: Daily completion tracking
**Format**: Integer count

---

#### Measure: Pipelines Running (Real-time)
```dax
Pipelines Running = 
CALCULATE(
    COUNTROWS(Fact_PipelineExecution),
    Fact_PipelineExecution[Status] = "Running"
)
```

**Usage**: Live operational dashboard
**Format**: Integer count (auto-refresh every 10 seconds)

---

---

## Section 3: Data Quality & Validation Metrics

### 3.1 Quality Dimension Scores

#### Measure: Completeness Score
```dax
Completeness Score = 
AVERAGEX(Fact_DataQuality, Fact_DataQuality[CompletenessScore])
```

**Usage**: Data presence metric
**Format**: Percentage (0-100) with 1 decimal place
**SLA Target**: 98%+

---

#### Measure: Accuracy Score
```dax
Accuracy Score = 
AVERAGEX(Fact_DataQuality, Fact_DataQuality[AccuracyScore])
```

**Usage**: Data correctness metric
**Format**: Percentage (0-100) with 1 decimal place
**SLA Target**: 95%+

---

#### Measure: Consistency Score
```dax
Consistency Score = 
AVERAGEX(Fact_DataQuality, Fact_DataQuality[ConsistencyScore])
```

**Usage**: Cross-source alignment metric
**Format**: Percentage (0-100) with 1 decimal place
**SLA Target**: 97%+

---

#### Measure: Freshness Score
```dax
Freshness Score = 
AVERAGEX(Fact_DataQuality, Fact_DataQuality[FreshnessScore])
```

**Usage**: Data timeliness metric
**Format**: Percentage (0-100) with 1 decimal place
**SLA Target**: 99%+

---

#### Measure: Overall Data Quality Score
```dax
Overall Quality Score = 
AVERAGE(
    VALUES(Fact_DataQuality[OverallScore])
)
```

**Usage**: Composite quality indicator
**Format**: Percentage (0-100) with 1 decimal place

---

### 3.2 Validation Rule Metrics

#### Measure: Validation Rules Passed (24h)
```dax
Rules Passed (24h) = 
VAR Last24h = NOW() - 1
RETURN
CALCULATE(
    COUNTROWS(Fact_ValidationRule),
    Fact_ValidationRule[Status] = "Passed",
    Fact_ValidationRule[ExecutionTime] >= Last24h
)
```

**Usage**: Success tracking
**Format**: Integer count

---

#### Measure: Validation Rules Failed (24h)
```dax
Rules Failed (24h) = 
VAR Last24h = NOW() - 1
RETURN
CALCULATE(
    COUNTROWS(Fact_ValidationRule),
    Fact_ValidationRule[Status] = "Failed",
    Fact_ValidationRule[ExecutionTime] >= Last24h
)
```

**Usage**: Failure alert metric
**Format**: Integer count

---

#### Measure: Validation Pass Rate
```dax
Validation Pass Rate % = 
VAR PassedRules = 
    CALCULATE(
        COUNTROWS(Fact_ValidationRule),
        Fact_ValidationRule[Status] = "Passed"
    )
VAR TotalRules = COUNTROWS(Fact_ValidationRule)
RETURN
DIVIDE(PassedRules, TotalRules, 0) * 100
```

**Usage**: Overall validation health
**Format**: Percentage with 1 decimal place

---

#### Measure: Failed Records Count
```dax
Failed Records = 
SUMX(Fact_ValidationRule, Fact_ValidationRule[FailedCount])
```

**Usage**: Data quality issue volume
**Format**: Integer count with thousands separator

---

#### Measure: Critical Validation Failures
```dax
Critical Validation Issues = 
CALCULATE(
    SUMX(Fact_ValidationRule, Fact_ValidationRule[FailedCount]),
    Fact_ValidationRule[SeverityLevel] = "Critical"
)
```

**Usage**: High-priority remediation
**Format**: Integer count

---

### 3.3 Trend & Comparison Metrics

#### Measure: Quality Score vs Previous Day
```dax
Quality Score Trend = 
VAR CurrentScore = [Overall Quality Score]
VAR PreviousDayScore = 
    CALCULATE(
        [Overall Quality Score],
        DATEADD(Fact_DataQuality[CheckDate], -1, DAY)
    )
RETURN
DIVIDE(
    CurrentScore - PreviousDayScore,
    PreviousDayScore,
    0
) * 100
```

**Usage**: Trend analysis with % change
**Format**: Percentage with 1 decimal place (shows ↑↓ direction)

---

#### Measure: Quality Status Indicator
```dax
Quality Status = 
VAR Score = [Overall Quality Score]
RETURN
IF(Score >= 95, "Excellent", 
IF(Score >= 90, "Good", 
IF(Score >= 85, "Fair", "Poor")))
```

**Usage**: Visual status for executive dashboard
**Format**: Text with conditional formatting (Green/Yellow/Red)

---

---

## Section 4: SLA & Target Compliance

### 4.1 SLA Metrics

#### Measure: SLA Compliance Rate
```dax
SLA Compliance % = 
VAR OnTimeExecutions = 
    CALCULATE(
        COUNTROWS(Fact_PipelineExecution),
        Fact_PipelineExecution[Duration] <= 
            RELATED(Dim_Pipeline[SLAThreshold])
    )
VAR TotalExecutions = COUNTROWS(Fact_PipelineExecution)
RETURN
DIVIDE(OnTimeExecutions, TotalExecutions, 0) * 100
```

**Usage**: Contract compliance tracking
**Format**: Percentage with 1 decimal place
**Target**: 99%+

---

#### Measure: Pipelines Meeting SLA (24h)
```dax
On-Time Executions (24h) = 
VAR Last24h = NOW() - 1
RETURN
CALCULATE(
    COUNTROWS(Fact_PipelineExecution),
    Fact_PipelineExecution[Duration] <= 
        RELATED(Dim_Pipeline[SLAThreshold]),
    Fact_PipelineExecution[StartTime] >= Last24h
)
```

**Usage**: Daily SLA tracking
**Format**: Integer count

---

#### Measure: SLA Breach Count (24h)
```dax
SLA Breaches (24h) = 
VAR Last24h = NOW() - 1
RETURN
CALCULATE(
    COUNTROWS(Fact_PipelineExecution),
    Fact_PipelineExecution[Duration] > 
        RELATED(Dim_Pipeline[SLAThreshold]),
    Fact_PipelineExecution[StartTime] >= Last24h
)
```

**Usage**: Compliance violation tracking
**Format**: Integer count (trigger alert if > 0)

---

---

## Section 5: Operational Efficiency Metrics

#### Measure: Total Automation Events (24h)
```dax
Total Automation Events (24h) = 
VAR Last24h = NOW() - 1
RETURN
CALCULATE(
    COUNTROWS(Fact_PipelineExecution) + 
    COUNTROWS(Fact_ValidationRule),
    Fact_PipelineExecution[StartTime] >= Last24h,
    Fact_ValidationRule[ExecutionTime] >= Last24h
)
```

**Usage**: Activity volume tracking
**Format**: Integer count

---

#### Measure: Automation Efficiency Ratio
```dax
Automation Efficiency % = 
VAR SuccessfulEvents = 
    CALCULATE(
        COUNTROWS(Fact_PipelineExecution),
        Fact_PipelineExecution[Status] = "Success"
    ) + 
    CALCULATE(
        COUNTROWS(Fact_ValidationRule),
        Fact_ValidationRule[Status] = "Passed"
    )
VAR TotalEvents = [Total Automation Events (24h)]
RETURN
DIVIDE(SuccessfulEvents, TotalEvents, 0) * 100
```

**Usage**: Overall system reliability
**Format**: Percentage with 1 decimal place

---

#### Measure: Cost Avoidance (automated vs manual)
```dax
Automated Records % = 
VAR AutomatedRecords = [Records Processed (24h)]
VAR ManualEquivalent = AutomatedRecords * 0.001  -- 0.1 cent per record
RETURN
ManualEquivalent
```

**Usage**: Business value justification
**Format**: Currency ($) with 2 decimal places
**Note**: Adjust multiplier based on actual labor cost

---

---

## Implementation Guide

### Power Query M Code - Sample Load
```m
let
    Source = Sql.Database("ServerName", "DatabaseName"),
    PipelineExecution = Source{[Schema="dbo",Item="Fact_PipelineExecution"]}[Data],
    ValidationRule = Source{[Schema="dbo",Item="Fact_ValidationRule"]}[Data],
    DataQuality = Source{[Schema="dbo",Item="Fact_DataQuality"]}[Data],
    Pipeline = Source{[Schema="dbo",Item="Dim_Pipeline"]}[Data]
in
    [Tables of data...]
```

### Recommended Refresh Schedule
- **Fact_PipelineExecution**: Every 1 minute (real-time)
- **Fact_ValidationRule**: Every 5 minutes
- **Fact_DataQuality**: Every 1 hour
- **Dimension tables**: Daily at 2 AM

### Visual Recommendations

| Measure | Visual Type | Context |
|---------|-------------|---------|
| Pipeline Success Rate (24h) | KPI Card | Header row |
| Failed Executions (24h) | Large Number | Alert area |
| Avg Pipeline Duration | KPI Card | Performance row |
| Data Processed (24h) | KPI Card | Throughput row |
| Overall Quality Score | Gauge | Quality row |
| Validation Pass Rate | KPI Card | Validation row |
| SLA Compliance Rate | KPI Card | Compliance row |
| Pipelines Running | Large Number | Real-time status |

### Color Coding Standards
- **Success/Green**: ≥95% (or metric exceeds target)
- **Warning/Yellow**: 85-94% (or metric approaching target)
- **Alert/Red**: <85% (or metric below critical threshold)

---

## Deployment Checklist

- [ ] Create all fact tables in source database
- [ ] Create all dimension tables in source database
- [ ] Configure Power Query connections
- [ ] Import all measures into Power BI model
- [ ] Create KPI cards with conditional formatting
- [ ] Configure drill-through relationships
- [ ] Set up 1-minute refresh schedule
- [ ] Test all measure calculations
- [ ] Configure alert thresholds
- [ ] Create automation runbooks for failures
- [ ] Train users on dashboard interpretation

---

## Support & Maintenance

For measure updates, validation rule changes, or SLA modifications, update the DAX code in the Power BI desktop file and republish. All dependent visuals will automatically reflect the changes.

Last Updated: June 2026
