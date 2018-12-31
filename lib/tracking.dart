import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'my_inherited_widget.dart';
import 'root_drawer.dart';
import 'google_maps.dart';

class Tracking extends StatefulWidget {
  Tracking({Key key}) : super(key: key);

  @override
  State createState() => TrackingState();
}

class TrackingState extends State<Tracking> {
  @override
  Widget build (BuildContext context) {
    return MyInheritedWidget(
      child: Scaffold(
        appBar: AppBar(
          title: FittedBox(
            fit: BoxFit.contain,
            child: Text('Higher Soaring')
          ),
        ),
        body: Builder(
          builder: (BuildContext context) {
            final state = MyInheritedWidget.of(context);
            state.setPositionStream();
            return GoogleMaps(center: state.myLocation ?? LatLng(-23.5614909,-46.6560097), polylines: _calculatePolylines(state.positions), clearAll: true);
          }
        ),
        drawer: RootDrawer(),
      ),
    );
  }

  List<List<LatLng>> _calculatePolylines(List<Position> positions) {
    return [positions.map((position) => LatLng(position.latitude, position.longitude)).toList()];
  }
}