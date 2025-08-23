import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../infrastructure/db/database.dart';
import '../services/time_utils.dart';
import 'providers.dart';

class HeatDay {
  final DateTime day; // UTC at 00:00
  final int minutes;
  HeatDay(this.day, this.minutes);
}

Future<List<HeatDay>> _computeHeatmap(
  Ref ref,
  int activityId, {
  required DateTime startLocal,
  required DateTime endLocalExclusive,
}) async {
  final sessionDao = ref.read(sessionDaoProvider);
  final pauseDao = ref.read(pauseDaoProvider);

  final days = endLocalExclusive.difference(startLocal).inDays;
  final Map<DateTime, int> minutesPerDay = {};
  for (int i = 0; i < days; i++) {
    final d = DateTime(startLocal.year, startLocal.month, startLocal.day + i);
    minutesPerDay[d.toUtc()] = 0;
  }

  final sessions = await sessionDao.recentSessionsForActivity(activityId, limit: 5000);
  final startUtc = startLocal.toUtc();
  final endUtc = endLocalExclusive.toUtc();

  for (final s in sessions) {
    final pauses = await pauseDao.pausesForSession(s.id);
    final sStart = DateTime.fromMillisecondsSinceEpoch(s.startUtc * 1000, isUtc: true);
    final sEnd = DateTime.fromMillisecondsSinceEpoch((s.endUtc ?? (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000)) * 1000, isUtc: true);

    if (sEnd.isBefore(startUtc) || sStart.isAfter(endUtc)) continue;

    for (int i = 0; i < days; i++) {
      final dayStartLocal = DateTime(startLocal.year, startLocal.month, startLocal.day + i);
      final dayEndLocal = dayStartLocal.add(const Duration(days: 1));
      final d = effectiveOverlapDuration(
        sStart,
        sEnd,
        pauses,
        dayStartLocal.toUtc(),
        dayEndLocal.toUtc(),
      );
      if (d > Duration.zero) {
        final key = DateTime(dayStartLocal.year, dayStartLocal.month, dayStartLocal.day).toUtc();
        minutesPerDay[key] = (minutesPerDay[key] ?? 0) + d.inMinutes;
      }
    }
  }

  return minutesPerDay.entries.map((e) => HeatDay(e.key, e.value)).toList()
    ..sort((a, b) => a.day.compareTo(b.day));
}

/// 365 derniers jours (aujourd'hui inclus)
final last365HeatmapProvider = FutureProvider.family<List<HeatDay>, int>((ref, activityId) async {
  final nowLocal = DateTime.now();
  final todayLocal = DateTime(nowLocal.year, nowLocal.month, nowLocal.day);
  final startLocal = todayLocal.subtract(const Duration(days: 364));
  final endLocalExclusive = todayLocal.add(const Duration(days: 1));
  return _computeHeatmap(ref, activityId, startLocal: startLocal, endLocalExclusive: endLocalExclusive);
});

/// 8 dernières semaines ~ 56 jours (mini heatmap)
final last8WeeksHeatmapProvider = FutureProvider.family<List<HeatDay>, int>((ref, activityId) async {
  final nowLocal = DateTime.now();
  final todayLocal = DateTime(nowLocal.year, nowLocal.month, nowLocal.day);
  final startLocal = todayLocal.subtract(const Duration(days: 55));
  final endLocalExclusive = todayLocal.add(const Duration(days: 1));
  return _computeHeatmap(ref, activityId, startLocal: startLocal, endLocalExclusive: endLocalExclusive);
});
