# Importing python libraries 

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import plotly.express as px

# Load the dataset

UPI_data = pd.read_csv(r"raw_UPI_data.csv")

# Dataset Structure

print(UPI_data.info())

# Checking missing values

print(UPI_data.isna().sum())

# To show the records which contains any or all null values

print(UPI_data[UPI_data.isna().any(axis=1)])

print(UPI_data[UPI_data.isna().all(axis=1)]) # To check if any row is entirely missing

# Fill missing values with mode

mode_val = UPI_data["Latency_ms"].mode()[0]

UPI_data["Latency_ms"] = UPI_data["Latency_ms"].fillna(mode_val)

# Cast to integer (removes the .0)
UPI_data["Latency_ms"] = UPI_data["Latency_ms"].astype(int)

# Drop those rows that have missing values in "City" cloumn

UPI_data = UPI_data.dropna(subset = ["City", "Response_msg"])

invalid_success = (UPI_data["Status"] == "Success") & (
    UPI_data["Response_msg"] != "Transaction Completed Successfully"
)
invalid_failed = (UPI_data["Status"] == "Failed") & (
    UPI_data["Response_msg"] == "Transaction Completed Successfully"
)
# Drop them
UPI_data = UPI_data[~(invalid_success | invalid_failed)].copy()

#Saving CSV file

UPI_data.to_csv("UPI_data.csv", index=False)

print(UPI_data.isna().sum())