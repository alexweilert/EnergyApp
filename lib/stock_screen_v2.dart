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

  List<FlSpot> chart1DataMax = [];
  List<FlSpot> chart1Data1Year = [];
  List<FlSpot> chart1DataYearNow = [];
  List<FlSpot> chart1Data6Months = [];
  List<FlSpot> chart1Data1Month = [];
  List<FlSpot> chart1Data5Days = [];
  List<FlSpot> chart1Data1Day = [];

  List<FlSpot> chart2DataMax = [];
  List<FlSpot> chart2Data1Year = [];
  List<FlSpot> chart2DataYearNow = [];
  List<FlSpot> chart2Data6Months = [];
  List<FlSpot> chart2Data1Month = [];
  List<FlSpot> chart2Data5Days = [];
  List<FlSpot> chart2Data1Day = [];

  int currentYearMonthsCount = 0;
  int maxYearMonthsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(() {
      setState(() {
        selectedTab = _tabController.index;
      });
    });
  }

  Future<void> _loadData() async {
    try {
      if (widget.database.connection.isClosed) {
        widget.database.connectToDatabase();
      }
      dayData = await widget.database.fetchLast24HoursData('boiler');
      day5Data = await widget.database.fetchLast5DaysData('boiler');
      monthData = await widget.database.fetchMonthData('boiler');
      month6Data = await widget.database.fetch6MonthData('boiler');
      yearCurrentData = await widget.database.fetchCurrentYearlyData('boiler');
      yearData = await widget.database.fetchYearlyData('boiler');
      yearAllData = await widget.database.fetchYearlyMaxData('boiler');

      dayDataB2 = await widget.database.fetchLast24HoursData('boiler2');
      day5DataB2 = await widget.database.fetchLast5DaysData('boiler2');
      monthDataB2 = await widget.database.fetchMonthData('boiler2');
      month6DataB2 = await widget.database.fetch6MonthData('boiler2');
      yearCurrentDataB2 = await widget.database.fetchCurrentYearlyData('boiler2');
      yearDataB2 = await widget.database.fetchYearlyData('boiler2');
      yearAllDataB2 = await widget.database.fetchYearlyMaxData('boiler2');

      currentYearMonthsCount = await widget.database.countMonthsCurrentYear('boiler');
      maxYearMonthsCount = await widget.database.countMonthsMax('boiler');

      setState(() {});
      getFLSpotDataReady();
      setState(() {});
    } catch (e) {
      print("Fehler beim Laden der Jahresdaten: $e");
    }
  }

  List<FlSpot> convertToFlSpots(List<Map<String, dynamic>> data) {

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

  void getFLSpotDataReady() {
    chart1DataMax = convertToFlSpots(yearAllData);
    chart1Data1Year = convertToFlSpots(yearData);
    chart1DataYearNow = convertToFlSpots(yearCurrentData);
    chart1Data6Months = convertToFlSpots(month6Data);
    chart1Data1Month = convertToFlSpots(monthData);
    chart1Data5Days = convertToFlSpots(day5Data);
    chart1Data1Day = convertToFlSpots(dayData);

    chart2DataMax = convertToFlSpots(yearAllDataB2);
    chart2Data1Year = convertToFlSpots(yearDataB2);
    chart2DataYearNow = convertToFlSpots(yearCurrentDataB2);
    chart2Data6Months = convertToFlSpots(month6DataB2);
    chart2Data1Month = convertToFlSpots(monthDataB2);
    chart2Data5Days = convertToFlSpots(day5DataB2);
    chart2Data1Day = convertToFlSpots(dayDataB2);

    setState(() {});
  }


  List<FlSpot> getChartDataFromDB() {
    switch (selectedTab) {
      case 0:
        return chart1Data1Day;
      case 1:
        return chart1Data5Days;
      case 2:
        return chart1Data1Month;
      case 3:
        return chart1Data6Months;
      case 4:
        if (chart1DataYearNow.length == 1) {
          // Add a dummy point to create a flat line
          chart1DataYearNow.add(FlSpot(chart1DataYearNow[0].x + 1, chart1DataYearNow[0].y));
        }
        return chart1DataYearNow;
      case 5:
        return chart1Data1Year;
      case 6:
        return chart1DataMax;
      default:
        return [];
    }
  }

  List<FlSpot> getChartDataFromDBB2() {
    switch (selectedTab) {
      case 0:
        return chart2Data1Day;
      case 1:
        return chart2Data5Days;
      case 2:
        return chart2Data1Month;
      case 3:
        return chart2Data6Months;
      case 4:
        if (chart2DataYearNow.length == 1) {
          // Add a dummy point to create a flat line
          chart2DataYearNow.add(FlSpot(chart2DataYearNow[0].x + 1, chart2DataYearNow[0].y));
        }
        return chart2DataYearNow;
      case 5:
        return chart2Data1Year;
      case 6:
        return chart2DataMax;
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
    //regulates how many intervals are set through the x axis
    switch (selectedTab) {
      //96Inputs-15min interval
      case 0: return 12;
      //120Inputs-1h interval
      case 1: return 24;
      //30Inputs-7d interval
      case 2: return 7;
      //6Inputs-1m Interval
      case 3: return 1;
      //1-12Inputs-1m Interval
      case 4: return 2;
      //12Inputs-1y Interval
      case 5: return 2;
      //1-maxInputs-1m Interval
      case 6: return 12;
      default: return 1;
    }
  }

  Widget getXAxisLabels(double value) {
    DateTime now = DateTime.now();
    switch (selectedTab) {
      case 0: return Text(DateFormat('HH:mm').format(now.add(Duration(minutes: 15 * value.toInt()))), style: TextStyle(color: Colors.grey, fontSize: 10));
      case 1: return Text(DateFormat('d. MMM').format(now.subtract(Duration(minutes: 60 * (120 - value.toInt())))), style: TextStyle(color: Colors.grey, fontSize: 10));
      case 2: return Text(DateFormat('d. MMM').format(now.subtract(Duration(days: (28 - value.toInt())))), style: TextStyle(color: Colors.grey, fontSize: 10));
      case 3: return Text(DateFormat('MMM').format(now.subtract(Duration(days: 30 * (6 - value.toInt())))), style: TextStyle(color: Colors.grey, fontSize: 10));
      case 4: return Text(DateFormat('MMM').format(now.subtract(Duration(days: 30 * ((currentYearMonthsCount) - value.toInt())))), style: TextStyle(color: Colors.grey, fontSize: 10));
      case 5: return Text(DateFormat('MMM').format(now.subtract(Duration(days: 30 * (12- value.toInt())))), style: TextStyle(color: Colors.grey, fontSize: 10));
      case 6: return Text(DateFormat('y').format(now.subtract(Duration(days: 30 * ((maxYearMonthsCount-1)- value.toInt())))), style: TextStyle(color: Colors.grey, fontSize: 10));
      //case 6: return Text((now.year - (5 - (value / 60).toInt())).toString(), style: TextStyle(color: Colors.grey, fontSize: 10));
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
    double result1 = minY - (maxY - minY) * 0.1 - 5;
    double result2 = minY2 - (maxY2 - minY2) * 0.1 - 5;
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
    double result1 = maxY + (maxY - minY) * 0.1 +5;
    double result2 = maxY2 + (maxY2 - minY2) * 0.1+5;
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
        title: Text("Heizung"),
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
