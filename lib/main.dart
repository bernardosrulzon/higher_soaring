import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong/latlong.dart' as lat_lng;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import 'dart:async';

import 'airport.dart';
import 'glide_parameters.dart';
import 'flight_status.dart';

var f = NumberFormat("#,##0", "en_US");

void main() {
  runApp(MaterialApp(
    title: 'Higher Soaring',
    theme: ThemeData(
      primarySwatch: Colors.indigo,
    ),
    home: Altitude(),
  ));
}

class Altitude extends StatefulWidget {
  Altitude({Key key}) : super(key: key);

  @override
  State createState() => AltitudeState();
}

class AltitudeState extends State<Altitude> {
  int altitude = 500;
  final patternAltitude = 400;

  bool _flightMode = false;
  bool _showControls = true;
  bool _plotAllAltitudes = false;

  final lat_lng.Distance distance = lat_lng.Distance();
  final p1 = lat_lng.LatLng(-22.4291879,-47.5618677);

  final headings = List<double>.generate(37, (i) => 10.0 * i);

  Airport airport = Airport("Rio Claro", "SDRK", 619, LatLng(-22.4291879,-47.5618677));

  List<GlideParameters> glideParameters;

  var windDirection = GlideParameters("Wind Direction", Icons.cloud_queue, 0.0, 0.0, 360.0, 72, "º");
  var windSpeed = GlideParameters("Wind Speed", Icons.arrow_forward, 0.0, 0.0, 15.0, 15, "m/s");
  var glideSpeed = GlideParameters("Best Glide", Icons.local_airport, 85.0, 70.0, 100.0, 30, "km/h");
  var glideRatio = GlideParameters("Glide Ratio", Icons.flight_land, 27.0, 25.0, 40.0, 15, ":1");

  var geolocator = Geolocator();
  StreamSubscription<Position> _positionStreamSubscription;
  final locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
  Position _position;

  GoogleMapController mapController;

