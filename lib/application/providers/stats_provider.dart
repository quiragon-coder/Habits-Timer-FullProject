// Stats & Visualisations providers (unifiés)
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart' as drift;

import '../../infrastructure/db/database.dart';
import '../../application/providers/unified_providers.dart';
import '../../application/services/time_utils.dart';

class DurationPoint {
  final DateTime x;
  final Duration y;
  const DurationPoint(this.x, this.y);
}

class DayTotal {
  final DateTime day;
  final Duration duration;
  const DayTotal(this.day, this.duration);
}

DateTime _startOfDayLocal(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime _endOfDayLocal(DateTime d) => DateTime(d.year, d.month, d.day).add(const Duration(days: 1));
DateTime _mondayOfWeekLocal(DateTime d) {
  final wd = d.weekday; // 1=Mon..7=Sun
  return _startOfDayLocal(d).subtract(Duration(days: wd - 1));
}
DateTime _sundayOfWeekLocal(DateTime d) => _mondayOfWeekLocal(d).add(const Duration(days: 7));
DateTime _firstOfMonthLocal(DateTime d) => DateTime(d.year, d.month, 1);
DateTime _firstOfNextMonthLocal(DateTime d) => (d.month == 12) ? DateTime(d.year + 1, 1, 1) : DateTime(d.year, d.month + 1, 1);
DateTime _firstOfYearLocal(int year) => DateTime(year, 1, 1);
DateTime _firstOfNextYearLocal(int year) => DateTime(year + 1, 1, 1);

Future<(List<Session>, Map<int, List<Pause>>)> _sessionsWithPausesBetween(
  Ref ref,
  int activityId,
  DateTime fromLocal,
  DateTime toLocal,
) async {
  final db = ref.read(databaseProvider);
  final fromUtc = fromLocal.toUtc();
  final toUtc = toLocal.toUtc();
  final fromTs = (fromUtc.millisecondsSinceEpoch / 1000).floor();
  final toTs = (toUtc.millisecondsSinceEpoch / 1000).floor();

  final sessions = await (db.select(db.sessions)
        ..where((s) => s.activityId.equals(activityId))
        ..where((s) => s.startUtc.isSmallerThanValue(toTs))
        ..where((s) => s.endUtc.isNull() | s.endUtc.isBiggerOrEqualValue(fromTs)))
      .get();

  if (sessions.isEmpty) return (sessions, <int, List<Pause>>{});

  final ids = sessions.map((s) => s.id).toList();
  final pauses = await (db.select(db.pauses)..where((p) => p.sessionId.isIn(ids))).get();

  final bySession = <int, List<Pause>>{};
  for (final p in pauses) {
    bySession.putIfAbsent(p.sessionId, () => []).add(p);
  }
  return (sessions, bySession);
}

Duration _effectiveForSlice(Session s, List<Pause> pauses, DateTime sliceStartLocal, DateTime sliceEndLocal) {
  final start = DateTime.fromMillisecondsSinceEpoch(s.startUtc * 1000, isUtc: true);
  final end = (s.endUtc == null)
      ? DateTime.now().toUtc()
      : DateTime.fromMillisecondsSinceEpoch(s.endUtc! * 1000, isUtc: true);
  return effectiveOverlapDuration(
    start,
    end,
    pauses,
    sliceStartLocal.toUtc(),
    sliceEndLocal.toUtc(),
  );
}

// == Totaux rapides (today/week) ==
final totalsProvider = FutureProvider.family<Map<String, Duration>, int>((ref, activityId) async {
  final now = DateTime.now();
  final todayStart = _startOfDayLocal(now);
  final todayEnd = _endOfDayLocal(now);
  final weekStart = _mondayOfWeekLocal(now);
  final weekEnd = _sundayOfWeekLocal(now);

  final (sessions, pausesBySession) = await _sessionsWithPausesBetween(ref, activityId, weekStart, weekEnd);

  Duration todayTotal = Duration.zero;
  Duration weekTotal = Duration.zero;

  for (final s in sessions) {
    final pauses = pausesBySession[s.id] ?? const <Pause>[];
    // week
    weekTotal += _effectiveForSlice(s, pauses, weekStart, weekEnd);
    // today
    todayTotal += _effectiveForSlice(s, pauses, todayStart, todayEnd);
  }

  return {
    'today': todayTotal,
    'week': weekTotal,
  };
});

// == Historique récent (sessions triées desc, limité) ==
final recentHistoryProvider = FutureProvider.family<List<Session>, int>((ref, activityId) async {
  final db = ref.read(databaseProvider);
  final result = await (db.select(db.sessions)
        ..where((s) => s.activityId.equals(activityId))
        ..orderBy([(t) => drift.OrderingTerm.desc(t.startUtc)])
        ..limit(50))
      .get();
  return result;
});

// == Derniers 7 jours (totaux par jour) ==
final last7DaysTotalsProvider = FutureProvider.family<List<DayTotal>, int>((ref, activityId) async {
  final today = _startOfDayLocal(DateTime.now());
  final start = today.subtract(const Duration(days: 6));
  final end = today.add(const Duration(days: 1));
  final (sessions, pausesBySession) = await _sessionsWithPausesBetween(ref, activityId, start, end);

  final buckets = List<Duration>.filled(7, Duration.zero);
  for (final s in sessions) {
    final pauses = pausesBySession[s.id] ?? const <Pause>[];
    for (int i = 0; i < 7; i++) {
      final sliceStart = start.add(Duration(days: i));
      final sliceEnd = sliceStart.add(const Duration(days: 1));
      final d = _effectiveForSlice(s, pauses, sliceStart, sliceEnd);
      if (d > Duration.zero) buckets[i] += d;
    }
  }
  return List.generate(7, (i) => DayTotal(start.add(Duration(days: i)), buckets[i]));
});

// == Buckets avancés pour charts détaillés ==
final dayHourlyBucketsProvider = FutureProvider.family<List<DurationPoint>, (int activityId, DateTime dayLocal)>((ref, input) async {
  final activityId = input.$1;
  final dayLocal = input.$2;
  final dayStart = _startOfDayLocal(dayLocal);
  final dayEnd = _endOfDayLocal(dayLocal);
  final (sessions, pausesBySession) = await _sessionsWithPausesBetween(ref, activityId, dayStart, dayEnd);

  final buckets = List<Duration>.filled(24, Duration.zero);
  for (final s in sessions) {
    final pauses = pausesBySession[s.id] ?? const <Pause>[];
    for (int h = 0; h < 24; h++) {
      final sliceStart = dayStart.add(Duration(hours: h));
      final sliceEnd = sliceStart.add(const Duration(hours: 1));
      buckets[h] += _effectiveForSlice(s, pauses, sliceStart, sliceEnd);
    }
  }
  return List.generate(24, (i) => DurationPoint(dayStart.add(Duration(hours: i)), buckets[i]));
});

final weekDailyBucketsProvider = FutureProvider.family<List<DurationPoint>, (int activityId, DateTime refDayLocal)>((ref, input) async {
  final activityId = input.$1;
  final refDayLocal = input.$2;
  final weekStart = _mondayOfWeekLocal(refDayLocal);
  final weekEnd = _sundayOfWeekLocal(refDayLocal);
  final (sessions, pausesBySession) = await _sessionsWithPausesBetween(ref, activityId, weekStart, weekEnd);

  final buckets = List<Duration>.filled(7, Duration.zero);
  for (final s in sessions) {
    final pauses = pausesBySession[s.id] ?? const <Pause>[];
    for (int d = 0; d < 7; d++) {
      final sliceStart = weekStart.add(Duration(days: d));
      final sliceEnd = sliceStart.add(const Duration(days: 1));
      buckets[d] += _effectiveForSlice(s, pauses, sliceStart, sliceEnd);
    }
  }
  return List.generate(7, (i) => DurationPoint(weekStart.add(Duration(days: i)), buckets[i]));
});

final monthDailyBucketsProvider = FutureProvider.family<List<DurationPoint>, (int activityId, DateTime refDayLocal)>((ref, input) async {
  final activityId = input.$1;
  final refDayLocal = input.$2;
  final monthStart = _firstOfMonthLocal(refDayLocal);
  final monthEnd = _firstOfNextMonthLocal(refDayLocal);
  final daysInMonth = monthEnd.difference(monthStart).inDays;

  final (sessions, pausesBySession) = await _sessionsWithPausesBetween(ref, activityId, monthStart, monthEnd);
  final buckets = List<Duration>.filled(daysInMonth, Duration.zero);

  for (final s in sessions) {
    final pauses = pausesBySession[s.id] ?? const <Pause>[];
    for (int d = 0; d < daysInMonth; d++) {
      final sliceStart = monthStart.add(Duration(days: d));
      final sliceEnd = sliceStart.add(const Duration(days: 1));
      buckets[d] += _effectiveForSlice(s, pauses, sliceStart, sliceEnd);
    }
  }
  return List.generate(daysInMonth, (i) => DurationPoint(monthStart.add(Duration(days: i)), buckets[i]));
});

final yearMonthlyBucketsProvider = FutureProvider.family<List<DurationPoint>, (int activityId, int year)>((ref, input) async {
  final activityId = input.$1;
  final year = input.$2;
  final yearStart = _firstOfYearLocal(year);
  final yearEnd = _firstOfNextYearLocal(year);

  final (sessions, pausesBySession) = await _sessionsWithPausesBetween(ref, activityId, yearStart, yearEnd);
  final buckets = List<Duration>.filled(12, Duration.zero);

  for (final s in sessions) {
    final pauses = pausesBySession[s.id] ?? const <Pause>[];
    for (int m = 0; m < 12; m++) {
      final monthStart = DateTime(year, m + 1, 1);
      final monthEnd = (m == 11) ? DateTime(year + 1, 1, 1) : DateTime(year, m + 2, 1);
      buckets[m] += _effectiveForSlice(s, pauses, monthStart, monthEnd);
    }
  }
  return List.generate(12, (i) => DurationPoint(DateTime(year, i + 1, 1), buckets[i]));
});
