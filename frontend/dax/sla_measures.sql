-- ============================================================
-- SLA MEASURES - Enterprise KPI Platform
-- Operations Dashboard: SLA Monitoring & Department Analysis
-- ============================================================
-- Source Tables:
--   Fact_SLA_Tracking        : SLA ticket events
--   Fact_Operational_Metrics : Department operational data
--   Dim_Department           : Department dimension
--   Dim_SLA_Category         : SLA category & target hours
--   Dim_Employee             : Staff dimension
--   Dim_Date                 : Date dimension
-- ============================================================


-- ============================================================
-- SECTION 1: SLA COMPLIANCE CORE METRICS
-- ============================================================

-- 1.1 SLA Compliance Rate (Resolved Tickets)
-- Percentage of resolved tickets closed within the SLA window
SELECT
    d.DepartmentName,
    sc.Priority,
    sc.CategoryName,
    COUNT(*)                                                        AS TotalResolved,
    SUM(CASE WHEN s.IsBreached = 0 THEN 1 ELSE 0 END)             AS ResolvedWithinSLA,
    CAST(
        SUM(CASE WHEN s.IsBreached = 0 THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(*), 0)
    AS DECIMAL(5,2))                                               AS SLA_Compliance_Rate_Pct,
    CAST(
        SUM(CASE WHEN s.IsBreached = 1 THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(*), 0)
    AS DECIMAL(5,2))                                               AS SLA_Breach_Rate_Pct
FROM  Fact_SLA_Tracking       s
JOIN  Dim_Department          d  ON s.DepartmentKey    = d.DepartmentKey
JOIN  Dim_SLA_Category        sc ON s.CategoryKey      = sc.CategoryKey
WHERE s.Status = 'Resolved'
GROUP BY
    d.DepartmentName,
    sc.Priority,
    sc.CategoryName
ORDER BY
    SLA_Breach_Rate_Pct DESC,
    d.DepartmentName;


-- 1.2 Overall SLA Compliance (All Statuses — Holistic View)
SELECT
    d.DepartmentName,
    COUNT(*)                                                           AS TotalTickets,
    SUM(CASE WHEN s.IsBreached = 0 THEN 1 ELSE 0 END)                AS WithinSLA,
    SUM(CASE WHEN s.IsBreached = 1 THEN 1 ELSE 0 END)                AS Breached,
    SUM(CASE WHEN s.Status = 'AtRisk'  THEN 1 ELSE 0 END)            AS AtRisk,
    SUM(CASE WHEN s.Status = 'Open'    THEN 1 ELSE 0 END)            AS Open,
    CAST(
        SUM(CASE WHEN s.IsBreached = 0 THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(*), 0)
    AS DECIMAL(5,2))                                                   AS Overall_SLA_Pct,
    d.SLA_Target_Pct,
    CAST(
        SUM(CASE WHEN s.IsBreached = 0 THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(*), 0)
    AS DECIMAL(5,2))
    - d.SLA_Target_Pct                                                 AS vs_Target_Pts
FROM  Fact_SLA_Tracking  s
JOIN  Dim_Department     d ON s.DepartmentKey = d.DepartmentKey
GROUP BY
    d.DepartmentName,
    d.SLA_Target_Pct
ORDER BY
    vs_Target_Pts ASC;   -- Worst performers first


-- ============================================================
-- SECTION 2: SLA RESOLUTION TIME ANALYSIS
-- ============================================================

-- 2.1 Average, Median, P95 Resolution Time by Department & Priority
SELECT
    d.DepartmentName,
    s.Priority,
    COUNT(*)                                         AS TicketCount,
    CAST(AVG(s.ResolutionMinutes) AS DECIMAL(10,2)) AS Avg_Resolution_Min,
    CAST(
        PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY s.ResolutionMinutes)
    AS DECIMAL(10,2))                                AS Median_Resolution_Min,
    CAST(
        PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY s.ResolutionMinutes)
    AS DECIMAL(10,2))                                AS P95_Resolution_Min,
    CAST(AVG(s.ResolutionMinutes) / 60.0 AS DECIMAL(10,2))  AS Avg_Resolution_Hours,
    sc.SLA_Hours                                     AS SLA_Target_Hours,
    CAST(
        AVG(s.ResolutionMinutes) / 60.0 - sc.SLA_Hours
    AS DECIMAL(10,2))                                AS Avg_vs_SLA_Target_Hours
