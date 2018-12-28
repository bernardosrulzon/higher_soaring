import 'package:google_maps_flutter/google_maps_flutter.dart';

class Airport {
  String name;
  String icao;
  int altitudeInMeters;
  LatLng coordinates;

  Airport(this.name, this.icao, this.altitudeInMeters, this.coordinates);
}
