import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong/latlong.dart' as lat_lng;

import 'airport.dart';
import 'google_maps.dart';
import 'glide_parameters.dart';
import 'flight_status.dart';
import 'my_inherited_widget.dart';
import 'root_drawer.dart';
import 'utils.dart';

class Altitude extends StatefulWidget {
  Altitude({Key key}) : super(key: key);

  @override
  State createState() => AltitudeState();
}

class AltitudeState extends State<Altitude> {

  List<GlideParameters> glideParameters;

  var windSpeed = GlideParameters("Wind Speed", Icons.arrow_forward, 0.0, 0.0, 15.0, 15, "m/s");
  var windDirection = GlideParameters("Wind Direction", Icons.cloud_queue, 0.0, 0.0, 360.0, 72, "º");
  var glideSpeed = GlideParameters("Best Glide", Icons.local_airport, 85.0, 70.0, 100.0, 30, "km/h");
  var glideRatio = GlideParameters("Glide Ratio", Icons.flight_land, 27.0, 25.0, 40.0, 15, ":1");
  final lat_lng.Distance distance = lat_lng.Distance();
  final int patternAltitude = 400;

  @override
  Widget build(BuildContext context) {
    glideParameters ??= [windDirection, windSpeed, glideSpeed, glideRatio];
    var variableToUse = glideParameters[0];

    return MyInheritedWidget(
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(variableToUse),
        drawer: RootDrawer(),
      ),
    );
  }

  Widget _buildBody(variableToUse) {
    return Builder(
        builder: (BuildContext context) {
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
                        onChanged: (newValue) => _dataChanged(newValue, variableToUse, state.altitude, state.showAllAltitudes),
                      ),
                    ),
                    Center(
                        child: Text(
                            "${variableToUse.value.toStringAsFixed(
                                0)}${variableToUse.unit}")),
                    IconButton(
                      icon: Icon(Icons.swap_horiz),
                      onPressed: () => _swapVariable(glideParameters, state.altitude, state.showAllAltitudes),
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
              Flexible(
                child: GoogleMaps(windDirection: windDirection, windSpeed: windSpeed, glideSpeed: glideSpeed, glideRatio: glideRatio),
              ),
            ]),
          );
        }
    );
  }

  Widget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: Builder(
        builder: (BuildContext context) {
          final state = MyInheritedWidget.of(context);
          return AppBar(
            title: FittedBox(fit: BoxFit.contain, child: Text('Higher Soaring')),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.arrow_back_ios),
                tooltip: 'Back',
                onPressed: state.altitude > 500 && !state.showAllAltitudes ? () => state.decrementAltitude() : null,
              ),
              Center(
                  child: Text(
                    !state.showAllAltitudes ? "${state.altitude.toString()}m" : "500-1500m",
                    textAlign: TextAlign.center,
                  )),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios),
                tooltip: 'Forward',
                onPressed: !state.showAllAltitudes ? () => state.incrementAltitude() : null,
              )
            ],
          );
        }
      ),
    );
  }

  _flightStatus(state) {
    Airport airport = state.airport;
    if (state.position?.altitude == null ||
        (state.position.altitude - airport.altitudeInMeters) < 0) {
      return FlightStatus("Warning!", Icons.warning, Colors.amber, "Unable to fetch position or altitude");
    }

    var heading = glideHeading(airport.coordinates, LatLng(state.position.latitude, state.position.longitude));
    var maximumGlidingDistance = glideDistance(heading, windDirection.value, windSpeed.value, glideSpeed.value, glideRatio.value, (state.position.altitude - airport.altitudeInMeters).round(), patternAltitude);
    var distanceToRunway = distance.as(lat_lng.LengthUnit.Meter, lat_lng.LatLng(airport.coordinates.latitude, airport.coordinates.longitude), lat_lng.LatLng(state.position.latitude, state.position.longitude));

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
}