  setPositionStream() {
    final Stream<Position> positionStream = Geolocator().getPositionStream(locationOptions);
    _positionStreamSubscription = positionStream.listen((Position position) => setState(() => _position = position));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    glideParameters ??= [
      windDirection, windSpeed, glideSpeed, glideRatio
    ];
    var variableToUse = glideParameters[0];

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(fit: BoxFit.contain, child: Text('Higher Soaring')),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back_ios),
            tooltip: 'Back',
            onPressed: altitude > 500 && !_plotAllAltitudes ? _decrementAltitude : null,
          ),
          Center(
          child: Text("${altitude.toString()}m", textAlign: TextAlign.center,)
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios),
            tooltip: 'Forward',
            onPressed: !_plotAllAltitudes ? _incrementAltitude : null,
          )
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget> [
            Visibility(
              visible: _showControls,
              child: Container(
                margin: EdgeInsets.only(left: 7.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(variableToUse.icon),
                    ),
                    Text(variableToUse.name),
                    Expanded(
                      child: Slider(
                        activeColor: Colors.indigoAccent,
                        min: variableToUse.min,
                        max: variableToUse.max,
                        divisions: variableToUse.divisions,
                        value: variableToUse.value,
                        onChanged: (newValue) => _dataChanged(newValue, variableToUse),
                      ),
                    ),
                    Center(
                      child: Text("${variableToUse.value.toStringAsFixed(0)}${variableToUse.unit}")
                    ),
                    IconButton(
                      icon: Icon(Icons.swap_horiz),
                      onPressed: () => _swapVariable(glideParameters),
                    )
                  ]
                ),
              ),
            ),
            Visibility(
              visible: _flightMode,
              child: Container(
                margin: EdgeInsets.only(left: 7.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(_flightStatus().icon, color: _flightStatus().color),
                    ),
                    Text("${_flightStatus().status} ${_flightStatus().distanceAdvisory}"),
                  ]
                ),
              ),
            ),
            Flexible(
              child: GoogleMap(
                onMapCreated: (controller) => _onMapCreated(controller),
                options: GoogleMapOptions(
                  myLocationEnabled: true,
                  mapType: MapType.hybrid,
                  cameraPosition: CameraPosition(
                    target: airport.coordinates,
                    zoom: 12.0,
                  ),
                ),
              ),
            ),
          ]
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
                accountName: Text(
                  "Bernardo Srulzon",
                  style: TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.w500),
                ),
                accountEmail: Text(
                  "bernardosrulzon@gmail.com",
                  style: TextStyle(
                      fontSize: 14.0, fontWeight: FontWeight.w300),
                )),
            SwitchListTile(
              title: Text("I'm flying!"),
              value: _flightMode,
              onChanged: (bool value) => _flightModeToggle(value),
              secondary: Icon(Icons.flight_takeoff),
            ),
            SwitchListTile(
              title: Text('Show controls'),
              value: _showControls,
              onChanged: (bool value) { setState(() { _showControls = value; }); },
              secondary: Icon(Icons.settings),
            ),
            SwitchListTile(
              title: Text('Plot all altitudes'),
              value: _plotAllAltitudes,
              onChanged: (bool value) => _allAltitudesToggle(value),
              secondary: Icon(Icons.all_inclusive),
            ),
            ListTile(
              leading: Icon(Icons.local_airport),
              title: Text('Data for ${airport.icao}'),
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Coordinates'),
              subtitle: Text(_locationData('latlon')),
            ),
            ListTile(
              leading: Icon(Icons.navigation),
              title: Text('Altitude'),
              subtitle: Text("MSL: ${_locationData('altitude')}\nAGL: ${_locationData('height')}"),
            ),
            ListTile(
              leading: Icon(_positionStreamSubscription == null || _positionStreamSubscription.isPaused ? Icons.gps_off : Icons.gps_fixed),
              title: Text('Location updates'),
              subtitle: Text(_positionStreamSubscription == null || _positionStreamSubscription.isPaused ? 'Disabled' : 'Enabled'),
            ),
          ]
        ),
      ),
    );
  }

  void _allAltitudesToggle(value) {
    setState(() {
      _plotAllAltitudes = value;
      _onMapCreated(mapController);
    });
  }

  void _flightModeToggle(value) {
    setState(() {
      _flightMode = value;

      if(value) {
        if (_positionStreamSubscription == null) {
          setPositionStream();
        }
        _positionStreamSubscription.resume();
      }
      else if (_positionStreamSubscription != null) {
        _positionStreamSubscription.pause();
      }
    });
  }

  String _locationData(type) {
    if (_position == null) {
      return "Unknown!";
    }

    if (type == 'latlon') {
      return "Latitude: ${_position.latitude.toStringAsFixed(4)}\nLongitude: ${_position.longitude.toStringAsFixed(4)}";
    }
    else {
      if (_position.altitude == null) {
        return "Unknown!";
      }
      else if (type == 'altitude') {
        return "${_position?.altitude?.toStringAsFixed(0)}m";
      }
      else if (type == 'height') {
        return "${(_position.altitude - airport.altitudeInMeters).toStringAsFixed(0)}m";
      }
    }
  }

  _flightStatus() {
    if(_position?.altitude == null || (_position.altitude - airport.altitudeInMeters) < 0) {
      return FlightStatus("Warning!", Icons.warning, Colors.amber, "Unable to fetch position or altitude");
    }

    var heading = glideHeading(airport.coordinates, LatLng(_position.latitude, _position.longitude));
    var maximumGlidingDistance = glideDistance(heading, windDirection.value, windSpeed.value, glideSpeed.value, glideRatio.value, (_position.altitude - airport.altitudeInMeters).round(), patternAltitude);
    var distanceToRunway = distance.as(lat_lng.LengthUnit.Meter, lat_lng.LatLng(airport.coordinates.latitude,airport.coordinates.longitude), lat_lng.LatLng(_position.latitude, _position.longitude));

    if(maximumGlidingDistance > distanceToRunway) {
      return FlightStatus("Good!", Icons.check_circle, Colors.green, "You still have an additional ${f.format((maximumGlidingDistance - distanceToRunway).round())}m");
    }
    else {
      return FlightStatus("Ooops!", Icons.alarm, Colors.red, "You're missing ${f.format((distanceToRunway - maximumGlidingDistance).round())}m");
    }
  }

  void _dataChanged(newValue, variableToUse) {
    setState(() {
      variableToUse.value = newValue;
    });
    _onMapCreated(mapController);
  }

  void _swapVariable(glideParameters) {
    setState(() {
      glideParameters.add(glideParameters.removeAt(0));
    });
  }

  void _incrementAltitude() {
      setState(() {
        altitude += 100;
      });
      _onMapCreated(mapController);
  }

  void _decrementAltitude() {
      setState(() {
        altitude -= 100;
      });
      _onMapCreated(mapController);
  }

  void _onMapCreated(GoogleMapController controller) async {
    List<int> altitudes;
    List<LatLng> points;

    if (mapController == null) {
      mapController = controller;
    }

    await mapController.clearPolylines();

    if (_plotAllAltitudes) {
      altitudes = List<int>.generate(5, (i) => 500 + 100 * i);
    }
    else {
      altitudes = [altitude];
    }

    altitudes.forEach((alt) {
      points = [];
      headings.forEach((hdg) {
        var distanceToGlide = glideDistance(hdg, windDirection.value, windSpeed.value, glideSpeed.value, glideRatio.value, alt, patternAltitude);
        var p2 = distance.offset(p1, distanceToGlide, hdg);
        points.add(LatLng(p2.latitude, p2.longitude));
      });
      _addPolyline(points);
    });
  }

  _addPolyline(List<LatLng> points) {
    mapController.addPolyline(
      PolylineOptions(
          width: 5,
          points: points,
          geodesic: false,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: 2,
          color: Colors.indigoAccent.value
      )
    );
  }

}
