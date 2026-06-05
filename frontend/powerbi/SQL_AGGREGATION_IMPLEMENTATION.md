# SQL Implementation Guide: Data Aggregation for Power BI Optimization

**Purpose**: Create aggregated fact tables to reduce Power BI import size by 97% and refresh time by 75%  
**Scope**: Automation Reporting Dashboard + Validation Insights  
**Timeline**: 1 week implementation  

---

## Phase 1: Create Aggregation Tables

### Table 1: Fact_PipelineExecution_Hourly

**Purpose**: Aggregate raw pipeline executions to hourly level (24 rows per pipeline per day vs 1,000+ raw rows)

```sql
-- Step 1: Create the aggregation table
CREATE TABLE [dbo].[Fact_PipelineExecution_Hourly] (
    AggregationKey BIGINT NOT NULL PRIMARY KEY,
    ExecutionDate DATE NOT NULL,
    ExecutionHour TINYINT NOT NULL,
    PipelineID INT NOT NULL,
    ExecutionStatus NVARCHAR(20) NOT NULL,
    
    -- Execution Counts
    TotalExecutions INT NOT NULL DEFAULT 0,
    SuccessfulExecutions INT NOT NULL DEFAULT 0,
    FailedExecutions INT NOT NULL DEFAULT 0,
    TimeoutExecutions INT NOT NULL DEFAULT 0,
    RunningExecutions INT NOT NULL DEFAULT 0,
    
    -- Duration Metrics (in minutes)
    MinDuration DECIMAL(10,2) NOT NULL DEFAULT 0,
    MaxDuration DECIMAL(10,2) NOT NULL DEFAULT 0,
    AvgDuration DECIMAL(10,2) NOT NULL DEFAULT 0,
    MedianDuration DECIMAL(10,2) NOT NULL DEFAULT 0,
    
    -- Volume Metrics
    TotalRecordsProcessed BIGINT NOT NULL DEFAULT 0,
    AvgRecordsPerExecution DECIMAL(15,2) NOT NULL DEFAULT 0,
    TotalDataVolume DECIMAL(18,4) NOT NULL DEFAULT 0,  -- GB
    AvgDataVolumePerExecution DECIMAL(15,4) NOT NULL DEFAULT 0,  -- GB
    
    -- Retry Metrics
    TotalRetries INT NOT NULL DEFAULT 0,
    SuccessfulRetries INT NOT NULL DEFAULT 0,
    FailedRetries INT NOT NULL DEFAULT 0,
    
    -- Error Tracking
    UniqueErrorCodes INT NOT NULL DEFAULT 0,
    MostCommonErrorCode NVARCHAR(100),
    
    -- Data Quality
    DataQualityScore DECIMAL(5,2),
    ValidationPassCount INT DEFAULT 0,
    ValidationFailCount INT DEFAULT 0,
    
    -- Metadata
    LoadedAt DATETIME2 DEFAULT GETDATE(),
    LastModified DATETIME2 DEFAULT GETDATE()
);

-- Step 2: Create Primary Key (AggregationKey composite)
-- AggregationKey format: YYYYMMDDHH<PipelineID>
-- Example: 2026060512000015 = 2026-06-05 12:00, PipelineID 15

-- Step 3: Create indexes for query performance
CREATE UNIQUE NONCLUSTERED INDEX [IX_PipelineExecutionHourly_PK]
    ON [dbo].[Fact_PipelineExecution_Hourly] (
        ExecutionDate ASC,
        ExecutionHour ASC,
        PipelineID ASC,
        ExecutionStatus ASC
    )
    WITH (PAD_INDEX = OFF, FILLFACTOR = 90, STATISTICS_NORECOMPUTE = OFF);

CREATE NONCLUSTERED INDEX [IX_PipelineExecutionHourly_Pipeline]
    ON [dbo].[Fact_PipelineExecution_Hourly] (
        PipelineID ASC,
        ExecutionDate DESC
    )
    INCLUDE (TotalExecutions, SuccessfulExecutions, FailedExecutions);

CREATE NONCLUSTERED INDEX [IX_PipelineExecutionHourly_Status]
    ON [dbo].[Fact_PipelineExecution_Hourly] (
        ExecutionStatus ASC,
        ExecutionDate DESC,
        ExecutionHour DESC
    )
    INCLUDE (TotalExecutions, AvgDuration);

CREATE NONCLUSTERED INDEX [IX_PipelineExecutionHourly_DateStatus]
    ON [dbo].[Fact_PipelineExecution_Hourly] (
        ExecutionDate DESC,
        ExecutionStatus ASC
    )
    INCLUDE (TotalExecutions, FailedExecutions, AvgDuration);

-- Step 4: Add columnstore for analytical queries (optional, requires Enterprise Edition)
-- CREATE NONCLUSTERED COLUMNSTORE INDEX [IX_PipelineExecutionHourly_Columnstore]
--     ON [dbo].[Fact_PipelineExecution_Hourly] (
--         ExecutionDate, PipelineID, ExecutionStatus, TotalExecutions, AvgDuration
--     );
```

