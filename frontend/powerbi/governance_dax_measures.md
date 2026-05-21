# Governance Dashboard - DAX Measures & Implementation

## Governance Data Model Requirements

### Fact Tables
1. **Fact_Compliance**: Main compliance tracking facts
   - ComplianceID (Key)
   - Date
   - RegulationType
   - ComplianceScore
   - NumberOfControls
   - ControlsEffective
   - ViolationCount

2. **Fact_RiskRegister**: Risk assessment data
   - RiskID (Key)
   - Date
   - RiskName
   - Likelihood (1-5)
   - Impact (1-5)
   - MitigationStatus
   - OwnerID

3. **Fact_Audit**: Audit schedule and results
   - AuditID (Key)
   - AuditType
   - ScheduledStart
   - ScheduledEnd
   - ActualStart
   - ActualEnd
   - Status
   - Findings

4. **Fact_Issues**: Governance issues tracking
   - IssueID (Key)
   - IssueType (Policy, Compliance, Risk, Audit)
   - Severity (Critical, High, Medium, Low)
   - Status (Open, In Progress, Resolved)
   - CreatedDate
   - ResolvedDate
   - OwnerID
   - Description

### Dimension Tables
1. **Dim_Regulation**: Regulation types
   - RegulationID
   - RegulationName (SOX, GDPR, HIPAA, etc.)
   - RegulationCategory
   - EffectiveDate

2. **Dim_Control**: Control definitions
   - ControlID
   - ControlName
   - RegulationID (FK)
   - ControlType
   - Frequency
   - Owner

3. **Dim_Date**: Standard date dimension
   - DateID
   - Date
   - Month
   - Quarter
   - Year
   - DayOfWeek

---

## DAX Measures - Governance Metrics

### COMPLIANCE SCORE MEASURES

#### Measure 1: Overall Compliance Score
```dax
Overall Compliance Score = 
    DIVIDE(
        SUMX(
            Fact_Compliance,
            Fact_Compliance[ControlsEffective]
        ),
        SUMX(
            Fact_Compliance,
            Fact_Compliance[NumberOfControls]
        ),
        0
    ) * 100

Format: 0.0"%"
Description: Weighted average of all controls operating effectively
Related Filters: Regulation, Date Range
```

#### Measure 2: Compliance Score by Regulation
```dax
Compliance Score by Regulation = 
    CALCULATE(
        [Overall Compliance Score],
        ALL(Dim_Regulation),
        VALUES(Dim_Regulation[RegulationName])
    )

Format: 0.0"%"
Description: Compliance score broken down by regulation type
Context: Use in matrix/table by regulation
```

#### Measure 3: Compliance vs Target
```dax
Compliance Achievement % = 
    DIVIDE(
        [Overall Compliance Score],
        90, -- Target is 90%
        0
    ) * 100

Format: 0.0"%"
Description: Current compliance as % of target (90% target)
Interpretation: >100% = exceeds target
```

#### Measure 4: Compliance Trend
```dax
Compliance Previous Month = 
    CALCULATE(
        [Overall Compliance Score],
        DATEADD(Dim_Date[Date], -1, MONTH)
    )

Format: 0.0"%"
Description: Previous month's compliance score for trend comparison
Use: Calculate month-over-month change
```

#### Measure 5: Compliance Change vs Previous Month
```dax
Compliance MoM Change = 
    [Overall Compliance Score] - [Compliance Previous Month]

Format: 0.0"%"
Description: Month-over-month change in compliance
Positive: Improvement, Negative: Decline
```

---

### ISSUE TRACKING MEASURES

#### Measure 6: Critical Issues Count
```dax
Critical Issues Count = 
    CALCULATE(
        COUNTROWS(Fact_Issues),
        Fact_Issues[Severity] = "Critical",
        Fact_Issues[Status] <> "Resolved"
    )

Format: #,##0
Description: Count of unresolved critical issues
Related Filters: Date (by CreatedDate)
```

#### Measure 7: Open Issues by Severity
```dax
Open Issues Count = 
    CALCULATE(
        COUNTROWS(Fact_Issues),
        Fact_Issues[Status] = "Open" OR Fact_Issues[Status] = "In Progress"
    )

Format: #,##0
Description: Total open and in-progress issues
Use: Drill-down by severity
```

#### Measure 8: Issue Resolution Rate
```dax
Issue Resolution Rate = 
    DIVIDE(
        CALCULATE(
            COUNTROWS(Fact_Issues),
            Fact_Issues[Status] = "Resolved"
        ),
        COUNTROWS(Fact_Issues),
        0
    ) * 100

Format: 0.0"%"
Description: % of issues resolved
Context: Month-to-date or rolling 30 days
```

