import 'package:flutter/material.dart';

class Index extends StatelessWidget {
  Index({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(fit: BoxFit.contain, child: Text('Higher Soaring')),
      ),
      body: Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                flex: 5,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/altitude'),
                  child: Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flexible(
                          child: Image.asset('assets/glider1.jpg',
                              fit: BoxFit.fitWidth,
                              width: MediaQuery.of(context).size.width),
                        ),
                        Padding(
                          child: Text('See safety altitudes'),
                          padding: const EdgeInsets.all(10.0),
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.all(14.0),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/flight-track'),
                  child: Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flexible(
                          child: Image.asset('assets/glider2.jpg',
                              fit: BoxFit.fitWidth,
                              width: MediaQuery.of(context).size.width),
                        ),
                        Padding(
                          child: Text('Track my flight'),
                          padding: const EdgeInsets.all(10.0),
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.all(14.0),
                  ),
                ),
              ),
            ]),
      ),
    );
  }
}
