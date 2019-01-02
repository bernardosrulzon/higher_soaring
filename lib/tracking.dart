import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'my_inherited_widget.dart';
import 'my_home.dart';
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
    return MyHome(
      appBar: _buildAppBar(),
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
    print(chartData);
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
        clearAll: true);
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
