import 'package:postgres/postgres.dart';
import 'package:intl/intl.dart';

class PostgresDatabase {
  late PostgreSQLConnection connection;

  Future<void> connectToDatabase() async {
    try {
      connection = PostgreSQLConnection(
        "10.0.2.2",   //"192.168.56.1",
        5432,
        "postgres",
        username: "postgres",
        password: "alex",
      );
      await connection.open();
      print("Verbindung wurde erfolgreich hergestellt.");
    } catch (e) {
      print('Fehler beim Herstellen der Verbindung zur Datenbank: $e');
    }
  }

  Future<void> connectWithRetry({int maxRetries = 5, int retryDelaySeconds = 5}) async {
    int attempt = 0;
    if(connection.isClosed){
      while (attempt < maxRetries) {
        attempt++;
        try {
          print("Verbindungsversuch $attempt von $maxRetries...");
          await connectToDatabase();
          print("Verbindung erfolgreich!");
          return;
        } catch (e) {
          print("Fehler bei der Verbindung: $e");
          if (attempt >= maxRetries) {
            print(
              "Maximale Anzahl von Wiederholungen erreicht. Verbindung fehlgeschlagen.");
            rethrow;
        }
          print("Erneuter Versuch in $retryDelaySeconds Sekunden...");
          await Future.delayed(Duration(seconds: retryDelaySeconds));
        }
      }
    }
  }


