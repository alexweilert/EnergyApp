import 'package:flutter/material.dart';
import 'postgresDatabase.dart';

class GesamtstatistikScreen extends StatefulWidget {
  final PostgresDatabase database;

  GesamtstatistikScreen({required this.database});

  @override
  _GesamtstatistikScreenState createState() => _GesamtstatistikScreenState();
}

class _GesamtstatistikScreenState extends State<GesamtstatistikScreen> {
  // Datenbankverbindung
  late PostgresDatabase database;
  bool isYearly = true; // Umschaltung zwischen Jahres- und Tagesstatistik
  bool showPercentage = false; // Anzeige in Prozent oder Absolutwerten

  // Daten für die Statistik
  List<Map<String, dynamic>> yearlyData = []; // Jahresstatistik
  List<Map<String, dynamic>> dailyData = []; // Tagesstatistik

  // Filter für die Tagesstatistik
  DateTime? fromDate; // Startdatum
  DateTime? toDate; // Enddatum

  // Pagination
  int currentPage = 0; // Aktuelle Seite
  final int itemsPerPage = 40; // Anzahl der Elemente pro Seite
  @override
  void initState() {
    super.initState();
    _loadYearlyData(); // Standardmäßig wird die Jahresstatistik geladen
  }

  Future<void> _loadYearlyData() async {
    try {
      if (widget.database.connection.isClosed) {
        widget.database.connectToDatabase();
      }
      yearlyData = await widget.database.fetchYearlyStatistics();
      setState(() {});
    } catch (e) {
      print("Fehler beim Laden der Jahresdaten: $e");
    }
  }

