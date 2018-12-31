import 'package:flutter/material.dart';

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
