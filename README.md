# Medicare Inpatient Payment Analysis

An end-to-end analytics project that uses CMS data to examine how Medicare inpatient payments vary across hospitals, states, and patient populations.

**Data:** CMS Medicare Inpatient Hospitals by Provider, 2023 and 2024
**Stack:** Python (ETL), PostgreSQL (star schema), Tableau (8 dashboards)

## Business Questions

| # | Question |
|---|----------|
| Q1 | How does payment per discharge vary across regions? |
| Q2 | Do minority-serving hospitals receive lower Medicare payments? |
| Q3 | Which chronic condition burden levels drive the highest Medicare expenditure? |
| Q4 | What is the charge-to-payment markup ratio across US hospitals? |
| Q5 | How do behavioral health comorbidities affect inpatient utilization? |
| Q6 | How do beneficiary age and gender composition affect payment and length of stay? |
| Q7 | Does HCC risk score predict hospital-level Medicare payments? |
| Q8 | Are high dual-eligible hospitals underpaid relative to risk-adjusted expectations? |


## Key Findings

- **Minority-serving hospitals are not paid less.** Hospitals with ≥50% minority share average $24,495 per beneficiary vs. $16,707 for low-minority hospitals. *Hypothesis (not yet tested): urban concentration, since high-cost cities get higher CMS wage-index adjustments.*
- **High dual-eligible hospitals are paid more per discharge** ($13,764 vs. $11,938). The median gap is only $516, so outlier hospitals account for much of the difference. *Same untested urban-concentration hypothesis.*
- **Low-comorbidity hospitals are paid more per discharge than high-burden ones** ($14,493 vs. $12,045). *Hypothesis: specialty hospitals with different reimbursement structures.*

## Architecture

```mermaid
flowchart LR
    A[CMS Medicare<br/>Inpatient data<br/>2023, 2024] --> B[Python ETL<br/>cleaning and validation]
    B --> C[(PostgreSQL<br/>star schema)]
    C --> D[Tableau<br/>8 dashboards]
```