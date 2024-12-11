import psycopg2
import csv
import time

# Database connection parameters
db_params = {
    'host': 'localhost',
    'dbname': 'energyapp',
    'user': 'postgres',
    'password': '1234'
}

# Establish connection to database
conn = psycopg2.connect(**db_params)
cur = conn.cursor()


file_path = 'boiler_data_per_minute.csv'
with open(file_path, mode='r', encoding='utf-8', errors='ignore') as file:

    row_count = sum(1 for row in file)

start_time = time.time()

# Führe den COPY-Befehl aus, ohne die HEADER-Option, für die erste Zeile
with open(file_path, "r") as f:
    cur.copy_expert("""
    COPY boiler (year, month, day, time, temperature, status)
    FROM STDIN
    DELIMITER ','
    CSV HEADER;
    """, f)
# Commit transaction for every rec
conn.commit()

end_time = time.time()
duration = end_time - start_time

print(f"Total time taken: {duration}")
print(f"Finished inserting data into boiler table. Total no. of rows: {row_count}")


file_path_b2 = 'boiler2_data_per_minute.csv'
with open(file_path_b2, mode='r', encoding='utf-8', errors='ignore') as file:

    row_count = sum(1 for row in file)

start_time = time.time()

# Führe den COPY-Befehl aus, ohne die HEADER-Option, für die erste Zeile
with open(file_path_b2, "r") as f:
    cur.copy_expert("""
    COPY boiler2 (year, month, day, time, temperature, status)
    FROM STDIN
    DELIMITER ','
    CSV HEADER;
    """, f)
# Commit transaction for every rec
conn.commit()

end_time = time.time()
duration = end_time - start_time

print(f"Total time taken: {duration}")
print(f"Finished inserting data into boiler2 table. Total no. of rows: {row_count}")





file_path1 = 'battery_data_per_minute.csv'
with open(file_path1, mode='r', encoding='utf-8', errors='ignore') as file:

    row_count1 = sum(1 for row1 in file)

start_time = time.time()

# Führe den COPY-Befehl aus, ohne die HEADER-Option, für die erste Zeile
with open(file_path1, "r") as f:
    cur.copy_expert("""
    COPY battery (year, month, day, time, battery, status)
    FROM STDIN
    DELIMITER ','
    CSV HEADER;
    """, f)
# Commit transaction for every rec
conn.commit()

end_time = time.time()
duration = end_time - start_time

print(f"Total time taken: {duration}")
print(f"Finished inserting data into battery table. Total no. of rows: {row_count1}")

cur.execute("""DROP VIEW IF EXISTS Gesamtstatistik""" )
cur.execute("""CREATE VIEW Gesamtstatistik AS
SELECT b.year AS Jahr, b.month AS Monat, b.day AS Tag, b.time AS Uhrzeit, bo.temperature AS boiler_temp, b.battery AS batterie_status
FROM Battery b LEFT JOIN Boiler bo 
ON b.year = bo.year AND b.month = bo.month AND b.day = bo.day AND b.time = bo.time;""")
conn.commit()

# Close database connection
cur.close()
conn.close()