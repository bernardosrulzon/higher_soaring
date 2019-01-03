import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'my_inherited_widget.dart';
import 'google_maps.dart';
import 'altitude_chart.dart';

class Tracking extends StatefulWidget {
  Tracking({Key key}) : super(key: key);

  @override
  State createState() => TrackingState();
}

class TrackingState extends State<Tracking> {
  @override
  Widget build(BuildContext context) {
    final state = MyInheritedWidget.of(context);
    state.setPositionStream();
    List<PositionTimeSeries> chartData = [];
    state.positions.forEach((position) {
      chartData.add(PositionTimeSeries(
          DateTime.parse(position['created_at']),
          (position['altitude'] - state.airport.altitudeInMeters),
          position['speed'] * 3.6,
          Colors.indigo));
    });
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: Column(
        children: <Widget>[
          Expanded(child: TrackingMap(positions: state.positions)),
          Container(
              child: Column(
                children: <Widget>[
                  Flexible(
                    child: AltitudeChart(
                        data: _getHeightTimeSeries(chartData),
                        animate: true,
                        title: 'Height',
                        unit: 'm'),
                  ),
                  Divider(),
                  Flexible(
                    child: AltitudeChart(
                        data: _getSpeedTimeSeries(chartData),
                        animate: true,
                        title: 'Speed',
                        unit: 'km/h'),
                  ),
                ],
              ),
              height: MediaQuery.of(context).size.height * 0.3),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Builder(builder: (BuildContext context) {
      final state = MyInheritedWidget.of(context);
      return Drawer(
        child: ListView(padding: const EdgeInsets.all(0.0), children: <Widget>[
          UserAccountsDrawerHeader(
              accountName: Text(
                "Bernardo Srulzon",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
              ),
              accountEmail: Text(
                "bernardosrulzon@gmail.com",
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300),
              )),
          ListTile(
            leading: Icon(Icons.arrow_back),
            title: Text('Take me back'),
            onTap: () => Navigator.popUntil(context, ModalRoute.withName('/')),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.navigation),
            title: Text('Altitude'),
            subtitle: Text(
                "MSL: ${state.myAltitude.round()}m\nAGL: ${state.myHeight.round()}m"),
          ),
          ListTile(
            leading: Icon(state.positionStreamSubscription == null ||
                    state.positionStreamSubscription.isPaused
                ? Icons.gps_off
                : Icons.gps_fixed),
            title: Text('Location updates'),
            subtitle: Text(state.positionStreamSubscription == null ||
                    state.positionStreamSubscription.isPaused
                ? 'Disabled'
                : 'Enabled'),
          ),
        ]),
      );
    });
  }

  _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: true,
      title: FittedBox(fit: BoxFit.contain, child: Text('Higher Soaring')),
    );
  }

  _getHeightTimeSeries(List<PositionTimeSeries> chartData) {
    return [
      charts.Series<PositionTimeSeries, DateTime>(
        id: 'Height Time Series',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (PositionTimeSeries data, _) => data.timestamp,
        measureFn: (PositionTimeSeries data, _) => data.altitude,
        data: chartData,
      )
    ];
  }

  _getSpeedTimeSeries(List<PositionTimeSeries> chartData) {
    return [
      charts.Series<PositionTimeSeries, DateTime>(
        id: 'Speed Time Series',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (PositionTimeSeries data, _) => data.timestamp,
        measureFn: (PositionTimeSeries data, _) => data.speed,
        data: chartData,
      )
    ];
  }
}

class TrackingMap extends StatelessWidget {
  TrackingMap({Key key, this.positions}) : super(key: key);

  final List positions;

  @override
  Widget build(BuildContext context) {
    final state = MyInheritedWidget.of(context);
    return GoogleMaps(
      center: state.myLocation ?? LatLng(-23.5614909, -46.6560097),
      polylines: _calculatePolylines(),
      clearAll: true,
      zoom: 16.0,
    );
  }

  List<List<LatLng>> _calculatePolylines() {
    return [
      positions
          .map(
              (position) => LatLng(position['latitude'], position['longitude']))
          .toList()
    ];
  }
}

class PositionTimeSeries {
  PositionTimeSeries(this.timestamp, this.altitude, this.speed, Color color)
      : this.color = new charts.Color(
            r: color.red, g: color.green, b: color.blue, a: color.alpha);

  final DateTime timestamp;
  final double altitude;
  final double speed;
  final charts.Color color;
}
