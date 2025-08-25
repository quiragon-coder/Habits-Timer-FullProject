import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'unified_providers.dart' show databaseProvider;

class Streaks {
  final int current;
  final int best;
  final int activeDaysInYear;
  const Streaks({required this.current, required this.best, required this.activeDaysInYear});
}

int _dayKey(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

Future<Set<int>> _activeDayKeysForLastYear(dynamic db, int activityId) async {
  final now = DateTime.now().toUtc();
  final start = DateTime(now.year - 1, now.month, now.day).toUtc();
  final sessions = await (db.select(db.sessions)..where((s) => s.activityId.equals(activityId))).get();

  final days = <int>{};
  for (final s in sessions) {
    final int sMs = s.startUtc;
    final int eMs = s.endUtc ?? DateTime.now().toUtc().millisecondsSinceEpoch;
    DateTime sDay = DateTime.fromMillisecondsSinceEpoch(sMs, isUtc: true);
    DateTime eDay = DateTime.fromMillisecondsSinceEpoch(eMs, isUtc: true);
    sDay = DateTime.utc(sDay.year, sDay.month, sDay.day);
    eDay = DateTime.utc(eDay.year, eDay.month, eDay.day);
    for (DateTime d = sDay; !d.isAfter(eDay); d = d.add(const Duration(days: 1))) {
      if (d.isBefore(start)) continue;
      days.add(_dayKey(d));
    }
  }
  return days;
}

Streaks _computeFromDays(Set<int> dayKeys) {
  final now = DateTime.now().toUtc();
  int current = 0, best = 0;
  for (DateTime d = DateTime.utc(now.year, now.month, now.day);; d = d.subtract(const Duration(days: 1))) {
    if (dayKeys.contains(_dayKey(d))) current++; else break;
  }
  int run = 0;
  for (int i = 0; i < 365; i++) {
    final d = DateTime.utc(now.year, now.month, now.day).subtract(Duration(days: i));
    if (dayKeys.contains(_dayKey(d))) { run++; if (run > best) best = run; } else { run = 0; }
  }
  return Streaks(current: current, best: best, activeDaysInYear: dayKeys.length);
}

final streaksProvider = FutureProvider.family<Streaks, int>((ref, activityId) async {
  final db = ref.watch(databaseProvider);
  final dayKeys = await _activeDayKeysForLastYear(db, activityId);
  return _computeFromDays(dayKeys);
});
