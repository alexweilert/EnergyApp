import 'package:postgres/postgres.dart';

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
        COUNT(DISTINCT CASE WHEN boiler_temp > 140 THEN DATE(jahr || '-' || monat || '-' || tag) END) AS anzahl_boiler_ueber_140
      FROM 
        gesamtstatistik
      GROUP BY 
        jahr;
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

      query += '\nGROUP BY Jahr, Monat, Tag\nORDER BY Jahr, Monat, Tag';

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

  Future<List<Map<String, dynamic>>> fetchAllYearChartData(String tableName) async {
    try {
      if (connection.isClosed) {
        connectWithRetry();
      }
      String query_start = "SELECT year, month, day, time, temperature FROM ";
      String query_end =" WHERE time = '00:00:00' GROUP BY year, month, day, time, temperature;";
      String query = "";
      query += query_start + tableName + query_end;

      List<List<dynamic>> results = await connection.query(query);

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
      print('Fehler beim Abrufen der Jahresstatistik: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchYearChartData(String tableName) async {
    try {
      if (connection.isClosed) {
        connectWithRetry();
      }
      String query_start = "SELECT year, month, day, time, temperature FROM ";
      String query_end =" WHERE year = '2023' AND time = '00:00:00' GROUP BY year, month, day, time, temperature;";
      String query = "";
      query += query_start + tableName + query_end;

      List<List<dynamic>> results = await connection.query(query);

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
      print('Fehler beim Abrufen der Jahresstatistik: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchCurrentYearChartData(String tableName) async {
    try {
      if (connection.isClosed) {
        connectWithRetry();
      }
      String query_start = "SELECT year, month, day, time, temperature FROM ";
      String query_end =" WHERE year = '2023' AND time = '00:00:00' GROUP BY year, month, day, time, temperature;";
      String query = "";
      query += query_start + tableName + query_end;

      List<List<dynamic>> results = await connection.query(query);

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
      print('Fehler beim Abrufen der derzeitigen Jahresstatistik: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetch6MonthChartData(String tableName) async {
    try {
      if (connection.isClosed) {
        connectWithRetry();
      }
      String query_start = "SELECT year, month, day, time, temperature FROM ";
      String query_end =" WHERE year = '2023' AND month <= '6' AND time = '00:00:00' GROUP BY year, month, day, time, temperature;";
      String query = "";
      query += query_start + tableName + query_end;

      List<List<dynamic>> results = await connection.query(query);

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
      print('Fehler beim Abrufen der 6 Monatstatistik: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchMonthChartData(String tableName) async {
    try {
      if (connection.isClosed) {
        connectWithRetry();
      }
      String query_start = "SELECT year, month, day, time, temperature FROM ";
      String query_end =" WHERE year = '2023' AND month = '1' AND time = '00:00:00' GROUP BY year, month, day, time, temperature;";
      String query = "";
      query += query_start + tableName + query_end;

      List<List<dynamic>> results = await connection.query(query);

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
      print('Fehler beim Abrufen der Monatsstatistik: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetch5DaysChartData(String tableName) async {
    try {
      if (connection.isClosed) {
        connectWithRetry();
      }
      String query_start = "SELECT year, month, day, time, temperature FROM ";
      String query_end =" WHERE year = '2023'AND Month = '1' AND day <= 5 AND EXTRACT(EPOCH FROM time)::INT % (15 * 60) = 0 GROUP BY year, month, day, time, temperature;";
      String query = "";
      query += query_start + tableName + query_end;

      List<List<dynamic>> results = await connection.query(query);

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
      print('Fehler beim Abrufen der 5 Tagestatistik: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchDayChartData(String tableName) async {
    try {
      if (connection.isClosed) {
        connectWithRetry();
      }
      String query_start = "SELECT year, month, day, time, temperature FROM ";
      String query_end =" WHERE year = '2023' AND month = '1' AND day = '1' AND EXTRACT(EPOCH FROM time)::INT % (15 * 60) = 0 ORDER BY time;";
      String query = "";
      query += query_start + tableName + query_end;

      List<List<dynamic>> results = await connection.query(query);

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
      print('Fehler beim Abrufen der Tagestatistik: $e');
      return [];
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
