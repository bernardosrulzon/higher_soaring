import 'package:flutter/material.dart';

class FlightStatus {
  String status;
  IconData icon;
  MaterialColor color;
  String distanceAdvisory;

  FlightStatus(this.status, this.icon, this.color, this.distanceAdvisory);
}
