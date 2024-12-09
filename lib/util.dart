import 'package:flutter/material.dart';

class StatisticsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> batteryData = [
    {'date': '03.11.24', 'status': true},
    {'date': '02.11.24', 'status': false},
    {'date': '01.11.24', 'status': true},
    {'date': '31.10.24', 'status': true},
    {'date': '30.10.24', 'status': false},
    {'date': '29.10.24', 'status': true},
    {'date': '28.10.24', 'status': false},

  ];

  String getMonthName(String date) {
    final month = date.split('.')[1];
    switch (month) {
      case '12':
        return 'Dezember';
      case '11':
        return 'November';
      case '10':
        return 'Oktober';
      case '09':
        return 'September';
      case '08':
        return 'August';
      case '07':
        return 'Juli';
      case '06':
        return 'Juni';
      case '05':
        return 'Mai';
      case '04':
        return 'April';
      case '03':
        return 'März';
      case '02':
        return 'Februar';
      case '01':
        return 'Jänner';
      default:
        return '';
    }
  }

  List<TableRow> buildBatteryTableRows() {
    List<TableRow> rows = [];
    String? currentMonth;

    rows.add(
      TableRow(
        children: [
          Center(child: Text('Datum', style: TextStyle(fontWeight: FontWeight.bold))),
          Center(child: Text('Batterie Status \n'
              '    >= 100%       ')),
        ],
      ),
    );


    for (var entry in batteryData) {
      final date = entry['date'];
      final status = entry['status'];
      final month = getMonthName(date);

      if (currentMonth != month) {
        currentMonth = month;
        rows.add(
          TableRow(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    month,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              Center(child: Text('')), // Empty cell for spacing
            ],
          ),
        );
      }

      rows.add(
        TableRow(
          children: [
            Center(child: Text(date)),
            Center(
              child: Icon(
                status ? Icons.check : Icons.close,
                color: status ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      );
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Batterie Statistik"),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(color: Colors.black),
                  children: buildBatteryTableRows(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
