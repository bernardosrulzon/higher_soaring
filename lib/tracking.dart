import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
    return MyHome(
      appBar: _buildAppBar(),
      body: Column(
        children: <Widget>[
          Expanded(child: TrackingMap()),
          Container(child: AltitudeChart(animate: true),
          height: MediaQuery.of(context).size.height * 0.2),
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
}

class TrackingMap extends StatelessWidget {
  TrackingMap({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = MyInheritedWidget.of(context);
    state.setPositionStream();
    return GoogleMaps(
        center: state.myLocation ?? LatLng(-23.5614909, -46.6560097),
        polylines: _calculatePolylines(state.positions),
        clearAll: true);
  }

  List<List<LatLng>> _calculatePolylines(List positions) {
    return [
      positions
          .map(
              (position) => LatLng(position[1].latitude, position[1].longitude))
          .toList()
    ];
  }
}
