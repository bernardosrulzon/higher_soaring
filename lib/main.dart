import 'package:flutter/material.dart';
import 'altitude.dart';
import 'app_database.dart';
import 'index.dart';
import 'my_inherited_widget.dart';
import 'tracking.dart';

void main() async {
  await AppDatabase().setupDatabase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyInheritedWidget(
      child: MaterialApp(
          title: 'Higher Soaring',
          theme: ThemeData(
            primarySwatch: Colors.indigo,
          ),
          routes: {
            '/altitude': (BuildContext context) => Altitude(),
            '/flight-track': (BuildContext context) => Tracking(),
            '/': (BuildContext context)=> Index(),
          }),
    );
  }
}
