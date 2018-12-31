import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dart:async';
import 'airport.dart';

class _MyInherited extends InheritedWidget {
  _MyInherited({Key key,
    @required this.data,
    Widget child})
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
  }): super(key: key);

  final Widget child;

  @override
  MyInheritedWidgetState createState() => new MyInheritedWidgetState();

  static MyInheritedWidgetState of(BuildContext context){
    return (context.inheritFromWidgetOfExactType(_MyInherited) as _MyInherited).data;
  }
}

class MyInheritedWidgetState extends State<MyInheritedWidget>{
  StreamSubscription<Position> _positionStreamSubscription;
  final locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
  Stream<Position> _positionStream;
  List<Position> positions = [];

  final Airport _airport = Airport("Rio Claro", "SDRK", 619, LatLng(-22.4291879,-47.5618677));
  bool _flightMode = false;
  bool _showControls = true;
  bool _showAllAltitudes = false;
  int _altitude = 500;

  Airport get airport => _airport;
  bool get flightMode => _flightMode;
  bool get showControls => _showControls;
  bool get showAllAltitudes => _showAllAltitudes;
  get positionStream => _positionStream;
  get positionStreamSubscription => _positionStreamSubscription;
  int get altitude => _altitude;

  Position get position {
    return positions.isNotEmpty ? positions.last : null;
  }

  LatLng get myLocation {
    if (positions.isNotEmpty) {
      var position = positions.last;
      return LatLng(position.latitude, position.longitude);
    }
    return null;
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

  void incrementAltitude() {
    setState((){
      _altitude += 100;
    });
  }

  void decrementAltitude() {
    setState((){
      _altitude -= 100;
    });
  }

  void setPositionStream() {
    final Stream<Position> _positionStream = Geolocator().getPositionStream(locationOptions);
    _positionStreamSubscription = _positionStream.listen((Position position) { setState(() { positions.add(position); }); });
  }

  @override
  Widget build(BuildContext context){
    return _MyInherited(
      data: this,
      child: widget.child,
    );
  }
}