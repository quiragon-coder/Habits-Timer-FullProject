import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import '../../presentation/pages/heatmap_overview_page.dart' show dailyTotalsProvider;

@immutable
class PeriodStats {
  final Duration duration;
  const PeriodStats(this.duration);
}

DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime startOfWeekMonday(DateTime d) {
  final wd = d.weekday; // 1=Mon .. 7=Sun
  return _startOfDay(d).subtract(Duration(days: wd - 1));
}

DateTime startOfMonth(DateTime d) => DateTime(d.year, d.month, 1);


int _sumMinutesFromTotals(dynamic totals) {
  int minutes = 0;
  if (totals is Map) {
    // Expect keys DateTime -> values Duration or int
    for (final v in totals.values) {
      if (v is Duration) {
        minutes += v.inMinutes;
      } else if (v is int) {
        minutes += v;
      }
    }
    return minutes;
  }
  if (totals is List) {
    for (final t in totals) {
      try {
        final dyn = t as dynamic;
        if (dyn.minutes is int) {
          minutes += dyn.minutes as int;
        } else if (dyn.duration is Duration) {
          minutes += (dyn.duration as Duration).inMinutes;
        } else if (dyn['minutes'] is int) {
          minutes += dyn['minutes'] as int;
        } else if (dyn['duration'] is Duration) {
          minutes += (dyn['duration'] as Duration).inMinutes;
        }
      } catch (_) {}
    }
    return minutes;
  }
  return 0;
}


final currentWeekStatsProvider = FutureProvider.family<PeriodStats, int>((ref, activityId) async {
  final now = DateTime.now();
  final start = startOfWeekMonday(now);
  final end = start.add(const Duration(days: 7));
  final totals = await ref.watch(dailyTotalsProvider((activityId: activityId, startLocal: start, endLocal: end)).future);
  final minutes = _sumMinutesFromTotals(totals);
  return PeriodStats(Duration(minutes: minutes));
});

final previousWeekStatsProvider = FutureProvider.family<PeriodStats, int>((ref, activityId) async {
  final now = DateTime.now();
  final end = startOfWeekMonday(now);
  final start = end.subtract(const Duration(days: 7));
  final totals = await ref.watch(dailyTotalsProvider((activityId: activityId, startLocal: start, endLocal: end)).future);
  final minutes = _sumMinutesFromTotals(totals);
  return PeriodStats(Duration(minutes: minutes));
});

final currentMonthStatsProvider = FutureProvider.family<PeriodStats, int>((ref, activityId) async {
  final now = DateTime.now();
  final start = startOfMonth(now);
  final end = DateTime(now.year, now.month + 1, 1);
  final totals = await ref.watch(dailyTotalsProvider((activityId: activityId, startLocal: start, endLocal: end)).future);
  final minutes = _sumMinutesFromTotals(totals);
  return PeriodStats(Duration(minutes: minutes));
});

final previousMonthStatsProvider = FutureProvider.family<PeriodStats, int>((ref, activityId) async {
  final now = DateTime.now();
  final start = startOfMonth(now);           // first day of current month
  final prevStart = DateTime(start.year, start.month - 1, 1);
  final prevEnd = start;                      // exclusive
  final totals = await ref.watch(dailyTotalsProvider((activityId: activityId, startLocal: prevStart, endLocal: prevEnd)).future);
  final minutes = _sumMinutesFromTotals(totals);
  return PeriodStats(Duration(minutes: minutes));
});
