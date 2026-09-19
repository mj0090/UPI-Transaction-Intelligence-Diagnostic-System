-- Overall Health KPIs

-- Q1. What is the overall transaction success rate?
SELECT
COUNT(*) AS total_transactions,
COUNT(*) FILTER (WHERE status = 'Success') AS successful_transactions,
ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'Success') / COUNT(*), 2) AS success_rate_pct
FROM upi_transactions;
-- Q2. What is the total transaction value processed, and how much of
-- that value sits in FAILED transactions ("value at risk")?
SELECT
ROUND(SUM(amount_inr), 2) AS total_value_inr,
ROUND(SUM(amount_inr) FILTER (WHERE status = 'Failed'), 2) AS failed_value_inr,
ROUND(100.0 * SUM(amount_inr) FILTER (WHERE status = 'Failed') / SUM(amount_inr), 2) AS pct_value_failed
FROM upi_transactions;

-- Success / Failure Rate by Dimension

-- Q3. Success rate by payment app (Company) — which apps have the
-- healthiest transaction outcomes?
SELECT
company,
COUNT(*) AS total_txns,
ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'Success') / COUNT(*), 2) AS success_rate_pct
FROM upi_transactions
GROUP BY company
ORDER BY success_rate_pct DESC;
-- Q4. Success rate by acquiring bank — which banks are the weakest link?
SELECT
acquiring_bank,
COUNT(*) AS total_txns,
ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'Success') / COUNT(*), 2) AS success_rate_pct
FROM upi_transactions
GROUP BY acquiring_bank
ORDER BY success_rate_pct ASC;
-- Q5. Success rate by city
SELECT
city,
COUNT(*) AS total_txns,
ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'Success') / COUNT(*), 2) AS success_rate_pct
FROM upi_transactions
GROUP BY city
ORDER BY success_rate_pct ASC;
-- Q6. Success rate by merchant category — which category of spend is
-- most prone to failed payments?
SELECT
category,
COUNT(*) AS total_txns,
ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'Success') / COUNT(*), 2) AS success_rate_pct
FROM upi_transactions
GROUP BY category
ORDER BY success_rate_pct ASC;

-- Q7. Failure reason breakdown, restricted to rows where the response
-- message is internally consistent with a failed outcome
SELECT
response_msg,
COUNT(*) AS failed_txns,
ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_failures
FROM upi_transactions
WHERE status = 'Failed'
AND response_msg <> 'Transaction Completed Successfully'
GROUP BY response_msg
ORDER BY failed_txns DESC;

-- Latency Analysis

-- Q8. Average and median gateway latency, split by outcome — does
-- slower latency correlate with failure?
SELECT
status,
ROUND(AVG(latency_ms), 0) AS avg_latency_ms,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY latency_ms) AS median_latency_ms,
MAX(latency_ms) AS max_latency_ms
FROM upi_transactions
GROUP BY status;
-- Q9. Failure rate by latency bucket — is there a latency threshold
-- beyond which failures spike?
SELECT
CASE
WHEN latency_ms < 500 THEN '1. <500ms'
WHEN latency_ms < 1000 THEN '2. 500-999ms'
WHEN latency_ms < 1500 THEN '3. 1000-1499ms'
ELSE '4. 1500ms+'
END AS latency_bucket,
COUNT(*) AS total_txns,
ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'Failed') / COUNT(*), 2) AS failure_rate_pct
FROM upi_transactions
GROUP BY latency_bucket
ORDER BY latency_bucket;
-- Q10. Which acquiring banks have the highest average latency?
-- Ranked with a window function so ties are handled explicitly.
SELECT
acquiring_bank,
ROUND(AVG(latency_ms), 0) AS avg_latency_ms,
RANK() OVER (ORDER BY AVG(latency_ms) DESC) AS latency_rank
FROM upi_transactions
GROUP BY acquiring_bank
ORDER BY latency_rank;

-- Value / Revenue Analysis

-- Q11. Top 10 highest-value transactions, with outcome, for manual review.
SELECT transaction_id, txn_timestamp, company, acquiring_bank, city,
amount_inr, status, response_msg
FROM upi_transactions
ORDER BY amount_inr DESC
LIMIT 10;
-- Q12. Value at risk (failed-transaction value) by city, so operations
-- knows where to prioritize outreach to acquiring banks.
SELECT
city,
ROUND(SUM(amount_inr) FILTER (WHERE status = 'Failed'), 2) AS failed_value_inr,
COUNT(*) FILTER (WHERE status = 'Failed') AS failed_txns
FROM upi_transactions
GROUP BY city
ORDER BY failed_value_inr DESC;
-- Q13. Average ticket size by category, split by outcome — do failures
-- skew toward higher or lower value transactions?
SELECT
category,
status,
ROUND(AVG(amount_inr), 2) AS avg_amount_inr,
COUNT(*) AS txn_count
FROM upi_transactions
GROUP BY category, status
ORDER BY category, status;

-- Time-Based Trends

-- Q13. Monthly transaction count and value trend.
SELECT
DATE_TRUNC('month', txn_timestamp) AS txn_month,
COUNT(*) AS total_txns,
ROUND(SUM(amount_inr), 2) AS total_value_inr,
ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'Success') / COUNT(*), 2) AS success_rate_pct
FROM upi_transactions
GROUP BY txn_month
ORDER BY txn_month;

-- Q14. Day-of-week pattern — which weekday has the highest volume
-- and the weakest success rate?
SELECT
TO_CHAR(txn_timestamp, 'Day') AS day_of_week,
COUNT(*) AS total_txns,
ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'Success') / COUNT(*), 2) AS success_rate_pct
FROM upi_transactions
GROUP BY day_of_week, EXTRACT(ISODOW FROM txn_timestamp)
ORDER BY EXTRACT(ISODOW FROM txn_timestamp);

--  Advanced / Window Function Queries

-- Q15. Payment app market share (% of total transaction count)
WITH app_totals AS (
SELECT company, COUNT(*) AS txn_count
FROM upi_transactions
GROUP BY company
)
SELECT
company,
txn_count,
ROUND(100.0 * txn_count / SUM(txn_count) OVER (), 2) AS market_share_pct,
ROUND(
100.0 * SUM(txn_count) OVER (ORDER BY txn_count DESC) / SUM(txn_count) OVER (),
2
) AS cumulative_share_pct
FROM app_totals
ORDER BY txn_count DESC;
-- Q16. Acquiring banks whose failure rate is worse than the network
-- average — the shortlist for a vendor performance review.
WITH bank_failure_rate AS (
SELECT
acquiring_bank,
COUNT(*) AS total_txns,
ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'Failed') / COUNT(*), 2) AS failure_rate_pct
FROM upi_transactions
GROUP BY acquiring_bank
)
SELECT *
FROM bank_failure_rate
WHERE failure_rate_pct > (SELECT AVG(failure_rate_pct) FROM bank_failure_rate)
ORDER BY failure_rate_pct DESC;

-- Q17. For each city, rank acquiring banks by transaction volume
-- (top 2 banks per city)
WITH ranked AS (
SELECT
city,
acquiring_bank,
COUNT(*) AS txn_count,
ROW_NUMBER() OVER (PARTITION BY city ORDER BY COUNT(*) DESC) AS rn
FROM upi_transactions
GROUP BY city, acquiring_bank
)
SELECT city, acquiring_bank, txn_count
FROM ranked
WHERE rn <= 2
ORDER BY city, rn;