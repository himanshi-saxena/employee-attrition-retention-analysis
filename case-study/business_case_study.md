# Business Case Study: Reducing SLA Breaches in a Testing Laboratory

## 1. Background
Testing laboratories promise clients a result within an agreed number of days,
called the Service Level Agreement (SLA). Delays hurt client trust, increase
complaints and weaken audit performance. This study looks at three lab
sections: Chemical, Instrumental and Microbiology.

![Dashboard](../Dashboard-Summary.png)

## 2. Problem Statement
About one in four samples (25.5%) breaches its SLA. Management has no single
view that shows where in the process time is lost and which causes matter most.

## 3. Objective
Build a clear, repeatable dashboard that measures turnaround time (TAT) and
SLA breaches, finds the bottleneck and supports practical recommendations.

## 4. Data and Approach
- **Data:** 5,916 completed samples and 62 open samples ([2025-2026]), anonymised
  and simulated to reflect real laboratory workflows.
- **Method:** Total TAT was split into four stages (assigned, queue, analysis,
  review) to see where time is spent. Pivot tables and slicers allow
  filtering by month, lab section and priority class.
- **Tool:** Excel (pivot tables, formulas, charts, dashboard design).

## 5. Findings

| Area | Finding |
|---|---|
| Overall | Average TAT is 4.76 days; 25.5% of samples breach the SLA |
| Lab section | Instrumental is worst at about 30%; others are about 23 to 24% |
| Process time | Instrumental takes about 8.4 days against about 3.3 for Chemical |
| Bottleneck | Queue and analysis take the largest share of time in Instrumental |
| Delay causes | Analyst workload is the leading reason, then review backlog |
| Trend | Breach rate is steady across months, so the issue is structural |

![Breach by Lab Section](../Breach_pcnt_by_lab_section.png)
![Delay Reason](../Delay%20Reason.png)

## 6. Recommendations

| # | Action | Expected benefit |
|---|---|---|
| 1 | Daily at-risk list for samples nearing their SLA | Earlier action, fewer breaches |
| 2 | Rebalance analyst workload, starting with Instrumental | Shorter queue time |
| 3 | Fixed review slots | Lower review backlog |
| 4 | Plan instrument maintenance outside peak periods | Fewer downtime delays |

## 7. Business Impact
If Instrumental's breach rate moves closer to the other sections, the overall
rate would fall noticeably. A reasonable goal would be [your target, e.g.
under 20%]. This is a target to aim for, not a result already achieved.

## 8. Limitations and Next Steps
- The data is anonymised/simulated, so the findings demonstrate the method,
  not the performance of any real laboratory.
- [Add one assumption, e.g. how open samples were treated]
- **Next steps:** repeat the analysis in SQL, build Power BI and Tableau
  versions, and use Python to test whether the differences between sections
  are statistically significant.