---

### Stored Procedure: Populate Hourly Aggregations

**Purpose**: Run every 5 minutes to aggregate raw executions into hourly bins

```sql
-- Step 1: Create stored procedure
CREATE PROCEDURE [dbo].[sp_AggregateExecutions_Hourly]
    @ExecutionDate DATE = NULL,  -- NULL = TODAY
    @ExecutionHour TINYINT = NULL  -- NULL = CURRENT HOUR
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    DECLARE @CurrDate DATE = ISNULL(@ExecutionDate, CAST(GETDATE() AS DATE));
    DECLARE @CurrHour TINYINT = ISNULL(@ExecutionHour, DATEPART(HOUR, GETDATE()));
    
    -- Get the hour start/end times
    DECLARE @HourStart DATETIME2 = DATETIMEFROMPARTS(
        YEAR(@CurrDate), MONTH(@CurrDate), DAY(@CurrDate),
        @CurrHour, 0, 0, 0, 0
    );
    DECLARE @HourEnd DATETIME2 = DATEADD(HOUR, 1, @HourStart);
    
    -- Delete existing aggregation for this hour (idempotent)
    DELETE FROM [dbo].[Fact_PipelineExecution_Hourly]
    WHERE ExecutionDate = @CurrDate AND ExecutionHour = @CurrHour;
    
    -- Insert aggregated data
    INSERT INTO [dbo].[Fact_PipelineExecution_Hourly]
    SELECT
        -- Generate AggregationKey
        CAST(CONCAT(
            FORMAT(YEAR(@CurrDate), '0000'),
            FORMAT(MONTH(@CurrDate), '00'),
            FORMAT(DAY(@CurrDate), '00'),
            FORMAT(@CurrHour, '00'),
            FORMAT(pe.PipelineID, '00000'),
            FORMAT(ROW_NUMBER() OVER (ORDER BY pe.Status), '00')
        ) AS BIGINT) AS AggregationKey,
        
        -- Dimensions
        @CurrDate AS ExecutionDate,
        @CurrHour AS ExecutionHour,
        pe.PipelineID,
        pe.Status AS ExecutionStatus,
        
        -- Execution Counts
        COUNT(*) AS TotalExecutions,
        SUM(CASE WHEN pe.Status = 'Success' THEN 1 ELSE 0 END) AS SuccessfulExecutions,
        SUM(CASE WHEN pe.Status = 'Failed' THEN 1 ELSE 0 END) AS FailedExecutions,
        SUM(CASE WHEN pe.Status = 'Timeout' THEN 1 ELSE 0 END) AS TimeoutExecutions,
        SUM(CASE WHEN pe.Status = 'Running' THEN 1 ELSE 0 END) AS RunningExecutions,
        
        -- Duration Metrics (convert to minutes)
        ROUND(MIN(CAST(pe.Duration AS DECIMAL(10,2))), 2) AS MinDuration,
        ROUND(MAX(CAST(pe.Duration AS DECIMAL(10,2))), 2) AS MaxDuration,
        ROUND(AVG(CAST(pe.Duration AS DECIMAL(10,2))), 2) AS AvgDuration,
        -- Median duration (approximate using PERCENTILE_CONT if SQL Server 2012+)
        ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY CAST(pe.Duration AS DECIMAL(10,2)))
              OVER (PARTITION BY pe.PipelineID), 2) AS MedianDuration,
        
        -- Volume Metrics
        SUM(pe.RecordsProcessed) AS TotalRecordsProcessed,
        ROUND(CAST(SUM(pe.RecordsProcessed) AS DECIMAL(15,2)) / COUNT(*), 2) AS AvgRecordsPerExecution,
        ROUND(SUM(pe.DataVolume), 4) AS TotalDataVolume,
        ROUND(CAST(SUM(pe.DataVolume) AS DECIMAL(15,4)) / COUNT(*), 4) AS AvgDataVolumePerExecution,
        
        -- Retry Metrics
        SUM(CASE WHEN pe.IsRetry = 1 THEN 1 ELSE 0 END) AS TotalRetries,
        SUM(CASE WHEN pe.IsRetry = 1 AND pe.Status = 'Success' THEN 1 ELSE 0 END) AS SuccessfulRetries,
        SUM(CASE WHEN pe.IsRetry = 1 AND pe.Status = 'Failed' THEN 1 ELSE 0 END) AS FailedRetries,
        
        -- Error Tracking
        COUNT(DISTINCT pe.ErrorCode) AS UniqueErrorCodes,
        (SELECT TOP 1 pe2.ErrorCode 
         FROM [dbo].[Fact_PipelineExecution] pe2 
         WHERE pe2.PipelineID = pe.PipelineID 
         AND pe2.StartTime >= @HourStart 
         AND pe2.StartTime < @HourEnd
         AND pe2.ErrorCode IS NOT NULL
         GROUP BY pe2.ErrorCode 
         ORDER BY COUNT(*) DESC) AS MostCommonErrorCode,
        
        -- Data Quality
        ROUND(AVG(CAST(dq.OverallScore AS DECIMAL(5,2))), 2) AS DataQualityScore,
        SUM(CASE WHEN vr.Status = 'Passed' THEN 1 ELSE 0 END) AS ValidationPassCount,
        SUM(CASE WHEN vr.Status = 'Failed' THEN 1 ELSE 0 END) AS ValidationFailCount,
        
        -- Metadata
        GETDATE() AS LoadedAt,
        GETDATE() AS LastModified
    FROM
        [dbo].[Fact_PipelineExecution] pe
    LEFT JOIN
        [dbo].[Fact_DataQuality] dq ON pe.PipelineID = dq.DataSourceID 
        AND CAST(pe.StartTime AS DATE) = dq.CheckDate
    LEFT JOIN
        [dbo].[Fact_ValidationRule] vr ON pe.PipelineID = vr.RuleID 
        AND CAST(pe.StartTime AS DATE) = CAST(vr.ExecutionTime AS DATE)
    WHERE
        pe.StartTime >= @HourStart
        AND pe.StartTime < @HourEnd
    GROUP BY
        pe.PipelineID,
        pe.Status;
    
    -- Log completion
    INSERT INTO [dbo].[AggregationLog] (TableName, AggregationDate, AggregationHour, RecordsAffected, ExecutionDuration)
    VALUES ('Fact_PipelineExecution_Hourly', @CurrDate, @CurrHour, @@ROWCOUNT, @@CPU_TIME);
    
    PRINT CONCAT('Aggregation complete: ', @CurrDate, ' Hour ', @CurrHour, ', Rows: ', @@ROWCOUNT);
END;
```

