import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'postgresDatabase.dart';

class StockScreenV2 extends StatefulWidget {
  final PostgresDatabase database;
  StockScreenV2({required this.database});

  @override
  _StockScreenStateV2 createState() => _StockScreenStateV2();
}

class _StockScreenStateV2 extends State<StockScreenV2> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int selectedTab = 0;

  List<Map<String, dynamic>> yearAllData = [];
  List<Map<String, dynamic>> yearData = [];
  List<Map<String, dynamic>> yearCurrentData = [];
  List<Map<String, dynamic>> month6Data = [];
  List<Map<String, dynamic>> monthData = [];
  List<Map<String, dynamic>> day5Data = [];
  List<Map<String, dynamic>> dayData = [];

  List<Map<String, dynamic>> yearAllDataB2 = [];
  List<Map<String, dynamic>> yearDataB2 = [];
  List<Map<String, dynamic>> yearCurrentDataB2 = [];
  List<Map<String, dynamic>> month6DataB2 = [];
  List<Map<String, dynamic>> monthDataB2 = [];
  List<Map<String, dynamic>> day5DataB2 = [];
  List<Map<String, dynamic>> dayDataB2 = [];

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

  List<FlSpot> getChartDataSecond() {
    switch (selectedTab) {
      case 0: return [FlSpot(0, 150), FlSpot(1.5, 150),  FlSpot(3, 196), FlSpot(6, 220), FlSpot(9, 198), FlSpot(12, 222), FlSpot(15, 170), FlSpot(18, 196), FlSpot(21, 190), FlSpot(24, 198)];
      case 1: return [FlSpot(0, 195), FlSpot(1, 196), FlSpot(2, 198), FlSpot(3, 197), FlSpot(4, 196), FlSpot(5, 199)];
      case 2: return [FlSpot(0, 190), FlSpot(7, 192), FlSpot(15, 195), FlSpot(22, 198), FlSpot(30, 200)];
      case 3: return [FlSpot(0, 185), FlSpot(30, 188), FlSpot(60, 190), FlSpot(90, 195), FlSpot(120, 192), FlSpot(150, 195), FlSpot(180, 198)];
      case 4: return [FlSpot(0, 185), FlSpot(60, 190), FlSpot(120, 200), FlSpot(180, 198), FlSpot(240, 196), FlSpot(300, 195)];
      case 5: return [FlSpot(0, 180), FlSpot(60, 185), FlSpot(120, 190), FlSpot(180, 195), FlSpot(240, 192), FlSpot(300, 198), FlSpot(360, 200)];
      case 6: return [FlSpot(0, 175), FlSpot(60, 180), FlSpot(120, 185), FlSpot(180, 190), FlSpot(240, 195), FlSpot(300, 198), FlSpot(360, 200)];
      default: return [];
    }
  }

  Future<void> _loadData() async {
    try {
      if (widget.database.connection.isClosed) {
        widget.database.connectToDatabase();
      }
      dayData = await widget.database.fetchDayChartData('boiler');
      day5Data = await widget.database.fetch5DaysChartData('boiler');
      monthData = await widget.database.fetchMonthChartData('boiler');
      month6Data = await widget.database.fetch6MonthChartData('boiler');
      yearCurrentData = await widget.database.fetchCurrentYearChartData('boiler');
      yearData = await widget.database.fetchYearChartData('boiler');
      yearAllData = await widget.database.fetchAllYearChartData('boiler');

      dayDataB2 = await widget.database.fetchDayChartData('boiler2');
      day5DataB2 = await widget.database.fetch5DaysChartData('boiler2');
      monthDataB2 = await widget.database.fetchMonthChartData('boiler2');
      month6DataB2 = await widget.database.fetch6MonthChartData('boiler2');
      yearCurrentDataB2 = await widget.database.fetchCurrentYearChartData('boiler2');
      yearDataB2 = await widget.database.fetchYearChartData('boiler2');
      yearAllDataB2 = await widget.database.fetchAllYearChartData('boiler2');
      setState(() {});
    } catch (e) {
      print("Fehler beim Laden der Jahresdaten: $e");
    }
  }

  List<FlSpot> convertToFlSpots(List<Map<String, dynamic>> data) {
    //if (data.length != 365) {
      //throw ArgumentError('The input list must contain exactly 365 entries.');
    //}

    return List<FlSpot>.generate(data.length, (index) {
      final temperature = data[index]['Temperature'];
      if (temperature is! double && temperature is! int) {
        throw ArgumentError(
          'Invalid temperature value at index $index: $temperature. It must be a number.',
        );
      }
      return FlSpot(index.toDouble(), temperature.toDouble());
    });
  }

  List<FlSpot> getChartDataFromDB() {
    List<FlSpot> result = [];
    _loadData();
    switch (selectedTab) {
      case 0:
        result = convertToFlSpots(dayData);
        return result;
      case 1:
        result = convertToFlSpots(day5Data);
        return result;
      case 2:
        result = convertToFlSpots(monthData);
        return result;
      case 3:
        result = convertToFlSpots(month6Data);
        return result;
      case 4:
        result = convertToFlSpots(yearCurrentData);
        return result;
      case 5:
        result = convertToFlSpots(yearData);
        return result;
      case 6:
        result = convertToFlSpots(yearAllData);
        return result;
      default:
        return [];
    }
  }

  List<FlSpot> getChartDataFromDBB2() {
    List<FlSpot> result = [];
    _loadData();
    switch (selectedTab) {
      case 0:
        result = convertToFlSpots(dayDataB2);
        return result;
      case 1:
        result = convertToFlSpots(day5DataB2);
        return result;
      case 2:
        result = convertToFlSpots(monthDataB2);
        return result;
      case 3:
        result = convertToFlSpots(month6DataB2);
        return result;
      case 4:
        result = convertToFlSpots(yearCurrentDataB2);
        return result;
      case 5:
        result = convertToFlSpots(yearDataB2);
        return result;
      case 6:
        result = convertToFlSpots(yearAllDataB2);
        return result;
      default:
        return [];
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
      case 0: return 12;
      case 1: return 96;
      case 2: return 7;
      case 3: return 30;
      case 4: return 62;
      case 5: return 62;
      case 6: return 62;
      default: return 1;
    }
  }

  Widget getXAxisLabels(double value) {
    DateTime now = DateTime.now();
    switch (selectedTab) {
      case 0: return Text(DateFormat('HH:mm').format(now.add(Duration(minutes: 15 * value.toInt()))), style: TextStyle(color: Colors.grey, fontSize: 10));
      case 1: return Text(DateFormat('d. MMM').format(now.add(Duration(minutes: 15 * value.toInt()))), style: TextStyle(color: Colors.grey, fontSize: 10));
      case 2: return Text(DateFormat('d. MMM').format(now.subtract(Duration(days: (30 - value.toInt()) * 1))), style: TextStyle(color: Colors.grey, fontSize: 10));
      case 3: return Text(DateFormat('MMM').format(now.subtract(Duration(days: (180 - value.toInt()) * 1))), style: TextStyle(color: Colors.grey, fontSize: 10));
      case 4: return Text(DateFormat('MMM').format(now.subtract(Duration(days: (360 - value.toInt()) * 1))), style: TextStyle(color: Colors.grey, fontSize: 10));
      case 5: return Text(DateFormat('MMM').format(now.subtract(Duration(days: (360 - value.toInt()) * 1))), style: TextStyle(color: Colors.grey, fontSize: 10));
      case 6: return Text((now.year - (5 - (value / 60).toInt())).toString(), style: TextStyle(color: Colors.grey, fontSize: 10));
      default: return Text("");
    }
  }

  double getMinY() {
    //Gets the smallest y-value form first Chart Data
    double minY = getChartDataFromDBB2().map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    double maxY = getChartDataFromDBB2().map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    //Gets the smallest y-value from second Chart Data
    double minY2 = getChartDataFromDB().map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    double maxY2 = getChartDataFromDB().map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    //Calculate a suitable minimum
    double result1 = minY - (maxY - minY) * 0.1;
    double result2 = minY2 - (maxY2 - minY2) * 0.1;
    //Checks which min is smaller and returns it
    if(result1 < result2) {
      return result1;
    }
    else {
      return result2;
    }
  }

  double getMaxY() {
    //Gets the biggest y-value form first Chart Data
    double minY = getChartDataFromDBB2().map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    double maxY = getChartDataFromDBB2().map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    //Gets the biggest y-value form second Chart Data
    double minY2 = getChartDataFromDB().map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    double maxY2 = getChartDataFromDB().map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    //Calculate a suitable maximum
    double result1 = maxY + (maxY - minY) * 0.1;
    double result2 = maxY2 + (maxY2 - minY2) * 0.1;
    //Checks which min is smaller and returns it
    if(result1 > result2) {
      return result1;
    }
    else {
      return result2;
    }
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
                    maxX: getChartDataFromDB().last.x,
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
                      //First Line
                      LineChartBarData(
                        spots: getChartDataFromDBB2(),
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 2,
                        belowBarData: BarAreaData(show: false, color: Colors.green.withOpacity(0.2)),
                        dotData: FlDotData(show: false), // Disable the dots
                      ),
                      //Second Line
                      LineChartBarData(
                        spots: getChartDataFromDB(),
                        isCurved: true,
                        color: Colors.red,
                        barWidth: 2,
                        belowBarData: BarAreaData(show: false, color: Colors.green.withOpacity(0.2)),
                        dotData: FlDotData(show: false), // Disable the dots
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      enabled: false, // Disable touch interaction
                    ),
                  ),
                ),
              ),
            ),
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
