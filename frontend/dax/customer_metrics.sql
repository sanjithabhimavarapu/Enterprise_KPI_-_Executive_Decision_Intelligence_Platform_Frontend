-- ============================================================
-- CUSTOMER METRICS - Enterprise KPI Platform
-- Customer Dashboard: Segmentation, Retention & Behavior
-- ============================================================
-- Source Tables:
--   Dim_Customer              : Customer master dimension
--   Fact_Customer_Metrics     : Per-customer period KPIs
--   Fact_Customer_Behavior    : Event-level behavioral data
--   Fact_Sales                : Transaction history (RFM source)
--   Dim_Date                  : Date dimension
--   Dim_Product               : Product catalog
--   Dim_Channel               : Interaction channel
-- ============================================================


-- ============================================================
-- SECTION 1: CUSTOMER BASE SUMMARY
-- ============================================================

-- 1.1 Active Customer Count by Segment and Type
SELECT
    c.Segment,
    c.CustomerType,
    c.RegionName,
    COUNT(DISTINCT c.CustomerKey)                                    AS Total_Customers,
    SUM(CASE WHEN c.IsActive = 1 THEN 1 ELSE 0 END)                 AS Active_Customers,
    SUM(CASE WHEN cm.IsNewCustomer = 1 THEN 1 ELSE 0 END)           AS New_This_Period,
    SUM(CASE WHEN cm.IsChurned = 1 THEN 1 ELSE 0 END)               AS Churned_This_Period,
    SUM(CASE WHEN cm.IsNewCustomer = 1 THEN 1 ELSE 0 END)
        - SUM(CASE WHEN cm.IsChurned = 1 THEN 1 ELSE 0 END)         AS Net_Customer_Change,
    CAST(
        AVG(cm.HealthScore)
    AS DECIMAL(5,2))                                                 AS Avg_Health_Score,
    CAST(
        AVG(cm.ChurnRiskScore)
    AS DECIMAL(5,2))                                                 AS Avg_Churn_Risk_Score,
    CAST(
        AVG(cm.EngagementScore)
    AS DECIMAL(5,2))                                                 AS Avg_Engagement_Score
FROM  Dim_Customer          c
LEFT JOIN Fact_Customer_Metrics cm ON c.CustomerKey = cm.CustomerKey
GROUP BY
    c.Segment,
    c.CustomerType,
    c.RegionName
ORDER BY
    c.Segment,
    c.CustomerType;


-- 1.2 Net Promoter Score (NPS) by Segment
SELECT
    c.Segment,
    COUNT(CASE WHEN cm.NPS_Score >= 9 THEN 1 END)   AS Promoters,
    COUNT(CASE WHEN cm.NPS_Score BETWEEN 7 AND 8 THEN 1 END) AS Passives,
    COUNT(CASE WHEN cm.NPS_Score <= 6 THEN 1 END)   AS Detractors,
    COUNT(cm.NPS_Score)                              AS Total_Respondents,
    CAST(
        (COUNT(CASE WHEN cm.NPS_Score >= 9 THEN 1 END)
         - COUNT(CASE WHEN cm.NPS_Score <= 6 THEN 1 END)) * 100.0
        / NULLIF(COUNT(cm.NPS_Score), 0)
    AS DECIMAL(5,1))                                 AS NPS_Score,
    CAST(COUNT(CASE WHEN cm.NPS_Score >= 9 THEN 1 END) * 100.0
        / NULLIF(COUNT(cm.NPS_Score), 0) AS DECIMAL(5,1)) AS Promoter_Pct,
    CAST(COUNT(CASE WHEN cm.NPS_Score <= 6 THEN 1 END) * 100.0
        / NULLIF(COUNT(cm.NPS_Score), 0) AS DECIMAL(5,1)) AS Detractor_Pct
FROM  Dim_Customer          c
JOIN  Fact_Customer_Metrics cm ON c.CustomerKey = cm.CustomerKey
WHERE cm.NPS_Score IS NOT NULL
GROUP BY
    c.Segment
