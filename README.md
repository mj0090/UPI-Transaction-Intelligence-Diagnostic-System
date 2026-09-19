# UPI-Transaction-Intelligence-Diagnostic-System
Data Analysis &amp; Business Intelligence Project

Tech Stack: Python (pandas, numpy), PostgreSQL, Power BI (DAX, What-If Modeling)

> ### 📊 ANALYZED RECORDS            
> # `63,000+`
> **Synthetic UPI Transactions**

> ### 📊 GROSS VALUE ANALYZED
> # `₹261.1M`
> **Transaction Volume Tracked**

> ### 📊 BASELINE SUCCESS
> # `16.53%`
> **High-Failure Scenario Sim**

> ### 📊 AVERAGE LATENCY
> # `1,040 ms`
> **Acquirer Gateway Benchmark**

# 1. Executive Project Summary
Modern Unified Payments Interface (UPI) infrastructures handle tens of millions of daily transactions across diverse apps (Google Pay, PhonePe, Paytm, CRED) and banking gateways (HDFC, SBI, ICICI, Axis). This project establishes a production-grade business intelligence solution designed to monitor transaction telemetry in real-time, detect operational latency bottlenecks, pinpoint root causes for transaction failures, and model the financial revenue recovery of technical gateway optimizations.

# 2. Architecture & Data Engineering Pipeline
The system relies on a star schema data architecture structured to handle high-velocity payment events with strict relational integrity and high-performance DAX aggregation.

Pipeline Stage	Implementation Specifics	Business Outcome
Data Ingestion & Hygiene	Python automated data cleaning; removed inconsistent status response logs; converted ISO timestamps into structured date-time series.	Eliminated contradictory records (e.g. success statuses masked with failure errors).
Star Schema Modeling	Decoupled transaction events (`UPI_data`) from a dynamically calculated calendar dimension (`DateTable`) via a 1-to-many relationship.	Supports multi-level time-intelligence drill-downs (Year → Quarter → Month → Day).
DAX Measure Store	Created dedicated `_Measures` table containing dynamic filter-aware operational metrics, failure rate aggregations, and percentiles.	Zero report latency; cross-filtering enables real-time visual recalculation across all canvas elements.
Key Architectural Challenge Solved
Resolved relationship filtering disconnections caused by mixed date-time text strings by implementing an explicit calendar table generated via DAX `CALENDAR()` and enforcing clean date keys across fact and dimension boundaries.

# 3. Multi-Page Dashboard Implementation
The dashboard is organized into four purpose-built analytical workspaces, balancing high-level executive summaries with granular developer diagnostics.

Dashboard View	Visual Components Used	Strategic Focus & Analytical Depth
1. Executive Overview	Metric Chips (Cards), Multi-level Drill-down Line Chart, Clustered Bar Chart, App Donut Chart.	Provides C-level visibility into core operational KPIs, volume trends across quarters, and market share by payment application.
2. Failure & Latency Diagnostics	App × Acquirer Matrix Heatmap, Latency Distribution Bar Chart, Treemap of Error Reasons.	Pinpoints acquiring bank gateway timeouts, network dropouts, and identifies underperforming bank-app pairs through color gradients.
3. Transaction Explorer	Tabular Transaction Ledger with in-cell Data Bars on Amount (INR), Multi-select Slicer Drawer.	Enables audit-level investigation for operations teams, filtering down to exact transaction IDs, merchants, and failure codes.
4. What-If Simulation	DAX Numeric Parameter Slicer (`0%` to `50%`), Dynamic Comparison Cards, Revenue Recovery Metric.	Enables product leadership to quantify the business impact of technical stability improvements on success rates and recovered revenue.

# 4. Mission-Critical DAX Measures
High-performance measures were authored to evaluate dynamic context without triggering full-table locks or ignoring active visual slicing.

Context-Aware Success Rate %
// Evaluates dynamically across any visual slicer
Success Rate % = 
DIVIDE(
    CALCULATE(
        COUNTROWS(UPI_data), 
        UPI_data[Status] = "Success"
    ),
    COUNTROWS(UPI_data),
    0
)
Revenue at Risk (Lost Volume)
// Calculates total failed volume in INR
Revenue at Risk = 
CALCULATE(
    SUM(UPI_data[Amount(INR)]), 
    UPI_data[Status] = "Failed"
)
Dynamic What-If Simulation Measure
Integrates with the numeric parameter slider to dynamically project new success benchmarks as engineering teams resolve acquirer timeout bottlenecks:

// Simulates recovered transactions based on user parameter input
Projected Success Rate (Simulated) = 
VAR CurrentSuccess = [Success Rate %]
VAR CurrentFailure = [Failure Rate %]
VAR ReductionFactor = 'Failure Reduction %'[Failure Reduction % Value]
VAR RecoveredFailures = CurrentFailure * ReductionFactor
RETURN
CurrentSuccess + RecoveredFailures
