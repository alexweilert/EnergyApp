import csv
import random
from datetime import datetime, timedelta

# File path for the CSV output
output_file = "boiler_data_per_minute.csv"
output_file_b2 = "boiler2_data_per_minute.csv"
output_file2 = "battery_data_per_minute.csv"

# Define the time period for the data (one year)
start_date = datetime(2023, 1, 1, 0, 0, 0)  # Start of the year
end_date = datetime(2024, 12, 31, 23, 59, 59)  # End of the year
time_step = timedelta(minutes=1)  # Step is now in minutes


# Helper function to simulate seasonal changes
def get_seasonal_temperature(base_temperature, month):
    """
    Adjusts base temperature based on the month.
    Winter months (Dec, Jan, Feb): Higher temperature needed
    Summer months (Jun, Jul, Aug): Lower temperature needed
    """
    if month in [12, 1, 2]:  # Winter
        return base_temperature + random.uniform(5, 10)
    elif month in [6, 7, 8]:  # Summer
        return base_temperature - random.uniform(5, 10)
    else:  # Spring/Autumn
        return base_temperature


# Mockup data generator
def generate_boiler_data():
    current_time = start_date
    previous_temperature = random.uniform(70, 90)  # Initial boiler temperature

    while current_time <= end_date:
        # Base temperature variation
        base_temperature = random.uniform(70, 90)  # Average operating range
        temperature = get_seasonal_temperature(base_temperature, current_time.month)

        # Smooth minute-to-minute changes
        temperature = previous_temperature + random.uniform(-0.5, 0.5)
        temperature = max(70, min(temperature, 150))  # Clamp temperature to realistic limits

        # Boiler status based on random usage pattern
        status = "On" if random.random() > 0.2 else "Off"  # 80% chance boiler is "On"

        yield {
            "Year": current_time.year,
            "Month": current_time.month,
            "Day": current_time.day,
            "Time": current_time.time(),
            "Temperature (°C)": round(temperature, 2),
            "Status": status
        }

        # Update for the next iteration
        previous_temperature = temperature
        current_time += time_step

def generate_battery_data():
    current_time = start_date
    while current_time <= end_date:
        battery = round(random.uniform(0, 100))  # Status in %
        status = random.choice(["Loading", "Not loading"])  # Battery status
        yield {
            "Year": current_time.year,
            "Month": current_time.month,
            "Day": current_time.day,
            "Time": current_time.time(),
            "Battery (%)": battery,
            "Status": status
        }
        current_time += time_step


# Write the data to a CSV file
with open(output_file, mode='w', newline='') as csv_file1:
    fieldnames = ["Year", "Month", "Day", "Time", "Temperature (°C)", "Status"]
    writer = csv.DictWriter(csv_file1, fieldnames=fieldnames)

    # Write header
    writer.writeheader()

    # Write mockup data
    for row in generate_boiler_data():
        writer.writerow(row)

print(f"Mockup boiler data per minute for one year has been written to '{output_file}'.")

# Write the data to a CSV file
with open(output_file_b2, mode='w', newline='') as csv_file1:
    fieldnames = ["Year", "Month", "Day", "Time", "Temperature (°C)", "Status"]
    writer = csv.DictWriter(csv_file1, fieldnames=fieldnames)

    # Write header
    writer.writeheader()

    # Write mockup data
    for row in generate_boiler_data():
        writer.writerow(row)

print(f"Mockup boiler data 2 per minute for one year has been written to '{output_file_b2}'.")


# Write the data to a CSV file
with open(output_file2, mode='w', newline='') as csv_file2:
    fieldnames = ["Year", "Month", "Day", "Time", "Battery (%)", "Status"]
    writer = csv.DictWriter(csv_file2, fieldnames=fieldnames)

    # Write header
    writer.writeheader()

    # Write mockup data
    for row in generate_battery_data():
        writer.writerow(row)

print(f"Mockup boiler data per minute for one year has been written to '{output_file2}'.")