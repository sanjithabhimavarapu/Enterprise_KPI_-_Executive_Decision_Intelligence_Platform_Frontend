# Pipeline Monitoring Visuals - DAX Measures & Implementation

## Pipeline Monitoring Data Model Requirements

### Fact Tables
1. **Fact_PipelineExecution**: Individual pipeline run records
   - ExecutionID (Key)
   - PipelineID
   - ExecutionDate
   - StartTime
   - EndTime
   - DurationMinutes
   - Status (Success/Failed/Running/Pending)
   - RecordsProcessed
   - DataVolumeGB
   - ErrorMessage
   - OwnerID
   - Retries

2. **Fact_PipelineStage**: Individual job/stage execution
   - StageExecutionID (Key)
   - ExecutionID (FK)
   - PipelineID
   - StageName
   - StageOrder
   - StartTime
   - EndTime
   - Duration
   - Status
   - RecordsIn
   - RecordsOut

3. **Fact_PipelineAlert**: Alert events for pipelines
   - AlertID (Key)
   - PipelineID
   - AlertDate
   - AlertType (Failure/Slow/DataQuality/Other)
   - Severity (Critical/High/Medium/Low)
   - Message
   - IsResolved

4. **Fact_DataFlow**: Data lineage and flow tracking
   - FlowID (Key)
   - SourcePipelineID
   - TargetPipelineID
   - ExecutionDate
   - DataVolumeGB
   - RecordCount
   - TransferDuration
   - Status

### Dimension Tables
1. **Dim_Pipeline**: Pipeline definitions
   - PipelineID
   - PipelineName
   - PipelineCategory
   - OwnerID
   - SLAMinutes
   - ExpectedRecords
   - ExpectedDataGB
   - Active (Y/N)

2. **Dim_PipelineStage**: Pipeline stages/jobs
   - StageID
   - PipelineID
   - StageName
   - StageType (Extract/Transform/Load)
   - StageOrder

3. **Dim_DataSource**: Source systems
   - SourceID
   - SourceName
   - SourceType

4. **Dim_Date**: Standard date dimension

---

## DAX Measures - Pipeline Monitoring

### PIPELINE UPTIME & PERFORMANCE MEASURES

#### Measure 1: Pipeline Uptime Percentage
```dax
Pipeline Uptime % = 
    DIVIDE(
        CALCULATE(
            COUNTROWS(Fact_PipelineExecution),
            Fact_PipelineExecution[Status] = "Success"
        ),
        COUNTROWS(Fact_PipelineExecution),
        0
    ) * 100

Format: 0.0"%"
Description: % of scheduled pipelines completing successfully
Target: ≥ 99%
Period: Last 24 hours (default), configurable
```

#### Measure 2: Pipeline Success Count
```dax
Pipelines Successful = 
    CALCULATE(
        COUNTROWS(Fact_PipelineExecution),
        Fact_PipelineExecution[Status] = "Success"
    )

Format: #,##0
Description: Number of successful pipeline executions
Period: Configurable (daily, weekly)
```

#### Measure 3: Pipeline Failure Count
```dax
Pipelines Failed = 
    CALCULATE(
        COUNTROWS(Fact_PipelineExecution),
        Fact_PipelineExecution[Status] = "Failed"
    )

Format: #,##0
Description: Number of failed pipeline executions
Alert: Red if > 0
```

#### Measure 4: Pipeline Running Count
```dax
Pipelines Running = 
    CALCULATE(
        COUNTROWS(Fact_PipelineExecution),
        Fact_PipelineExecution[Status] = "Running"
    )

Format: #,##0
Description: Number of currently running pipelines
Use: Real-time status indicator
```

#### Measure 5: Average Pipeline Duration
```dax
Average Pipeline Duration Minutes = 
    AVERAGE(Fact_PipelineExecution[DurationMinutes])

Format: 0.0" minutes"
Description: Average time to execute pipeline
Related: By pipeline, by time period
```

#### Measure 6: Pipeline Duration vs SLA
```dax
Pipeline Duration vs SLA = 
    DIVIDE(
        [Average Pipeline Duration Minutes],
        MAX(Dim_Pipeline[SLAMinutes]),
        0
    ) * 100

Format: 0.0"%"
Description: Actual duration as % of SLA threshold
Alert: Green <100%, Yellow 100-150%, Red >150%
```

