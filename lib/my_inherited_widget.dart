import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dart:async';
import 'airport.dart';
import 'app_database.dart';

class _MyInherited extends InheritedWidget {
  _MyInherited({Key key, @required this.data, Widget child})
      : super(key: key, child: child);

  final MyInheritedWidgetState data;

  @override
  bool updateShouldNotify(_MyInherited old) {
    return old.hashCode != this.hashCode;
  }
}

class MyInheritedWidget extends StatefulWidget {
  MyInheritedWidget({
    Key key,
    this.child,
  }) : super(key: key);

  final Widget child;

  @override
  MyInheritedWidgetState createState() => new MyInheritedWidgetState();

  static MyInheritedWidgetState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_MyInherited) as _MyInherited)
        .data;
  }
}

class MyInheritedWidgetState extends State<MyInheritedWidget> {
  StreamSubscription<Position> _positionStreamSubscription;
  final Stream<Position> _positionStream = Geolocator().getPositionStream(
      LocationOptions(accuracy: LocationAccuracy.best, distanceFilter: 5));
  List _positions = [];

  final Airport _airport =
      Airport("Rio Claro", "SDRK", 619, LatLng(-22.4291879, -47.5618677));
  bool _trackMyFlight = false;
  bool _flightMode = false;
  bool _showControls = true;
  bool _showAllAltitudes = false;
  int _altitude = 500;

  bool get trackMyFlight => _trackMyFlight;
  Airport get airport => _airport;
  bool get flightMode => _flightMode;
  bool get showControls => _showControls;
  bool get showAllAltitudes => _showAllAltitudes;
  get positionStream => _positionStream;
  get positionStreamSubscription => _positionStreamSubscription;
  int get altitude => _altitude;

  get positions => _positions;

  get position {
    return _positions.isNotEmpty ? _positions.last : null;
  }

  LatLng get myLocation {
    if (_positions.isNotEmpty) {
      var position = _positions.last;
      return LatLng(position['latitude'], position['longitude']);
    }
    return null;
  }

  double get myAltitude {
    return _positions.isNotEmpty ? _positions.last['altitude'] : null;
  }

  double get myHeight {
    return _positions.isNotEmpty ? _positions.last['altitude'] - _airport.altitudeInMeters : null;
  }

  set trackMyFlight(bool value) {
    setState(() {
      _trackMyFlight = value;
    });
  }

  set flightMode(bool value) {
    setState(() {
      _flightMode = value;
    });
  }

  set showControls(bool value) {
    setState(() {
      _showControls = value;
    });
  }

  set showAllAltitudes(bool value) {
    setState(() {
      _showAllAltitudes = value;
    });
  }

  @override
  void dispose() {
    cancelPositionStream();
    super.dispose();
  }

  void cancelPositionStream() {
    _positionStreamSubscription.cancel();
  }

  void incrementAltitude() {
    setState(() {
      _altitude += 100;
    });
  }

  void decrementAltitude() {
    setState(() {
      _altitude -= 100;
    });
  }

  _updatePositions() async {
    _positions = await AppDatabase().queryData("SELECT * FROM positions;");
    setState(() {});
  }

  void setPositionStream() {
    if (_positionStreamSubscription == null) {
      _positionStreamSubscription = _positionStream.listen((Position position) {
        if (position.altitude == null || position.altitude > 0.0) {
          AppDatabase().insertPositionData(
              DateTime.now().toString(),
              position.latitude,
              position.longitude,
              position.altitude,
              position.speed);
          _updatePositions();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _MyInherited(
      data: this,
      child: widget.child,
    );
  }
}
