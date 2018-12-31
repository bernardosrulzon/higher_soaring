import 'package:flutter/material.dart';
import 'altitude.dart';
import 'tracking.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Higher Soaring',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      initialRoute: '/',
      routes: {
        '/': (BuildContext context) => Altitude(),
        '/flight-track': (BuildContext context) => Tracking(),
      }
    );
  }
}
