import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'heatmap_provider.dart' show last365DaysHeatmapProvider;
import '../services/streaks_service.dart';

final currentStreakProvider = FutureProvider.family<int, int>((ref, activityId) async {
  final heat = await ref.watch(last365DaysHeatmapProvider(activityId).future);
  final map = <DateTime, int>{ for (final h in heat) DateTime.utc(h.day.year, h.day.month, h.day.day): h.minutes };
  final res = Streaks.fromDailyMinutes(map);
  return res.currentStreakDays;
});

final bestStreakProvider = FutureProvider.family<int, int>((ref, activityId) async {
  final heat = await ref.watch(last365DaysHeatmapProvider(activityId).future);
  final map = <DateTime, int>{ for (final h in heat) DateTime.utc(h.day.year, h.day.month, h.day.day): h.minutes };
  final res = Streaks.fromDailyMinutes(map);
  return res.bestStreakDays;
});