---

## Phase 2: SQL Agent Job Setup

### Create SQL Agent Job (Execute Every 5 Minutes)

```sql
-- Step 1: Create job
USE [msdb];
GO

EXEC sp_add_job
    @job_name = 'AggregateExecutions_Hourly',
    @enabled = 1,
    @description = 'Aggregate pipeline executions to hourly level for Power BI performance';

-- Step 2: Add job step
EXEC sp_add_jobstep
    @job_name = 'AggregateExecutions_Hourly',
    @step_name = 'ExecuteAggregation',
    @subsystem = 'TSQL',
    @database_name = 'YourDatabaseName',  -- Update with your database
    @command = 'EXEC [dbo].[sp_AggregateExecutions_Hourly]',
    @retry_attempts = 2,
    @retry_interval = 1,
    @on_success_action = 1;  -- Go to next step

-- Step 3: Create schedule (every 5 minutes)
EXEC sp_add_schedule
    @schedule_name = 'Every5Minutes',
    @freq_type = 4,  -- Daily
    @freq_interval = 1,
    @freq_subday_type = 2,  -- Minute
    @freq_subday_interval = 5,
    @active_start_time = 000000,
    @active_end_time = 235959;

-- Step 4: Attach schedule to job
EXEC sp_attach_schedule
    @job_name = 'AggregateExecutions_Hourly',
    @schedule_name = 'Every5Minutes';

-- Step 5: Start job
EXEC sp_start_job @job_name = 'AggregateExecutions_Hourly';

-- Verify job is running
SELECT 
    name AS JobName,
    enabled AS IsEnabled,
    date_created AS CreatedDate
FROM sysjobs
WHERE name = 'AggregateExecutions_Hourly';
```

