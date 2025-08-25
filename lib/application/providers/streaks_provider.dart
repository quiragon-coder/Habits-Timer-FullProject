import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../infrastructure/db/database.dart';
import 'providers.dart';
import 'heatmap_provider.dart' show HeatDay, last365DaysHeatmapProvider, last8WeeksHeatmapProvider;
import '../services/streaks_service.dart';

/// Current streak for an activity (days with >= 1 min), using last-365 heatmap.
final currentStreakProvider = FutureProvider.family<int, int>((ref, activityId) async {
  final heat = await ref.watch(last365DaysHeatmapProvider(activityId).future);
  final map = <DateTime, int>{ for (final h in heat) DateTime.utc(h.day.year, h.day.month, h.day.day): h.minutes };
  final res = Streaks.fromDailyMinutes(map);
  return res.currentStreakDays;
});

/// Best streak for an activity (max over last-365 days).
final bestStreakProvider = FutureProvider.family<int, int>((ref, activityId) async {
  final heat = await ref.watch(last365DaysHeatmapProvider(activityId).future);
  final map = <DateTime, int>{ for (final h in heat) DateTime.utc(h.day.year, h.day.month, h.day.day): h.minutes };
  final res = Streaks.fromDailyMinutes(map);
  return res.bestStreakDays;
});