ORDER BY
    NPS_Score DESC;


-- ============================================================
-- SECTION 2: CUSTOMER SEGMENTATION — RFM ANALYSIS
-- ============================================================

-- 2.1 RFM Scores per Customer (raw)
WITH CustomerRFM AS (
    SELECT
        c.CustomerKey,
        c.CustomerName,
        c.Segment,
        c.CustomerType,
        c.RegionName,

        -- Recency: days since last purchase
        DATEDIFF(DAY, MAX(s.OrderDate), CAST(GETDATE() AS DATE))   AS Recency_Days,

        -- Frequency: distinct orders in last 12 months
        COUNT(DISTINCT s.SalesOrderNumber)                          AS Frequency,

        -- Monetary: total spend in last 12 months
        CAST(SUM(s.ExtendedAmount) AS DECIMAL(18,2))               AS Monetary_Value,

        -- Annual contract value
        c.AnnualContractValue

    FROM  Dim_Customer  c
    JOIN  Fact_Sales    s ON c.CustomerKey = s.CustomerKey
    WHERE s.OrderDate >= DATEADD(YEAR, -1, CAST(GETDATE() AS DATE))
    GROUP BY
        c.CustomerKey,
        c.CustomerName,
        c.Segment,
        c.CustomerType,
        c.RegionName,
        c.AnnualContractValue
),
RFM_Scored AS (
    SELECT
        *,
        -- Recency Score (1-5, higher = more recent)
        NTILE(5) OVER (ORDER BY Recency_Days ASC)    AS Recency_Score,
        -- Frequency Score (1-5, higher = more frequent)
        NTILE(5) OVER (ORDER BY Frequency DESC)      AS Frequency_Score,
        -- Monetary Score (1-5, higher = more spend)
        NTILE(5) OVER (ORDER BY Monetary_Value DESC) AS Monetary_Score
    FROM CustomerRFM
)
SELECT
    CustomerKey,
    CustomerName,
    Segment,
    CustomerType,
    RegionName,
    Recency_Days,
    Frequency,
    Monetary_Value,
    AnnualContractValue,
    Recency_Score,
    Frequency_Score,
    Monetary_Score,
    (Recency_Score + Frequency_Score + Monetary_Score)       AS RFM_Total_Score,

    -- RFM Segment assignment
    CASE
        WHEN Recency_Score >= 4 AND Frequency_Score >= 4 THEN 'Champions'
        WHEN Recency_Score >= 3 AND Frequency_Score >= 3 THEN 'Loyal'
        WHEN Recency_Score >= 4 AND Frequency_Score <= 2 THEN 'Promising'
        WHEN Recency_Score >= 3 AND Frequency_Score <= 2 THEN 'New Customer'
        WHEN Recency_Score <= 2 AND Frequency_Score >= 4 THEN 'Cant Lose Them'
        WHEN Recency_Score <= 2 AND Frequency_Score >= 3 THEN 'At Risk'
        WHEN Recency_Score <= 2 AND Frequency_Score <= 2 THEN 'Lost'
        ELSE 'Need Attention'
    END                                                       AS RFM_Segment
FROM RFM_Scored
ORDER BY
    RFM_Total_Score DESC;


