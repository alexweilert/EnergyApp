import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class StockScreen extends StatefulWidget {
  @override
  _StockScreenState createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(() {
      setState(() {
        selectedTab = _tabController.index;
      });
    });
  }

  List<FlSpot> getChartData() {
    switch (selectedTab) {
      case 0: return [FlSpot(0, 198), FlSpot(3, 196), FlSpot(6, 200), FlSpot(9, 198), FlSpot(12, 199), FlSpot(15, 198), FlSpot(18, 196), FlSpot(21, 197), FlSpot(24, 198)];
      case 1: return [FlSpot(0, 195), FlSpot(1, 196), FlSpot(2, 198), FlSpot(3, 197), FlSpot(4, 196), FlSpot(5, 199)];
      case 2: return [FlSpot(0, 190), FlSpot(7, 192), FlSpot(15, 195), FlSpot(22, 198), FlSpot(30, 200)];
      case 3: return [FlSpot(0, 185), FlSpot(30, 188), FlSpot(60, 190), FlSpot(90, 195), FlSpot(120, 192), FlSpot(150, 195), FlSpot(180, 198)];
      case 4: return [FlSpot(0, 185), FlSpot(60, 190), FlSpot(120, 200), FlSpot(180, 198), FlSpot(240, 196), FlSpot(300, 195)];
      case 5: return [FlSpot(0, 180), FlSpot(60, 185), FlSpot(120, 190), FlSpot(180, 195), FlSpot(240, 192), FlSpot(300, 198), FlSpot(360, 200)];
      case 6: return [FlSpot(0, 175), FlSpot(60, 180), FlSpot(120, 185), FlSpot(180, 190), FlSpot(240, 195), FlSpot(300, 198), FlSpot(360, 200)];
      default: return [];
    }
  }

  String getTimeDescription() {
    switch (selectedTab) {
      case 0: return "1 Nov, 15:40:40";
      case 1: return "Last 5 Days";
      case 2: return "Last 1 Month";
      case 3: return "Last 6 Months";
      case 4: return "Year to Date";
      case 5: return "Last 1 Year";
      case 6: return "Last 6 Years";
      default: return "";
    }
  }

  double getInterval() {
    switch (selectedTab) {
      case 0: return 3;
      case 1: return 1;
      case 2: return 7;
      case 3: return 30;
      case 4: return 60;
      case 5: return 60;
      case 6: return 60;
      default: return 1;
    }
  }

  Widget getXAxisLabels(double value) {
    DateTime now = DateTime.now();
    switch (selectedTab) {
      case 0: return Text(DateFormat('HH:mm').format(now.add(Duration(hours: value.toInt()))), style: TextStyle(color: Colors.grey, fontSize: 10));
      case 1: return Text(DateFormat('d. MMM').format(now.add(Duration(days: value.toInt() - 5))), style: TextStyle(color: Colors.grey, fontSize: 10));
      case 2: return Text(DateFormat('d. MMM').format(now.subtract(Duration(days: (30 - value.toInt()) * 1))), style: TextStyle(color: Colors.grey, fontSize: 10));
      case 3: return Text(DateFormat('MMM').format(now.subtract(Duration(days: (180 - value.toInt()) * 1))), style: TextStyle(color: Colors.grey, fontSize: 10));
      case 4: return Text(DateFormat('MMM').format(now.subtract(Duration(days: (360 - value.toInt()) * 1))), style: TextStyle(color: Colors.grey, fontSize: 10));
      case 5: return Text(DateFormat('MMM').format(now.subtract(Duration(days: (360 - value.toInt()) * 1))), style: TextStyle(color: Colors.grey, fontSize: 10));
      case 6: return Text((now.year - (5 - (value / 60).toInt())).toString(), style: TextStyle(color: Colors.grey, fontSize: 10));
      default: return Text("");
    }
  }

  double getMinY() {
    double minY = getChartData().map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    double maxY = getChartData().map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    return minY - (maxY - minY) * 0.1;
  }

  double getMaxY() {
    double minY = getChartData().map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    double maxY = getChartData().map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    return maxY + (maxY - minY) * 0.1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Boiler"),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(getTimeDescription())]),
              ],
            ),
            SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.blueAccent,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blueAccent,
              tabs: [Tab(text: "1T"), Tab(text: "5T"), Tab(text: "1M"), Tab(text: "6M"), Tab(text: "YTD"), Tab(text: "1J"), Tab(text: "MAX")],
            ),
            SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: getChartData().last.x,
                    minY: getMinY(),
                    maxY: getMaxY(),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 35,
                          interval: getInterval(),
                          getTitlesWidget: (value, _) => getXAxisLabels(value),
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: (getMaxY() - getMinY()) / 4, // Ensure 5 labels (0 to 4 intervals)
                          getTitlesWidget: (value, _) => Text(value.toStringAsFixed(0), style: TextStyle(color: Colors.grey, fontSize: 10)),
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                        drawVerticalLine: false,
                        horizontalInterval: (getMaxY() - getMinY()) / 4),
                    lineBarsData: [
                      LineChartBarData(
                        spots: getChartData(),
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 2,
                        belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.2)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
//           Center(
//             child: ElevatedButton(
//               onPressed: () {
//                  Navigator.push(
//                    context,
//                    MaterialPageRoute(builder: (context) => BoilerStatisticsScreen()),
//                  );
//                },
//                child: Text("Boiler Statistik"),
//                style: ElevatedButton.styleFrom(
//                  backgroundColor: Colors.red,
//                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                ),
//              ),
//            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

/*
// Boiler Statistics Screen
class BoilerStatisticsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> boilerData = [
    {'date': '05.10.24', 'temperature': 70},
    {'date': '04.10.24', 'temperature': 65},
    {'date': '03.10.24', 'temperature': 72},
    {'date': '02.10.24', 'temperature': 68},
    {'date': '01.10.24', 'temperature': 75},
    {'date': '30.09.24', 'temperature': 69},
    {'date': '29.09.24', 'temperature': 71},
    {'date': '28.09.24', 'temperature': 23},
    {'date': '27.09.24', 'temperature': 42},
    {'date': '26.09.24', 'temperature': 80},
  ];

  String getMonthName(String date) {
    final month = date.split('.')[1];
    switch (month) {
      case '09':
        return 'September';
      case '10':
        return 'Oktober';
      case '11':
        return 'November';
      default:
        return '';
    }
  }

  final int thresholdTemperature = 70; // Threshold temperature in Celsius

  List<TableRow> buildBoilerTableRows() {
    List<TableRow> rows = [];
    String? currentMonth;
    rows.add(
      TableRow(
        children: [
          Center(child: Text('', style: TextStyle(fontWeight: FontWeight.bold))),
          Center(child: Text('Temperatur \n' + '   >= 70°C')),
        ],
      ),
    );

    for (var entry in boilerData) {
      final date = entry['date'];
      final temperature = entry['temperature'];
      final month = getMonthName(date);
      final isThresholdMet = temperature >= thresholdTemperature;

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
            Center(child: Icon(
              isThresholdMet ? Icons.check : Icons.close,
              color: isThresholdMet ? Colors.green : Colors.red,),
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
        title: Text("Boiler Statistik"),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Table(
            border: TableBorder.all(color: Colors.black),
            children: buildBoilerTableRows(),
          ),
        ),
      ),
    );
  }
}

 */