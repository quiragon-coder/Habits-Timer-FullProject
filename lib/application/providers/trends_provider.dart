import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/periods_provider.dart' show startOfWeekMonday, startOfMonth;
import '../../presentation/pages/heatmap_overview_page.dart' show dailyTotalsProvider;

int _sumMinutesFromTotals(dynamic totals) {
  int minutes = 0;
  if (totals is Map) {
    for (final v in totals.values) {
      if (v is Duration) {
        minutes += v.inMinutes;
      } else if (v is int) {
        minutes += v;
      }
    }
  } else if (totals is List) {
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
  }
  return minutes;
}

class WeekPoint {
  final DateTime start; // Monday (local)
  final int minutes;
  const WeekPoint(this.start, this.minutes);
}

class MonthPoint {
  final DateTime start; // 1st of month (local)
  final int minutes;
  const MonthPoint(this.start, this.minutes);
}

final last8WeeksTotalsProvider = FutureProvider.family<List<WeekPoint>, int>((ref, activityId) async {
  final now = DateTime.now();
  final currentWeekStart = startOfWeekMonday(now);
  final weeks = <WeekPoint>[];

  for (int i = 7; i >= 0; i--) {
    final start = currentWeekStart.subtract(Duration(days: 7 * i));
    final end = start.add(const Duration(days: 7));
    final totals = await ref.read(
      dailyTotalsProvider((activityId: activityId, startLocal: start, endLocal: end)).future,
    );
    final minutes = _sumMinutesFromTotals(totals);
    weeks.add(WeekPoint(start, minutes));
  }
  return weeks;
});

final last12MonthsTotalsProvider = FutureProvider.family<List<MonthPoint>, int>((ref, activityId) async {
  final now = DateTime.now();
  final months = <MonthPoint>[];
  final currentStart = startOfMonth(now);

  for (int i = 11; i >= 0; i--) {
    final start = DateTime(currentStart.year, currentStart.month - i, 1);
    final end = DateTime(start.year, start.month + 1, 1);
    final totals = await ref.read(
      dailyTotalsProvider((activityId: activityId, startLocal: start, endLocal: end)).future,
    );
    final minutes = _sumMinutesFromTotals(totals);
    months.add(MonthPoint(start, minutes));
  }
  return months;
});