-- 2.2 RFM Segment Summary (for scatter plot / matrix)
WITH CustomerRFM AS (
    SELECT
        c.CustomerKey,
        c.Segment                                                       AS Customer_Segment,
        DATEDIFF(DAY, MAX(s.OrderDate), CAST(GETDATE() AS DATE))       AS Recency_Days,
        COUNT(DISTINCT s.SalesOrderNumber)                              AS Frequency,
        SUM(s.ExtendedAmount)                                           AS Monetary_Value
    FROM  Dim_Customer  c
    JOIN  Fact_Sales    s ON c.CustomerKey = s.CustomerKey
    WHERE s.OrderDate >= DATEADD(YEAR, -1, CAST(GETDATE() AS DATE))
    GROUP BY c.CustomerKey, c.Segment
),
RFM_Scored AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency_Days ASC)    AS Recency_Score,
        NTILE(5) OVER (ORDER BY Frequency DESC)      AS Frequency_Score,
        NTILE(5) OVER (ORDER BY Monetary_Value DESC) AS Monetary_Score
    FROM CustomerRFM
),
Segmented AS (
    SELECT *,
        CASE
            WHEN Recency_Score >= 4 AND Frequency_Score >= 4 THEN 'Champions'
            WHEN Recency_Score >= 3 AND Frequency_Score >= 3 THEN 'Loyal'
            WHEN Recency_Score >= 4 AND Frequency_Score <= 2 THEN 'Promising'
            WHEN Recency_Score >= 3 AND Frequency_Score <= 2 THEN 'New Customer'
            WHEN Recency_Score <= 2 AND Frequency_Score >= 4 THEN 'Cant Lose Them'
            WHEN Recency_Score <= 2 AND Frequency_Score >= 3 THEN 'At Risk'
            WHEN Recency_Score <= 2 AND Frequency_Score <= 2 THEN 'Lost'
            ELSE 'Need Attention'
        END AS RFM_Segment
    FROM RFM_Scored
)
SELECT
    RFM_Segment,
    Customer_Segment,
    COUNT(*)                                                          AS Customer_Count,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()  AS DECIMAL(5,2)) AS Pct_of_Base,
    CAST(AVG(Recency_Days)     AS DECIMAL(10,1))                     AS Avg_Recency_Days,
    CAST(AVG(Frequency)        AS DECIMAL(10,1))                     AS Avg_Frequency,
    CAST(AVG(Monetary_Value)   AS DECIMAL(18,2))                     AS Avg_Monetary_Value,
    CAST(SUM(Monetary_Value)   AS DECIMAL(18,2))                     AS Total_Revenue
FROM Segmented
GROUP BY
    RFM_Segment,
    Customer_Segment
ORDER BY
    Total_Revenue DESC;


-- ============================================================
-- SECTION 3: RETENTION ANALYSIS
-- ============================================================

-- 3.1 Monthly Retention Rate by Segment
SELECT
    dt.Year,
    dt.Month,
    dt.MonthName,
    c.Segment,
    COUNT(DISTINCT cm.CustomerKey)                                    AS Base_Customers,
    SUM(CASE WHEN cm.RetentionFlag = 1 THEN 1 ELSE 0 END)            AS Retained,
    SUM(CASE WHEN cm.IsChurned     = 1 THEN 1 ELSE 0 END)            AS Churned,
    SUM(CASE WHEN cm.IsNewCustomer = 1 THEN 1 ELSE 0 END)            AS New_Acquired,
    CAST(
        SUM(CASE WHEN cm.RetentionFlag = 1 THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(DISTINCT cm.CustomerKey), 0)
    AS DECIMAL(5,2))                                                  AS Retention_Rate_Pct,
    CAST(
        SUM(CASE WHEN cm.IsChurned = 1 THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(DISTINCT cm.CustomerKey), 0)
    AS DECIMAL(5,2))                                                  AS Churn_Rate_Pct
FROM  Fact_Customer_Metrics  cm
JOIN  Dim_Date               dt ON cm.DateKey     = dt.DateKey
JOIN  Dim_Customer           c  ON cm.CustomerKey = c.CustomerKey
GROUP BY
    dt.Year,
    dt.Month,
    dt.MonthName,
    c.Segment
ORDER BY
    dt.Year DESC,
    dt.Month DESC,
    c.Segment;


