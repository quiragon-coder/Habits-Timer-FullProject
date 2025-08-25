import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../infrastructure/db/database.dart';
import 'providers.dart';
import 'stats_provider.dart' as stats;
import '../services/time_utils.dart';

class GoalProgress {
  final int minutesPerWeek;
  final int daysPerWeek;
  final Duration doneWeek;
  final int daysDone;

  GoalProgress({required this.minutesPerWeek, required this.daysPerWeek, required this.doneWeek, required this.daysDone});
}

final goalProgressProvider = FutureProvider.family<GoalProgress, int>((ref, activityId) async {
  final db = ref.read(databaseProvider);
  final goalDao = GoalDao(db);
  final goal = await goalDao.forActivity(activityId);
  final totals = await ref.read(stats.totalsProvider(activityId).future);

  // Days done (>= 10 min by default for MVP)
  final sessionDao = ref.read(sessionDaoProvider);
  final pauseDao = ref.read(pauseDaoProvider);
  final now = DateTime.now().toUtc();
  final weekStart = DateTime.utc(now.year, now.month, now.day).subtract(Duration(days: DateTime.utc(now.year, now.month, now.day).weekday - 1));
  int daysDone = 0;
  for (int i = 0; i < 7; i++) {
    final ds = DateTime.utc(weekStart.year, weekStart.month, weekStart.day + i);
    final de = ds.add(const Duration(days: 1));
    final sessions = await sessionDao.recentSessionsForActivity(activityId, limit: 400);
    Duration sum = Duration.zero;
    for (final s in sessions) {
      final pauses = await pauseDao.pausesForSession(s.id);
      final start = DateTime.fromMillisecondsSinceEpoch(s.startUtc * 1000, isUtc: true);
      final endSec = s.endUtc ?? (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000);
      final end = DateTime.fromMillisecondsSinceEpoch(endSec * 1000, isUtc: true);
      sum += effectiveOverlapDuration(start, end, pauses, ds, de);
    }
    if (sum >= const Duration(minutes: 10)) daysDone++;
  }

  return GoalProgress(
    minutesPerWeek: goal?.minutesPerWeek ?? 0,
    daysPerWeek: goal?.daysPerWeek ?? 0,
    doneWeek: (totals['week'] ?? Duration.zero),
    daysDone: daysDone,
  );
});
