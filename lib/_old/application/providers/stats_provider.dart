import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../infrastructure/db/database.dart';
import 'providers.dart';
import '../services/time_utils.dart';

class DayTotal {
  final DateTime day;
  final Duration duration;
  DayTotal(this.day, this.duration);
}

final last7DaysTotalsProvider = FutureProvider.family<List<DayTotal>, int>((ref, activityId) async {
  final sessionDao = ref.read(sessionDaoProvider);
  final pauseDao = ref.read(pauseDaoProvider);

  final now = DateTime.now().toUtc();
  final start7 = DateTime.utc(now.year, now.month, now.day).subtract(const Duration(days: 6));
  final end7 = start7.add(const Duration(days: 7));

  final sessions = await sessionDao.recentSessionsForActivity(activityId, limit: 400);
  final Map<DateTime, Duration> map = {};
  for (int i = 0; i < 7; i++) {
    final d = DateTime.utc(start7.year, start7.month, start7.day + i);
    map[d] = Duration.zero;
  }

  for (final s in sessions) {
    final pauses = await pauseDao.pausesForSession(s.id);
    final start = DateTime.fromMillisecondsSinceEpoch(s.startUtc * 1000, isUtc: true);
    final endSec = s.endUtc ?? (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000);
    final end = DateTime.fromMillisecondsSinceEpoch(endSec * 1000, isUtc: true);
    if (end.isBefore(start7) || start.isAfter(end7)) continue;
    for (int i = 0; i < 7; i++) {
      final dayStart = DateTime.utc(start7.year, start7.month, start7.day + i);
      final dayEnd = dayStart.add(const Duration(days: 1));
      final d = effectiveOverlapDuration(start, end, pauses, dayStart, dayEnd);
      map[dayStart] = map[dayStart]! + d;
    }
  }

  return [
    for (int i = 0; i < 7; i++)
      DayTotal(DateTime.utc(start7.year, start7.month, start7.day + i), map[DateTime.utc(start7.year, start7.month, start7.day + i)]!),
  ];
});
