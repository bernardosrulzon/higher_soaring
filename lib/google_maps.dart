import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:collection/collection.dart';
import 'dart:math';

class GoogleMaps extends StatefulWidget {
  GoogleMaps({Key key, this.center, this.polylines, this.clearAll, this.zoom})
      : super(key: key);

  final LatLng center;
  final bool clearAll;
  final List<List<LatLng>> polylines;
  final double zoom;

  @override
  State createState() => GoogleMapsState();
}

class GoogleMapsState extends State<GoogleMaps> {
  GoogleMapController mapController;
  Function eq = const DeepCollectionEquality().equals;

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (mapController != null) {
      if (!eq(oldWidget.polylines, widget.polylines)) {
        addPolylines();
        _automaticZoom();
      }
      if (widget.center != oldWidget.center && eq(oldWidget.polylines, [[]])) {
        _moveCamera();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: (controller) => _onMapCreated(controller),
      options: GoogleMapOptions(
        myLocationEnabled: true,
        tiltGesturesEnabled: false,
        mapType: MapType.hybrid,
        cameraPosition: CameraPosition(
          target: widget.center,
          zoom: widget.zoom,
        ),
      ),
    );
  }

  void _moveCamera() async {
    await mapController.animateCamera(CameraUpdate.newLatLng(widget.center));
  }

  _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    addPolylines();
    _automaticZoom();
  }

  addPolylines() async {
    if (widget.clearAll) {
      await mapController.clearPolylines();
    }
    widget.polylines.forEach((polyline) {
      mapController.addPolyline(PolylineOptions(
          width: 5,
          points: polyline,
          geodesic: false,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: 2,
          color: Colors.indigoAccent.value));
    });
  }

  _automaticZoom() {
    List<LatLng> flatPolylines = widget.polylines.expand((i) => i).toList();
    List<double> latitudes = flatPolylines.map((i) => i.latitude).toList();
    List<double> longitudes = flatPolylines.map((i) => i.longitude).toList();

    if (flatPolylines.length >= 5) {
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(latitudes.reduce(min), longitudes.reduce(min)),
            northeast: LatLng(latitudes.reduce(max), longitudes.reduce(max)),
          ),
          32.0,
        ),
      );
    }
  }
}
