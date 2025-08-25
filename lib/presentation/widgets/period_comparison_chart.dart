import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Simple line chart for monthly/yearly trends.
class PeriodComparisonChart extends StatelessWidget {
  final List<double> values; // ordered oldest -> newest
  final String label;

  const PeriodComparisonChart({super.key, required this.values, required this.label});

  @override
  Widget build(BuildContext context) {
    final maxVal = values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b);
    final maxY = maxVal == 0 ? 1.0 : maxVal * 1.2;

    return AspectRatio(
      aspectRatio: 1.8,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 34)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (values.length / 6).clamp(1, 12).toDouble(),
                getTitlesWidget: (value, meta) => Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
                ),
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          minX: 0,
          maxX: (values.length - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: [for (int i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i])],
              isCurved: true,
              barWidth: 3,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
