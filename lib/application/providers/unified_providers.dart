import 'package:drift/drift.dart' as drift;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../infrastructure/db/database.dart';
import '../../infrastructure/db/session_dao_extras.dart';
import '../../infrastructure/db/goal_dao_extras.dart';
import 'providers.dart';

// Re-export aliases for a single import point.
// (Directives must come before any declarations.)
export 'providers.dart' show databaseProvider, activityDaoProvider, sessionDaoProvider, pauseDaoProvider, activeTimerProvider;
export 'stats_provider.dart' show totalsProvider, last7DaysTotalsProvider, recentHistoryProvider;
export 'goals_provider.dart' show goalProgressProvider;
export 'heatmap_provider.dart' show last365HeatmapProvider, last8WeeksHeatmapProvider;

// GoalDao provider (some projects don't expose it in providers.dart)
final goalDaoProvider = Provider<GoalDao>((ref) => ref.watch(databaseProvider).goalDao);

// Derived simple streams
final activitiesStreamProvider = StreamProvider<List<Activity>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.activities)
        ..orderBy([(t) => drift.OrderingTerm(expression: t.id)]))
      .watch();
});

final sessionsStreamProvider = StreamProvider.family<List<Session>, int>((ref, activityId) {
  final dao = ref.watch(sessionDaoProvider);
  return dao.watchByActivity(activityId);
});

final goalsStreamProvider = StreamProvider.family<Goal?, int>((ref, activityId) {
  final dao = ref.watch(goalDaoProvider);
  return dao.watchByActivity(activityId);
});
