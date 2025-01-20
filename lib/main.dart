import 'package:flutter/material.dart';
import 'postgresDatabase.dart';
import 'stock_screen.dart';
import 'stock_screen_v2.dart';
import 'stock_screen_v3.dart';
import 'Gesamtstatistik.dart';
import 'ToggleItem.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Für asynchrone Initialisierung notwendig
  final database = PostgresDatabase();
  await database.connectToDatabase().timeout(Duration(seconds: 20)); // Datenbank direkt beim Start initialisieren
  runApp(MyApp(database: database));
}

class MyApp extends StatelessWidget {
  final PostgresDatabase database;

  MyApp({required this.database});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Main Screen',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MainScreen(database: database),
    );
  }
}

class MainScreen extends StatelessWidget {
  final PostgresDatabase database;

  MainScreen({required this.database});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: AppDrawer(database: database),
      body: Column(
        children: [
          ToggleItem(
            icon: Icons.water,
            label: "Wasser",
            onTap: () {},
          ),
          ToggleItem(
            icon: Icons.bolt, // Placeholder for PV icon
            label: "Strom (PV)",
            onTap: () {},
          ),
          ToggleItem(
            icon: Icons.battery_full, // Placeholder for Batterie icon
            label: "Strom (Batterie)",
            onTap: () {},
          ),
          ToggleItem(
            icon: Icons.lightbulb, // Placeholder for Boiler icon
            label: "Boiler",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StockScreenV3(database: database)),
              );
            },
          ),
          ToggleItem(
            icon: Icons.thermostat, // Placeholder for Heizung icon
            label: "Heizung",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StockScreenV2(database: database)),
              );
            },
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) => Icon(Icons.circle, size: 10, color: Colors.grey[400])),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  final PostgresDatabase database;

  AppDrawer({required this.database});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.grey[300],
            ),
            child: Text('Menu', style: TextStyle(fontSize: 24)),
          ),
          ListTile(
            title: Text('Text -> Funktion 1'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Divider(),
          ListTile(
            title: Text('Text 2 -> Funktion 2'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Divider(),
          ListTile(
            title: Text('Erweiterte Statistik'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GesamtstatistikScreen(database: database),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
