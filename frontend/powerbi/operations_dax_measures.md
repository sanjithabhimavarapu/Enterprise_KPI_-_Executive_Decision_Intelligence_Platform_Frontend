# Operations Dashboard - DAX Measures & Implementation

## Operations Data Model Requirements

### Fact Tables

#### 1. Fact_Operational_Metrics
```
Table: dbo.Fact_Operational_Metrics
Refresh: Real-time / 30-second incremental
Import Mode: DirectQuery (real-time requirement)

Columns:
  MetricID         (INT, PK)
  DateKey          (INT, FK → Dim_Date)
  DepartmentKey    (INT, FK → Dim_Department)
  EmployeeKey      (INT, FK → Dim_Employee)
  ShiftKey         (INT, FK → Dim_Shift)
  TasksAssigned    (INT)
  TasksCompleted   (INT)
  TasksOnTime      (INT)
  TasksOverdue     (INT)
  ProcessingTimeMin(DECIMAL 10,2)
  ErrorCount       (INT)
  ErrorRate        (DECIMAL 5,4)
  CapacityHours    (DECIMAL 10,2)
  AllocatedHours   (DECIMAL 10,2)
  HourKey          (INT)    -- 0-23 for hourly aggregation
  RecordedAt       (DATETIME)
```

#### 2. Fact_SLA_Tracking
```
Table: dbo.Fact_SLA_Tracking
Refresh: Every 15 seconds (real-time)
Import Mode: DirectQuery

Columns:
  SLATicketID      (INT, PK)
  TicketRef        (VARCHAR 50)
  DateKey          (INT, FK → Dim_Date)
  DepartmentKey    (INT, FK → Dim_Department)
  OwnerEmployeeKey (INT, FK → Dim_Employee)
  CategoryKey      (INT, FK → Dim_SLA_Category)
  Priority         (VARCHAR 20) -- Critical/High/Medium/Low
  CreatedAt        (DATETIME)
  SLADeadline      (DATETIME)
  ResolvedAt       (DATETIME, nullable)
  Status           (VARCHAR 20) -- Open/AtRisk/Breached/Resolved
  ResolutionMinutes(INT, nullable)
  IsBreached       (BIT)
  BreachMinutes    (INT, nullable)  -- minutes past deadline (0 if met)
  EscalationLevel  (INT)    -- 0=none, 1=manager, 2=director, 3=exec
```

#### 3. Fact_Resource_Allocation
```
Table: dbo.Fact_Resource_Allocation
Refresh: Hourly
Import Mode: Import

Columns:
  AllocationID     (INT, PK)
  DateKey          (INT, FK → Dim_Date)
  DepartmentKey    (INT, FK → Dim_Department)
  EmployeeKey      (INT, FK → Dim_Employee)
  ShiftKey         (INT, FK → Dim_Shift)
  AllocatedTasks   (INT)
  CapacityTasks    (INT)
  AllocatedHours   (DECIMAL 10,2)
  CapacityHours    (DECIMAL 10,2)
  UtilizationRate  (DECIMAL 5,4)
  IsOverloaded     (BIT)
```

### Dimension Tables

#### Dim_Department
```
Table: dbo.Dim_Department
Columns:
  DepartmentKey    (INT, PK)
  DepartmentID     (VARCHAR 20)
  DepartmentName   (VARCHAR 100)
  DivisionName     (VARCHAR 100)
  ManagerKey       (INT, FK → Dim_Employee)
  ParentDeptKey    (INT, self-referencing)
  CostCenter       (VARCHAR 20)
  HeadCount        (INT)
  SLA_Target_Pct   (DECIMAL 5,2)  -- department SLA target e.g. 95.00
  Efficiency_Target(DECIMAL 5,2)  -- e.g. 85.00
  IsActive         (BIT)
```

#### Dim_SLA_Category
```
Table: dbo.Dim_SLA_Category
Columns:
  CategoryKey      (INT, PK)
  CategoryName     (VARCHAR 100)
  ServiceType      (VARCHAR 50)
  Priority         (VARCHAR 20)
  SLA_Hours        (DECIMAL 5,2)  -- target resolution hours by category
  EscalationHours  (DECIMAL 5,2)
  BusinessHoursOnly(BIT)
```

