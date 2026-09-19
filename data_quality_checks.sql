--Data Quality Checks

-- 1. Confirming transaction_id is truly unique (should return 0 rows)
SELECT transaction_id, COUNT(*)
FROM upi_transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;

-- 2. Find rows where Status and Response_msg don't logically agree.
SELECT status, response_msg, COUNT(*) AS row_count
FROM upi_transactions
WHERE (status = 'Failed' AND response_msg = 'Transaction Completed Successfully')
OR (status = 'Success' AND response_msg <> 'Transaction Completed Successfully')
GROUP BY status, response_msg
ORDER BY row_count DESC;

-- 3. Quantify how many rows have a timestamp before UPI's 2016 launch
SELECT
COUNT(*) FILTER (WHERE txn_timestamp < '2016-01-01') AS pre_2016_rows,
COUNT(*) FILTER (WHERE txn_timestamp >= '2016-01-01') AS post_2016_rows,
ROUND(100.0 * COUNT(*) FILTER (WHERE txn_timestamp < '2016-01-01') / COUNT(*), 2) AS pct_pre_2016
FROM upi_transactions;

-- 4. Check for any exact duplicate timestamps (informational only —
-- not an error).

SELECT txn_timestamp, COUNT(*)
FROM upi_transactions
GROUP BY txn_timestamp
HAVING COUNT(*) > 1;