---

### PIPELINE STATUS MEASURES

#### Measure 7: Completed Pipelines
```dax
Pipelines Completed = 
    CALCULATE(
        COUNTROWS(Fact_PipelineExecution),
        Fact_PipelineExecution[Status] IN {"Success", "Failed"}
    )

Format: #,##0
Description: Total completed pipeline executions (both success and failed)
```

#### Measure 8: Pending Pipelines
```dax
Pipelines Pending = 
    CALCULATE(
        COUNTROWS(Fact_PipelineExecution),
        Fact_PipelineExecution[Status] = "Pending"
    )

Format: #,##0
Description: Pipelines scheduled but not yet started
Use: Scheduling dashboard
```

#### Measure 9: Pipeline Status Distribution
```dax
Success Count = [Pipelines Successful]
Failed Count = [Pipelines Failed]
Running Count = [Pipelines Running]
Pending Count = [Pipelines Pending]

Total Executions = 
    [Success Count] + [Failed Count] + [Running Count] + [Pending Count]

Format: #,##0
Description: Individual counts for pie/donut chart
Use: Status breakdown visualization
```

---

### FAILURE ANALYSIS MEASURES

#### Measure 10: Failed Pipeline Names (Top)
```dax
Most Failed Pipeline = 
    TOPN(
        1,
        SUMMARIZE(
            Fact_PipelineExecution,
            Dim_Pipeline[PipelineName]
        ),
        COUNTROWS(Fact_PipelineExecution)
    )

Format: Text
Description: Pipeline with most failures
Use: Alert and drill-down
```

#### Measure 11: Failure Rate by Pipeline
```dax
Failure Rate % = 
    DIVIDE(
        CALCULATE(
            COUNTROWS(Fact_PipelineExecution),
            Fact_PipelineExecution[Status] = "Failed"
        ),
        COUNTROWS(Fact_PipelineExecution),
        0
    ) * 100

Format: 0.0"%"
Description: % of executions failed
Related: By pipeline, by time period
```

#### Measure 12: Consecutive Failures
```dax
Consecutive Failures = 
    COUNTROWS(
        FILTER(
            TOPN(
                5,
                Fact_PipelineExecution,
                Fact_PipelineExecution[ExecutionDate], DESC
            ),
            Fact_PipelineExecution[Status] = "Failed"
        )
    )

Format: #,##0
Description: Count of consecutive failed executions
Alert: Red if > 1
```

---

### DATA PROCESSING MEASURES

#### Measure 13: Total Records Processed
```dax
Total Records Processed = 
    SUMX(
        Fact_PipelineExecution,
        Fact_PipelineExecution[RecordsProcessed]
    )

Format: #,##0
Description: Total records moved through pipelines
Related: By pipeline, by source
```

#### Measure 14: Total Data Volume Processed
```dax
Total Data Volume GB = 
    SUMX(
        Fact_PipelineExecution,
        Fact_PipelineExecution[DataVolumeGB]
    )

Format: 0.0" GB"
Description: Total data volume processed
Related: By pipeline, by day
```

#### Measure 15: Expected vs Actual Volume
```dax
Expected Volume = 
    SUMX(
        SUMMARIZE(Fact_PipelineExecution, Dim_Pipeline[PipelineID]),
        MAX(Dim_Pipeline[ExpectedDataGB])
    )

Volume Variance % = 
    DIVIDE(
        [Total Data Volume GB] - [Expected Volume],
        [Expected Volume],
        0
    ) * 100

Format: 0.0"%"
Description: Actual volume vs expected (identifies data anomalies)
Alert: Red if variance > 20%
```

#### Measure 16: Records Per Minute
```dax
Records Per Minute = 
    DIVIDE(
        [Total Records Processed],
        [Average Pipeline Duration Minutes],
        0
    )

Format: #,##0" recs/min"
Description: Processing throughput metric
Related: By pipeline type, benchmark
```

---

### PIPELINE RELIABILITY MEASURES

#### Measure 17: MTBF (Mean Time Between Failures)
```dax
Days Since Last Failure = 
    INT((TODAY() - MAX(
        CALCULATE(
            Fact_PipelineExecution[ExecutionDate],
            Fact_PipelineExecution[Status] = "Failed"
        )
    )))

Format: #,##0" days"
Description: Days elapsed since last failure
Use: Reliability tracking
```