#### Dim_Shift
```
Table: dbo.Dim_Shift
Columns:
  ShiftKey         (INT, PK)
  ShiftName        (VARCHAR 50)  -- "Shift 1", "Shift 2", "Shift 3"
  StartTime        (TIME)
  EndTime          (TIME)
  ShiftType        (VARCHAR 20)  -- Day/Evening/Night
```

---

## DAX Measures — Efficiency Metrics

### MEASURE 1: Total Tasks Assigned
```dax
Total Tasks Assigned = 
    SUM(Fact_Operational_Metrics[TasksAssigned])

Description: Total number of tasks assigned in current filter context
Format: #,##0
```

---

### MEASURE 2: Total Tasks Completed
```dax
Total Tasks Completed = 
    SUM(Fact_Operational_Metrics[TasksCompleted])

Description: Total completed tasks
Format: #,##0
```

---

### MEASURE 3: Operational Efficiency Index
```dax
Operational Efficiency Index = 
    DIVIDE(
        SUM(Fact_Operational_Metrics[TasksOnTime]),
        SUM(Fact_Operational_Metrics[TasksAssigned]),
        0
    ) * 100

Description: Percentage of assigned tasks completed on time
Format: 0.0"%"
Range: 0-100%
Target: 85%
```

---

### MEASURE 4: Efficiency vs Target
```dax
Efficiency vs Target = 
    [Operational Efficiency Index]
    - AVERAGE(Dim_Department[Efficiency_Target])

Description: Variance between actual efficiency and department target
Format: +0.0"% pts";-0.0"% pts"
Positive = above target (good), Negative = below target (bad)
```

---

### MEASURE 5: Task Completion Rate
```dax
Task Completion Rate = 
    DIVIDE(
        [Total Tasks Completed],
        [Total Tasks Assigned],
        0
    ) * 100

Description: Overall ratio of completed to assigned tasks (includes late completions)
Format: 0.0"%"
```

---

### MEASURE 6: Overdue Tasks Count
```dax
Overdue Tasks Count = 
    SUM(Fact_Operational_Metrics[TasksOverdue])

Description: Number of tasks past their due date
Format: #,##0
```

---

### MEASURE 7: Overdue Rate
```dax
Overdue Rate = 
    DIVIDE(
        [Overdue Tasks Count],
        [Total Tasks Assigned],
        0
    ) * 100

Description: Percentage of tasks that are overdue
Format: 0.0"%"
Color Threshold: < 5% Green | 5-10% Amber | > 10% Red
```

---

### MEASURE 8: Average Processing Time (Minutes)
```dax
Avg Processing Time (Min) = 
    DIVIDE(
        SUM(Fact_Operational_Metrics[ProcessingTimeMin]),
        [Total Tasks Completed],
        0
    )

Description: Mean minutes to process/complete a task
Format: #,##0.0" min"
```

---

### MEASURE 9: Error Rate
```dax
Operational Error Rate = 
    DIVIDE(
        SUM(Fact_Operational_Metrics[ErrorCount]),
        [Total Tasks Completed],
        0
    ) * 100

Description: Errors per completed task as a percentage
Format: 0.00"%"
Target: < 2%
```

---

### MEASURE 10: WoW Efficiency Change
```dax
WoW Efficiency Change = 
    VAR CurrentWeekEff = 
        CALCULATE(
            [Operational Efficiency Index],
            DATESINPERIOD(Dim_Date[Date], MAX(Dim_Date[Date]), -7, DAY)
        )
    VAR PriorWeekEff = 
        CALCULATE(
            [Operational Efficiency Index],
            DATESINPERIOD(Dim_Date[Date], MAX(Dim_Date[Date]) - 7, -7, DAY)
        )
    RETURN 
        CurrentWeekEff - PriorWeekEff

Description: Week-over-week efficiency index change in percentage points
Format: +0.0"% pts";-0.0"% pts"
```

---

## DAX Measures — Department Analysis

