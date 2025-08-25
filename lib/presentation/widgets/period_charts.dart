// Period charts: WeekBars + PeriodChart wrapper (no enum here to avoid name clashes).
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/providers/stats_provider.dart' as stats; // expects last7DaysTotalsProvider

/// Durations → hours bar chart for a week (Mon..Sun).
class WeekBars extends StatelessWidget {
  final List<Duration> perDay; // 7 items
  const WeekBars({super.key, required this.perDay});

  double _maxHours() {
    final h = perDay.map((d) => d.inMinutes / 60.0).toList();
    if (h.isEmpty) return 1;
    final m = h.reduce((a, b) => a > b ? a : b);
    if (m <= 1) return 1;
    if (m <= 3) return 3;
    if (m <= 6) return 6;
    if (m <= 12) return 12;
    return (m / 6).ceil() * 6;
  }

  @override
  Widget build(BuildContext context) {
    final hours = perDay.map((d) => d.inMinutes / 60.0).toList();
    final data = List<double>.generate(7, (i) => i < hours.length ? hours[i] : 0.0);
    final maxY = _maxHours();
    final labels = const ['L','M','M','J','V','S','D'];

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barTouchData: BarTouchData(enabled: false),
          gridData: FlGridData(show: true, horizontalInterval: maxY / 3),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: maxY / 3,
                getTitlesWidget: (v, _) => Text(
                  v.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i > 6) return const SizedBox.shrink();
                  return Text(labels[i], style: Theme.of(context).textTheme.titleSmall);
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: [
            for (int i = 0; i < 7; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: data[i],
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

/// Thin wrapper used in ActivityDetailPage. It fetches last-7-days totals and feeds WeekBars.
/// `period` is accepted but ignored for now (kept for call-site compatibility).
class PeriodChart extends ConsumerWidget {
  final int activityId;
  final dynamic period; // kept for compatibility with callers using StatsPeriod
  const PeriodChart({super.key, required this.activityId, this.period});

  Duration _toDuration(dynamic value) {
    if (value is Duration) return value;
    if (value is int) return Duration(minutes: value);
    try {
      // Try common shapes: DayTotal(minutes/int), totalMinutes/int, durationMinutes/int, duration/Duration
      final minutes1 = value.minutes;
      if (minutes1 is int) return Duration(minutes: minutes1);
    } catch (_) {}
    try {
      final minutes2 = value.totalMinutes;
      if (minutes2 is int) return Duration(minutes: minutes2);
    } catch (_) {}
    try {
      final minutes3 = value.durationMinutes;
      if (minutes3 is int) return Duration(minutes: minutes3);
    } catch (_) {}
    try {
      final dur = value.duration;
      if (dur is Duration) return dur;
    } catch (_) {}
    return Duration.zero;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(stats.last7DaysTotalsProvider(activityId));
    return async.when(
      data: (list) {
        // Convert any supported shape to Duration
        final durations = list.map(_toDuration).toList();
        // pad/truncate to 7
        while (durations.length < 7) durations.add(Duration.zero);
        if (durations.length > 7) durations.removeRange(7, durations.length);
        return WeekBars(perDay: durations);
      },
      loading: () => const SizedBox(height: 220, child: Center(child: CircularProgressIndicator())),
      error: (e, _) => SizedBox(
        height: 220,
        child: Center(child: Text('Erreur graphique: $e')),
      ),
    );
  }
}