-- 3.2 Cohort Retention Table
-- Rows = Acquisition Cohort (month), Columns = months since acquisition (M+0 to M+23)
WITH CohortBase AS (
    SELECT
        c.CustomerKey,
        DATEFROMPARTS(YEAR(c.CustomerAcquisitionDate), MONTH(c.CustomerAcquisitionDate), 1) AS CohortMonth,
        DATEFROMPARTS(dt.Year, dt.Month, 1)                                                  AS ActivityMonth,
        DATEDIFF(
            MONTH,
            DATEFROMPARTS(YEAR(c.CustomerAcquisitionDate), MONTH(c.CustomerAcquisitionDate), 1),
            DATEFROMPARTS(dt.Year, dt.Month, 1)
        )                                                                                    AS MonthOffset
    FROM  Fact_Customer_Metrics  cm
    JOIN  Dim_Customer           c  ON cm.CustomerKey = c.CustomerKey
    JOIN  Dim_Date               dt ON cm.DateKey     = dt.DateKey
    WHERE cm.RetentionFlag = 1
      AND c.CustomerAcquisitionDate IS NOT NULL
),
CohortSize AS (
    SELECT
        DATEFROMPARTS(YEAR(CustomerAcquisitionDate), MONTH(CustomerAcquisitionDate), 1) AS CohortMonth,
        COUNT(DISTINCT CustomerKey) AS InitialSize
    FROM Dim_Customer
    WHERE CustomerAcquisitionDate IS NOT NULL
    GROUP BY DATEFROMPARTS(YEAR(CustomerAcquisitionDate), MONTH(CustomerAcquisitionDate), 1)
)
SELECT
    cb.CohortMonth,
    cs.InitialSize,
    cb.MonthOffset,
    COUNT(DISTINCT cb.CustomerKey)                                   AS Retained_Count,
    CAST(
        COUNT(DISTINCT cb.CustomerKey) * 100.0
        / NULLIF(cs.InitialSize, 0)
    AS DECIMAL(5,2))                                                 AS Retention_Pct
FROM  CohortBase  cb
JOIN  CohortSize  cs ON cb.CohortMonth = cs.CohortMonth
WHERE cb.MonthOffset BETWEEN 0 AND 23
GROUP BY
    cb.CohortMonth,
    cs.InitialSize,
    cb.MonthOffset
ORDER BY
    cb.CohortMonth,
    cb.MonthOffset;


-- 3.3 Voluntary vs Involuntary Churn Breakdown
SELECT
    dt.Year,
    dt.MonthName,
    c.Segment,
    cm.ChurnType,
    COUNT(DISTINCT cm.CustomerKey)                                    AS Churned_Count,
    CAST(
        COUNT(DISTINCT cm.CustomerKey) * 100.0
        / NULLIF(SUM(COUNT(DISTINCT cm.CustomerKey)) OVER (PARTITION BY dt.Year, dt.Month), 0)
    AS DECIMAL(5,2))                                                  AS Churn_Type_Pct
FROM  Fact_Customer_Metrics  cm
JOIN  Dim_Date               dt ON cm.DateKey     = dt.DateKey
JOIN  Dim_Customer           c  ON cm.CustomerKey = c.CustomerKey
WHERE cm.IsChurned = 1
GROUP BY
    dt.Year,
    dt.Month,
    dt.MonthName,
    c.Segment,
    cm.ChurnType
ORDER BY
    dt.Year DESC,
    dt.Month DESC;


-- ============================================================
-- SECTION 4: CHURN RISK ANALYSIS
-- ============================================================

-- 4.1 Churn Risk Distribution by Segment
SELECT
    c.Segment,
    c.CustomerType,
    COUNT(CASE WHEN cm.ChurnRiskScore BETWEEN  0 AND 25 THEN 1 END)  AS Low_Risk,
    COUNT(CASE WHEN cm.ChurnRiskScore BETWEEN 26 AND 50 THEN 1 END)  AS Medium_Risk,
    COUNT(CASE WHEN cm.ChurnRiskScore BETWEEN 51 AND 75 THEN 1 END)  AS High_Risk,
    COUNT(CASE WHEN cm.ChurnRiskScore BETWEEN 76 AND 100 THEN 1 END) AS Critical_Risk,
    COUNT(*)                                                           AS Total,
    CAST(AVG(cm.ChurnRiskScore) AS DECIMAL(5,2))                     AS Avg_Risk_Score,
    CAST(
        SUM(CASE WHEN cm.ChurnRiskScore > 50 THEN s.ExtendedAmount ELSE 0 END)
    AS DECIMAL(18,2))                                                  AS Revenue_at_Risk