  Future<void> _loadDailyData() async {
    try {
      // Verbindung zur Datenbank sicherstellen
      if (widget.database.connection.isClosed) {
        await widget.database.connectToDatabase();
      }

      // Daten abrufen: mit oder ohne Filter
      if (fromDate != null && toDate != null) {
        // Wenn ein Datum-Filter gesetzt ist
        dailyData = await widget.database.fetchDailyStatistics(
          startDate: fromDate,
          endDate: toDate,
        );
      } else if (fromDate != null && toDate == null) {
        // Wenn kein Filter gesetzt ist, alle Daten laden
        dailyData = await widget.database.fetchDailyStatistics(
          startDate: fromDate,
        );
      } else if (fromDate == null && toDate != null){
        dailyData = await widget.database.fetchDailyStatistics(
          endDate: toDate,
        );
      } else {
        dailyData = await widget.database.fetchDailyStatistics();
      }
      setState(() {});
    } catch (e) {
      print("Fehler beim Laden der Tagesdaten: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Gesamtstatistik"),
          centerTitle: true,
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Umschalter für Jahres-/Tagesstatistik
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () async {
                      setState(() {
                        isYearly = true;
                        _loadYearlyData();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isYearly ? Colors.red : Colors.grey,
                      foregroundColor: Colors.white, // Textfarbe
                    ),
                    child: Text('Jahresstatistik'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isYearly = false;
                        _loadDailyData();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !isYearly ? Colors.red : Colors.grey,
                      foregroundColor: Colors.white, // Textfarbe
                    ),
                    child: Text('Tagesstatistik'),
                  ),
                ],
              ),
              if (isYearly) _buildYearlyToggleButton(),
//              if (!isYearly) _buildDateFilter(),
              Expanded(
                child: isYearly ? _buildYearlyView() : _buildDailyView(),
              ),
            ],
          ),
        )
    );
  }

  Widget _buildDateFilter() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () async {
              DateTimeRange? pickedRange = await showDateRangePicker(
                context: context,
                initialDateRange: fromDate != null && toDate != null
                    ? DateTimeRange(start: fromDate!, end: toDate!)
                    : null,
                firstDate: DateTime(2000), // Anfangsdatum festlegen
                lastDate: DateTime.now().add(Duration(days: 365 * 10)), // Zukünftige Jahre erlauben
              );

              if (pickedRange != null) {
                setState(() {
                  fromDate = pickedRange.start;
                  toDate = pickedRange.end;
                  _loadDailyData();
                });
              }
            },
            child: Text(
              fromDate == null || toDate == null
                  ? 'Zeitraum wählen'
                  : 'Von: ${fromDate!.toLocal().toIso8601String().substring(0, 10)} '
                  'bis: ${toDate!.toLocal().toIso8601String().substring(0, 10)}',
            ),
          ),
          ElevatedButton(
            onPressed: _resetDateFilter,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Farbe des Buttons
              foregroundColor: Colors.white,
            ),
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }

  /// Funktion zum Zurücksetzen des Datumsfilters
  void _resetDateFilter() {
    setState(() {
      fromDate = null;
      toDate = null;
      _loadDailyData(); // Initialabfrage durchführen
    });
  }

  Widget _buildYearlyToggleButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      // Abstand oben und unten
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        // Button am rechten Rand platzieren
        children: [
          TextButton(
            onPressed: () {
              setState(() {
                showPercentage = !showPercentage;
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red, // Textfarbe
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Runde Ecken
              ),
            ),
            child: Text(
              showPercentage ? 'Zeige absolute Werte' : 'Zeige Prozentwerte',
              style: const TextStyle(fontSize: 14,
                  fontWeight: FontWeight.bold), // Styling des Textes
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildDailyView() {
    // Berechnung der aktuellen Anzahl an Seiten basierend auf itemsPerPage
    final int pageCount = (dailyData.length / itemsPerPage).ceil();

    return Column(
      children: [
        // Filter für Datumsauswahl
        _buildDateFilter(),
        if (dailyData.isEmpty)
          Expanded(
            child: Center(
              child: Text('Daten werden geladen.'),
            ),
          )
        else
          Expanded(
            child: Column(
              children: [
                // Tabelle mit den täglichen Daten
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Datum')),
                          DataColumn(label: Text('Batterie 100%')),
                          DataColumn(label: Text('Boiler > 100°C')),
                        ],
                        rows: dailyData
                            .skip(currentPage * itemsPerPage)
                            .take(itemsPerPage)
                            .map((data) {
                          bool batteryReached = double.parse(data['batterie_status']) == 100;
                          bool boilerExceeded = (data['boiler_temp']) > 100;

                          return DataRow(cells: [
                            // Datum anzeigen
                            DataCell(Text(
                                '${data['Tag'].toString().padLeft(2, '0')}.${data['Monat'].toString().padLeft(2, '0')}.${data['Jahr']}')),
                            // Batterie Status: Haken oder X
                            DataCell(Row(
                              children: [
                                batteryReached
                                    ? Icon(Icons.check, color: Colors.green) // Grüner Haken
                                    : Icon(Icons.close, color: Colors.red), // Rotes X
                              ],
                            )),
                            // Boiler Status: Haken oder X
                            DataCell(Row(
                              children: [
                                boilerExceeded
                                    ? Icon(Icons.check, color: Colors.green) // Grüner Haken
                                    : Icon(Icons.close, color: Colors.red), // Rotes X
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                // Pagination Steuerung
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: currentPage > 0
                          ? () {
                        setState(() {
                          currentPage--;
                        });
                      }
                          : null,
                      icon: Icon(Icons.arrow_back),
                    ),
                    Text('Seite ${currentPage + 1} von $pageCount'),
                    IconButton(
                      onPressed: currentPage < pageCount - 1
                          ? () {
                        setState(() {
                          currentPage++;
                        });
                      }
                          : null,
                      icon: Icon(Icons.arrow_forward),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }


  Widget _buildYearlyView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Jahr')),
          DataColumn(label: Text('Batterie >= 100%')),
          DataColumn(label: Text('Boiler > 100°C')),
        ],
        rows: yearlyData.map((data) {
          int year = data['Jahr'];
          int daysInYear = isLeapYear(year) ? 366 : 365;
          return DataRow(cells: [
            DataCell(Text('${data['Jahr']}')),
            DataCell(Text(showPercentage
                ? '${(data['anzahl_batterie_100'] / daysInYear * 100)
                .toStringAsFixed(2)}%'
                : '${data['anzahl_batterie_100']} / $daysInYear')),
            DataCell(Text(showPercentage
                ? '${(data['anzahl_boiler_ueber_140'] / daysInYear * 100)
                .toStringAsFixed(2)}%'
                : '${data['anzahl_boiler_ueber_140']} / $daysInYear')),
          ]);
        }).toList(),
      ),
    );
  }

  /// Funktion zur Prüfung, ob ein Jahr ein Schaltjahr ist
  bool isLeapYear(int year) {
    if (year % 4 == 0) {
      if (year % 100 == 0) {
        return year % 400 == 0; // Nur Schaltjahr, wenn auch durch 400 teilbar
      }
      return true; // Durch 4 teilbar, aber nicht durch 100
    }
    return false; // Kein Schaltjahr
  }
}