FROM  Fact_SLA_Tracking   s
JOIN  Dim_Department      d  ON s.DepartmentKey = d.DepartmentKey
JOIN  Dim_SLA_Category    sc ON s.CategoryKey   = sc.CategoryKey
WHERE s.Status = 'Resolved'
  AND s.ResolutionMinutes IS NOT NULL
GROUP BY
    d.DepartmentName,
    s.Priority,
    sc.SLA_Hours
ORDER BY
    Avg_vs_SLA_Target_Hours DESC;


-- 2.2 Resolution Time Distribution Buckets
SELECT
    d.DepartmentName,
    s.Priority,
    SUM(CASE WHEN s.ResolutionMinutes <=  60 THEN 1 ELSE 0 END) AS Within_1hr,
    SUM(CASE WHEN s.ResolutionMinutes BETWEEN  61 AND  240 THEN 1 ELSE 0 END) AS Within_4hrs,
    SUM(CASE WHEN s.ResolutionMinutes BETWEEN 241 AND  480 THEN 1 ELSE 0 END) AS Within_8hrs,
    SUM(CASE WHEN s.ResolutionMinutes BETWEEN 481 AND 1440 THEN 1 ELSE 0 END) AS Within_24hrs,
    SUM(CASE WHEN s.ResolutionMinutes  > 1440 THEN 1 ELSE 0 END)              AS Over_24hrs,
    COUNT(*)                                                                   AS Total
FROM  Fact_SLA_Tracking  s
JOIN  Dim_Department     d ON s.DepartmentKey = d.DepartmentKey
WHERE s.Status = 'Resolved'
GROUP BY
    d.DepartmentName,
    s.Priority
ORDER BY
    d.DepartmentName,
    s.Priority;


-- ============================================================
-- SECTION 3: SLA BREACH ANALYSIS
-- ============================================================

-- 3.1 Breach Summary by Department, Priority, and Category
SELECT
    d.DepartmentName,
    s.Priority,
    sc.CategoryName,
    COUNT(*)                                                          AS TotalBreaches,
    CAST(AVG(s.BreachMinutes)         AS DECIMAL(10,2))              AS Avg_Breach_Overrun_Min,
    CAST(AVG(s.BreachMinutes) / 60.0  AS DECIMAL(10,2))              AS Avg_Breach_Overrun_Hrs,
    CAST(MAX(s.BreachMinutes) / 60.0  AS DECIMAL(10,2))              AS Max_Breach_Overrun_Hrs,
    MAX(s.EscalationLevel)                                            AS Max_Escalation_Level
FROM  Fact_SLA_Tracking  s
JOIN  Dim_Department     d  ON s.DepartmentKey = d.DepartmentKey
JOIN  Dim_SLA_Category   sc ON s.CategoryKey   = sc.CategoryKey
WHERE s.IsBreached = 1
GROUP BY
    d.DepartmentName,
    s.Priority,
    sc.CategoryName
ORDER BY
    s.Priority,
    TotalBreaches DESC;


-- 3.2 Critical SLA Breaches — Actionable List
SELECT
    s.TicketRef,
    d.DepartmentName,
    sc.CategoryName,
    s.Priority,
    s.CreatedAt,
    s.SLADeadline,
    s.ResolvedAt,
    CAST(s.BreachMinutes / 60.0 AS DECIMAL(10,2)) AS Breach_Hours,
    e.EmployeeName                                 AS Owner,
    s.EscalationLevel,
    s.Status
FROM  Fact_SLA_Tracking  s
JOIN  Dim_Department     d  ON s.DepartmentKey     = d.DepartmentKey
JOIN  Dim_SLA_Category   sc ON s.CategoryKey       = sc.CategoryKey
JOIN  Dim_Employee       e  ON s.OwnerEmployeeKey  = e.EmployeeKey
WHERE s.IsBreached = 1
  AND s.Priority   IN ('Critical', 'High')