#### Measure 18: MTTR (Mean Time To Recovery)
```dax
Average Recovery Time Minutes = 
    AVERAGEX(
        FILTER(
            Fact_PipelineExecution,
            Fact_PipelineExecution[Status] = "Success",
            NOT(ISBLANK(Fact_PipelineExecution[Retries]))
        ),
        Fact_PipelineExecution[DurationMinutes]
    )

Format: 0.0" minutes"
Description: Average time to recover from failure and complete successfully
Target: < 30 minutes
```

#### Measure 19: Retry Count
```dax
Total Retries = 
    SUMX(
        Fact_PipelineExecution,
        Fact_PipelineExecution[Retries]
    )

Format: #,##0
Description: Total retry attempts
Related: By pipeline, by failure type
```

---

### DATA FLOW & LINEAGE MEASURES

#### Measure 20: Data Flow Success Rate
```dax
Data Flows Successful = 
    CALCULATE(
        COUNTROWS(Fact_DataFlow),
        Fact_DataFlow[Status] = "Success"
    )

Data Flow Success % = 
    DIVIDE(
        [Data Flows Successful],
        COUNTROWS(Fact_DataFlow),
        0
    ) * 100

Format: 0.0"%"
Description: % of inter-pipeline data transfers successful
Target: ≥ 99%
```

#### Measure 21: Data Transfer Latency
```dax
Average Transfer Duration Minutes = 
    AVERAGE(Fact_DataFlow[TransferDuration])

Format: 0.0" minutes"
Description: Average time for inter-pipeline data transfer
Related: By source/target pair
```

---

### ALERT & INCIDENT MEASURES

#### Measure 22: Active Alerts
```dax
Active Alerts = 
    CALCULATE(
        COUNTROWS(Fact_PipelineAlert),
        Fact_PipelineAlert[IsResolved] = FALSE
    )

Format: #,##0
Description: Current unresolved alerts
Alert: Red if > 0
```

#### Measure 23: Critical Alerts
```dax
Critical Alerts = 
    CALCULATE(
        COUNTROWS(Fact_PipelineAlert),
        Fact_PipelineAlert[Severity] = "Critical",
        Fact_PipelineAlert[IsResolved] = FALSE
    )

High Alerts = 
    CALCULATE(
        COUNTROWS(Fact_PipelineAlert),
        Fact_PipelineAlert[Severity] = "High",
        Fact_PipelineAlert[IsResolved] = FALSE
    )

Format: #,##0
Description: Alerts by severity
Use: Alert dashboard
```

#### Measure 24: Alert Response Time
```dax
Average Alert Response Time Hours = 
    -- Note: Requires AlertDetectedTime and AlertResolvedTime fields
    AVERAGEX(
        Fact_PipelineAlert,
        IF(Fact_PipelineAlert[IsResolved] = TRUE,
            (Fact_PipelineAlert[ResolvedTime] - Fact_PipelineAlert[DetectedTime]) * 24,
            BLANK()
        )
    )

Format: 0.0" hours"
Description: Average time from alert to resolution
Target: < 1 hour for critical
```

---

### PIPELINE DEPENDENCY MEASURES

#### Measure 25: Blocked Dependencies
```dax
Dependencies Blocked = 
    CALCULATE(
        COUNTROWS(Fact_DataFlow),
        Fact_DataFlow[Status] = "Failed"
    )

Format: #,##0
Description: Number of downstream pipelines blocked by failures
Alert: Red if > 0
```

#### Measure 26: Critical Path Health
```dax
Critical Path Pipelines = 
    CALCULATE(
        COUNTROWS(Dim_Pipeline),
        Dim_Pipeline[IsCriticalPath] = TRUE
    )

Critical Path Success % = 
    DIVIDE(
        CALCULATE(
            COUNTROWS(Fact_PipelineExecution),
            Dim_Pipeline[IsCriticalPath] = TRUE,
            Fact_PipelineExecution[Status] = "Success"
        ),
        CALCULATE(
            COUNTROWS(Fact_PipelineExecution),
            Dim_Pipeline[IsCriticalPath] = TRUE
        ),
        0
    ) * 100

Format: 0.0"%"
Description: Success rate of critical path pipelines only
Target: 99.9%+
```

