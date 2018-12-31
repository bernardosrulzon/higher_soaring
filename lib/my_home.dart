import 'package:flutter/material.dart';
import 'root_drawer.dart';

class MyHome extends StatelessWidget {
  MyHome({Key key, this.appBar, this.body}) : super(key: key);

  final Widget appBar;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      drawer: RootDrawer(),
    );
  }
}