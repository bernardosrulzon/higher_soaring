import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong/latlong.dart' as lat_lng;
import 'package:quiver/core.dart';
import 'package:quiver/collection.dart';

import 'airport.dart';
import 'google_maps.dart';
import 'my_inherited_widget.dart';
import 'utils.dart';

class Altitude extends StatefulWidget {
  Altitude({Key key}) : super(key: key);

  @override
  State createState() => AltitudeState();
}

class AltitudeState extends State<Altitude> {
  List<GlideParameters> glideParameters;

  var windSpeed = GlideParameters(
      "Wind Speed", Icons.arrow_forward, 0.0, 0.0, 15.0, 15, "m/s");
  var windDirection = GlideParameters(
      "Wind Direction", Icons.cloud_queue, 0.0, 0.0, 360.0, 72, "º");
  var glideSpeed = GlideParameters(
      "Best Glide", Icons.local_airport, 85.0, 70.0, 100.0, 30, "km/h");
  var glideRatio = GlideParameters(
      "Glide Ratio", Icons.flight_land, 27.0, 25.0, 40.0, 15, ":1");
  final lat_lng.Distance distance = lat_lng.Distance();
  final int patternAltitude = 400;

  @override
  Widget build(BuildContext context) {
    glideParameters ??= [windSpeed, windDirection, glideSpeed, glideRatio];
    var variableToUse = glideParameters[0];

    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(variableToUse),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildBody(variableToUse) {
    return Builder(builder: (BuildContext context) {
      final state = MyInheritedWidget.of(context);
      final thisFlightStatus = _flightStatus(state);
      return Container(
        child: Column(children: <Widget>[
          Visibility(
            visible: state.showControls,
            child: Container(
              margin: EdgeInsets.only(left: 7.0),
              child: Row(children: <Widget>[
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
                    onChanged: (newValue) => _dataChanged(newValue,
                        variableToUse, state.altitude, state.showAllAltitudes),
                  ),
                ),
                Center(
                    child: Text(
                        "${variableToUse.value.toStringAsFixed(0)}${variableToUse.unit}")),
                IconButton(
                  icon: Icon(Icons.swap_horiz),
                  onPressed: () => _swapVariable(
                      glideParameters, state.altitude, state.showAllAltitudes),
                )
              ]),
            ),
          ),
          Visibility(
            visible: state.flightMode,
            child: Container(
              margin: EdgeInsets.only(left: 7.0),
              child: Row(children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(thisFlightStatus.icon,
                      color: thisFlightStatus.color),
                ),
                Text(
                    "${thisFlightStatus.status} ${thisFlightStatus.distanceAdvisory}"),
              ]),
            ),
          ),
          Expanded(
            child: GoogleMaps(
                center: state.airport.coordinates,
                polylines: _calculatePolylines(
                    state.airport, state.showAllAltitudes, state.altitude),
                clearAll: true,
                zoom: 12.0),
          ),
        ]),
      );
    });
  }

  Widget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: Builder(builder: (BuildContext context) {
        final state = MyInheritedWidget.of(context);
        return AppBar(
          title: FittedBox(fit: BoxFit.contain, child: Text('Higher Soaring')),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back_ios),
              tooltip: 'Back',
              onPressed: state.altitude > 500 && !state.showAllAltitudes
                  ? () => state.decrementAltitude()
                  : null,
            ),
            Center(
                child: Text(
              !state.showAllAltitudes
                  ? "${state.altitude.toString()}m"
                  : "500-1000m",
              textAlign: TextAlign.center,
            )),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              tooltip: 'Forward',
              onPressed: !state.showAllAltitudes
                  ? () => state.incrementAltitude()
                  : null,
            )
          ],
        );
      }),
    );
  }

  List<List<LatLng>> _calculatePolylines(
      Airport airport, bool showAllAltitudes, int altitude) {
    List<int> altitudes;
    List<LatLng> points = [];
    List<List<LatLng>> polylines = [];
    LruMap<int, List<LatLng>> _cacheMap =
        LruMap<int, List<LatLng>>(maximumSize: 1000);
    final p1 = lat_lng.LatLng(
        airport.coordinates.latitude, airport.coordinates.longitude);
    final headings = List<double>.generate(37, (i) => 10.0 * i);

    if (showAllAltitudes) {
      altitudes = List<int>.generate(6, (i) => 500 + 100 * i);
    } else {
      altitudes = [altitude];
    }

    altitudes.forEach((alt) {
      final _hashCode = hashObjects([
        airport.icao,
        alt,
        windDirection.value,
        windSpeed.value,
        glideSpeed.value,
        glideRatio.value
      ]);
      if (!_cacheMap.containsKey(_hashCode)) {
        points = [];
        headings.forEach((hdg) {
          var distanceToGlide = glideDistance(
              hdg,
              windDirection.value,
              windSpeed.value,
              glideSpeed.value,
              glideRatio.value,
              alt,
              patternAltitude);
          var p2 = distance.offset(p1, distanceToGlide, hdg);
          points.add(LatLng(p2.latitude, p2.longitude));
        });
        _cacheMap[_hashCode] = points;
      }
      polylines.add(_cacheMap[_hashCode]);
    });

    return polylines;
  }

  _flightStatus(state) {
    Airport airport = state.airport;
    if (state.position == null ||
        state.position['altitude'] == null ||
        (state.position['altitude'] - airport.altitudeInMeters) < 0) {
      return FlightStatus("Warning!", Icons.warning, Colors.amber,
          "Unable to fetch position or altitude");
    }

    var heading = glideHeading(airport.coordinates, state.myLocation);
    var maximumGlidingDistance = glideDistance(
        heading,
        windDirection.value,
        windSpeed.value,
        glideSpeed.value,
        glideRatio.value,
        (state.position['altitude'] - airport.altitudeInMeters).round(),
        patternAltitude);
    var distanceToRunway = distance.as(
        lat_lng.LengthUnit.Meter,
        lat_lng.LatLng(
            airport.coordinates.latitude, airport.coordinates.longitude),
        lat_lng.LatLng(
            state.position['latitude'], state.position['longitude']));

    if (maximumGlidingDistance > distanceToRunway) {
      return FlightStatus("Good!", Icons.check_circle, Colors.green,
          "You still have an additional ${f.format((maximumGlidingDistance - distanceToRunway).round())}m");
    } else {
      return FlightStatus("Ooops!", Icons.alarm, Colors.red,
          "You're missing ${f.format((distanceToRunway - maximumGlidingDistance).round())}m");
    }
  }

  void _dataChanged(newValue, variableToUse, altitude, showAllAltitudes) {
    setState(() {
      variableToUse.value = newValue;
    });
  }

  void _swapVariable(glideParameters, altitude, showAllAltitudes) {
    setState(() {
      glideParameters.add(glideParameters.removeAt(0));
    });
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
          SwitchListTile(
            title: Text("I'm flying!"),
            value: state.flightMode,
            onChanged: (bool value) => setState(() {
                  state.setPositionStream();
                  state.flightMode = value;
                }),
            secondary: Icon(Icons.flight_takeoff),
          ),
          SwitchListTile(
            title: Text('Show controls'),
            value: state.showControls,
            onChanged: (bool value) {
              setState(() {
                state.showControls = value;
              });
            },
            secondary: Icon(Icons.settings),
          ),
          SwitchListTile(
            title: Text('Plot all altitudes'),
            value: state.showAllAltitudes,
            onChanged: (bool value) => setState(() {
                  state.showAllAltitudes = value;
                }),
            secondary: Icon(Icons.all_inclusive),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.navigation),
            title: Text('Altitude'),
            subtitle: Text(
                "MSL: ${state.myAltitude != null ? state.myAltitude.round() : '?'}m\nAGL: ${state.myHeight != null ? state.myHeight.round() : '?'}m"),
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
}

class FlightStatus {
  String status;
  IconData icon;
  MaterialColor color;
  String distanceAdvisory;

  FlightStatus(this.status, this.icon, this.color, this.distanceAdvisory);
}

class GlideParameters {
  String name;
  IconData icon;
  double value;
  double min;
  double max;
  int divisions;
  String unit;

  GlideParameters(this.name, this.icon, this.value, this.min, this.max,
      this.divisions, this.unit);
}
