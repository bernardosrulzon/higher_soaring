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
        addPolylines(widget.polylines, widget.clearAll);
      }
      if (widget.center != oldWidget.center) {
        _moveCamera(widget.center);
      }
      _automaticZoom(widget.polylines);
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

  void _moveCamera(LatLng target) async {
    await mapController.animateCamera(CameraUpdate.newLatLng(target));
    setState(() {});
  }

  _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    addPolylines(widget.polylines, widget.clearAll);
    _automaticZoom(widget.polylines);
    setState(() {});
  }

  addPolylines(List<List<LatLng>> polylines, bool clearAll) async {
    if (clearAll) {
      await mapController.clearPolylines();
    }
    polylines.forEach((polyline) {
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

  _automaticZoom(List<List<LatLng>> polylines) {
    List<LatLng> flatPolylines = polylines.expand((i) => i).toList();
    if (flatPolylines.length > 5) {
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
                flatPolylines.map((i) => i.latitude).toList().reduce(min),
                flatPolylines.map((i) => i.longitude).toList().reduce(min)),
            northeast: LatLng(
                flatPolylines.map((i) => i.latitude).toList().reduce(max),
                flatPolylines.map((i) => i.longitude).toList().reduce(max)),
          ),
          32.0,
        ),
      );
    }
  }
}