FROM  Fact_Customer_Metrics  cm
JOIN  Dim_Customer           c  ON cm.CustomerKey = c.CustomerKey
LEFT JOIN Fact_Sales         s  ON cm.CustomerKey = s.CustomerKey
GROUP BY
    c.Segment,
    c.CustomerType
ORDER BY
    Avg_Risk_Score DESC;


-- 4.2 High-Risk Customer Actionable List (Top 100)
SELECT TOP 100
    c.CustomerKey,
    c.CustomerName,
    c.Segment,
    c.CustomerType,
    c.RegionName,
    cm.ChurnRiskScore,
    cm.HealthScore,
    cm.EngagementScore,
    cm.DaysSinceLastPurchase,
    cm.SupportTickets,
    c.AnnualContractValue,
    c.LastTransactionDate,
    CAST(DATEDIFF(MONTH, c.CustomerAcquisitionDate, GETDATE()) AS INT) AS Tenure_Months
FROM  Fact_Customer_Metrics  cm
JOIN  Dim_Customer           c  ON cm.CustomerKey = c.CustomerKey
WHERE cm.ChurnRiskScore >= 51
ORDER BY
    c.AnnualContractValue DESC,
    cm.ChurnRiskScore DESC;


-- ============================================================
-- SECTION 5: BEHAVIORAL ANALYTICS
-- ============================================================

-- 5.1 Customer Journey Funnel (Event-based Conversion)
SELECT
    cb.EventType,
    c.Segment,
    COUNT(DISTINCT cb.CustomerKey)                                    AS Unique_Customers,
    SUM(cb.EventCount)                                                AS Total_Events,
    CAST(
        COUNT(DISTINCT cb.CustomerKey) * 100.0
        / NULLIF(
            LEAD(COUNT(DISTINCT cb.CustomerKey)) OVER (
                PARTITION BY c.Segment
                ORDER BY
                    CASE cb.EventType
                        WHEN 'ProductView'    THEN 1
                        WHEN 'CartAdd'        THEN 2
                        WHEN 'CheckoutStart'  THEN 3
                        WHEN 'Purchase'       THEN 4
                        WHEN 'RepeatPurchase' THEN 5
                        ELSE 99
                    END
            ),
            0
        )
    AS DECIMAL(5,2))                                                  AS Conversion_to_Next_Pct
FROM  Fact_Customer_Behavior  cb
JOIN  Dim_Customer            c ON cb.CustomerKey = c.CustomerKey
WHERE cb.EventType IN ('ProductView','CartAdd','CheckoutStart','Purchase','RepeatPurchase')
GROUP BY
    cb.EventType,
    c.Segment
ORDER BY
    c.Segment,
    CASE cb.EventType
        WHEN 'ProductView'    THEN 1
        WHEN 'CartAdd'        THEN 2
        WHEN 'CheckoutStart'  THEN 3
        WHEN 'Purchase'       THEN 4
        WHEN 'RepeatPurchase' THEN 5
        ELSE 99
    END;


-- 5.2 Product Category Affinity by Segment (Heatmap Source)
SELECT
    c.Segment,
    pc.CategoryName,
    COUNT(DISTINCT cb.CustomerKey)                                    AS Customers_Who_Purchased,
    CAST(
        COUNT(DISTINCT cb.CustomerKey) * 100.0
        / NULLIF(
            COUNT(DISTINCT c.CustomerKey),
            0
        )
    AS DECIMAL(5,2))                                                  AS Category_Penetration_Pct,
    CAST(AVG(s.ExtendedAmount)        AS DECIMAL(18,2))               AS Avg_Order_Value,
    CAST(SUM(s.ExtendedAmount)        AS DECIMAL(18,2))               AS Total_Revenue
