import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../infrastructure/db/database.dart';
import '../../infrastructure/db/goal_dao_extras.dart';
import 'unified_providers.dart' show databaseProvider;

DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime _endOfDay(DateTime d) => DateTime(d.year, d.month, d.day, 23, 59, 59, 999);
DateTime _startOfWeekMonday(DateTime d) {
  final weekday = d.weekday;
  return _startOfDay(d).subtract(Duration(days: weekday - 1));
}
DateTime _endOfWeekMonday(DateTime d) => _endOfDay(_startOfWeekMonday(d).add(const Duration(days: 6)));
DateTime _startOfMonth(DateTime d) => DateTime(d.year, d.month, 1);
DateTime _endOfMonth(DateTime d) => DateTime(d.year, d.month + 1, 0, 23, 59, 59, 999);

int _clipSessionToRangeMs(int startMs, int? endMs, int rangeStartMs, int rangeEndMs) {
  final s = startMs.clamp(rangeStartMs, rangeEndMs);
  final e = (endMs ?? DateTime.now().toUtc().millisecondsSinceEpoch).clamp(rangeStartMs, rangeEndMs);
  final delta = e - s;
  return delta > 0 ? delta : 0;
}

Future<int> _sumMinutesForRange(dynamic db, int activityId, DateTime rangeStart, DateTime rangeEnd) async {
  final rs = rangeStart.toUtc().millisecondsSinceEpoch;
  final re = rangeEnd.toUtc().millisecondsSinceEpoch;
  final sessions = await (db.select(db.sessions)..where((s) => s.activityId.equals(activityId))).get();
  int totalMs = 0;
  for (final s in sessions) {
    totalMs += _clipSessionToRangeMs(s.startUtc, s.endUtc, rs, re);
  }
  return (totalMs ~/ 60000);
}

final goalByActivityProvider = StreamProvider.family<Goal?, int>((ref, activityId) {
  final db = ref.watch(databaseProvider);
  return db.goalDao.watchSingleByActivityId(activityId);
});

final dayMinutesProvider = FutureProvider.family<int, int>((ref, activityId) async {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  return _sumMinutesForRange(db, activityId, _startOfDay(now), _endOfDay(now));
});

final weekMinutesProvider = FutureProvider.family<int, int>((ref, activityId) async {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  return _sumMinutesForRange(db, activityId, _startOfWeekMonday(now), _endOfWeekMonday(now));
});

final monthMinutesProvider = FutureProvider.family<int, int>((ref, activityId) async {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  return _sumMinutesForRange(db, activityId, _startOfMonth(now), _endOfMonth(now));
});

final dailyGoalMinutesProvider = Provider.family<int, int>((ref, activityId) {
  final g = ref.watch(goalByActivityProvider(activityId)).valueOrNull;
  return g?.minutesPerDay ?? 0;
});

final weeklyGoalMinutesProvider = Provider.family<int, int>((ref, activityId) {
  final g = ref.watch(goalByActivityProvider(activityId)).valueOrNull;
  return g?.minutesPerWeek ?? 0;
});

final monthlyGoalMinutesProvider = Provider.family<int, int>((ref, activityId) {
  final now = DateTime.now();
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
  final perDay = ref.watch(dailyGoalMinutesProvider(activityId));
  final perWeek = ref.watch(weeklyGoalMinutesProvider(activityId));
  final fromDaily = perDay * daysInMonth;
  final fromWeekly = (perWeek * (daysInMonth / 7.0)).round();
  final best = [fromDaily, fromWeekly, 0].where((v) => v > 0).fold<int>(0, (a, b) => a > b ? a : b);
  return best;
});

class ActivityProgress {
  final int dayCurrent, dayGoal;
  final int weekCurrent, weekGoal;
  final int monthCurrent, monthGoal;
  const ActivityProgress({
    required this.dayCurrent, required this.dayGoal,
    required this.weekCurrent, required this.weekGoal,
    required this.monthCurrent, required this.monthGoal,
  });
}

final activityProgressProvider = FutureProvider.family<ActivityProgress, int>((ref, activityId) async {
  final dayCur = await ref.watch(dayMinutesProvider(activityId).future);
  final weekCur = await ref.watch(weekMinutesProvider(activityId).future);
  final monthCur = await ref.watch(monthMinutesProvider(activityId).future);
  final dayGoal = ref.watch(dailyGoalMinutesProvider(activityId));
  final weekGoal = ref.watch(weeklyGoalMinutesProvider(activityId));
  final monthGoal = ref.watch(monthlyGoalMinutesProvider(activityId));
  return ActivityProgress(
    dayCurrent: dayCur, dayGoal: dayGoal,
    weekCurrent: weekCur, weekGoal: weekGoal,
    monthCurrent: monthCur, monthGoal: monthGoal,
  );
});
