import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import 'dart:math' as math;

var f = NumberFormat("#,##0", "en_US");

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
