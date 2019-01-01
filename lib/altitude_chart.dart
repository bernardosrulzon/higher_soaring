import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

import 'my_inherited_widget.dart';

class AltitudeChart extends StatelessWidget {
  final bool animate;

  AltitudeChart({this.animate});

  @override
  Widget build(BuildContext context) {
    final state = MyInheritedWidget.of(context);
    return charts.TimeSeriesChart(_calculateAltitudes(state.positions),
        animate: animate,
        primaryMeasureAxis: charts.NumericAxisSpec(
            tickProviderSpec:
                charts.BasicNumericTickProviderSpec(zeroBound: false),
            tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
                (num value) => '${value.toStringAsFixed(0)}m'),
            renderSpec: charts.GridlineRendererSpec(
              lineStyle: charts.LineStyleSpec(
                  thickness: 0, color: charts.MaterialPalette.transparent),
              labelStyle: charts.TextStyleSpec(
                  fontSize: 10, color: charts.MaterialPalette.black),
            )),
        domainAxis: charts.DateTimeAxisSpec(
            showAxisLine: true, renderSpec: charts.NoneRenderSpec()),
        behaviors: [
          charts.ChartTitle('Altitude',
              behaviorPosition: charts.BehaviorPosition.start,
              titleOutsideJustification: charts.OutsideJustification.middleDrawArea,
              titleStyleSpec: charts.TextStyleSpec(
                  fontSize: 13, color: charts.MaterialPalette.black)),
        ]);
  }

  _calculateAltitudes(List positions) {
    var altitudes = positions
        .map((position) => AltitudeTimeSeries(
            position[0], position[1].altitude, Colors.indigo))
        .toList();

    return [
      new charts.Series<AltitudeTimeSeries, DateTime>(
        id: 'Altitude Time Series',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (AltitudeTimeSeries altitude, _) => altitude.timestamp,
        measureFn: (AltitudeTimeSeries altitude, _) => altitude.altitude,
        data: altitudes,
      )
    ];
  }
}

class AltitudeTimeSeries {
  AltitudeTimeSeries(this.timestamp, this.altitude, Color color)
      : this.color = new charts.Color(
            r: color.red, g: color.green, b: color.blue, a: color.alpha);

  final DateTime timestamp;
  final double altitude;
  final charts.Color color;
}