ORDER BY
    s.SLADeadline ASC;


-- 3.3 Weekly SLA Breach Trend
SELECT
    dt.Year,
    dt.Week,
    CAST(MIN(dt.Date) AS DATE)    AS WeekStartDate,
    d.DepartmentName,
    s.Priority,
    COUNT(*)                      AS TotalTickets,
    SUM(CASE WHEN s.IsBreached = 1 THEN 1 ELSE 0 END)  AS Breaches,
    CAST(
        SUM(CASE WHEN s.IsBreached = 0 AND s.Status = 'Resolved' THEN 1 ELSE 0 END) * 100.0
        / NULLIF(SUM(CASE WHEN s.Status = 'Resolved' THEN 1 ELSE 0 END), 0)
    AS DECIMAL(5,2))              AS Weekly_SLA_Compliance_Pct
FROM  Fact_SLA_Tracking  s
JOIN  Dim_Date           dt ON s.DateKey       = dt.DateKey
JOIN  Dim_Department     d  ON s.DepartmentKey = d.DepartmentKey
GROUP BY
    dt.Year,
    dt.Week,
    d.DepartmentName,
    s.Priority
ORDER BY
    dt.Year,
    dt.Week,
    d.DepartmentName;


-- ============================================================
-- SECTION 4: DEPARTMENT ANALYSIS
-- ============================================================

-- 4.1 Department Operational Performance Summary
SELECT
    d.DepartmentName,
    d.DivisionName,
    d.HeadCount,
    SUM(om.TasksAssigned)                                              AS Tasks_Assigned,
    SUM(om.TasksCompleted)                                             AS Tasks_Completed,
    SUM(om.TasksOnTime)                                                AS Tasks_On_Time,
    SUM(om.TasksOverdue)                                               AS Tasks_Overdue,
    SUM(om.ErrorCount)                                                 AS Error_Count,
    CAST(
        SUM(om.TasksOnTime) * 100.0
        / NULLIF(SUM(om.TasksAssigned), 0)
    AS DECIMAL(5,2))                                                   AS Efficiency_Index_Pct,
    CAST(
        SUM(om.TasksOverdue) * 100.0
        / NULLIF(SUM(om.TasksAssigned), 0)
    AS DECIMAL(5,2))                                                   AS Overdue_Rate_Pct,
    CAST(
        SUM(om.ErrorCount) * 100.0
        / NULLIF(SUM(om.TasksCompleted), 0)
    AS DECIMAL(5,2))                                                   AS Error_Rate_Pct,
    CAST(
        AVG(om.ProcessingTimeMin)
    AS DECIMAL(10,2))                                                  AS Avg_Processing_Min,
    d.Efficiency_Target                                                AS Target_Efficiency_Pct,
    CAST(
        SUM(om.TasksOnTime) * 100.0
        / NULLIF(SUM(om.TasksAssigned), 0)
    AS DECIMAL(5,2))
    - d.Efficiency_Target                                              AS vs_Target_Pts
FROM  Fact_Operational_Metrics  om
JOIN  Dim_Department            d  ON om.DepartmentKey = d.DepartmentKey
GROUP BY
    d.DepartmentName,
    d.DivisionName,
    d.HeadCount,
    d.Efficiency_Target
ORDER BY
    vs_Target_Pts ASC;   -- Worst performers first


