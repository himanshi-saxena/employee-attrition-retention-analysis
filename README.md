# Testing Turnaround Time (TAT) & SLA Breach Analysis

An Excel dashboard and SQL Server analysis of turnaround time and SLA breaches
across three laboratory sections, to find where delays occur and what can be
done about them.

![Dashboard](screenshots/dashboard.png)

## 📌 Project Overview
In a testing laboratory, clients are promised results within an agreed time
called the Service Level Agreement (SLA). When a sample takes longer than the
SLA, it is an SLA breach. Breaches affect client trust, repeat business and
compliance records.

This project analyses **5,916 completed samples** (plus 62 still open) to
measure performance, locate bottlenecks and recommend improvements. The Excel
dashboard shows the results, and the SQL phase rebuilds the same numbers so
every figure is traceable to a query.

## 🎯 Business Questions
1. What is the overall turnaround time and SLA breach rate?
2. Which lab section performs worst?
3. At which process stage is time being lost?
4. What are the main reasons for delay?
5. Do breaches follow a monthly pattern?
6. Which open samples are most likely to breach next?

## 📂 Dataset
- **Data type:** Simulated laboratory data generated using Claude AI. No company
  or client data is used.
- **Records:** 5,916 completed samples, 62 open samples
- **Period:** [write the exact period, for example Jan 2025 to Sep 2026]

| Column | Description |
|---|---|
| Sample_ID | Anonymised unique sample code |
| LabSection | Chemical, Instrumental or Microbiology |
| Priority Class | Normal or Urgent |
| Month | Month of sample receipt |
| Assigned_Days | Days from receipt to assignment |
| Queue_Days | Days waiting in queue |
| Analysis_Days | Days taken for testing |
| Review_Days | Days taken for review and approval |
| TAT_Days | Total turnaround time (calculated) |
| SLA_Breached | 1 if TAT exceeded SLA, else 0 (calculated) |
| Delay_Reason | Main cause of delay for breached samples |

## 🛠 Tools & Skills
- **Excel:** pivot tables, slicers, charts, conditional formatting, dashboard design
- **Formulas:** `IF`, `COUNTIFS`, `AVERAGEIFS`, `NETWORKDAYS`
- **Data cleaning:** duplicates, blanks, date formats, header corrections
- **SQL Server:** staging tables, CTEs, window functions (`ROW_NUMBER`, `LAG`,
  `RANK`, running totals), views, star schema, `JOIN`, `CROSS APPLY`

## ⚙️ Method
**Phase 1: Excel**
1. Cleaned the raw data and corrected column headers
2. Calculated total TAT from the stage-wise days
3. Flagged breaches by comparing TAT with the SLA
4. Built pivot tables by lab section, month, priority and delay reason
5. Designed a one-page dashboard with KPI cards and slicers (month, lab
   section, priority class)

**Phase 2: SQL Server**
1. Loaded the raw CSV into a staging table with every column as text
2. Checked duplicates (6,060 rows vs 6,000 unique IDs) and removed them
3. Cleaned and converted types safely (`TRIM`, `NULLIF`, `TRY_CAST`)
4. Built a star schema (DimTest, DimClient, DimAnalyst)
5. Created views for stage days, TAT and SLA breach
6. Built a risk score for open samples
7. Wrote 8 KPI queries and checked them against the Excel pivots

## 🗄 SQL Analysis (Phase 2)
Script: [`sql/LabTAT_full_sql_script.sql`](sql/LabTAT_full_sql_script.sql)

**Checkpoints**

| Check | Result |
|---|---|
| Raw rows / unique sample IDs | 6,060 / 6,000 (60 duplicates removed) |
| Clean rows | 6,000 |
| Completed samples with a valid timeline | 5,916 |
| Open samples | 62 |
| Overall SLA breach rate | 25.5% |

**Key design decisions**
- **NULLIF before TRY_CAST:** SQL Server turns a blank text into the date
  1900-01-01. Converting blanks to NULL first protects the TAT of open samples.
- **Open samples are excluded from breach %:** their outcome is not known yet.
- **Views:** all calculations sit in one base view, and a second view keeps only
  completed samples with a valid timeline, so every KPI uses one trusted source.
- **Risk score for open samples:** 40% share of SLA time used + 35% historical
  breach rate for the test and priority + 25% historical breach rate of the
  analyst. The weights are a judgement call, not a statistical model.

**KPI queries**

| Query | Question answered |
|---|---|
| Q1 | Overall completed samples, average TAT, breach % |
| Q2 | Breach % by lab section and test |
| Q3 | Monthly trend with month-over-month change and rolling 3-month average |
| Q4 | Average days per stage by section (where time is lost) |
| Q5 | Analyst ranking by breach rate |
| Q6 | Delay reasons with cumulative % (Pareto) |
| Q7 | Effect of retest and priority |
| Q8 | Watchlist of open samples with the highest risk |

![SQL checkpoints](screenshots/sql_checkpoints.png)

## 📊 Key Insights
- Average TAT is **4.76 days**, and **25.5%** of samples breach the SLA.
- **Instrumental has the highest breach rate (about 30%)**, compared with
  about 24% for Microbiology and about 23.5% for Chemical.
- Instrumental also has the longest process: about **8.4 days** in total
  versus about 3.3 days for Chemical.
- In Instrumental, the largest shares of time go to **queue waiting and
  analysis**, not review, which points to capacity and scheduling.
- **Analyst workload** is the leading delay reason, followed by review backlog.
- The monthly breach rate stays fairly steady through the year, suggesting
  the problem is structural rather than seasonal.

## 💡 Recommendations
1. **Reduce queue time in Instrumental** by introducing a daily at-risk list
   of samples nearing their SLA (the SQL watchlist in Q8 produces this list).
2. **Rebalance analyst workload** across sections, since workload is the top
   delay cause.
3. **Clear review backlog** with fixed review slots, so completed analyses do
   not wait for approval.
4. **Track instrument downtime** and plan maintenance outside peak periods.

## ⚠️ Limitations
- Data is anonymised/simulated, so findings demonstrate the method rather than
  the performance of any real laboratory.
- TAT is counted in calendar days, so weekends and holidays are not removed.
- The risk score weights and cut-offs are a judgement call and have not been
  validated against past data.

## 🗺 Roadmap
- [x] Data cleaning and preparation
- [x] TAT calculation and SLA breach flag
- [x] Pivot table analysis
- [x] Excel executive dashboard
- [x] SQL analysis (queries, CTEs, window functions)
- [ ] Power BI dashboard
- [ ] Tableau dashboard
- [ ] Python analysis (pandas, statistical testing)

## 📁 Repository Structure
- `data/` : anonymised dataset
- `excel/` : dashboard workbook and PDF export
- `sql/` : SQL Server script
- `screenshots/` : dashboard, pivot and SQL result images
- `case-study/` : full business case study

## 👩‍💻 About Me
**Himanshi Saxena**: quality professional moving into data analytics.
Learning and applying Excel, SQL, Power BI, Tableau and Python through
real-world projects.
[LinkedIn](https://www.linkedin.com/in/himanshi-saxena-b2960a20b)

[📄 Read the full business case study](case-study/business_case_study.md)