### MEASURE 11: Department Efficiency Rank
```dax
Department Efficiency Rank = 
    RANKX(
        ALL(Dim_Department[DepartmentName]),
        [Operational Efficiency Index],
        ,
        DESC,
        DENSE
    )

Description: Ranks departments by efficiency (1 = highest)
Format: #0
Use: Leaderboard, top/bottom performers
```

---

### MEASURE 12: Department Composite Score
```dax
Department Composite Score = 
    VAR EfficiencyScore = [Operational Efficiency Index] * 0.40
    VAR SLAScore = [SLA Compliance Rate] * 0.40
    VAR CapacityScore = 
        IF(
            [Resource Utilization Rate] > 95,
            (200 - [Resource Utilization Rate]) * 0.20,  -- penalize over-capacity
            [Resource Utilization Rate] * 0.20
        )
    RETURN 
        EfficiencyScore + SLAScore + CapacityScore

Description: Weighted composite KPI score per department (0-100)
Weights: Efficiency 40% | SLA Rate 40% | Capacity Utilization 20%
Format: 0.0
Range: 0-100
```

---

### MEASURE 13: Department Composite Rank
```dax
Department Composite Rank = 
    RANKX(
        ALL(Dim_Department[DepartmentName]),
        [Department Composite Score],
        ,
        DESC,
        DENSE
    )

Description: Ranks departments by composite score (1 = best overall)
Format: #0
```

---

### MEASURE 14: Department SLA Target
```dax
Department SLA Target = 
    CALCULATE(
        AVERAGE(Dim_Department[SLA_Target_Pct]),
        VALUES(Dim_Department[DepartmentKey])
    )

Description: The SLA compliance target configured for the department
Format: 0.0"%"
```

---

### MEASURE 15: Tasks Per Employee
```dax
Tasks Per Employee = 
    DIVIDE(
        [Total Tasks Assigned],
        DISTINCTCOUNT(Fact_Operational_Metrics[EmployeeKey]),
        0
    )

Description: Average workload per employee in the filtered context
Format: #,##0.0
```

---

### MEASURE 16: Department Below Target Count
```dax
Departments Below Target Count = 
    COUNTROWS(
        FILTER(
            VALUES(Dim_Department[DepartmentName]),
            [Operational Efficiency Index] < [Department SLA Target]
        )
    )

Description: Number of departments currently below their efficiency target
Format: #0
Alert: Any value > 0 should trigger dashboard warning
```

---

## DAX Measures — SLA Monitoring

### MEASURE 17: Total SLA Tickets
```dax
Total SLA Tickets = 
    COUNTROWS(Fact_SLA_Tracking)

Description: Total SLA tickets in current filter context
Format: #,##0
```

---

### MEASURE 18: SLA Compliance Rate
```dax
SLA Compliance Rate = 
    DIVIDE(
        COUNTROWS(
            FILTER(
                Fact_SLA_Tracking,
                Fact_SLA_Tracking[IsBreached] = FALSE()
                    && Fact_SLA_Tracking[Status] = "Resolved"
            )
        ),
        COUNTROWS(
            FILTER(
                Fact_SLA_Tracking,
                Fact_SLA_Tracking[Status] = "Resolved"
            )
        ),
        0
    ) * 100

Description: % of resolved tickets that were resolved within SLA window
Format: 0.0"%"
Target: 95%
```

---

### MEASURE 19: SLA Compliance Rate (All Closed + Open)
```dax
SLA Compliance Rate (Overall) = 
    DIVIDE(
        COUNTROWS(
            FILTER(
                Fact_SLA_Tracking,
                Fact_SLA_Tracking[IsBreached] = FALSE()
            )
        ),
        [Total SLA Tickets],
        0
    ) * 100

Description: SLA rate across all tickets including open/pending
Format: 0.0"%"
Use: Executive summary card, holistic view
```

---

### MEASURE 20: SLA Breached Count
```dax
SLA Breached Count = 
    CALCULATE(
        COUNTROWS(Fact_SLA_Tracking),
        Fact_SLA_Tracking[IsBreached] = TRUE()
    )

Description: Number of SLA-breached tickets
Format: #,##0
```

---

### MEASURE 21: SLA At Risk Count
```dax
SLA At Risk Count = 
    CALCULATE(
        COUNTROWS(Fact_SLA_Tracking),
        Fact_SLA_Tracking[Status] = "AtRisk"
    )

Description: Open tickets within 80% of their SLA deadline
Format: #,##0
```