-- 4.2 Department SLA Performance vs Operational Efficiency (Combined View)
SELECT
    d.DepartmentName,
    d.DivisionName,

    -- Efficiency metrics
    CAST(
        SUM(om.TasksOnTime) * 100.0
        / NULLIF(SUM(om.TasksAssigned), 0)
    AS DECIMAL(5,2))   AS Efficiency_Pct,

    -- SLA metrics
    CAST(
        SUM(CASE WHEN s.IsBreached = 0 AND s.Status = 'Resolved' THEN 1 ELSE 0 END) * 100.0
        / NULLIF(SUM(CASE WHEN s.Status = 'Resolved' THEN 1 ELSE 0 END), 0)
    AS DECIMAL(5,2))   AS SLA_Compliance_Pct,

    -- Resource utilization
    CAST(
        SUM(ra.AllocatedHours) * 100.0
        / NULLIF(SUM(ra.CapacityHours), 0)
    AS DECIMAL(5,2))   AS Resource_Utilization_Pct,

    -- Composite score: Efficiency 40% + SLA 40% + Capacity 20%
    CAST(
        (SUM(om.TasksOnTime) * 100.0 / NULLIF(SUM(om.TasksAssigned), 0)) * 0.40
      + (SUM(CASE WHEN s.IsBreached = 0 AND s.Status = 'Resolved' THEN 1 ELSE 0 END) * 100.0
         / NULLIF(SUM(CASE WHEN s.Status = 'Resolved' THEN 1 ELSE 0 END), 0)) * 0.40
      + CASE
            WHEN (SUM(ra.AllocatedHours) * 100.0 / NULLIF(SUM(ra.CapacityHours), 0)) > 95
            THEN (200 - (SUM(ra.AllocatedHours) * 100.0 / NULLIF(SUM(ra.CapacityHours), 0))) * 0.20
            ELSE (SUM(ra.AllocatedHours) * 100.0 / NULLIF(SUM(ra.CapacityHours), 0)) * 0.20
        END
    AS DECIMAL(5,2))   AS Composite_Score,

    -- Targets
    d.Efficiency_Target,
    d.SLA_Target_Pct

FROM  Fact_Operational_Metrics  om
JOIN  Dim_Department            d   ON om.DepartmentKey = d.DepartmentKey
LEFT JOIN Fact_SLA_Tracking     s   ON s.DepartmentKey  = d.DepartmentKey
LEFT JOIN Fact_Resource_Allocation ra ON ra.DepartmentKey = d.DepartmentKey
GROUP BY
    d.DepartmentName,
    d.DivisionName,
    d.Efficiency_Target,
    d.SLA_Target_Pct
ORDER BY
    Composite_Score DESC;


-- 4.3 Department Daily Trend (Rolling 30 Days)
SELECT
    dt.Date,
    d.DepartmentName,
    CAST(
        SUM(om.TasksOnTime) * 100.0
        / NULLIF(SUM(om.TasksAssigned), 0)
    AS DECIMAL(5,2))   AS Daily_Efficiency_Pct,
    CAST(
        SUM(CASE WHEN s.IsBreached = 0 AND s.Status = 'Resolved' THEN 1 ELSE 0 END) * 100.0
        / NULLIF(SUM(CASE WHEN s.Status = 'Resolved' THEN 1 ELSE 0 END), 0)
    AS DECIMAL(5,2))   AS Daily_SLA_Compliance_Pct,
    SUM(om.TasksAssigned)  AS Daily_Tasks_Assigned,
    SUM(om.TasksOverdue)   AS Daily_Overdue
FROM  Fact_Operational_Metrics  om
JOIN  Dim_Date                  dt ON om.DateKey       = dt.DateKey
JOIN  Dim_Department            d  ON om.DepartmentKey = d.DepartmentKey
LEFT JOIN Fact_SLA_Tracking     s  ON s.DepartmentKey  = d.DepartmentKey
                                   AND s.DateKey       = dt.DateKey
WHERE dt.Date >= DATEADD(DAY, -30, CAST(GETDATE() AS DATE))
GROUP BY
    dt.Date,
    d.DepartmentName
ORDER BY
    dt.Date DESC,
    d.DepartmentName;


-- ============================================================
-- SECTION 5: SHIFT & PEAK HOUR ANALYSIS
-- ============================================================

-- 5.1 Hourly Volume vs Capacity
SELECT
    om.HourKey                                   AS HourOfDay,
    FORMAT(CAST(om.HourKey AS VARCHAR) + ':00', 'HH:mm') AS HourLabel,
    d.DepartmentName,
    SUM(om.TasksAssigned)                        AS Volume_Tasks,
    SUM(ra.CapacityTasks)                        AS Capacity_Tasks,
    CAST(
        SUM(om.TasksAssigned) * 100.0
        / NULLIF(SUM(ra.CapacityTasks), 0)
    AS DECIMAL(5,2))                             AS Hourly_Load_Pct
