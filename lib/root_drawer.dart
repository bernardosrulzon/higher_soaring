import 'package:flutter/material.dart';

import 'my_inherited_widget.dart';

class RootDrawer extends StatefulWidget {
  RootDrawer({Key key}) : super(key: key);

  @override
  State createState() => RootDrawerState();
}

class RootDrawerState extends State<RootDrawer> {
  @override
  Widget build(BuildContext context) {
    final MyInheritedWidgetState state = MyInheritedWidget.of(context);

    return Drawer(
      child: ListView(children: <Widget>[
        UserAccountsDrawerHeader(
          accountName: Text(
            "Bernardo Srulzon",
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
          ),
          accountEmail: Text(
            "bernardosrulzon@gmail.com",
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300),
          )
        ),
        _buildTrackMyFlight(state),
        Visibility(
          visible: !state.trackMyFlight,
          child: SwitchListTile(
            title: Text("I'm flying!"),
            value: state.flightMode,
            onChanged: (bool value) => _flightModeToggle(state, value),
            secondary: Icon(Icons.flight_takeoff),
          )
        ),
        Visibility(
          visible: !state.trackMyFlight,
          child: SwitchListTile(
            title: Text('Show controls'),
            value: state.showControls,
            onChanged: (bool value) { setState(() {
              state.showControls = value;
            }); },
            secondary: Icon(Icons.settings),
          ),
        ),
        Visibility(
          visible: !state.trackMyFlight,
          child: SwitchListTile(
            title: Text('Plot all altitudes'),
            value: state.showAllAltitudes,
            onChanged: (bool value) => _allAltitudesToggle(state, value),
            secondary: Icon(Icons.all_inclusive),
          ),
        ),
        ListTile(
          leading: Icon(Icons.local_airport),
          title: Text('Data for ${state.airport.icao}'),
        ),
        ListTile(
          leading: Icon(Icons.map),
          title: Text('Coordinates'),
          subtitle: Text(_locationData('latlon', state)),
        ),
        ListTile(
          leading: Icon(Icons.navigation),
          title: Text('Altitude'),
          subtitle: Text(
              "MSL: ${_locationData('altitude', state)}\nAGL: ${_locationData('height', state)}"),
        ),
        ListTile(
          leading: Icon(state.positionStreamSubscription == null || state.positionStreamSubscription.isPaused ? Icons.gps_off : Icons.gps_fixed),
          title: Text('Location updates'),
          subtitle: Text(state.positionStreamSubscription == null || state.positionStreamSubscription.isPaused ? 'Disabled' : 'Enabled'),
        ),
      ]),
    );
  }

  void _allAltitudesToggle(state, value) {
    setState(() {
      state.showAllAltitudes = value;
    });
  }

  void _flightModeToggle(state, value) {
    if (value) {
      if (state.positionStreamSubscription == null) {
        state.setPositionStream();
      }
      state.positionStreamSubscription.resume();
    } else if (state.positionStreamSubscription != null) {
      state.positionStreamSubscription.pause();
    }

    setState(() {
      state.flightMode = value;
    });
  }

  String _locationData(type, state) {
    if (state.position == null) {
      return "Unknown!";
    }
    if (type == 'latlon') {
      return "Latitude: ${state.position.latitude.toStringAsFixed(4)}\nLongitude: ${state.position.longitude.toStringAsFixed(4)}";
    } else {
      if (state.position.altitude == null) {
        return "Unknown!";
      } else if (type == 'altitude') {
        return "${state.position?.altitude?.toStringAsFixed(0)}m";
      } else if (type == 'height') {
        return "${(state.position.altitude - state.airport.altitudeInMeters).toStringAsFixed(0)}m";
      }
    }
    return "Unknown!";
  }

  _buildTrackMyFlight(state) {
    return ListTile(
      leading: Icon(Icons.navigation),
      title: state.trackMyFlight ? Text("Return to altitude") : Text("Track my flight"),
      onTap: () {
        state.trackMyFlight = !state.trackMyFlight;
        if (state.trackMyFlight) {
          Navigator.pushNamed(context, '/flight-track');
        } else {
          Navigator.popUntil(context, ModalRoute.withName('/'));
        }
      },
    );
  }
}