-- Project: Testing Turnaround Time & SLA Breach Analysis
-- Purpose: staging, cleaning, star schema, views, risk score and KPI queries (Q1 to Q8)
-- Run order: top to bottom

SELECT COUNT(*) AS Rawrows
FROM
	raw_sample;

--Unique count--
SELECT COUNT(DISTINCT SampleID) AS unique_rows
FROM
	raw_sample;

--02 Cleaned typed table--
USE LabTAT;
Go
IF OBJECT_ID('dbo.clean_samples') IS NOT NULL DROP TABLE dbo.clean_samples;
Go
WITH dedup AS(
	SELECT*,
		ROW_NUMBER() OVER(PARTITION BY SampleID ORDER BY SampleID) AS rn
		FROM raw_sample
)
SELECT
	LTRIM(RTRIM(SampleID))                                   AS SampleID,
	LTRIM(RTRIM(ClientName))                                 AS ClientName,
	LTRIM(RTRIM(Industry))                                   AS Industry,
	LTRIM(RTRIM(LabSection))                                 AS LabSection,
	LTRIM(RTRIM(TestName))                                   AS TestName,
	CASE WHEN LOWER(LTRIM(RTRIM(Priority))) = 'urgent'
		THEN 'urgent' ELSE 'Normal' END                      AS Priority,
	COALESCE(NULLIF(LTRIM(RTRIM(AnalystName)), ''), 'unknown')AS AnalystName,
	TRY_CAST(NULLIF(LTRIM(RTRIM(ReceivedDate)), '')     AS DATE) AS RecievedDate,
	TRY_CAST(NULLIF(LTRIM(RTRIM(AssignedDate)), '')     AS DATE) AS AssignedDate,
	TRY_CAST(NULLIF(LTRIM(RTRIM(AnalysisStartDate)), '') AS DATE) AS AnalysisStartDate,
	TRY_CAST(NULLIF(LTRIM(RTRIM(AnalysisEndDate)), '')  AS DATE) AS AnalysisEndDate,
	TRY_CAST(NULLIF(LTRIM(RTRIM(ReportIssuedDate)), '')  AS DATE) AS ReportIssuedDate,
	TRY_CAST(NULLIF(LTRIM(RTRIM(SLA_DAYS)), '')        AS INT) AS SLA_Days,
	LTRIM(RTRIM(Retest))                                AS Retest,
	NULLIF(LTRIM(RTRIM(DelayReason)), '')               AS DelayReason,
	LTRIM(RTRIM(Status))                                AS Status
INTO dbo.clean_samples
FROM dedup
WHERE rn=1;
GO

USE LabTAT;
GO
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'clean_samples'
ORDER BY ORDINAL_POSITION;

EXEC sp_rename 'dbo.clean_samples.RecievedDate', 'ReceivedDate', 'COLUMN';



--Step 3 Building Dimesion Table (Star Schema)--

SELECT ROW_NUMBER() OVER(ORDER BY TestName) AS TestKey, TestName, LabSection
INTO dbo.DimTest
FROM (SELECT DISTINCT TestName, LabSection FROM dbo.clean_samples) t;

SELECT ROW_NUMBER() OVER(ORDER BY ClientName) AS ClientKey, ClientName, Industry
INTO dbo.DimClient
FROM (SELECT DISTINCT ClientName, Industry FROM clean_samples) c;


SELECT ROW_NUMBER() OVER(ORDER BY AnalystName) AS AnalystKey, AnalystName
INTO dbo.DimAnalyst
FROM (SELECT DISTINCT AnalystName FROM clean_samples) a;
GO

SELECT (SELECT COUNT(*) FROM DimTest) AS Tests,
	   (SELECT COUNT(*) FROM DimClient) AS Clinets,
	   (SELECT COUNT(*) FROM DimAnalyst) AS Analysts;

