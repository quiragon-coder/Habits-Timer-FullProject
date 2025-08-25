import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../application/services/color_palette.dart';

class TrendsChart extends StatelessWidget {
  final ActivityPalette? palette;
  final List<double> y;           // values, in hours
  final List<String> labels;      // x labels
  final String title;

  const TrendsChart({super.key, required this.y, required this.labels, required this.title, this.palette});

  @override
  Widget build(BuildContext context) {
    final p = palette ?? buildPaletteFromInt(null, fallback: Theme.of(context).colorScheme.primary);
    final lineColor = p.main;
    final fillColor = p.fill(0.18);
    final spots = <FlSpot>[
      for (int i = 0; i < y.length; i++) FlSpot(i.toDouble(), y[i]),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (spots.isEmpty ? 0 : spots.last.x),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: fillColor),
                    )
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: (labels.length / 4).ceilToDouble().clamp(1, 4),
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(labels[i], style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 1,
                        getTitlesWidget: (value, meta) => Text('${value.toStringAsFixed(0)}h', style: const TextStyle(fontSize: 10)),
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
