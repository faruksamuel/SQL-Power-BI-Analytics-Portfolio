# Product Profitability Analysis (SQL Server + Power BI)

## Overview
This project analyzes product-level profitability using SQL Server and Power BI.
The goal is to identify high-performing products, low-margin products, and
categories that drive the most profit to support business decision-making.

## Business Questions
- What is profit per product?
- Which products should be promoted?
- Which products should be discontinued?
- Which categories generate the most profit?
- Which products sell a lot but make little money?

## Dataset
**Source:** AdventureWorks 2022  
**Tables Used:**
- `Sales` – transactional sales data
- `Products` – product attributes and categories

## Key Metrics
- Revenue = SUM(Sales)
- Cost = SUM(Cost)
- Profit = Revenue - Cost
- Profit Margin = Profit / Revenue
- Units Sold = SUM(Quantity)
- Orders = COUNT(DISTINCT SalesOrderNumber)

## Tools & Skills
- SQL Server (joins, aggregations, CTEs, CASE, NULLIF)
- Power BI (data modeling, DAX, dashboard design)
- Business analytics & storytelling

## Repository Structure
- `/datasets` → CSV files used for the analysis
- `/docs` → Assumptions and data dictionary
- `/powerbi` → Power BI dashboard file
- `/sql` → SQL scripts used for analysis
- `/screenshots` → Dashboard visuals


## Dashboard Preview
![Dashboard](screenshots/dashboard_overview.png)

## Key Insights
- A small number of products generate the majority of profit.
- Some high-volume products have very low profit margins.
- Certain categories consistently outperform others.
- Clear candidates exist for product promotion and discontinuation.
