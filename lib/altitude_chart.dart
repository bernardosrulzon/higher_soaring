import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';


class AltitudeChart extends StatelessWidget {
  final bool animate;
  final data;
  final String title;
  final String unit;

  AltitudeChart({this.data, this.animate, this.title, this.unit});

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(data,
        animate: animate,
        primaryMeasureAxis: charts.NumericAxisSpec(
            tickProviderSpec:
                charts.BasicNumericTickProviderSpec(zeroBound: false),
            tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
                (num value) => '${value.toStringAsFixed(0)}${unit}'),
            renderSpec: charts.GridlineRendererSpec(
              lineStyle: charts.LineStyleSpec(
                  thickness: 0, color: charts.MaterialPalette.transparent),
              labelStyle: charts.TextStyleSpec(
                  fontSize: 10, color: charts.MaterialPalette.black),
            )),
        domainAxis: charts.DateTimeAxisSpec(
            showAxisLine: true, renderSpec: charts.NoneRenderSpec()),
        behaviors: [
          charts.ChartTitle(title,
              behaviorPosition: charts.BehaviorPosition.start,
              titleOutsideJustification:
                  charts.OutsideJustification.middleDrawArea,
              titleStyleSpec: charts.TextStyleSpec(
                  fontSize: 13, color: charts.MaterialPalette.black)),
        ]);
  }
}