FROM  Dim_Customer            c
JOIN  Fact_Customer_Behavior  cb ON c.CustomerKey         = cb.CustomerKey
                                 AND cb.EventType         = 'Purchase'
JOIN  Dim_Product_Category    pc ON cb.ProductCategoryKey = pc.CategoryKey
LEFT JOIN Fact_Sales          s  ON c.CustomerKey         = s.CustomerKey
GROUP BY
    c.Segment,
    pc.CategoryName
ORDER BY
    c.Segment,
    Category_Penetration_Pct DESC;


-- 5.3 Engagement Activity Timeline (Daily — last 90 days)
SELECT
    dt.Date,
    cb.EventType,
    c.Segment,
    cb.DeviceType,
    COUNT(DISTINCT cb.CustomerKey)  AS Unique_Customers,
    SUM(cb.EventCount)              AS Total_Events,
    CAST(AVG(cb.SessionDuration / 60.0) AS DECIMAL(10,2)) AS Avg_Session_Min,
    CAST(AVG(cb.PagesViewed)            AS DECIMAL(10,1)) AS Avg_Pages_Per_Session
FROM  Fact_Customer_Behavior  cb
JOIN  Dim_Date                dt ON cb.DateKey     = dt.DateKey
JOIN  Dim_Customer            c  ON cb.CustomerKey = c.CustomerKey
WHERE dt.Date >= DATEADD(DAY, -90, CAST(GETDATE() AS DATE))
GROUP BY
    dt.Date,
    cb.EventType,
    c.Segment,
    cb.DeviceType
ORDER BY
    dt.Date DESC,
    cb.EventType;


-- 5.4 Channel Engagement Share
SELECT
    ch.ChannelName,
    ch.ChannelType,
    ch.IsDigital,
    c.Segment,
    COUNT(DISTINCT cb.CustomerKey)                                    AS Unique_Customers,
    SUM(cb.EventCount)                                                AS Total_Events,
    CAST(
        SUM(cb.EventCount) * 100.0
        / NULLIF(SUM(SUM(cb.EventCount)) OVER (PARTITION BY c.Segment), 0)
    AS DECIMAL(5,2))                                                  AS Channel_Share_Pct
FROM  Fact_Customer_Behavior  cb
JOIN  Dim_Channel             ch ON cb.ChannelKey  = ch.ChannelKey
JOIN  Dim_Customer            c  ON cb.CustomerKey = c.CustomerKey
GROUP BY
    ch.ChannelName,
    ch.ChannelType,
    ch.IsDigital,
    c.Segment
ORDER BY
    c.Segment,
    Channel_Share_Pct DESC;


-- 5.5 Cart Abandonment Rate by Segment & Category
SELECT
    c.Segment,
    pc.CategoryName,
    COUNT(DISTINCT CASE WHEN cb.EventType = 'CartAdd'  THEN cb.CustomerKey END) AS Cart_Adds,
    COUNT(DISTINCT CASE WHEN cb.EventType = 'Purchase' THEN cb.CustomerKey END) AS Purchases,
    CAST(
        (COUNT(DISTINCT CASE WHEN cb.EventType = 'CartAdd'  THEN cb.CustomerKey END)
         - COUNT(DISTINCT CASE WHEN cb.EventType = 'Purchase' THEN cb.CustomerKey END)) * 100.0
        / NULLIF(COUNT(DISTINCT CASE WHEN cb.EventType = 'CartAdd' THEN cb.CustomerKey END), 0)
    AS DECIMAL(5,2))                                                  AS Abandonment_Rate_Pct
