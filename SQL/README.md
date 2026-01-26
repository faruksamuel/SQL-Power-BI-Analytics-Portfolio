#  SQL Data Modeling – Product Profitability

##  Purpose
This folder contains all SQL logic used to prepare clean, analysis-ready datasets
for the Product Profitability Power BI dashboard.

The goal of the SQL layer is to:
- Ensure **one row per product**
- Calculate **profit, margin, and volume metrics**
- Apply **business rules** for product recommendations
- Push complexity upstream so Power BI stays lightweight

---

##  Environment
- SQL Server
- Views (no stored procedures)
- Designed for analytics / BI consumption

---

##  Files Overview

### 1️ `base_product_view.sql`
**Purpose:**  
Creates the foundational product-level dataset.

**Key characteristics:**
- One row per product
- Aggregated revenue, cost, profit, units sold
- Clean joins (single join strategy)
- No business rules yet

**Why this matters:**  
This is the **single source of truth** for all downstream analysis.

---

### 2️ `product_recommendation_view.sql`
**Purpose:**  
Applies business logic to classify each product.

**Recommendation logic:**
- **Continue** → Healthy profit & margin
- **Review** → Mixed performance (e.g. high margin but low volume)
- **Discontinue** → Negative profit or margin

**Techniques used:**
- CASE statements
- Portfolio averages as benchmarks
- Defensive logic to avoid NULL / divide-by-zero issues

---

### 3️ `high_margin_low_volume.sql`
**Purpose:**  
Identifies products with strong margins but weak sales volume.

**Business use case:**
- Growth opportunities
- Pricing and cost structure already strong
- Demand or exposure may be the issue

**Used for:**
- Insight generation in Power BI
- Product review prioritisation

---

##  Key Metrics Calculated
- Total Revenue
- Total Cost
- Total Profit
- Profit Margin
- Units Sold
- Portfolio Averages (benchmarks)

---

##  Design Principles
- Push logic to SQL, not visuals
- Views are reusable and auditable
- Clear separation of **data prep** vs **visualisation**
- Business-first logic, not just technical correctness

---

##  Outcome
This SQL layer provides a robust foundation for:
- Product-level profitability analysis
- Scalable Power BI reporting
- Consistent, explainable business recommendations

