// Unified providers: DB + DAOs + ActiveTimer
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../infrastructure/db/database.dart';
import '../services/timer_service.dart';

// Database
final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

// DAOs
final activityDaoProvider = Provider<ActivityDao>((ref) => ref.watch(databaseProvider).activityDao);
final sessionDaoProvider  = Provider<SessionDao>((ref) => ref.watch(databaseProvider).sessionDao);
final pauseDaoProvider    = Provider<PauseDao>((ref) => ref.watch(databaseProvider).pauseDao);
final goalDaoProvider     = Provider<GoalDao>((ref) => ref.watch(databaseProvider).goalDao);

// Active timer (per activity)
final activeTimerProvider = StateNotifierProvider.family<ActiveTimerNotifier, ActiveTimerState, int>(
  (ref, activityId) => ActiveTimerNotifier(ref, activityId),
);