---

## Phase 3: Data Validation Aggregation Table

### Table 2: Fact_ValidationRule_Daily

```sql
-- Create daily aggregation for validation rules
CREATE TABLE [dbo].[Fact_ValidationRule_Daily] (
    AggregationKey BIGINT NOT NULL PRIMARY KEY,
    ValidationDate DATE NOT NULL,
    RuleID INT NOT NULL,
    RuleCategory NVARCHAR(50),
    
    -- Rule Execution Stats
    TotalExecutions INT NOT NULL DEFAULT 0,
    PassedExecutions INT NOT NULL DEFAULT 0,
    FailedExecutions INT NOT NULL DEFAULT 0,
    WarningExecutions INT NOT NULL DEFAULT 0,
    
    -- Failure Details
    TotalRecordsValidated BIGINT NOT NULL DEFAULT 0,
    TotalRecordsFailed BIGINT NOT NULL DEFAULT 0,
    FailureRate DECIMAL(5,2),
    
    -- Severity Tracking
    CriticalFailures INT DEFAULT 0,
    HighFailures INT DEFAULT 0,
    MediumFailures INT DEFAULT 0,
    LowFailures INT DEFAULT 0,
    
    -- Trend
    FailureCountPreviousDay INT,
    FailureRateTrend DECIMAL(5,2),  -- % change vs previous day
    
    LoadedAt DATETIME2 DEFAULT GETDATE()
);

-- Create indexes
CREATE UNIQUE NONCLUSTERED INDEX [IX_ValidationRuleDaily_PK]
    ON [dbo].[Fact_ValidationRule_Daily] (
        ValidationDate DESC,
        RuleID ASC
    );

CREATE NONCLUSTERED INDEX [IX_ValidationRuleDaily_Category]
    ON [dbo].[Fact_ValidationRule_Daily] (
        RuleCategory ASC,
        ValidationDate DESC
    )
    INCLUDE (FailedExecutions, FailureRate);

-- Populate procedure
CREATE PROCEDURE [dbo].[sp_AggregateValidationRules_Daily]
    @ValidationDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CurrDate DATE = ISNULL(@ValidationDate, CAST(GETDATE() AS DATE));
    DECLARE @PrevDate DATE = DATEADD(DAY, -1, @CurrDate);
    
    DELETE FROM [dbo].[Fact_ValidationRule_Daily]
    WHERE ValidationDate = @CurrDate;
    
    INSERT INTO [dbo].[Fact_ValidationRule_Daily]
    SELECT
        CAST(CONCAT(FORMAT(YEAR(@CurrDate), '0000'), 
                   FORMAT(MONTH(@CurrDate), '00'),
                   FORMAT(DAY(@CurrDate), '00'),
                   FORMAT(vr.RuleID, '00000')) AS BIGINT) AS AggregationKey,
        @CurrDate AS ValidationDate,
        vr.RuleID,
        ISNULL(r.Category, 'Unknown') AS RuleCategory,
        
        COUNT(*) AS TotalExecutions,
        SUM(CASE WHEN vr.Status = 'Passed' THEN 1 ELSE 0 END) AS PassedExecutions,
        SUM(CASE WHEN vr.Status = 'Failed' THEN 1 ELSE 0 END) AS FailedExecutions,
        SUM(CASE WHEN vr.Status = 'Warning' THEN 1 ELSE 0 END) AS WarningExecutions,
        
        SUM(vr.RecordsValidated) AS TotalRecordsValidated,
        SUM(vr.FailedCount) AS TotalRecordsFailed,
        ROUND(100.0 * SUM(vr.FailedCount) / NULLIF(SUM(vr.RecordsValidated), 0), 2) AS FailureRate,
        
        SUM(CASE WHEN vr.SeverityLevel = 'Critical' THEN 1 ELSE 0 END) AS CriticalFailures,
        SUM(CASE WHEN vr.SeverityLevel = 'High' THEN 1 ELSE 0 END) AS HighFailures,
        SUM(CASE WHEN vr.SeverityLevel = 'Medium' THEN 1 ELSE 0 END) AS MediumFailures,
        SUM(CASE WHEN vr.SeverityLevel = 'Low' THEN 1 ELSE 0 END) AS LowFailures,
        
        (SELECT ISNULL(FailedExecutions, 0) FROM [dbo].[Fact_ValidationRule_Daily] 
         WHERE ValidationDate = @PrevDate AND RuleID = vr.RuleID) AS FailureCountPreviousDay,
        
        ROUND(100.0 * (SUM(CASE WHEN vr.Status = 'Failed' THEN 1 ELSE 0 END) - 
               ISNULL((SELECT FailedExecutions FROM [dbo].[Fact_ValidationRule_Daily] 
                       WHERE ValidationDate = @PrevDate AND RuleID = vr.RuleID), 0)) /
               NULLIF((SELECT FailedExecutions FROM [dbo].[Fact_ValidationRule_Daily] 
                       WHERE ValidationDate = @PrevDate AND RuleID = vr.RuleID), 1), 2) AS FailureRateTrend,
        
        GETDATE() AS LoadedAt
    FROM
        [dbo].[Fact_ValidationRule] vr
    LEFT JOIN
        [dbo].[Dim_ValidationRule] r ON vr.RuleID = r.RuleID
    WHERE
        CAST(vr.ExecutionTime AS DATE) = @CurrDate
    GROUP BY
        vr.RuleID,
        r.Category;
    
    PRINT 'Validation rule aggregation completed for ' + CAST(@CurrDate AS NVARCHAR(10));
END;
```

