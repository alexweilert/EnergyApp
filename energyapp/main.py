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

cur.execute("""DROP VIEW IF EXISTS Gesamtstatistik""" )
cur.execute("""DROP TABLE IF EXISTS EnergyAppData, Boiler, Boiler2,  Battery""")

cur.execute("""CREATE TABLE IF NOT EXISTS Boiler (
            year SMALLINT NOT NULL,          -- Jahr (z. B. 2024)
            month SMALLINT NOT NULL,          -- Monat (1 bis 12)
            day SMALLINT NOT NULL,            -- Tag (1 bis 31)
            time TIME NOT NULL,              -- Uhrzeit (z. B. 14:30:00)
            temperature DOUBLE PRECISION,
            status Varchar(50)
            );
            """)

cur.execute("""CREATE TABLE IF NOT EXISTS Boiler2 (
            year SMALLINT NOT NULL,          -- Jahr (z. B. 2024)
            month SMALLINT NOT NULL,          -- Monat (1 bis 12)
            day SMALLINT NOT NULL,            -- Tag (1 bis 31)
            time TIME NOT NULL,              -- Uhrzeit (z. B. 14:30:00)
            temperature DOUBLE PRECISION,
            status Varchar(50)
            );
            """)

cur.execute("""CREATE TABLE IF NOT EXISTS Battery (
            year SMALLINT NOT NULL,          -- Jahr (z. B. 2024)
            month SMALLINT NOT NULL,          -- Monat (1 bis 12)
            day SMALLINT NOT NULL,            -- Tag (1 bis 31)
            time TIME NOT NULL,              -- Uhrzeit (z. B. 14:30:00)
            battery NUMERIC(5, 2) NOT NULL,  -- Batteriewert (z. B. 75.00)
            status Varchar(50)
            );
            """)


# Commit the initial setup
conn.commit()

# Close database connection
cur.close()
conn.close()