#### Measure 9: Critical Issues Trend
```dax
Critical Issues Previous Period = 
    CALCULATE(
        [Critical Issues Count],
        DATEADD(Dim_Date[Date], -7, DAY)
    )

Format: #,##0
Description: Critical issues from 7 days ago for trend
Use: Show arrow indicator (up/down/stable)
```

---

### RISK ASSESSMENT MEASURES

#### Measure 10: Risk Count by Level
```dax
Risk Count = 
    COUNTROWS(Fact_RiskRegister)

Risk Count Critical = 
    CALCULATE(
        [Risk Count],
        Fact_RiskRegister[Likelihood] = 5,
        Fact_RiskRegister[Impact] = 5
    )

Risk Count Major = 
    CALCULATE(
        [Risk Count],
        OR(
            AND(Fact_RiskRegister[Likelihood] >= 4, Fact_RiskRegister[Impact] >= 4),
            AND(Fact_RiskRegister[Likelihood] = 5, Fact_RiskRegister[Impact] >= 3)
        )
    )

Format: #,##0
Description: Risk counts by severity classification
Use: Risk heat map segmentation
```

#### Measure 11: Average Risk Score
```dax
Average Risk Score = 
    AVERAGEX(
        Fact_RiskRegister,
        (Fact_RiskRegister[Likelihood] * Fact_RiskRegister[Impact]) / 25 * 100
    )

Format: 0.0
Description: Average risk score normalized to 0-100
Range: 0 (no risk) to 100 (maximum risk)
```

#### Measure 12: Mitigation Status
```dax
Mitigation Complete % = 
    DIVIDE(
        CALCULATE(
            COUNTROWS(Fact_RiskRegister),
            Fact_RiskRegister[MitigationStatus] = "Complete"
        ),
        COUNTROWS(Fact_RiskRegister),
        0
    ) * 100

Mitigation In Progress % = 
    DIVIDE(
        CALCULATE(
            COUNTROWS(Fact_RiskRegister),
            Fact_RiskRegister[MitigationStatus] = "In Progress"
        ),
        COUNTROWS(Fact_RiskRegister),
        0
    ) * 100

Format: 0.0"%"
Description: Distribution of mitigation progress
Use: Stacked bar chart
```

---

### COMPLIANCE CONTROL MEASURES

#### Measure 13: Control Effectiveness Score
```dax
Control Effectiveness Score = 
    AVERAGE(
        CALCULATETABLE(
            Fact_Compliance[ControlsEffective] / Fact_Compliance[NumberOfControls] * 100,
            ALL(Dim_Control),
            VALUES(Dim_Control)
        )
    )

Format: 0.0"%"
Description: Average control effectiveness across organization
Related: By control, by regulation, by department
```

#### Measure 14: Controls Tested
```dax
Controls Tested = 
    CALCULATE(
        COUNTROWS(Dim_Control),
        FILTER(
            Dim_Control,
            NOT(ISBLANK([Control Effectiveness Score]))
        )
    )

Format: #,##0
Description: Count of controls with recent assessment
```

#### Measure 15: Failed Controls
```dax
Controls Failed = 
    CALCULATE(
        COUNTROWS(Dim_Control),
        Dim_Control[ControlStatus] = "Failed"
    )

Format: #,##0
Description: Count of controls that failed assessment
Use: Alert indicator
```

---

### AUDIT MEASURES

#### Measure 16: Audit Schedule Status
```dax
Audits Scheduled = 
    CALCULATE(
        COUNTROWS(Fact_Audit),
        Fact_Audit[Status] = "Scheduled"
    )

Audits In Progress = 
    CALCULATE(
        COUNTROWS(Fact_Audit),
        Fact_Audit[Status] = "In Progress"
    )

Audits Completed = 
    CALCULATE(
        COUNTROWS(Fact_Audit),
        Fact_Audit[Status] = "Completed"
    )

Format: #,##0
Description: Audit counts by status
Use: Timeline and status tracking
```

#### Measure 17: Audit Findings Count
```dax
Audit Findings Count = 
    SUMX(
        Fact_Audit,
        Fact_Audit[Findings]
    )

Format: #,##0
Description: Total findings across all audits
Related: By audit, by finding severity, by regulation
```

#### Measure 18: Audit SLA Compliance
```dax
Audit On Time % = 
    DIVIDE(
        CALCULATE(
            COUNTROWS(Fact_Audit),
            Fact_Audit[ActualEnd] <= Fact_Audit[ScheduledEnd]
        ),
        COUNTROWS(Fact_Audit),
        0
    ) * 100

Format: 0.0"%"
Description: % of audits completed on schedule
```

