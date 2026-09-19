# UPI-Transaction-Intelligence-Diagnostic-System
Data Analysis &amp; Business Intelligence Project

Tech Stack: Python (pandas, numpy), PostgreSQL, Power BI (DAX, What-If Modeling)

| ANALYZED RECORDS | GROSS VALUE ANALYZED | BASELINE SUCCESS | AVERAGE LATENCY |
| :--- | :--- | :--- | :--- |
| # **63,000+**<br><sub>Synthetic UPI Transactions</sub> | # **₹261.1M**<br><sub>Transaction Volume Tracked</sub> | # **16.53%**<br><sub>High-Failure Scenario Sim</sub> | # **1,040 ms**<br><sub>Acquirer Gateway Benchmark</sub> |

# 1. Executive Project Summary
Modern Unified Payments Interface (UPI) infrastructures handle tens of millions of daily transactions across diverse apps (Google Pay, PhonePe, Paytm, CRED) and banking gateways (HDFC, SBI, ICICI, Axis). This project establishes a production-grade business intelligence solution designed to monitor transaction telemetry in real-time, detect operational latency bottlenecks, pinpoint root causes for transaction failures, and model the financial revenue recovery of technical gateway optimizations.

```text
========================================================================================
                 2. CORE METHODOLOGY & ANALYTICS ARCHITECTURE
========================================================================================

  [ Raw Synthetic Pipeline (35k Events) ]
                     │
                     ▼
  [ Data Quality & Defensive Engineering ]
    • Regex deduplication (1–2% duplicate transaction_ids)
    • Casing & status normalization ('Succ', 'SUCCESS' -> 'Success')
    • Anomaly removal (negative latencies, timestamps > business limits)
    • Explicit date casting & missing timestamp imputation
                     │
                     ▼
  [ Feature Engineering & Lifecycle State Engine ]
    • Attempt Tracking: attempt_no, retry_flag, reversal_flag
    • Temporal Deltas: settlement_delay_min = (settlement_ts - event_ts)
    • Operational State Flags: support_contact_flag, refund_flag
                     │
                     ▼
  [ Analytical Workflows & Inference ]
    • Pareto Analysis: Categorical & Merchant 80/20 drift concentration
    • Hypothesis Testing: Welch’s t-test (Gateway latency vs. Retry frequency)
    • Merchant Risk Score: Weighted normalized composite scoring
                     │
                     ▼
  [ Executive Delivery ]
    • Production DuckDB / PostgreSQL validation queries
    • 4-Page Power BI Control Room with dynamic What-If parameter simulation

========================================================================================
```

# 3. Multi-Page Dashboard Implementation
The dashboard is organized into four purpose-built analytical workspaces, balancing high-level executive summaries with granular developer diagnostics.

Dashboard View	Visual Components Used	Strategic Focus & Analytical Depth
| Page / Module | Key Visuals & Components | Operational Purpose & Value |
| :--- | :--- | :--- |
| **1. Executive Overview** | • Metric Chips (Cards)<br>• Multi-level Drill-down Line Chart<br>• Clustered Bar Chart<br>• App Donut Chart | Provides C-level visibility into core operational KPIs, volume trends across quarters, and market share by payment application. |
| **2. Failure & Latency Diagnostics** | • App × Acquirer Matrix Heatmap<br>• Latency Distribution Bar Chart<br>• Treemap of Error Reasons | Pinpoints acquiring bank gateway timeouts, network dropouts, and identifies underperforming bank-app pairs through color gradients. |
| **3. Transaction Explorer** | • Tabular Transaction Ledger with in-cell Data Bars on `Amount (INR)`<br>• Multi-select Slicer Drawer | Enables audit-level investigation for operations teams, filtering down to exact transaction IDs, merchants, and failure codes. |
| **4. What-If Simulation** | • DAX Numeric Parameter Slicer (`0%` to `50%`)<br>• Dynamic Comparison Cards<br>• Revenue Recovery Metric | Enables product leadership to quantify the business impact of technical stability improvements on success rates and recovered revenue. |

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
