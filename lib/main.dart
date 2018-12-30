import 'package:flutter/material.dart';
import 'altitude.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Higher Soaring',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: Altitude(),
    );
  }
}

