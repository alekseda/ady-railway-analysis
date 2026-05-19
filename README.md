# ADY Railway Analysis — SQL Project

## Overview
A SQL Server project simulating Train Operations and Delay Analysis
for Azerbaijan Railways (ADY), covering January 2023 – February 2024.

## Database Schema
| Table | Type | Rows | Description |
|---|---|---|---|
| stations | Dimension | 15 | Real ADY stations across Azerbaijan |
| trains | Dimension | 20 | Fleet: Express, Intercity, Regional, Local |
| routes | Dimension | 25 | Key ADY routes with real distances |
| delay_reasons | Dimension | 8 | Delay cause lookup |
| trips | Fact | 5,000 | Jan 2023 – Feb 2024 with seasonal delays |
| passengers | | 1,000 | Synthetic passenger profiles |
| tickets | | 8,000 | Ticket sales with pricing & channels |

## Analytical Queries (8 queries)
### Train Operations & On-Time Performance
- Overall on-time performance rate
- Performance by train type, route, and day of week
- Top 10 worst performing trains (RANK)
- Monthly OTP trend with month-over-month change (LAG)
- Running total of delayed trips (running SUM)

### Delay Analysis — Causes, Trends, Seasonality
- Delay breakdown by cause
- Monthly delay minutes by cause
- Winter vs other seasons comparison
- Top 20 worst delay days (RANK)
- 7-day and 30-day rolling average delay (sliding window AVG)
- Month-over-month change per delay cause (LAG)
- Route ranking with gap to next-best route (LEAD)

## SQL Techniques Demonstrated
- CTEs (Common Table Expressions)
- Window functions: RANK, LAG, LEAD, running totals, rolling averages
- Aggregations & GROUP BY
- Multi-table JOINs
- Reusable VIEWs

## How to Run
1. Open SSMS and connect to your SQL Server instance
2. Run `ady_railway_synthetic.sql` — creates the database and loads all data
3. Run `ady_railway_queries.sql` — executes all 8 analytical queries

## Tools
- SQL Server 2019+
- SQL Server Management Studio (SSMS)