--Step 4 Views_and_risk_score__
USE LabTAT;
GO
CREATE OR ALTER VIEW dbo.vw_SampleBase AS
WITH s AS (
SELECT *,
	CASE WHEN AssignedDate < ReceivedDate
	OR AnalysisStartDate < AssignedDate
	OR AnalysisEndDate < AnalysisStartDate
	OR ReportIssuedDate < AnalysisEndDate
	THEN 0 ELSE 1 END AS IsValidTimeline
	FROM dbo.clean_samples
)
SELECT
s.SampleID, t.TestKey, cl.ClientKey, a.AnalystKey,
s.Priority, s.ReTest, s.DelayReason, s.Status, s.IsValidTimeline,
s.ReceivedDate, s.AssignedDate, s.AnalysisStartDate, s.AnalysisEndDate, s.ReportIssuedDate,
s.SLA_Days,
DATEDIFF(DAY, s.ReceivedDate, s.AssignedDate) AS AssignDays,
DATEDIFF(DAY, s.AssignedDate, s.AnalysisStartDate) AS QueueDays,
DATEDIFF(DAY, s.AnalysisStartDate, s.AnalysisEndDate) AS AnalysisDays,
DATEDIFF(DAY, s.AnalysisEndDate, s.ReportIssuedDate) AS ReviewDays,
DATEDIFF(DAY, s.ReceivedDate, s.ReportIssuedDate) AS TAT_Days,
CASE WHEN s.ReportIssuedDate IS NULL THEN NULL
WHEN DATEDIFF(DAY, s.ReceivedDate, s.ReportIssuedDate) > s.SLA_Days THEN 1
ELSE 0 END AS SLA_Breached,
CASE WHEN DATEDIFF(DAY, s.ReceivedDate, s.ReportIssuedDate) > s.SLA_Days
THEN DATEDIFF(DAY, s.ReceivedDate, s.ReportIssuedDate) - s.SLA_Days
ELSE 0 END AS DaysOverSLA
FROM s
JOIN dbo.DimTest t ON t.TestName = s.TestName
JOIN dbo.DimClient cl ON cl.ClientName = s.ClientName
JOIN dbo.DimAnalyst a ON a.AnalystName = s.AnalystName;
GO

-- Completed, trustworthy samples only: this is the main fact table for Power BI
CREATE OR ALTER VIEW dbo.vw_FactCompleted AS
SELECT * FROM dbo.vw_SampleBase
WHERE Status = 'Reported' AND IsValidTimeline = 1;
GO

SELECT COUNT(*) FROM dbo.vw_FactCompleted; 

--Risk score view for open samples--

CREATE OR ALTER VIEW dbo.vw_OpenRisk AS
	WITH hist_tp AS (
	SELECT TestKey, Priority, AVG(1.0 * SLA_Breached) AS BreachRate_TestPriority
	FROM dbo.vw_FactCompleted GROUP BY TestKey, Priority
), hist_an AS (
	SELECT AnalystKey, AVG(1.0 * SLA_Breached) AS BreachRate_Analyst
	FROM dbo.vw_FactCompleted GROUP BY AnalystKey
), overall AS (
	SELECT AVG(1.0 * SLA_Breached) AS BreachRate_All FROM dbo.vw_FactCompleted
), o AS (
	SELECT b.*, DATEDIFF(DAY, b.ReceivedDate, CAST('2026-09-30' AS DATE)) AS DaysOpen
	FROM dbo.vw_SampleBase b
	WHERE b.Status = 'In Progress'
)
	SELECT
	o.SampleID, o.TestKey, o.ClientKey, o.AnalystKey, o.Priority, o.ReTest,
	o.ReceivedDate, o.SLA_Days, o.DaysOpen,
	o.SLA_Days - o.DaysOpen AS DaysToSLA,
	ROUND(rs.RiskScore, 3) AS RiskScore,
			CASE WHEN o.DaysOpen > o.SLA_Days THEN 'Already Breached'
			WHEN rs.RiskScore >= 0.40 THEN 'High Risk'
			WHEN rs.RiskScore >= 0.28 THEN 'Medium Risk'
			ELSE 'Low Risk' END AS RiskCategory
			FROM o
LEFT JOIN hist_tp h ON h.TestKey = o.TestKey AND h.Priority = o.Priority
LEFT JOIN hist_an a ON a.AnalystKey = o.AnalystKey
CROSS JOIN overall ov
CROSS APPLY (
			SELECT 0.40 * CASE WHEN 1.0 * o.DaysOpen / o.SLA_Days > 1 THEN 1
			ELSE 1.0 * o.DaysOpen / o.SLA_Days END
			+ 0.35 * COALESCE(h.BreachRate_TestPriority, ov.BreachRate_All)
			+ 0.25 * COALESCE(a.BreachRate_Analyst, ov.BreachRate_All) AS RiskScore
			) rs;
GO

