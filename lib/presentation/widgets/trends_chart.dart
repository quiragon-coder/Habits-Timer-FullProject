import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TrendsMeta {
  final List<String> labels;
  const TrendsMeta(this.labels);
}

class TrendsChart extends StatelessWidget {
  // New API
  final List<FlSpot>? series;
  final TrendsMeta? meta;

  // Back-compat (older API used in some pages)
  final List<double>? y;
  final List<String>? labels;
  final String? title;

  const TrendsChart({
    super.key,
    this.series,
    this.meta,
    this.y,
    this.labels,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    // Normalize inputs
    final s = series ?? _spotsFromY(y);
    final m = meta ?? TrendsMeta(labels ?? List.generate(s.length, (i) => i.toString()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null) Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(title!, style: Theme.of(context).textTheme.titleMedium),
        ),
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 1,
                    getTitlesWidget: (value, _) {
                      final i = value.toInt();
                      final txt = (i >= 0 && i < m.labels.length) ? m.labels[i] : '';
                      return Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(txt, style: const TextStyle(fontSize: 10)),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(show: true, border: Border.all(color: Theme.of(context).dividerColor)),
              lineBarsData: [
                LineChartBarData(spots: s, isCurved: true, dotData: const FlDotData(show: false)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _spotsFromY(List<double>? y) {
    if (y == null) return const <FlSpot>[];
    final out = <FlSpot>[];
    for (var i = 0; i < y.length; i++) {
      out.add(FlSpot(i.toDouble(), y[i]));
    }
    return out;
  }
}
