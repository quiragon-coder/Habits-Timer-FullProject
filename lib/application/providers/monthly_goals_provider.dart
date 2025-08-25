import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stocke les objectifs mensuels (minutes) dans SharedPreferences
/// Clés: 'monthly_goal_minutes_<activityId>'
class MonthlyGoalsNotifier extends StateNotifier<AsyncValue<Map<int, int>>> {
  MonthlyGoalsNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith('monthly_goal_minutes_'));
      final map = <int, int>{};
      for (final k in keys) {
        final idStr = k.substring('monthly_goal_minutes_'.length);
        final id = int.tryParse(idStr);
        final minutes = prefs.getInt(k);
        if (id != null && minutes != null && minutes > 0) {
          map[id] = minutes;
        }
      }
      state = AsyncValue.data(map);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setMinutes(int activityId, int? minutes) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'monthly_goal_minutes_$activityId';
    if (minutes == null || minutes <= 0) {
      await prefs.remove(key);
      final current = Map<int, int>.from(state.value ?? {});
      current.remove(activityId);
      state = AsyncValue.data(current);
      return;
    }
    await prefs.setInt(key, minutes);
    final current = Map<int, int>.from(state.value ?? {});
    current[activityId] = minutes;
    state = AsyncValue.data(current);
  }
}

/// Notifier global
final monthlyGoalsNotifierProvider =
    StateNotifierProvider<MonthlyGoalsNotifier, AsyncValue<Map<int, int>>>(
  (ref) => MonthlyGoalsNotifier(),
);

/// Sélecteur pour une activité
final monthlyGoalProvider = Provider.family<int?, int>((ref, activityId) {
  final data = ref.watch(monthlyGoalsNotifierProvider).value;
  return data?[activityId];
});