---

### MEASURE 22: SLA Breach Rate
```dax
SLA Breach Rate = 
    DIVIDE(
        [SLA Breached Count],
        [Total SLA Tickets],
        0
    ) * 100

Description: Percentage of tickets that breached their SLA
Format: 0.0"%"
Target: < 5%
```

---

### MEASURE 23: Average Resolution Time (Hours)
```dax
Avg Resolution Time (Hours) = 
    DIVIDE(
        CALCULATE(
            SUM(Fact_SLA_Tracking[ResolutionMinutes]),
            Fact_SLA_Tracking[Status] = "Resolved",
            NOT ISBLANK(Fact_SLA_Tracking[ResolutionMinutes])
        ),
        CALCULATE(
            COUNTROWS(Fact_SLA_Tracking),
            Fact_SLA_Tracking[Status] = "Resolved"
        ),
        0
    ) / 60

Description: Mean resolution time in hours for resolved tickets
Format: 0.0" hrs"
```

---

### MEASURE 24: Median Resolution Time (Hours)
```dax
Median Resolution Time (Hours) = 
    MEDIANX(
        FILTER(
            Fact_SLA_Tracking,
            Fact_SLA_Tracking[Status] = "Resolved"
                && NOT ISBLANK(Fact_SLA_Tracking[ResolutionMinutes])
        ),
        Fact_SLA_Tracking[ResolutionMinutes]
    ) / 60

Description: P50 resolution time in hours — less sensitive to outliers
Format: 0.0" hrs"
```

---

### MEASURE 25: P95 Resolution Time (Hours)
```dax
P95 Resolution Time (Hours) = 
    PERCENTILEX.INC(
        FILTER(
            Fact_SLA_Tracking,
            Fact_SLA_Tracking[Status] = "Resolved"
                && NOT ISBLANK(Fact_SLA_Tracking[ResolutionMinutes])
        ),
        Fact_SLA_Tracking[ResolutionMinutes],
        0.95
    ) / 60

Description: 95th percentile resolution time — captures worst-case performance
Format: 0.0" hrs"
Use: Identify outliers and chronically delayed tickets
```

---

### MEASURE 26: SLA Time Remaining (Minutes)
```dax
SLA Time Remaining (Min) = 
    VAR NowUTC = NOW()
    RETURN 
        AVERAGEX(
            FILTER(
                Fact_SLA_Tracking,
                Fact_SLA_Tracking[Status] IN {"Open", "AtRisk"}
            ),
            DATEDIFF(NowUTC, Fact_SLA_Tracking[SLADeadline], MINUTE)
        )

Description: Average minutes remaining before SLA breach for open tickets
Format: #,##0" min"
Note: Negative values indicate already-breached tickets
```

---

### MEASURE 27: Average Breach Overrun (Hours)
```dax
Avg Breach Overrun (Hours) = 
    DIVIDE(
        CALCULATE(
            SUM(Fact_SLA_Tracking[BreachMinutes]),
            Fact_SLA_Tracking[IsBreached] = TRUE()
        ),
        [SLA Breached Count],
        0
    ) / 60

Description: How far past the SLA deadline breached tickets ran on average
Format: 0.0" hrs over SLA"
Use: Quantify breach severity, identify systematic delays
```

---

### MEASURE 28: Critical SLA Breaches Today
```dax
Critical SLA Breaches Today = 
    CALCULATE(
        [SLA Breached Count],
        Fact_SLA_Tracking[Priority] = "Critical",
        Dim_Date[Date] = TODAY()
    )

Description: Count of Critical priority SLA breaches today
Format: #0
Alert Threshold: Any value > 0 → Red alert badge
```

---

### MEASURE 29: SLA Compliance Rate (Critical Priority)
```dax
SLA Compliance Rate - Critical = 
    CALCULATE(
        [SLA Compliance Rate],
        Fact_SLA_Tracking[Priority] = "Critical"
    )

Description: SLA compliance rate restricted to Critical-priority tickets
Format: 0.0"%"
Target: 99% for Critical priority
```

---

