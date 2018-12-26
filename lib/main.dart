import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:latlong/latlong.dart' as lat_lng;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'dart:async';

var f = new NumberFormat("#,##0", "en_US");

void main() {
  //Future<Map<PermissionGroup, PermissionStatus>> permissions = PermissionHandler().requestPermissions([PermissionGroup.location]);
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

  final lat_lng.Distance distance = lat_lng.Distance();
  final p1 = lat_lng.LatLng(-22.4291879,-47.5618677);

  final headings = List<double>.generate(361, (i) => 1.0 * i);

  List<GlideParameters> glideParameters;

  var windDirection = GlideParameters("Wind Direction", Icons.cloud_queue, 0.0, 0.0, 359.0, 360, "º");
  var windSpeed = GlideParameters("Wind Speed", Icons.arrow_forward, 0.0, 0.0, 15.0, 15, "m/s");
  var glideSpeed = GlideParameters("Best Glide", Icons.local_airport, 85.0, 70.0, 100.0, 30, "km/h");
  var glideRatio = GlideParameters("Glide Ratio", Icons.flight_land, 27.0, 25.0, 40.0, 15, ":1");

  var geolocator = Geolocator();
  Position _position;
  GoogleMapController mapController;

  Stream<Position> getCurrentPosition() {
    var locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
    final Stream<Position> positionStream = Geolocator().getPositionStream(locationOptions);
    StreamSubscription<Position> _positionStreamSubscription = positionStream.listen((Position position) => setState(() => _position = position));
  }

  @override
  void initState() {
    super.initState();
    getCurrentPosition();
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
            onPressed: altitude > 500 ? _decrementAltitude : null,
          ),
          Center(
          child: Text("${altitude.toString()}m", textAlign: TextAlign.center,)
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios),
            tooltip: 'Forward',
            onPressed: _incrementAltitude,
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
                onMapCreated: _onMapCreated,
                options: GoogleMapOptions(
                  myLocationEnabled: true,
                  mapType: MapType.hybrid,
                  cameraPosition: CameraPosition(
                    target: LatLng(-22.4291879,-47.5618677),
                    zoom: 12.0,
                  ),
                ),
              ),
            ),
          ]
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
                accountName: Text(
                  "Bernardo Srulzon",
                  style: TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.w500),
                )),
            SwitchListTile(
              title: Text('Flight mode'),
              value: _flightMode,
              onChanged: (bool value) { setState(() { _flightMode = value; }); },
              secondary: Icon(Icons.flight),
            ),
            SwitchListTile(
              title: Text('Show controls'),
              value: _showControls,
              onChanged: (bool value) { setState(() { _showControls = value; }); },
              secondary: Icon(Icons.settings),
            ),
          ]
        ),
      ),
    );
  }

  String _locationData(type) {
    if(_position == null) {
      return "Unknown!";
    }

    if(type == 'latlon') {
      return _position.toString();
    }
    else if(type == 'altitude') {
      return "Altitude: ${_position?.altitude?.toStringAsFixed(0)}m";
    }
  }

  _flightStatus() {
    if(_position == null) {
      return FlightStatus("Warning", Icons.warning, Colors.amber, "Unable to fetch position. Stay alert :)");
    }

    var heading = glideHeading(LatLng(-22.4291879,-47.5618677), LatLng(_position.latitude, _position.longitude));
    var maximumGlidingDistance = glideDistance(heading, windDirection.value, windSpeed.value, glideSpeed.value, glideRatio.value, _position.altitude.round(), patternAltitude);
    var distanceToRunway = distance.as(lat_lng.LengthUnit.Meter, lat_lng.LatLng(-22.4291879,-47.5618677), lat_lng.LatLng(_position.latitude, _position.longitude));

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
      altitude += 100;
      _onMapCreated(mapController);
  }

  void _decrementAltitude() {
      altitude -= 100;
      _onMapCreated(mapController);
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;

      final List<LatLng> points = [];

      headings.forEach((hdg) {
        var distanceToGlide = glideDistance(hdg, windDirection.value, windSpeed.value, glideSpeed.value, glideRatio.value, altitude, patternAltitude);
        var p2 = distance.offset(p1, distanceToGlide, hdg);
        points.add(LatLng(p2.latitude, p2.longitude));
      });

      _addPolyline(points);

    });
  }

  void _addPolyline(points) async {
    await mapController.clearPolylines();
    await mapController.addPolyline(
        PolylineOptions(
            width: 5,
            points: points,
            geodesic: false,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            color: Colors.indigoAccent.value
        )
    );
  }

  double toRadians(double angle) {
    return angle * math.pi / 180.0;
  }

  double toDegrees(double angle) {
    return angle * 180.0 / math.pi;
  }

  double toMetersPerSecond(speed) {
    return speed / 3.6;
  }

  double glideDistance(double course, double windDirection, double windSpeed, double glideSpeed, double glidePerformance, int altitude, int patternAltitude) {
    course = toRadians(course);
    windDirection = toRadians(windDirection);
    glideSpeed = toMetersPerSecond(glideSpeed);
    var verticalSpeed = - glideSpeed / glidePerformance;
    var descentTime = (altitude - patternAltitude) / verticalSpeed.abs();
    var windToTrack = course - windDirection;
    var windCorrectionAngle = windSpeed * math.sin(windToTrack) / glideSpeed;
    var groundSpeed = glideSpeed * math.cos(windCorrectionAngle) + windSpeed * math.cos(windToTrack);
    return groundSpeed * descentTime;
  }

  double glideHeading(LatLng p1, LatLng p2) {
    var lat1 = toRadians(p1.latitude);
    var lat2 = toRadians(p2.latitude);
    var lon1 = toRadians(p1.longitude);
    var lon2 = toRadians(p2.longitude);

    var y = math.sin(lon2-lon1) * math.cos(lat2);
    var x = math.cos(lat1)*math.sin(lat2) - math.sin(lat1)*math.cos(lat2)*math.cos(lon2-lon1);
    return toDegrees(math.atan2(y, x));
  }

}

class GlideParameters {
  String name;
  IconData icon;
  double value;
  double min;
  double max;
  int divisions;
  String unit;

  GlideParameters(this.name, this.icon, this.value, this.min, this.max, this.divisions, this.unit);
}

class FlightStatus {
  String status;
  IconData icon;
  MaterialColor color;
  String distanceAdvisory;

  FlightStatus(this.status, this.icon, this.color, this.distanceAdvisory);
}

/*ListView(
children: <Widget>[
Text(_locationData('latlon')),
Text(_locationData('altitude')),
Text(_locationData('heading')),
],
),*/