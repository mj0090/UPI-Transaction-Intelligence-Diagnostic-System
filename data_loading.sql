-- Loading the Data

COPY upi_transactions (
	transaction_id, txn_timestamp, merchant_id, category, company,
	acquiring_bank, city, amount_inr, status, response_msg, latency_ms
)
FROM 'D:\UPI project\UPI_data.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

SELECT COUNT(*) FROM upi_transactions;