-- Table: upi_transactions

CREATE TABLE upi_transactions (
	transaction_id		VARCHAR(16)		PRIMARY KEY,
	txn_timestamp		TIMESTAMP		NOT NULL,
	merchant_id			VARCHAR(10)		NOT NULL,
	category			VARCHAR(40)		NOT NULL,
	company				VARCHAR(20)		NOT NULL,
	acquiring_bank		VARCHAR(40)		NOT NULL,
	city	 			VARCHAR(30)		NOT NULL,	
	amount_inr			NUMERIC(12,2)	NOT NULL,
	status				VARCHAR(20)		NOT NULL,
	response_msg		VARCHAR(60)		NOT NULL,
	latency_ms			INT				NOT NULL,

	CONSTRAINT chk_status CHECK (status IN ('Success', 'Failed')),
	CONSTRAINT chk_amount_pos CHECK (amount_inr > 0),
	CONSTRAINT chk_latency_pos CHECK (latency_ms > 0)
);

-- Indexes for the query patterns(dimension filters + time-series)

CREATE INDEX idx_upi_company_time 
ON upi_transactions (company, txn_timestamp);

CREATE INDEX idx_upi_city_status_time 
ON upi_transactions (city, status, txn_timestamp);

CREATE INDEX idx_upi_failures 
ON upi_transactions (company, txn_timestamp) 
WHERE status = 'Failed';