---

### POLICY & APPROVAL MEASURES

#### Measure 19: Pending Approvals
```dax
Pending Approvals Count = 
    CALCULATE(
        COUNTROWS(Fact_Issues),
        Fact_Issues[IssueType] = "Policy",
        Fact_Issues[Status] = "Pending Approval"
    )

Format: #,##0
Description: Count of policy changes awaiting approval
```

#### Measure 20: Average Days Pending
```dax
Average Days Pending = 
    AVERAGEX(
        FILTER(
            Fact_Issues,
            Fact_Issues[Status] = "Pending Approval"
        ),
        INT(TODAY() - Fact_Issues[CreatedDate])
    )

Format: 0
Description: Average number of days pending approval
Related: Max days pending, median
```

---

### COMPLIANCE TRACKING MEASURES

#### Measure 21: Policy Violations
```dax
Policy Violations = 
    CALCULATE(
        COUNTROWS(Fact_Issues),
        Fact_Issues[IssueType] = "Policy",
        Fact_Issues[Status] <> "Resolved"
    )

Format: #,##0
Description: Count of active policy violations
```

#### Measure 22: Regulation Violations
```dax
Regulation Violations = 
    CALCULATE(
        COUNTROWS(Fact_Issues),
        Fact_Issues[IssueType] = "Compliance",
        Fact_Issues[Status] <> "Resolved"
    )

Format: #,##0
Description: Count of active regulatory violations
By Regulation: Use in drill-down
```

#### Measure 23: Certificate Expiration Alert
```dax
Certificates Expiring Soon = 
    CALCULATE(
        COUNTROWS(Dim_Regulation),
        Dim_Regulation[EffectiveDate] <= TODAY() + 90
    )

Format: #,##0
Description: Count of certifications/licenses expiring in 90 days
Alert: Red if > 0
```

---

### TRAINING & COMPLIANCE MEASURES

#### Measure 24: Training Completion Rate
```dax
Training Completion Rate = 
    DIVIDE(
        CALCULATE(
            SUMX(
                Fact_Issues,
                IF(Fact_Issues[IssueType] = "Training Completed", 1, 0)
            )
        ),
        SUMX(
            Fact_Issues,
            IF(Fact_Issues[IssueType] = "Training Required", 1, 0)
        ),
        0
    ) * 100

Format: 0.0"%"
Description: % of required training completed
Related: By department, by role, by employee
```

---

## HELPER MEASURES (for use in other calculations)

#### Current Period Range
```dax
[Date Range Start] = MIN(Dim_Date[Date])
[Date Range End] = MAX(Dim_Date[Date])
[Days in Period] = [Date Range End] - [Date Range Start]
```

#### Severity Classifications
```dax
[Risk Score] = (Fact_RiskRegister[Likelihood] * Fact_RiskRegister[Impact]) / 25
[Is Critical Risk] = [Risk Score] >= 0.8
[Is Major Risk] = AND([Risk Score] >= 0.5, [Risk Score] < 0.8)
```

---

## Dashboard-Specific Measure Collections

### For Compliance Score KPI Card
- Overall Compliance Score
- Compliance Achievement %
- Compliance MoM Change
- Compliance Previous Month

### For Critical Issues Card
- Critical Issues Count
- Critical Issues Previous Period
- Open Issues Count
- Issue Resolution Rate

### For Risk Assessment
- Risk Count Critical / Major / Medium / Low
- Average Risk Score
- Mitigation Complete %
- Mitigation In Progress %

### For Audit & Controls
- Control Effectiveness Score
- Controls Tested / Failed
- Audits Scheduled / In Progress / Completed
- Audit On Time %

### For Policy & Approvals
- Pending Approvals Count
- Average Days Pending
- Policy Violations
- Certificates Expiring Soon

---

## Performance Optimization Tips

1. **Measure Reuse**: Create base measures and build complex measures on top
2. **Use CALCULATE Sparingly**: Prefer context-aware calculations
3. **Filter Optimization**: Push filters to fact table row-level security (if applicable)
4. **Pre-aggregation**: For historical data, consider aggregate tables
5. **Materialization**: Pre-calculate compliance scores if refresh is slow

---

## Testing Checklist

- [ ] All measures return expected ranges (e.g., percentages 0-100%)
- [ ] Measures work with all slicer combinations
- [ ] Measures perform well (< 1 second calculation time)
- [ ] Formatting displays correctly (%, #, currency, etc.)
- [ ] Null/blank value handling is appropriate
- [ ] Measures calculate correctly for single row and aggregations
- [ ] YoY and MoM comparisons work correctly
- [ ] Drill-through data matches KPI summaries

