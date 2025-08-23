import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Simple weekly bar chart (Mon..Sun) with dynamic max and spacing.
class WeeklyBarChart extends StatelessWidget {
  final List<double> hours; // 7 values, Monday-first ISO week

  const WeeklyBarChart({super.key, required this.hours});

  @override
  Widget build(BuildContext context) {
    final maxVal = (hours.isEmpty ? 1.0 : hours.reduce((a, b) => a > b ? a : b)).clamp(1.0, double.infinity);
    final maxY = (maxVal == 0 ? 1.0 : (maxVal * 1.2)); // 20% headroom

    const labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (v, meta) {
                  final t = v.toStringAsFixed(0);
                  return Text(t, style: Theme.of(context).textTheme.bodySmall);
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i > 6) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(labels[i], style: Theme.of(context).textTheme.bodyMedium),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            horizontalInterval: maxY / 2,
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            for (int i = 0; i < 7; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: i < hours.length ? hours[i] : 0,
                    width: 14,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