FROM  Fact_Customer_Behavior  cb
JOIN  Dim_Customer            c  ON cb.CustomerKey         = c.CustomerKey
JOIN  Dim_Product_Category    pc ON cb.ProductCategoryKey  = pc.CategoryKey
GROUP BY
    c.Segment,
    pc.CategoryName
ORDER BY
    Abandonment_Rate_Pct DESC;


-- ============================================================
-- SECTION 6: CUSTOMER LIFETIME VALUE
-- ============================================================

-- 6.1 CLV by Segment (Historical)
SELECT
    c.Segment,
    c.CustomerType,
    COUNT(DISTINCT c.CustomerKey)                                     AS Customer_Count,
    CAST(AVG(c.AnnualContractValue)       AS DECIMAL(18,2))           AS Avg_Annual_Contract,
    CAST(AVG(
        DATEDIFF(MONTH, c.CustomerAcquisitionDate, ISNULL(c.LastTransactionDate, GETDATE())) / 12.0
    )                                      AS DECIMAL(10,2))           AS Avg_Tenure_Years,
    CAST(
        AVG(
            DATEDIFF(MONTH, c.CustomerAcquisitionDate, ISNULL(c.LastTransactionDate, GETDATE())) / 12.0
        )
        * AVG(c.AnnualContractValue)
    AS DECIMAL(18,2))                                                  AS Historical_CLV,
    CAST(SUM(s.ExtendedAmount)            AS DECIMAL(18,2))            AS Total_Revenue_Generated,
    CAST(
        SUM(s.ExtendedAmount) / NULLIF(COUNT(DISTINCT c.CustomerKey), 0)
    AS DECIMAL(18,2))                                                  AS Actual_Avg_Revenue_Per_Customer
FROM  Dim_Customer  c
LEFT JOIN Fact_Sales s ON c.CustomerKey = s.CustomerKey
GROUP BY
    c.Segment,
    c.CustomerType
ORDER BY
    Historical_CLV DESC;


-- 6.2 CLV Decile Distribution (10 tiers)
WITH CustomerCLV AS (
    SELECT
        c.CustomerKey,
        c.CustomerName,
        c.Segment,
        c.CustomerType,
        SUM(s.ExtendedAmount)                                          AS Total_Revenue
    FROM  Dim_Customer  c
    JOIN  Fact_Sales    s ON c.CustomerKey = s.CustomerKey
    GROUP BY
        c.CustomerKey, c.CustomerName, c.Segment, c.CustomerType
)
SELECT
    Decile,
    COUNT(*)                                                           AS Customer_Count,
    CAST(MIN(Total_Revenue) AS DECIMAL(18,2))                         AS Min_Revenue,
    CAST(MAX(Total_Revenue) AS DECIMAL(18,2))                         AS Max_Revenue,
    CAST(AVG(Total_Revenue) AS DECIMAL(18,2))                         AS Avg_Revenue,
    CAST(SUM(Total_Revenue) AS DECIMAL(18,2))                         AS Total_Revenue,
    CAST(
        SUM(Total_Revenue) * 100.0
        / NULLIF(SUM(SUM(Total_Revenue)) OVER (), 0)
    AS DECIMAL(5,2))                                                   AS Revenue_Share_Pct
FROM (
    SELECT
        *,
        NTILE(10) OVER (ORDER BY Total_Revenue DESC) AS Decile
    FROM CustomerCLV
) DecileTable
GROUP BY Decile
ORDER BY Decile;


-- ============================================================
-- SECTION 7: REPEAT PURCHASE & CROSS-SELL METRICS
-- ============================================================

-- 7.1 Repeat Purchase Rate by Segment
SELECT
    c.Segment,
    c.CustomerType,
    COUNT(DISTINCT c.CustomerKey)                                     AS Total_Customers,
    COUNT(DISTINCT CASE WHEN OrderFreq.Orders >= 2 THEN c.CustomerKey END) AS Repeat_Purchasers,
    CAST(
        COUNT(DISTINCT CASE WHEN OrderFreq.Orders >= 2 THEN c.CustomerKey END) * 100.0
        / NULLIF(COUNT(DISTINCT c.CustomerKey), 0)
    AS DECIMAL(5,2))                                                  AS Repeat_Purchase_Rate_Pct,
    CAST(AVG(OrderFreq.Orders) AS DECIMAL(10,2))                      AS Avg_Order_Frequency