  Future<void> disconnect() async {
    try {
      await connection.close();
      print('Verbindung zur PostgreSQL-Datenbank geschlossen.');
    } catch (e) {
      print('Fehler beim Schließen der Verbindung: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchYearlyStatistics() async {
    try {
      if(connection.isClosed) {
        connectWithRetry();
      }
      List<List<dynamic>> results = await connection.query('''
      SELECT 
        jahr,
        COUNT(DISTINCT CASE WHEN batterie_status = 100 THEN DATE(jahr || '-' || monat || '-' || tag) END) AS anzahl_batterie_100,
        COUNT(DISTINCT CASE WHEN boiler_temp > 100 THEN DATE(jahr || '-' || monat || '-' || tag) END) AS anzahl_boiler_ueber_140
      FROM 
        gesamtstatistik
      GROUP BY 
        jahr
      ORDER BY 
        jahr DESC;
      ''');

      return results.map((row) {
        return {
          'Jahr': row[0],
          'anzahl_batterie_100': row[1],
          'anzahl_boiler_ueber_140': row[2],
        };
      }).toList();
    } catch (e) {
      print('Fehler beim Abrufen der Jahresstatistik: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchDailyStatistics({DateTime? startDate, DateTime? endDate}) async {
    try {
      if (connection.isClosed) {
        connectWithRetry();
      }

      String query = '''
      SELECT DISTINCT ON (Jahr, Monat, Tag)
        Jahr, Monat, Tag, MAX(batterie_status) AS batterie_status, MAX(boiler_temp) AS boiler_temp
      FROM gesamtstatistik
    ''';

      List<String> conditions = [];
      if (startDate != null && endDate != null) {
        conditions.add('Jahr >= ${startDate.year} AND Jahr <= ${endDate.year}');
        conditions.add('Monat >= ${startDate.month} AND Monat <= ${endDate.month}');
        conditions.add('Tag >= ${startDate.day} AND Tag <= ${endDate.day}');
      } else if (startDate != null && endDate == null) {
        conditions.add('Jahr >= ${startDate.year}');
        conditions.add('Monat >= ${startDate.month}');
        conditions.add('Tag >= ${startDate.day}');
      } else if (startDate == null && endDate != null) {
        conditions.add('Jahr <= ${endDate.year}');
        conditions.add('Monat <= ${endDate.month}');
        conditions.add('Tag <= ${endDate.day}');
      }

      if (conditions.isNotEmpty) {
        for(int i = 0; i < conditions.length; i++){
          if(i == 0){
            query += '\nWHERE ' + conditions.elementAt(i);
          } else {
            query += '\nAND ' + conditions.elementAt(i);

          }
        }
      }

      query += '\nGROUP BY Jahr, Monat, Tag\nORDER BY Jahr DESC, Monat DESC, Tag DESC';

      List<List<dynamic>> results = await connection.query(query);

      return results.map((row) {
        return {
          'Jahr': row[0],
          'Monat': row[1],
          'Tag': row[2],
          'batterie_status': row[3],
          'boiler_temp': row[4],
        };
      }).toList();
    } catch (e) {
      print('Fehler beim Abrufen der Tagesstatistik: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchLast24HoursData(String tableName) async {
    try {
      if (connection.isClosed) {
        connectWithRetry();
      }

      // Calculate current time rounded down to the last quarter-hour
      DateTime now = DateTime.now();
      int minuteOffset = now.minute % 15;
      DateTime roundedTime = now.subtract(Duration(
          minutes: minuteOffset,
          seconds: now.second,
          milliseconds: now.millisecond,
          microseconds: now.microsecond));

      // Calculate the time 24 hours ago
      DateTime startTime = roundedTime.subtract(Duration(hours: 24));

      // Extract year, month, day, and time for filtering
      int startYear = startTime.year;
      int startMonth = startTime.month;
      int startDay = startTime.day;
      String startTimeOnly = DateFormat('HH:mm:ss').format(startTime);

      int endYear = roundedTime.year;
      int endMonth = roundedTime.month;
      int endDay = roundedTime.day;
      String endTimeOnly = DateFormat('HH:mm:ss').format(roundedTime);
      //print(startDay);
      //print(startTimeOnly);
      //print(endDay);
      //print(endTimeOnly);

      // Build the query considering the structure of the database
      String query = """
      SELECT year, month, day, time, temperature
      FROM $tableName
      WHERE 
        (year > $startYear OR (year = $startYear AND (month > $startMonth OR (month = $startMonth AND (day > $startDay OR (day = $startDay AND time >= '$startTimeOnly'))))))
        AND
        (year < $endYear OR (year = $endYear AND (month < $endMonth OR (month = $endMonth AND (day < $endDay OR (day = $endDay AND time <= '$endTimeOnly'))))))
        AND EXTRACT(EPOCH FROM time)::INT % (15 * 60) = 0
      ORDER BY year, month, day, time;
    """;

      // Execute the query
      List<List<dynamic>> results = await connection.query(query);

      //results.forEach((row) {
        //print('Raw time: ${row[3]}');  // Print the raw time array
      //});

      // Map the results to the expected structure
      return results.map((row) {
        return {
          'Year': row[0],
          'Month': row[1],
          'Day': row[2],
          'Time': row[3],
          'Temperature': row[4],
        };
      }).toList();
    } catch (e) {
      print('Error fetching last 24 hours data: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchLast5DaysData(String tableName) async {
    try {
      if (connection.isClosed) {
        connectWithRetry();
      }

      // Calculate current time rounded down to the last hour
      DateTime now = DateTime.now();
      int hourOffset = now.minute;  // Using minute to round to the last hour
      DateTime roundedTime = now.subtract(Duration(
          minutes: hourOffset,
          seconds: now.second,
          milliseconds: now.millisecond,
          microseconds: now.microsecond));


      // Calculate the time 24 hours ago
      DateTime startTime = roundedTime.subtract(Duration(days: 5));

      // Extract year, month, day, and time for filtering
      int startYear = startTime.year;
      int startMonth = startTime.month;
      int startDay = startTime.day;
      String startTimeOnly = DateFormat('HH:mm:ss').format(startTime);

      int endYear = roundedTime.year;
      int endMonth = roundedTime.month;
      int endDay = roundedTime.day;
      String endTimeOnly = DateFormat('HH:mm:ss').format(roundedTime);

      // Build the query considering the structure of the database
      String query = """
      SELECT year, month, day, time, temperature
      FROM $tableName
      WHERE 
        (year > $startYear OR (year = $startYear AND (month > $startMonth OR (month = $startMonth AND (day > $startDay OR (day = $startDay AND time >= '$startTimeOnly'))))))
        AND
        (year < $endYear OR (year = $endYear AND (month < $endMonth OR (month = $endMonth AND (day < $endDay OR (day = $endDay AND time <= '$endTimeOnly'))))))
        AND EXTRACT(EPOCH FROM time)::INT % (60 * 60) = 0
      ORDER BY year, month, day, time;
    """;

      // Execute the query
      List<List<dynamic>> results = await connection.query(query);

      // Map the results to the expected structure
      return results.map((row) {
        return {
          'Year': row[0],
          'Month': row[1],
          'Day': row[2],
          'Time': row[3],
          'Temperature': row[4],
        };
      }).toList();
    } catch (e) {
      print('Error fetching last 5 days data: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchMonthData(String tableName) async {
    try {
      if (connection.isClosed) {
        connectWithRetry();
      }

      // Calculate the date range for the last 30 days
      DateTime now = DateTime.now();
      DateTime endDate = now.subtract(Duration(days: 0));
      DateTime startDate = now.subtract(Duration(days: 28));

      // Extract year, month, and day for start and end dates
      int startYear = startDate.year;
      int startMonth = startDate.month;
      int startDay = startDate.day;

      int endYear = endDate.year;
      int endMonth = endDate.month;
      int endDay = endDate.day;

      // Build the query to calculate daily mean temperature for the last 30 days
      String query = """
    SELECT year, month, day, AVG(temperature) AS mean_temperature
    FROM $tableName
    WHERE 
      (year > $startYear OR (year = $startYear AND (month > $startMonth OR (month = $startMonth AND day >= $startDay))))
      AND
      (year < $endYear OR (year = $endYear AND (month < $endMonth OR (month = $endMonth AND day <= $endDay))))
    GROUP BY year, month, day
    ORDER BY year, month, day;
    """;

      // Execute the query
      List<List<dynamic>> results = await connection.query(query);

      // Map the results to the expected structure
      return results.map((row) {
        return {
          'Year': row[0],
          'Month': row[1],
          'Day': row[2],
          'Temperature': row[3],
        };
      }).toList();
    } catch (e) {
      print('Error fetching monthly chart data: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetch6MonthData(String tableName) async {
    try {
      if (connection.isClosed) {
        connectWithRetry();
      }

      // Calculate the date range for the past year
      DateTime now = DateTime.now();
      DateTime endDate = now;
      DateTime startDate = now.subtract(Duration(days: 180));

      // Extract year and month for the start and end dates
      int startYear = startDate.year;
      int startMonth = startDate.month;

      int endYear = endDate.year;
      int endMonth = endDate.month;

      // Build the query to calculate monthly mean temperature for the past year
      String query = """
    SELECT year, month, AVG(temperature) AS mean_temperature
    FROM $tableName
    WHERE 
      (year > $startYear OR (year = $startYear AND month >= $startMonth))
      AND
      (year < $endYear OR (year = $endYear AND month <= $endMonth))
    GROUP BY year, month
    ORDER BY year, month;
    """;

      // Execute the query
      List<List<dynamic>> results = await connection.query(query);

      // Map the results to the expected structure
      return results.map((row) {
        return {
          'Year': row[0],
          'Month': row[1],
          'Temperature': row[2],
        };
      }).toList();
    } catch (e) {
      print('Error fetching yearly monthly averages: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchYearlyData(String tableName) async {
    try {
      if (connection.isClosed) {
        connectWithRetry();
      }

      // Calculate the date range for the past year
      DateTime now = DateTime.now();
      DateTime endDate = now;
      DateTime startDate = now.subtract(Duration(days: 365));

      // Extract year and month for the start and end dates
      int startYear = startDate.year;
      int startMonth = startDate.month;

      int endYear = endDate.year;
      int endMonth = endDate.month;

      // Build the query to calculate monthly mean temperature for the past year
      String query = """
    SELECT year, month, AVG(temperature) AS mean_temperature
    FROM $tableName
    WHERE 
      (year > $startYear OR (year = $startYear AND month >= $startMonth))
      AND
      (year < $endYear OR (year = $endYear AND month <= $endMonth))
    GROUP BY year, month
    ORDER BY year, month;
    """;

      // Execute the query
      List<List<dynamic>> results = await connection.query(query);

      // Map the results to the expected structure
      return results.map((row) {
        return {
          'Year': row[0],
          'Month': row[1],
          'Temperature': row[2],
        };
      }).toList();
    } catch (e) {
      print('Error fetching yearly monthly averages: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchCurrentYearlyData(String tableName) async {
    try {
      if (connection.isClosed) {
        connectWithRetry();
      }

      // Get the current date and extract the year and month
      DateTime now = DateTime.now();
      int currentYear = now.year;
      int currentMonth = now.month;

      // Build the query to calculate the monthly mean temperature for the current year
      // up until the current month (including the current month)
      String query = """
    SELECT year, month, AVG(temperature) AS mean_temperature
    FROM $tableName
    WHERE 
      year = $currentYear AND
      month <= $currentMonth  -- Include the current month and previous months
    GROUP BY year, month
    ORDER BY month;
    """;

      // Execute the query
      List<List<dynamic>> results = await connection.query(query);

      // Map the results to the expected structure
      return results.map((row) {
        print(row);
        return {
          'Year': row[0],
          'Month': row[1],
          'Temperature': row[2],
        };
      }).toList();
    } catch (e) {
      print('Error fetching yearly monthly averages: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchYearlyMaxData(String tableName) async {
    try {
      if (connection.isClosed) {
        connectWithRetry();
      }

      // Get the current date and extract the year and month
      DateTime now = DateTime.now();
      int currentYear = now.year;
      int currentMonth = now.month;

      // Build the query to calculate the monthly mean temperature for all years
      // and include months up to the current month for the current year
      String query = """
    SELECT year, month, AVG(temperature) AS mean_temperature
    FROM $tableName
    WHERE 
      (year < $currentYear)  -- All past years
      OR 
      (year = $currentYear AND month <= $currentMonth)  -- Current year, up to the current month
    GROUP BY year, month
    ORDER BY year, month;
    """;

      // Execute the query
      List<List<dynamic>> results = await connection.query(query);

      // Map the results to the expected structure
      return results.map((row) {
        print(row);
        return {
          'Year': row[0],
          'Month': row[1],
          'Temperature': row[2],
        };
      }).toList();
    } catch (e) {
      print('Error fetching yearly monthly averages: $e');
      return [];
    }
  }



  Future<int> countMonthsCurrentYear(String tableName) async {
    try {
      if (connection.isClosed) {
        connectWithRetry();
      }

      // Get the current year and month
      DateTime now = DateTime.now();
      int currentYear = now.year;
      int currentMonth = now.month;

      // Build the query to count months for the current year
      String query = """
    SELECT COUNT(DISTINCT month)
    FROM $tableName
    WHERE 
      year = $currentYear AND month <= $currentMonth;
    """;

      // Execute the query
      List<List<dynamic>> results = await connection.query(query);

      // Extract the count from the query result
      if (results.isNotEmpty && results[0].isNotEmpty) {
        return results[0][0] as int;
      } else {
        return 0; // No months found
      }
    } catch (e) {
      print('Error counting completed or ongoing months in current year: $e');
      return 0; // Return 0 in case of an error
    }
  }

  Future<int> countMonthsMax(String tableName) async {
    try {
      if (connection.isClosed) {
        connectWithRetry();
      }

      // Get the current year and month
      DateTime now = DateTime.now();
      int currentYear = now.year;
      int currentMonth = now.month;

      // Build the query to count the months that are either over or currently in progress
      String query = """
    SELECT COUNT(DISTINCT (year, month))
    FROM $tableName
    WHERE 
      (year < $currentYear OR (year = $currentYear AND month <= $currentMonth));
    """;

      // Execute the query
      List<List<dynamic>> results = await connection.query(query);

      // Extract the count from the query result
      if (results.isNotEmpty && results[0].isNotEmpty) {
        return results[0][0] as int;
      } else {
        return 0; // No months found
      }
    } catch (e) {
      print('Error counting completed or ongoing months: $e');
      return 0; // Return 0 in case of an error
    }
  }


  Future<List<List<dynamic>>> fetchSelect(String s) async {
    try {
      List<List<dynamic>> results = await connection.query(s);
      return results;
    } catch (e) {
      print('Fehler beim Abrufen der Datenbank: $e');
      return [];
    }
  }

}