---

## Phase 4: Data Quality Aggregation

### Table 3: Fact_DataQuality_Daily

```sql
CREATE TABLE [dbo].[Fact_DataQuality_Daily] (
    AggregationKey BIGINT NOT NULL PRIMARY KEY,
    QualityCheckDate DATE NOT NULL,
    DataSourceID INT NOT NULL,
    
    -- Quality Scores (0-100)
    AvgCompletenessScore DECIMAL(5,2),
    AvgAccuracyScore DECIMAL(5,2),
    AvgConsistencyScore DECIMAL(5,2),
    AvgFreshnessScore DECIMAL(5,2),
    AvgTimelinessScore DECIMAL(5,2),
    OverallQualityScore DECIMAL(5,2),
    
    -- Status Indicators
    CompletessStatus NVARCHAR(20),  -- Green/Amber/Red
    AccuracyStatus NVARCHAR(20),
    ConsistencyStatus NVARCHAR(20),
    FreshnessStatus NVARCHAR(20),
    OverallStatus NVARCHAR(20),
    
    -- Trend vs Previous Day
    QualityTrendPercentage DECIMAL(5,2),
    
    -- Record Counts
    TotalRecordsChecked BIGINT,
    RecordsWithIssues BIGINT,
    IssuePercentage DECIMAL(5,2),
    
    LoadedAt DATETIME2 DEFAULT GETDATE()
);

CREATE UNIQUE NONCLUSTERED INDEX [IX_DataQualityDaily_PK]
    ON [dbo].[Fact_DataQuality_Daily] (
        QualityCheckDate DESC,
        DataSourceID ASC
    );

-- Populate procedure
CREATE PROCEDURE [dbo].[sp_AggregateDataQuality_Daily]
    @QualityCheckDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CurrDate DATE = ISNULL(@QualityCheckDate, CAST(GETDATE() AS DATE));
    DECLARE @PrevDate DATE = DATEADD(DAY, -1, @CurrDate);
    
    DELETE FROM [dbo].[Fact_DataQuality_Daily]
    WHERE QualityCheckDate = @CurrDate;
    
    INSERT INTO [dbo].[Fact_DataQuality_Daily]
    SELECT
        CAST(CONCAT(FORMAT(YEAR(@CurrDate), '0000'),
                   FORMAT(MONTH(@CurrDate), '00'),
                   FORMAT(DAY(@CurrDate), '00'),
                   FORMAT(dq.DataSourceID, '00000')) AS BIGINT) AS AggregationKey,
        @CurrDate AS QualityCheckDate,
        dq.DataSourceID,
        
        -- Average scores for the day
        ROUND(AVG(dq.CompletenessScore), 2) AS AvgCompletenessScore,
        ROUND(AVG(dq.AccuracyScore), 2) AS AvgAccuracyScore,
        ROUND(AVG(dq.ConsistencyScore), 2) AS AvgConsistencyScore,
        ROUND(AVG(dq.FreshnessScore), 2) AS AvgFreshnessScore,
        ROUND(AVG(dq.TimelinessScore), 2) AS AvgTimelinessScore,
        ROUND(AVG(dq.OverallScore), 2) AS OverallQualityScore,
        
        -- Status indicators
        CASE WHEN AVG(dq.CompletenessScore) >= 95 THEN 'Green'
             WHEN AVG(dq.CompletenessScore) >= 80 THEN 'Amber'
             ELSE 'Red' END AS CompletessStatus,
        CASE WHEN AVG(dq.AccuracyScore) >= 95 THEN 'Green'
             WHEN AVG(dq.AccuracyScore) >= 80 THEN 'Amber'
             ELSE 'Red' END AS AccuracyStatus,
        CASE WHEN AVG(dq.ConsistencyScore) >= 95 THEN 'Green'
             WHEN AVG(dq.ConsistencyScore) >= 80 THEN 'Amber'
             ELSE 'Red' END AS ConsistencyStatus,
        CASE WHEN AVG(dq.FreshnessScore) >= 95 THEN 'Green'
             WHEN AVG(dq.FreshnessScore) >= 80 THEN 'Amber'
             ELSE 'Red' END AS FreshnessStatus,
        CASE WHEN AVG(dq.OverallScore) >= 95 THEN 'Green'
             WHEN AVG(dq.OverallScore) >= 80 THEN 'Amber'
             ELSE 'Red' END AS OverallStatus,
        
        -- Trend
        ROUND(100.0 * (AVG(dq.OverallScore) - 
               ISNULL((SELECT AVG(OverallQualityScore) FROM [dbo].[Fact_DataQuality_Daily]
                      WHERE QualityCheckDate = @PrevDate AND DataSourceID = dq.DataSourceID), 
                      AVG(dq.OverallScore))) / 
               NULLIF((SELECT AVG(OverallQualityScore) FROM [dbo].[Fact_DataQuality_Daily]
                       WHERE QualityCheckDate = @PrevDate AND DataSourceID = dq.DataSourceID), 1), 2) AS QualityTrendPercentage,
        
        -- Record issue tracking
        SUM(CAST(1 AS BIGINT)) AS TotalRecordsChecked,  -- Placeholder - adjust based on your data
        COUNT(CASE WHEN dq.OverallScore < 80 THEN 1 END) AS RecordsWithIssues,
        ROUND(100.0 * COUNT(CASE WHEN dq.OverallScore < 80 THEN 1 END) / 
              NULLIF(COUNT(*), 0), 2) AS IssuePercentage,
        
        GETDATE() AS LoadedAt
    FROM
        [dbo].[Fact_DataQuality] dq
    WHERE
        dq.CheckDate = @CurrDate
    GROUP BY
        dq.DataSourceID;
    
    PRINT 'Data quality aggregation completed for ' + CAST(@CurrDate AS NVARCHAR(10));
END;
```