FROM  Dim_Customer  c
LEFT JOIN (
    SELECT CustomerKey, COUNT(DISTINCT SalesOrderNumber) AS Orders
    FROM   Fact_Sales
    GROUP BY CustomerKey
) OrderFreq ON c.CustomerKey = OrderFreq.CustomerKey
GROUP BY
    c.Segment,
    c.CustomerType
ORDER BY
    Repeat_Purchase_Rate_Pct DESC;


-- 7.2 Cross-Sell Index: Multi-Category Purchasers
SELECT
    c.Segment,
    COUNT(DISTINCT c.CustomerKey)                                     AS Total_Buyers,
    COUNT(DISTINCT CASE WHEN CatCount.Categories >= 2 THEN c.CustomerKey END) AS Multi_Cat_Buyers,
    CAST(
        COUNT(DISTINCT CASE WHEN CatCount.Categories >= 2 THEN c.CustomerKey END) * 100.0
        / NULLIF(COUNT(DISTINCT c.CustomerKey), 0)
    AS DECIMAL(5,2))                                                  AS Cross_Sell_Index_Pct,
    CAST(AVG(CatCount.Categories) AS DECIMAL(10,2))                   AS Avg_Categories_Per_Customer
FROM  Dim_Customer  c
LEFT JOIN (
    SELECT s.CustomerKey, COUNT(DISTINCT p.ProductCategory) AS Categories
    FROM   Fact_Sales s
    JOIN   Dim_Product p ON s.ProductKey = p.ProductKey
    GROUP BY s.CustomerKey
) CatCount ON c.CustomerKey = CatCount.CustomerKey
GROUP BY
    c.Segment
ORDER BY
    Cross_Sell_Index_Pct DESC;


-- ============================================================
-- SECTION 8: CUSTOMER HEALTH SCORE DISTRIBUTION
-- ============================================================

-- 8.1 Health Score Bands by Segment
SELECT
    c.Segment,
    SUM(CASE WHEN cm.HealthScore >= 75 THEN 1 ELSE 0 END)  AS Healthy,
    SUM(CASE WHEN cm.HealthScore BETWEEN 50 AND 74 THEN 1 ELSE 0 END) AS Stable,
    SUM(CASE WHEN cm.HealthScore BETWEEN 25 AND 49 THEN 1 ELSE 0 END) AS At_Risk,
    SUM(CASE WHEN cm.HealthScore < 25 THEN 1 ELSE 0 END)   AS Critical,
    COUNT(*)                                                AS Total,
    CAST(AVG(cm.HealthScore) AS DECIMAL(5,2))              AS Avg_Health_Score,
    -- Month-over-month change (self-join on prior month)
    CAST(AVG(cm.HealthScore) - AVG(prev.HealthScore) AS DECIMAL(5,2)) AS MoM_Health_Change
FROM  Fact_Customer_Metrics  cm
JOIN  Dim_Customer           c    ON cm.CustomerKey = c.CustomerKey
JOIN  Dim_Date               dt   ON cm.DateKey     = dt.DateKey
LEFT JOIN Fact_Customer_Metrics prev
       ON cm.CustomerKey = prev.CustomerKey
       AND prev.DateKey  = (
           SELECT TOP 1 DateKey
           FROM Dim_Date
           WHERE Date = DATEADD(MONTH, -1, dt.Date)
       )
WHERE dt.Date = CAST(EOMONTH(DATEADD(MONTH, -1, GETDATE())) AS DATE)
GROUP BY
    c.Segment
ORDER BY
    Avg_Health_Score DESC;