---

### TREND & COMPARISON MEASURES

#### Measure 27: Uptime Previous Day
```dax
Pipeline Uptime Previous Day = 
    CALCULATE(
        [Pipeline Uptime %],
        DATEADD(Dim_Date[Date], -1, DAY)
    )

Format: 0.0"%"
Description: Previous day's uptime for trend comparison
```

#### Measure 28: Uptime Change Indicator
```dax
Uptime Trend = 
    [Pipeline Uptime %] - [Pipeline Uptime Previous Day]

Format: 0.0"%"
Description: Day-over-day uptime change
Positive: Improvement, Negative: Decline
Display: With up/down arrow indicator
```

#### Measure 29: Failure Trend
```dax
Failures Previous Week = 
    CALCULATE(
        [Pipelines Failed],
        DATEADD(Dim_Date[Date], -7, DAY)
    )

Failure Trend Direction = 
    IF([Pipelines Failed] < [Failures Previous Week], "Improving", "Declining")

Format: Indicator
Description: Trending towards more or fewer failures
```

---

## HELPER MEASURES & CLASSIFICATIONS

#### Performance Classification
```dax
[Pipeline Performance] = 
    IF([Pipeline Duration vs SLA] < 80, "Excellent",
        IF([Pipeline Duration vs SLA] < 100, "Good",
            IF([Pipeline Duration vs SLA] < 150, "Acceptable",
                "Poor"
            )
        )
    )
```

#### Reliability Classification
```dax
[Pipeline Reliability] = 
    IF([Failure Rate %] = 0, "Excellent",
        IF([Failure Rate %] < 1, "Good",
            IF([Failure Rate %] < 5, "Fair",
                "Poor"
            )
        )
    )
```

#### Health Score (Composite)
```dax
[Pipeline Health Score] = 
    ([Pipeline Uptime %] * 0.4) +
    (100 - [Failure Rate %] * 0.3) +
    (MIN(100, 100 - ABS([Volume Variance %]) * 0.2) * 0.3)

Format: 0.0
Range: 0-100
Green: > 90, Yellow: 70-90, Red: < 70
```

---

## Dashboard-Specific Measure Collections

### For Real-Time Status Panel
- Pipelines Running
- Pipelines Successful (today)
- Pipelines Failed (today)
- Total Data Volume GB
- Average Pipeline Duration
- Pipeline Uptime %

### For Performance KPI Cards
- Pipeline Uptime %
- Average Pipeline Duration Minutes
- Pipelines Failed
- Total Data Volume Processed

### For Timeline Execution Chart
- All pipeline executions with status
- Duration for each execution
- Status color coding
- Record and volume counts

### For Status Distribution (Pie)
- Success Count
- Failed Count
- Running Count
- Pending Count

### For Dependency Graph
- Data flows between pipelines
- Status of each connection
- Data volume flowing
- Latency per connection

### For Alert Dashboard
- Active Alerts
- Critical / High Alerts
- Alerts by type
- Response time metrics

---

## Real-Time Data Refresh Strategy

1. **Pipeline Executions**: Refresh every 1 minute
2. **Alerts**: Refresh every 30 seconds
3. **Historical Data**: Refresh every 15 minutes
4. **Aggregations**: Refresh every 5 minutes
5. **Dependencies**: Refresh daily (static configuration)

---

## Performance Optimization Tips

1. **Incremental Load**: Only load last execution per pipeline
2. **Aggregated Facts**: Pre-aggregate hourly/daily data
3. **Live Connection**: For real-time status, consider DirectQuery
4. **Archiving**: Move executions > 90 days to archive table
5. **Indexing**: Index on PipelineID, ExecutionDate, Status

---

## Testing Checklist

- [ ] Uptime % ranges 0-100%
- [ ] Failed count ≤ total executions
- [ ] Duration measures in reasonable range
- [ ] Volume measures match pipeline configuration
- [ ] Trend measures calculate day-over-day correctly
- [ ] Dependency graph shows all pipelines
- [ ] Alert counts accurate and real-time
- [ ] All measures perform < 1 second
- [ ] Drill-down details match summary numbers
- [ ] Status icons display correctly for all states
- [ ] Retry logic calculates for failed pipelines
- [ ] MTBF/MTTR calculations reasonable