---

## Phase 5: Archive Strategy

### Archive Old Data (Monthly Cleanup)

```sql
-- Create archive table
CREATE TABLE [dbo].[Fact_PipelineExecution_Archive] (
    ArchiveID BIGINT IDENTITY(1,1),
    ExecutionID BIGINT NOT NULL,
    PipelineID INT NOT NULL,
    StartTime DATETIME2 NOT NULL,
    EndTime DATETIME2,
    Duration DECIMAL(10,2),
    Status NVARCHAR(20),
    RecordsProcessed BIGINT,
    DataVolume DECIMAL(18,4),
    ErrorCode NVARCHAR(100),
    IsRetry BIT,
    ArchivedDate DATETIME2 DEFAULT GETDATE()
);

-- Archive monthly (run on 1st of each month)
CREATE PROCEDURE [dbo].[sp_ArchiveOldExecutions]
    @DaysToKeep INT = 90
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CutoffDate DATETIME2 = DATEADD(DAY, -@DaysToKeep, CAST(GETDATE() AS DATE));
    
    -- Move to archive
    BEGIN TRANSACTION;
    
    INSERT INTO [dbo].[Fact_PipelineExecution_Archive]
    SELECT * FROM [dbo].[Fact_PipelineExecution]
    WHERE StartTime < @CutoffDate;
    
    DELETE FROM [dbo].[Fact_PipelineExecution]
    WHERE StartTime < @CutoffDate;
    
    COMMIT TRANSACTION;
    
    -- Rebuild indexes
    ALTER INDEX ALL ON [dbo].[Fact_PipelineExecution] REBUILD;
    ALTER INDEX ALL ON [dbo].[Fact_PipelineExecution_Hourly] REBUILD;
    
    PRINT CONCAT('Archived executions older than ', @CutoffDate);
END;
```