### MEASURE 30: SLA Compliance Rate (High Priority)
```dax
SLA Compliance Rate - High = 
    CALCULATE(
        [SLA Compliance Rate],
        Fact_SLA_Tracking[Priority] = "High"
    )

Description: SLA compliance rate for High-priority tickets
Format: 0.0"%"
Target: 97%
```

---

### MEASURE 31: WoW SLA Compliance Change
```dax
WoW SLA Compliance Change = 
    VAR ThisWeek = 
        CALCULATE(
            [SLA Compliance Rate],
            DATESINPERIOD(Dim_Date[Date], MAX(Dim_Date[Date]), -7, DAY)
        )
    VAR LastWeek = 
        CALCULATE(
            [SLA Compliance Rate],
            DATESINPERIOD(Dim_Date[Date], MAX(Dim_Date[Date]) - 7, -7, DAY)
        )
    RETURN 
        ThisWeek - LastWeek

Description: Week-over-week SLA compliance change in percentage points
Format: +0.0"% pts";-0.0"% pts"
```

---

### MEASURE 32: SLA Compliance MTD
```dax
SLA Compliance MTD = 
    CALCULATE(
        [SLA Compliance Rate],
        DATESMTD(Dim_Date[Date])
    )

Description: Month-to-date SLA compliance rate
Format: 0.0"%"
```

---

## DAX Measures — Resource Utilization

### MEASURE 33: Resource Utilization Rate
```dax
Resource Utilization Rate = 
    DIVIDE(
        SUM(Fact_Resource_Allocation[AllocatedHours]),
        SUM(Fact_Resource_Allocation[CapacityHours]),
        0
    ) * 100

Description: Percentage of available capacity actively allocated
Format: 0.0"%"
Optimal Range: 70-85%
```

---

### MEASURE 34: Overloaded Staff Count
```dax
Overloaded Staff Count = 
    CALCULATE(
        DISTINCTCOUNT(Fact_Resource_Allocation[EmployeeKey]),
        Fact_Resource_Allocation[IsOverloaded] = TRUE()
    )

Description: Number of employees currently assigned beyond 100% capacity
Format: #0
```

---

### MEASURE 35: Available Capacity (Hours)
```dax
Available Capacity Hours = 
    SUM(Fact_Resource_Allocation[CapacityHours])
    - SUM(Fact_Resource_Allocation[AllocatedHours])

Description: Remaining unallocated hours across filtered team/department
Format: #,##0.0" hrs"
```

---

### MEASURE 36: Capacity Gap
```dax
Capacity Gap = 
    VAR Demand = [Total Tasks Assigned]
    VAR Supply = SUM(Fact_Resource_Allocation[CapacityTasks])
    RETURN 
        Supply - Demand

Description: Surplus (positive) or deficit (negative) capacity vs demand
Format: +#,##0" surplus";-#,##0" deficit";0" balanced"
```

---

## DAX Measures — Trend & Time Intelligence

### MEASURE 37: 7-Day Rolling Efficiency
```dax
7-Day Rolling Efficiency = 
    CALCULATE(
        [Operational Efficiency Index],
        DATESINPERIOD(Dim_Date[Date], LASTDATE(Dim_Date[Date]), -7, DAY)
    )

Description: Efficiency index over trailing 7 days from last date in context
Format: 0.0"%"
Use: Line chart trend, smoothed metric
```

---

### MEASURE 38: 30-Day Rolling SLA Rate
```dax
30-Day Rolling SLA Rate = 
    CALCULATE(
        [SLA Compliance Rate],
        DATESINPERIOD(Dim_Date[Date], LASTDATE(Dim_Date[Date]), -30, DAY)
    )

Description: SLA compliance rate over trailing 30 days
Format: 0.0"%"
```

---

### MEASURE 39: Efficiency Forecast (Next 7 Days)
```dax
Efficiency Forecast (Next 7 Days) = 
    VAR Trend7D = 
        [7-Day Rolling Efficiency] - 
        CALCULATE(
            [Operational Efficiency Index],
            DATESINPERIOD(Dim_Date[Date], LASTDATE(Dim_Date[Date]) - 7, -7, DAY)
        )
    RETURN 
        [Operational Efficiency Index] + (Trend7D * 1)  -- linear projection

Description: Simple linear extrapolation of efficiency for next 7 days
Format: 0.0"%"
Note: Replace with ML-based forecast measure when available
```