--Step-06 KPI queries--
USE LabTAT;
GO
--Q1. Overall KPIs--
	SELECT COUNT(*) AS CompletedSamples,
	ROUND(AVG(1.0 * TAT_Days), 2) AS AvgTAT,
	SUM(SLA_Breached) AS BreachedSamples,
	ROUND(100.0 * SUM(SLA_Breached) / COUNT(*), 1) AS BreachPct -- expect 25.5
FROM dbo.vw_FactCompleted;

-- Q2. Breach by section and test (worst first)
SELECT t.LabSection, t.TestName, COUNT(*) AS Samples,
	ROUND(100.0 * AVG(1.0 * f.SLA_Breached), 1) AS BreachPct,
	ROUND(AVG(1.0 * f.TAT_Days), 2) AS AvgTAT
	FROM dbo.vw_FactCompleted f
	JOIN dbo.DimTest t ON t.TestKey = f.TestKey
GROUP BY t.LabSection, t.TestName
ORDER BY BreachPct DESC

-- Q3. Monthly trend with month-over-month change and rolling 3-month average
WITH m AS (
	SELECT DATEFROMPARTS(YEAR(ReceivedDate), MONTH(ReceivedDate), 1) AS MonthStart,
	COUNT(*) AS Samples,
	100.0 * AVG(1.0 * SLA_Breached) AS BreachPct
FROM dbo.vw_FactCompleted
GROUP BY DATEFROMPARTS(YEAR(ReceivedDate), MONTH(ReceivedDate), 1)
)
	SELECT MonthStart, Samples, ROUND(BreachPct, 1) AS BreachPct,
			ROUND(BreachPct - LAG(BreachPct) OVER (ORDER BY MonthStart), 1) AS MoM_Change_pts,
			ROUND(AVG(BreachPct) OVER (ORDER BY MonthStart
			ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 1) AS Rolling3M
FROM m
ORDER BY MonthStart;

-- Q4. Where is time lost? Average days per stage by section
SELECT t.LabSection,
	ROUND(AVG(1.0 * f.AssignDays), 2) AS AvgAssign,
	ROUND(AVG(1.0 * f.QueueDays), 2) AS AvgQueue,
	ROUND(AVG(1.0 * f.AnalysisDays), 2) AS AvgAnalysis,
	ROUND(AVG(1.0 * f.ReviewDays), 2) AS AvgReview
FROM dbo.vw_FactCompleted f
    JOIN dbo.DimTest t ON t.TestKey = f.TestKey
GROUP BY t.LabSection;

-- Q5. Analyst ranking
SELECT a.AnalystName, COUNT(*) AS Samples,
		ROUND(100.0 * AVG(1.0 * f.SLA_Breached), 1) AS BreachPct,
		RANK() OVER (ORDER BY AVG(1.0 * f.SLA_Breached) DESC) AS BreachRank
FROM dbo.vw_FactCompleted f
		JOIN dbo.DimAnalyst a ON a.AnalystKey = f.AnalystKey
GROUP BY a.AnalystName;

-- Q6. Delay reasons: Pareto with cumulative percentage
WITH r AS (
	SELECT COALESCE(DelayReason, 'Not recorded') AS DelayReason, COUNT(*) AS Cnt
	FROM dbo.vw_FactCompleted
	WHERE SLA_Breached = 1
   GROUP BY COALESCE(DelayReason, 'Not recorded')
)
	SELECT DelayReason, Cnt,
	ROUND(100.0 * SUM(Cnt) OVER (ORDER BY Cnt DESC ROWS UNBOUNDED PRECEDING)
	/ SUM(Cnt) OVER (), 1) AS CumulativePct
	FROM r
ORDER BY Cnt DESC;

-- Q7. Retest and priority effect
SELECT ReTest, Priority, COUNT(*) AS Samples,
	ROUND(100.0 * AVG(1.0 * SLA_Breached), 1) AS BreachPct
FROM dbo.vw_FactCompleted
GROUP BY ReTest, Priority
ORDER BY ReTest, Priority;

-- Q8. Open-sample watchlist (act today)
SELECT TOP 15 r.SampleID, t.TestName, r.Priority, r.DaysOpen, r.SLA_Days,
			r.DaysToSLA, r.RiskScore, r.RiskCategory
FROM dbo.vw_OpenRisk r
JOIN dbo.DimTest t ON t.TestKey = r.TestKey
ORDER BY r.RiskScore DESC;