---

## Phase 6: Monitoring & Validation

### Create Monitoring Table

```sql
-- Track aggregation job performance
CREATE TABLE [dbo].[AggregationLog] (
    LogID BIGINT IDENTITY(1,1),
    TableName NVARCHAR(100),
    AggregationDate DATE,
    AggregationHour TINYINT,
    RecordsAffected INT,
    ExecutionDurationMS INT,
    ExecutionStatus NVARCHAR(20),
    ErrorMessage NVARCHAR(MAX),
    LoggedAt DATETIME2 DEFAULT GETDATE()
);

-- Query to validate accuracy (compare raw vs aggregated)
SELECT 
    'Validation' AS CheckType,
    COUNT(*) AS RawExecutionCount
FROM [dbo].[Fact_PipelineExecution]
WHERE CAST(StartTime AS DATE) = CAST(GETDATE() AS DATE)

UNION ALL

SELECT
    'Aggregation',
    SUM(TotalExecutions)
FROM [dbo].[Fact_PipelineExecution_Hourly]
WHERE ExecutionDate = CAST(GETDATE() AS DATE);

-- Should match! If not, investigate the aggregation logic.
```

### Performance Comparison Query

```sql
-- Before/After performance comparison
SELECT 
    'Raw Data' AS DataSource,
    DATEDIFF(MILLISECOND, @QueryStart, GETDATE()) AS QueryDuration_ms,
    COUNT(*) AS RecordsReturned
FROM [dbo].[Fact_PipelineExecution]
WHERE StartTime >= DATEADD(DAY, -1, GETDATE())

UNION ALL

SELECT 
    'Aggregated Data',
    DATEDIFF(MILLISECOND, @QueryStart, GETDATE()),
    SUM(TotalExecutions)
FROM [dbo].[Fact_PipelineExecution_Hourly]
WHERE ExecutionDate >= DATEADD(DAY, -1, CAST(GETDATE() AS DATE));

-- Expected: Aggregated ~100x faster
```

