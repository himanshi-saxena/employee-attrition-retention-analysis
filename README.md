# Testing Turnaround Time (TAT) & SLA Breach Analysis

An Excel dashboard that analyses turnaround time and SLA breaches across three
laboratory sections, to find where delays occur and what can be done about them.

![Dashboard](screenshots/dashboard.png)

## 📌 Project Overview
In a testing laboratory, clients are promised results within an agreed time
called the Service Level Agreement (SLA). When a sample takes longer than the
SLA, it is an SLA breach. Breaches affect client trust, repeat business and
compliance records.

This project analyses **5,916 completed samples** (plus 62 still open) to
measure performance, locate bottlenecks and recommend improvements.

## 🎯 Business Questions
1. What is the overall turnaround time and SLA breach rate?
2. Which lab section performs worst?
3. At which process stage is time being lost?
4. What are the main reasons for delay?
5. Do breaches follow a monthly pattern?

## 📂 Dataset
- **Data type:** Anonymised / simulated laboratory data. No client names or
  confidential details are used.
- **Records:** 5,916 completed samples, 62 open samples
- **Period:** [Jan–Dec, 2025-2026]

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

## ⚙️ Method
1. Cleaned the raw data and corrected column headers
2. Calculated total TAT from the stage-wise days
3. Flagged breaches by comparing TAT with the SLA
4. Built pivot tables by lab section, month, priority and delay reason
5. Designed a one-page dashboard with KPI cards and slicers (month, lab
   section, priority class)

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
   of samples nearing their SLA.
2. **Rebalance analyst workload** across sections, since workload is the top
   delay cause.
3. **Clear review backlog** with fixed review slots, so completed analyses do
   not wait for approval.
4. **Track instrument downtime** and plan maintenance outside peak periods.

## ⚠️ Limitations
- Data is anonymised/simulated, so findings demonstrate the method rather than
  the performance of any real laboratory.

## 🗺 Roadmap
- [x] Data cleaning and preparation
- [x] TAT calculation and SLA breach flag
- [x] Pivot table analysis
- [x] Excel executive dashboard
- [ ] SQL analysis (queries, CTEs, window functions)
- [ ] Power BI dashboard
- [ ] Tableau dashboard
- [ ] Python analysis (pandas, statistical testing)

## 📁 Repository Structure
- `data/` : anonymised dataset
- `excel/` : dashboard workbook and PDF export
- `screenshots/` : dashboard and pivot images
- `case-study/` : full business case study

## 👩‍💻 About Me
**Himanshi Saxena**: quality professional moving into data analytics.
Learning and applying Excel, SQL, Power BI, Tableau and Python through
real-world projects.
[LinkedIn](https://www.linkedin.com/in/himanshi-saxena-b2960a20b)

[📄 Read the full business case study](case-study/business_case_study.md)
