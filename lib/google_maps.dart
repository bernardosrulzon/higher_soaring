import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:collection/collection.dart';
import 'dart:math';

class GoogleMaps extends StatefulWidget {
  GoogleMaps({Key key, this.center, this.polylines, this.clearAll}) : super(key: key);

  final LatLng center;
  final bool clearAll;
  final List<List<LatLng>> polylines;

  @override
  State createState() => GoogleMapsState();
}

class GoogleMapsState extends State<GoogleMaps> {
  GoogleMapController mapController;
  Function eq = const DeepCollectionEquality().equals;

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(mapController != null) {
      if (!eq(oldWidget.polylines, widget.polylines)) {
        addPolylines(widget.polylines, widget.clearAll);
      }
      if (widget.center != oldWidget.center) {
        _moveCamera(widget.center);
      }
      List<LatLng> flat_polylines = widget.polylines.expand((i) => i).toList();
      if (flat_polylines.length > 5) {
        print('<><><><> UPDATING');
        _automaticZoom(flat_polylines);
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
          zoom: 12.0,
        ),
      ),
    );
  }

  void _moveCamera(LatLng target) async {
    await mapController.animateCamera(CameraUpdate.newLatLng(target));
    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    addPolylines(widget.polylines, widget.clearAll);
  }

  void addPolylines(List<List<LatLng>> polylines, bool clearAll) async {
    if(clearAll) {
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
    setState(() {});
  }

  _automaticZoom(List<LatLng> flat_polylines) {
    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(flat_polylines.map((i) => i.latitude).toList().reduce(min), flat_polylines.map((i) => i.longitude).toList().reduce(min)),
          northeast: LatLng(flat_polylines.map((i) => i.latitude).toList().reduce(max), flat_polylines.map((i) => i.longitude).toList().reduce(max)),
        ),
        32.0,
      ),
    );
  }
}