FROM  Fact_Operational_Metrics   om
JOIN  Dim_Department             d   ON om.DepartmentKey = d.DepartmentKey
LEFT JOIN Fact_Resource_Allocation ra ON ra.DepartmentKey = d.DepartmentKey
                                      AND ra.ShiftKey    = om.ShiftKey
GROUP BY
    om.HourKey,
    d.DepartmentName
ORDER BY
    om.HourKey,
    d.DepartmentName;


-- 5.2 Shift Performance Comparison
SELECT
    sh.ShiftName,
    sh.ShiftType,
    d.DepartmentName,
    SUM(om.TasksAssigned)  AS Tasks_Assigned,
    CAST(
        SUM(om.TasksOnTime) * 100.0
        / NULLIF(SUM(om.TasksAssigned), 0)
    AS DECIMAL(5,2))       AS Efficiency_Pct,
    CAST(
        SUM(ra.AllocatedHours) * 100.0
        / NULLIF(SUM(ra.CapacityHours), 0)
    AS DECIMAL(5,2))       AS Utilization_Pct,
    CAST(
        SUM(om.ErrorCount) * 100.0
        / NULLIF(SUM(om.TasksCompleted), 0)
    AS DECIMAL(5,2))       AS Error_Rate_Pct
FROM  Fact_Operational_Metrics  om
JOIN  Dim_Shift                 sh ON om.ShiftKey      = sh.ShiftKey
JOIN  Dim_Department            d  ON om.DepartmentKey = d.DepartmentKey
LEFT JOIN Fact_Resource_Allocation ra ON ra.ShiftKey      = sh.ShiftKey
                                      AND ra.DepartmentKey = d.DepartmentKey
GROUP BY
    sh.ShiftName,
    sh.ShiftType,
    d.DepartmentName
ORDER BY
    sh.ShiftType,
    d.DepartmentName;


-- ============================================================
-- SECTION 6: RESOURCE UTILIZATION SUMMARY
-- ============================================================

-- 6.1 Department Resource Utilization
SELECT
    d.DepartmentName,
    CAST(SUM(ra.AllocatedHours)   AS DECIMAL(10,2))  AS Allocated_Hours,
    CAST(SUM(ra.CapacityHours)    AS DECIMAL(10,2))  AS Capacity_Hours,
    CAST(
        SUM(ra.CapacityHours) - SUM(ra.AllocatedHours)
    AS DECIMAL(10,2))                                AS Available_Hours,
    CAST(
        SUM(ra.AllocatedHours) * 100.0
        / NULLIF(SUM(ra.CapacityHours), 0)
    AS DECIMAL(5,2))                                 AS Utilization_Pct,
    COUNT(DISTINCT CASE WHEN ra.IsOverloaded = 1 THEN ra.EmployeeKey END) AS Overloaded_Staff,
    COUNT(DISTINCT ra.EmployeeKey)                   AS Total_Staff
FROM  Fact_Resource_Allocation  ra
JOIN  Dim_Department            d  ON ra.DepartmentKey = d.DepartmentKey
GROUP BY
    d.DepartmentName
ORDER BY
    Utilization_Pct DESC;


-- 6.2 Overloaded Staff Detail
SELECT
    e.EmployeeName,
    d.DepartmentName,
    CAST(SUM(ra.AllocatedHours) AS DECIMAL(10,2))  AS Allocated_Hours,
    CAST(SUM(ra.CapacityHours)  AS DECIMAL(10,2))  AS Capacity_Hours,
    CAST(
        SUM(ra.AllocatedHours) * 100.0
        / NULLIF(SUM(ra.CapacityHours), 0)
    AS DECIMAL(5,2))                               AS Utilization_Pct,
    CAST(
        SUM(ra.AllocatedHours) - SUM(ra.CapacityHours)
    AS DECIMAL(10,2))                              AS Overload_Hours
FROM  Fact_Resource_Allocation  ra
JOIN  Dim_Department            d  ON ra.DepartmentKey = d.DepartmentKey
JOIN  Dim_Employee              e  ON ra.EmployeeKey   = e.EmployeeKey
WHERE ra.IsOverloaded = 1
GROUP BY
    e.EmployeeName,
    d.DepartmentName
ORDER BY
    Overload_Hours DESC;
