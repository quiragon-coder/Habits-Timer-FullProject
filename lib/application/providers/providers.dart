import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../infrastructure/db/database.dart';
import '../services/timer_service.dart';
import '../services/time_utils.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  db.ensureDefaultActivity();
  return db;
});

final activityDaoProvider = Provider<ActivityDao>((ref) => ActivityDao(ref.read(databaseProvider)));
final sessionDaoProvider = Provider<SessionDao>((ref) => SessionDao(ref.read(databaseProvider)));
final pauseDaoProvider = Provider<PauseDao>((ref) => PauseDao(ref.read(databaseProvider)));

// Stream of activities
final activitiesStreamProvider = StreamProvider<List<Activity>>((ref) {
  final dao = ref.read(activityDaoProvider);
  return dao.watchAll();
});

// Active timer is per-activity
final activeTimerProvider = StateNotifierProvider.family<ActiveTimerNotifier, ActiveTimerState?, int>((ref, activityId) {
  return ActiveTimerNotifier(
    ref: ref,
    activityId: activityId,
    sessionDao: ref.read(sessionDaoProvider),
    pauseDao: ref.read(pauseDaoProvider),
  );
});

// Recent history with pauses for an activity
class SessionWithPauses {
  final int sessionId;
  final int activityId;
  final int startUtc;
  final int? endUtc;
  final List<Pause> pauses;
  SessionWithPauses({required this.sessionId, required this.activityId, required this.startUtc, required this.endUtc, required this.pauses});
}

final recentHistoryProvider = FutureProvider.family.autoDispose<List<SessionWithPauses>, int>((ref, activityId) async {
  final sessionDao = ref.read(sessionDaoProvider);
  final pauseDao = ref.read(pauseDaoProvider);
  final sessions = await sessionDao.recentSessionsForActivity(activityId, limit: 20);
  final out = <SessionWithPauses>[];
  for (final s in sessions) {
    final pauses = await pauseDao.pausesForSession(s.id);
    out.add(SessionWithPauses(sessionId: s.id, activityId: s.activityId, startUtc: s.startUtc, endUtc: s.endUtc, pauses: pauses));
  }
  return out;
});

// Totals for today and current ISO week
final totalsProvider = FutureProvider.family<Map<String, Duration>, int>((ref, activityId) async {
  final sessionDao = ref.read(sessionDaoProvider);
  final pauseDao = ref.read(pauseDaoProvider);

  final now = DateTime.now().toUtc();
  final dayStart = DateTime.utc(now.year, now.month, now.day);
  final dayEnd = dayStart.add(const Duration(days: 1));

  // ISO week boundaries
  final weekStart = dayStart.subtract(Duration(days: dayStart.weekday - 1)); // Monday
  final weekEnd = weekStart.add(const Duration(days: 7));

  final sessions = await sessionDao.recentSessionsForActivity(activityId, limit: 200);
  Duration sumDay = Duration.zero;
  Duration sumWeek = Duration.zero;

  for (final s in sessions) {
    final pauses = await pauseDao.pausesForSession(s.id);
    final start = DateTime.fromMillisecondsSinceEpoch(s.startUtc * 1000, isUtc: true);
    final endSec = s.endUtc ?? (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000);
    final end = DateTime.fromMillisecondsSinceEpoch(endSec * 1000, isUtc: true);

    sumDay += effectiveOverlapDuration(start, end, pauses, dayStart, dayEnd);
    sumWeek += effectiveOverlapDuration(start, end, pauses, weekStart, weekEnd);
  }

  return {'today': sumDay, 'week': sumWeek};
});