---

## DAX Calculated Columns

### Column 1: SLA Status Label (Fact_SLA_Tracking)
```dax
SLA Status Label = 
    SWITCH(
        TRUE(),
        Fact_SLA_Tracking[IsBreached] = TRUE(), "🔴 Breached",
        Fact_SLA_Tracking[Status] = "AtRisk",   "🟡 At Risk",
        Fact_SLA_Tracking[Status] = "Resolved"
            && Fact_SLA_Tracking[IsBreached] = FALSE(), "🟢 Met SLA",
        Fact_SLA_Tracking[Status] = "Open",     "⬜ Open",
        "Unknown"
    )

Description: Human-readable status label with emoji for table display
```

---

### Column 2: Priority Sort Order (Fact_SLA_Tracking)
```dax
Priority Sort Order = 
    SWITCH(
        Fact_SLA_Tracking[Priority],
        "Critical", 1,
        "High",     2,
        "Medium",   3,
        "Low",      4,
        99
    )

Description: Numeric sort key to order tickets by priority descending
Use: Sort the SLA table default order
```

---

### Column 3: Efficiency Band (Fact_Operational_Metrics)
```dax
Efficiency Band = 
    VAR Eff = 
        DIVIDE(
            Fact_Operational_Metrics[TasksOnTime],
            Fact_Operational_Metrics[TasksAssigned],
            0
        ) * 100
    RETURN 
        SWITCH(
            TRUE(),
            Eff >= 90, "Optimal (≥90%)",
            Eff >= 75, "Normal (75-89%)",
            Eff >= 60, "Below Target (60-74%)",
            "Critical (<60%)"
        )

Description: Efficiency category label per row for segmentation
Use: Conditional formatting, segment slicer
```

---

## DAX Measures — Status Cards

### MEASURE 40: Operations Status
```dax
Operations Status = 
    VAR Eff = [Operational Efficiency Index]
    VAR SLA = [SLA Compliance Rate]
    VAR CapUtil = [Resource Utilization Rate]
    RETURN 
        SWITCH(
            TRUE(),
            Eff < 60 || SLA < 85 || CapUtil > 98,  "🔴 CRITICAL",
            Eff < 75 || SLA < 92 || CapUtil > 90,  "🟡 AT RISK",
            "🟢 OPERATIONAL"
        )

Description: Composite status string for header badge
Format: Text
Use: Header status indicator, alert logic
```

---

## Relationships to Add in Power BI

```
Fact_SLA_Tracking[DateKey]         → Dim_Date[DateKey]           (Many:1, Single filter)
Fact_SLA_Tracking[DepartmentKey]   → Dim_Department[DepartmentKey] (Many:1, Single filter)
Fact_SLA_Tracking[OwnerEmployeeKey]→ Dim_Employee[EmployeeKey]   (Many:1, Single filter)
Fact_SLA_Tracking[CategoryKey]     → Dim_SLA_Category[CategoryKey](Many:1, Single filter)

Fact_Operational_Metrics[DateKey]        → Dim_Date[DateKey]           (Many:1, Single filter)
Fact_Operational_Metrics[DepartmentKey]  → Dim_Department[DepartmentKey](Many:1, Both filter)
Fact_Operational_Metrics[EmployeeKey]    → Dim_Employee[EmployeeKey]   (Many:1, Single filter)
Fact_Operational_Metrics[ShiftKey]       → Dim_Shift[ShiftKey]         (Many:1, Single filter)

Fact_Resource_Allocation[DateKey]        → Dim_Date[DateKey]           (Many:1, Single filter)
Fact_Resource_Allocation[DepartmentKey]  → Dim_Department[DepartmentKey](Many:1, Single filter)
Fact_Resource_Allocation[EmployeeKey]    → Dim_Employee[EmployeeKey]   (Many:1, Single filter)
Fact_Resource_Allocation[ShiftKey]       → Dim_Shift[ShiftKey]         (Many:1, Single filter)
```