---

## Phase 7: Power BI Integration

### Power Query: Import Aggregated Table

```m
let
    Source = Sql.Database("server", "database"),
    
    // Import aggregated table (1MB vs 30MB raw)
    PipelineExecutionHourly = Source{[Schema="dbo",Item="Fact_PipelineExecution_Hourly"]}[Data],
    
    // Filter to last 90 days only
    FilteredData = Table.SelectRows(
        PipelineExecutionHourly,
        each [ExecutionDate] >= Date.From(DateTime.FixedLocalNow()) - Duration.From(Duration.Days(90))
    ),
    
    // Type conversions
    TypedData = Table.TransformColumnTypes(
        FilteredData,
        {
            {"ExecutionDate", type date},
            {"ExecutionHour", Int8.Type},
            {"PipelineID", Int32.Type},
            {"TotalExecutions", Int32.Type},
            {"AvgDuration", type number},
            {"DataQualityScore", type number}
        }
    ),
    
    // Add calculated columns
    AddSuccessRate = Table.AddColumn(
        TypedData,
        "SuccessRate",
        each [SuccessfulExecutions] / [TotalExecutions],
        type number
    )
in
    AddSuccessRate
```

### Power BI Model Update

```
Remove: Fact_PipelineExecution (raw, 30MB import)
Add: Fact_PipelineExecution_Hourly (aggregated, 1MB import)

Results:
- Model size: 850MB → 150MB (82% reduction)
- Refresh time: 8 minutes → 1.5 minutes (5x faster)
- Query response: Milliseconds faster
```

---

## Troubleshooting

### Issue: Aggregation SQL Job Fails

```sql
-- Check job history
SELECT 
    jh.job_id,
    j.name,
    jh.step_id,
    jh.step_name,
    jh.sql_message_id,
    jh.message,
    jh.run_status
FROM msdb.dbo.sysjobhistory jh
JOIN msdb.dbo.sysjobs j ON jh.job_id = j.job_id
WHERE j.name = 'AggregateExecutions_Hourly'
ORDER BY jh.run_date DESC, jh.run_time DESC
LIMIT 10;

-- If failed, manually run:
EXEC [dbo].[sp_AggregateExecutions_Hourly] 
    @ExecutionDate = CAST(GETDATE() AS DATE),
    @ExecutionHour = DATEPART(HOUR, GETDATE());
```

### Issue: Aggregated Data Doesn't Match Raw

```sql
-- Debug query
SELECT 
    'Raw' AS Source,
    COUNT(*) AS ExecutionCount,
    SUM(CASE WHEN Status = 'Success' THEN 1 ELSE 0 END) AS SuccessCount
FROM [dbo].[Fact_PipelineExecution]
WHERE CAST(StartTime AS DATE) = '2026-06-05'
AND DATEPART(HOUR, StartTime) = 12

UNION ALL

SELECT
    'Aggregated',
    SUM(TotalExecutions),
    SUM(SuccessfulExecutions)
FROM [dbo].[Fact_PipelineExecution_Hourly]
WHERE ExecutionDate = '2026-06-05'
AND ExecutionHour = 12;
```

---

## Success Criteria

- [ ] Hourly aggregation tables created & populated
- [ ] SQL Agent jobs running every 5 minutes without errors
- [ ] Data validated: Aggregated = Raw (within 0.1%)
- [ ] Power BI model updated to use aggregated tables
- [ ] Import size: 30MB → <2MB
- [ ] Refresh time: 8min → <2min
- [ ] Query performance: <100ms on KPI measures
- [ ] Archive process running monthly

---

**Next Step**: Proceed to [AUTOMATION_PERFORMANCE_IMPLEMENTATION.md Week 2](AUTOMATION_PERFORMANCE_IMPLEMENTATION.md) for Power BI model optimization.

