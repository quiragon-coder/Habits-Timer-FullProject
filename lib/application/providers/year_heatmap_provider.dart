// Full-year heatmap provider (exact durations with pauses)
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart' as drift;

import '../../infrastructure/db/database.dart';
import '../services/time_utils.dart';
import 'unified_providers.dart';

/// Returns a map Day(start-of-day local) -> Duration for the inclusive range [startLocal, endLocal].
final dailyTotalsWithPausesProvider = FutureProvider.family<
    Map<DateTime, Duration>,
    ({int activityId, DateTime startLocal, DateTime endLocal})>((ref, args) async {
  final db = ref.read(databaseProvider);

  // Convert local bounds to UTC seconds for DB filtering.
  final startUtc = DateTime(args.startLocal.year, args.startLocal.month, args.startLocal.day).toUtc();
  final endUtcExclusive = DateTime(args.endLocal.year, args.endLocal.month, args.endLocal.day + 1).toUtc();
  final startSec = startUtc.millisecondsSinceEpoch ~/ 1000;
  final endSec = endUtcExclusive.millisecondsSinceEpoch ~/ 1000;

  // Fetch sessions intersecting range
  final sessions = await (db.select(db.sessions)
        ..where((s) => s.activityId.equals(args.activityId) &
            s.startUtc.isSmallerThanValue(endSec) &
            (s.endUtc.isNull() | s.endUtc.isBiggerOrEqualValue(startSec)))
        ..orderBy([(t) => drift.OrderingTerm.asc(t.startUtc)]))
      .get();

  if (sessions.isEmpty) {
    // Return zeroed map for range
    final out = <DateTime, Duration>{};
    var d = DateTime(args.startLocal.year, args.startLocal.month, args.startLocal.day);
    while (!d.isAfter(args.endLocal)) {
      out[d] = Duration.zero;
      d = d.add(const Duration(days: 1));
    }
    return out;
  }

  // Fetch pauses for these sessions
  final ids = sessions.map((s) => s.id).toList();
  final pauses = await (db.select(db.pauses)..where((p) => p.sessionId.isIn(ids))).get();

  // Group pauses
  final pausesBySession = <int, List<Pause>>{};
  for (final p in pauses) {
    (pausesBySession[p.sessionId] ??= []).add(p);
  }

  // Build day map
  final totals = <DateTime, Duration>{};
  var cursor = DateTime(args.startLocal.year, args.startLocal.month, args.startLocal.day);
  while (!cursor.isAfter(args.endLocal)) {
    totals[cursor] = Duration.zero;
    cursor = cursor.add(const Duration(days: 1));
  }

  for (final s in sessions) {
    final sStartUtc = DateTime.fromMillisecondsSinceEpoch(s.startUtc * 1000, isUtc: true);
    final sEndUtc = (s.endUtc == null)
        ? DateTime.now().toUtc()
        : DateTime.fromMillisecondsSinceEpoch(s.endUtc! * 1000, isUtc: true);
    // Iterate by local days overlapped
    DateTime dayLocal = DateTime(sStartUtc.toLocal().year, sStartUtc.toLocal().month, sStartUtc.toLocal().day);
    final lastDayLocal = sEndUtc.toLocal();
    while (!dayLocal.isAfter(DateTime(lastDayLocal.year, lastDayLocal.month, lastDayLocal.day))) {
      final dayStartLocal = DateTime(dayLocal.year, dayLocal.month, dayLocal.day);
      final dayEndLocal = dayStartLocal.add(const Duration(days: 1));

      // convert day window to UTC for accurate overlap
      final dayStartUtc = dayStartLocal.toUtc();
      final dayEndUtc = dayEndLocal.toUtc();

      final sessionDur = effectiveOverlapDuration(
        sStartUtc,
        sEndUtc,
        pausesBySession[s.id] ?? const [],
        dayStartUtc,
        dayEndUtc,
      );

      if (!sessionDur.isNegative && sessionDur.inSeconds > 0) {
        final key = DateTime(dayStartLocal.year, dayStartLocal.month, dayStartLocal.day);
        if (totals.containsKey(key)) {
          totals[key] = totals[key]! + sessionDur;
        } else {
          totals[key] = sessionDur;
        }
      }

      dayLocal = dayLocal.add(const Duration(days: 1));
    }
  }

  return totals;
});
