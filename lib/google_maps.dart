import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong/latlong.dart' as lat_lng;
import 'package:quiver/core.dart';
import 'package:quiver/collection.dart';

import 'glide_parameters.dart';
import 'my_inherited_widget.dart';
import 'utils.dart';

class GoogleMaps extends StatefulWidget {
  GoogleMaps({Key key, this.windDirection, this.windSpeed, this.glideSpeed, this.glideRatio}) : super(key: key);

  final GlideParameters windDirection;
  final GlideParameters windSpeed;
  final GlideParameters glideSpeed;
  final GlideParameters glideRatio;

  @override
  State createState() => GoogleMapsState();
}

class GoogleMapsState extends State<GoogleMaps> {
  GoogleMapController mapController;
  final headings = List<double>.generate(37, (i) => 10.0 * i);
  final lat_lng.Distance distance = lat_lng.Distance();
  final patternAltitude = 400;

  LruMap<int, List<LatLng>> _cacheMap = LruMap<int, List<LatLng>>(maximumSize: 1000);

  @override
  void didChangeDependencies() {
    final MyInheritedWidgetState state = MyInheritedWidget.of(context);
    if(mapController != null) {
      _onMapCreated(
          mapController,
          state.airport,
          state.altitude,
          state.showAllAltitudes,
          widget.windDirection,
          widget.windSpeed,
          widget.glideSpeed,
          widget.glideRatio);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final MyInheritedWidgetState state = MyInheritedWidget.of(context);
    final airport = state.airport;
    return GoogleMap(
      onMapCreated: (controller) => _onMapCreated(controller, airport, state.altitude, state.showAllAltitudes, widget.windDirection, widget.windSpeed, widget.glideSpeed, widget.glideRatio),
      options: GoogleMapOptions(
        myLocationEnabled: true,
        mapType: MapType.hybrid,
        cameraPosition: CameraPosition(
          target: airport.coordinates,
          zoom: 12.0,
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller, airport, altitude, showAllAltitudes, windDirection, windSpeed, glideSpeed, glideRatio) async {
    List<int> altitudes;
    List<LatLng> points;

    final p1 = lat_lng.LatLng(airport.coordinates.latitude, airport.coordinates.longitude);

    if(mapController == null) {
      mapController = controller;
    }

    await mapController.clearPolylines();

    if (showAllAltitudes) {
      altitudes = List<int>.generate(6, (i) => 500 + 100 * i);
    } else {
    altitudes = [altitude];
    }

    altitudes.forEach((alt) {
      final _hashCode = hashObjects([airport.icao, alt, windDirection.value, windSpeed.value, glideSpeed.value, glideRatio.value]);
      if (_cacheMap.containsKey(_hashCode)) {
        points = _cacheMap[_hashCode];
      }
      else {
        points = [];
        headings.forEach((hdg) {
          var distanceToGlide = glideDistance(hdg, windDirection.value, windSpeed.value, glideSpeed.value, glideRatio.value, alt, patternAltitude);
          var p2 = distance.offset(p1, distanceToGlide, hdg);
          points.add(LatLng(p2.latitude, p2.longitude));
          });
        _cacheMap[_hashCode] = points;
      }
      setState(() {
        _addPolyline(points);
      });
    });
  }

  _addPolyline(List<LatLng> points) {
    mapController.addPolyline(PolylineOptions(
        width: 5,
        points: points,
        geodesic: false,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: 2,
        color: Colors.indigoAccent.value));
  }
}