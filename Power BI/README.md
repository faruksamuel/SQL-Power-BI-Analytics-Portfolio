# Power BI Dashboard – Product Profitability

##  Purpose
This Power BI report transforms SQL output into **decision-ready insights**.
It focuses not only on reporting metrics, but on explaining **what action should be taken and why**.

---

##  Tools & Techniques
- Power BI Desktop
- DAX (measures only, no calculated columns for KPIs)
- Drill-through pages
- Conditional formatting
- Dynamic insight text

---

##  Pages Overview

### 1️. Product Profitability Overview
**Audience:** Senior stakeholders / decision-makers

**What it shows:**
- Total Revenue, Profit, Profit Margin, Units Sold
- Revenue vs Profit scatter plot
- Product recommendations (Continue / Review / Discontinue)
- Profit contribution by category

**Key design choice:**
- Scatter plot highlights **margin killers** and **growth opportunities**
- Recommendation distribution updates dynamically with filters

---

### 2️. Product Detail (Drill-Through)
**Audience:** Analysts / product managers

**What it shows:**
- Product-specific KPIs
- Recommendation badge (Continue / Review / Discontinue)
- Benchmark comparisons
- Written product insight (auto-generated)

**Why this matters:**
This page turns raw metrics into **clear guidance** for action.

---

##  Core Measures Used
- Total Revenue
- Total Profit
- Profit Margin
- Units Sold
- Average Profit (portfolio)
- Average Profit Margin (portfolio)
- Average Units Sold (portfolio)

Benchmarks are calculated using `ALL()` to ensure fair comparison
against the full product portfolio.

---

##  Insight Logic
Each product generates a written insight based on:
- Margin vs average margin
- Volume vs average volume
- Profit contribution

Example insight:
> “This product has a healthy profit margin but relatively low unit sales, indicating a strong pricing structure with limited demand. Recommendation is to review for scaling opportunities.”

---

##  Design & UX Principles
- Dark theme for focus
- KPIs at the top for instant context
- Insight text placed directly under KPIs
- Colour used only for meaning (green / amber / red)
- Minimal clutter, maximum clarity

---

##  Outcome
The dashboard enables users to:
- Quickly identify underperforming products
- Understand *why* a recommendation exists
- Move from reporting → decision-making
- Confidently prioritise product actions

---

##  Final Note
This project demonstrates not just Power BI skills,
but the ability to think in **business terms**, apply **logic**, and communicate insights clearly.
