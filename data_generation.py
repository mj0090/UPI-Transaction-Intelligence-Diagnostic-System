# Importing python libraries

import pandas as pd
import numpy as np
from randomtimestamp import randomtimestamp
import secrets

# Set seed for reproducibility


np.random.seed(40)


# Number of records


n = 200000


# Payment Apps


pay_app = ["Google Pay", "BHIM", "PhonePe", "Paytm", "CRED", "Amazon Pay"]


# Cities


cities = ["Delhi NCR", "Mumbai", "Hyderabad", "Chennai", "Kolkata", "Bengaluru"]


# Categories


categories = ["Electronics & Appliances", "Healthcare & Pharmacy", "Retail & Apparel", "Food & Dining", "Grocery & Supermarkets"]


# Acquiring banks


acq_banks = ["Axis Bank", "ICICI Bank", "HDFC Bank", "Kotak Mahindra Bank", "State Bank of India", "Bank of Baroda"]


# Payment FLow

pay_flow = ["INTENT_ONLINE_CHECKOUT", "MANDATE_AUTOPAY", "P2M_STATIC_QR", "P2M_DYNAMIC_QR"]

status = ["Success", "Failed"]

response_msg = ["Bank Timed Out", "Exceeded Daily Limit", "Insufficient Funds", "Invalid PIN", "System Error", "Transaction Completed Successfully"]

# Generate Synthetic data

data = {
    "Transaction ID": [secrets.token_hex(8) for _ in range(n)],
    "Timestamp": [randomtimestamp() for _ in range(n)],
    "Merchant ID": [secrets.token_hex(5) for _ in range(n)],
    "Cateogory" : np.random.choice(categories, n),
    "Company" : np.random.choice(pay_app, n),
    "Aquiring_Bank" : np.random.choice(acq_banks, n),
    "City" : np.random.choice(cities, n),
    "Amount(INR)" : np.round(np.random.uniform(1.00, 50000.00, n), 2),
    "Status" : np.random.choice(status, n), 
    "Response_msg" : np.random.choice(response_msg, n),
    "Latency_ms" : np.random.randint(150, 2000, n)
}

# Creating CSV file
csv_data = pd.DataFrame(data)

#Saving the CSV data

csv_data.to_csv("UPI_data.csv", index = False)

# Introducing null values intentionally

for col in ["City", "Response_msg", "Latency_ms"]:
    csv_data.loc[csv_data.sample(frac = np.random.uniform(0.1, 0.3)).index, col] = np.nan

start_date = pd.Timestamp("2023-01-01").value
end_date = pd.Timestamp("2026-09-01").value

# Generate n random timestamps in nanoseconds and convert back to datetime
csv_data["Timestamp"] = pd.to_datetime(
    np.random.randint(start_date, end_date, size=len(csv_data), dtype=np.int64)
)

#Saving the uncleaned CSV data

csv_data.to_csv("raw_UPI_data.csv", index = False)