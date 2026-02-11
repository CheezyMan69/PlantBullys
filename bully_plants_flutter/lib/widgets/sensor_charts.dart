import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../database/models/sensor_reading.dart';

class SensorChart extends StatelessWidget {

  final List<SensorReading> readings;
  final String type;

  const SensorChart({
    super.key,
    required this.readings,
    required this.type,
  });

  double _value(SensorReading r) {

    switch (type) {
      case "temp":
        return r.temperature ?? 0;
      case "soil":
        return r.soilMoisture ?? 0;
      case "light":
        return r.light ?? 0;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {

    final spots = readings.asMap().entries.map((e) {
      return FlSpot(
        e.key.toDouble(),
        _value(e.value),
      );
    }).toList();

    return SizedBox(
      height: 200,

      child: LineChart(
        LineChartData(
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),

          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              dotData: const FlDotData(show: false),
            )
          ],
        ),
      ),
    );
  }
}