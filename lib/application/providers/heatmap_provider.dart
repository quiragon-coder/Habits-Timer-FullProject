import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../presentation/pages/heatmap_overview_page.dart' show dailyTotalsProvider;

@immutable
class HeatDay {
  final DateTime day;   // local calendar day (00:00)
  final int minutes;
  const HeatDay({required this.day, required this.minutes});
}

List<HeatDay> _normalizeToHeatDays(dynamic totals) {
  final List<HeatDay> out = [];
  if (totals == null) return out;

  // Case 1: Map<DateTime, Duration> or Map<DateTime, int>
  if (totals is Map) {
    for (final entry in totals.entries) {
      final key = entry.key;
      final val = entry.value;
      if (key is DateTime) {
        final date = DateTime(key.year, key.month, key.day);
        int minutes = 0;
        if (val is Duration) {
          minutes = val.inMinutes;
        } else if (val is int) {
          minutes = val;
        }
        out.add(HeatDay(day: date, minutes: minutes));
      }
    }
    out.sort((a, b) => a.day.compareTo(b.day));
    return out;
  }

  // Case 2: List of models or maps
  if (totals is List) {
    for (final t in totals) {
      DateTime? d;
      int m = 0;
      try {
        // Access as model first
        final dynamic dyn = t;
        final dynamic maybeDate = (dyn.date ?? dyn.day ?? dyn['date'] ?? dyn['day']);
        if (maybeDate is DateTime) {
          d = DateTime(maybeDate.year, maybeDate.month, maybeDate.day);
        } else if (maybeDate is String) {
          d = DateTime.tryParse(maybeDate);
          if (d != null) d = DateTime(d.year, d.month, d.day);
        }
        final dynamic minutesField = (dyn.minutes ?? dyn['minutes']);
        final dynamic durationField = (dyn.duration ?? dyn['duration']);
        if (minutesField is int) {
          m = minutesField;
        } else if (durationField is Duration) {
          m = durationField.inMinutes;
        }
      } catch (_) {
        // ignore malformed row
      }
      if (d != null) {
        out.add(HeatDay(day: d, minutes: m));
      }
    }
    out.sort((a, b) => a.day.compareTo(b.day));
    return out;
  }

  // Fallback empty
  return out;
}

final last365DaysHeatmapProvider = FutureProvider.family<List<HeatDay>, int>((ref, activityId) async {
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final start = todayStart.subtract(const Duration(days: 364));
  final end = todayStart.add(const Duration(days: 1));

  final totals = await ref.watch(dailyTotalsProvider((
    activityId: activityId,
    startLocal: start,
    endLocal: end,
  )).future);

  final days = _normalizeToHeatDays(totals);
  // Keep only within [start, end)
  return days.where((e) => !e.day.isBefore(start) && e.day.isBefore(end)).toList();
});

final last8WeeksHeatmapProvider = FutureProvider.family<List<HeatDay>, int>((ref, activityId) async {
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final start = todayStart.subtract(const Duration(days: 55));
  final end = todayStart.add(const Duration(days: 1));

  final totals = await ref.watch(dailyTotalsProvider((
    activityId: activityId,
    startLocal: start,
    endLocal: end,
  )).future);

  final days = _normalizeToHeatDays(totals);
  return days.where((e) => !e.day.isBefore(start) && e.day.isBefore(end)).toList();
});

/// Backward-compat alias for existing widgets expecting this symbol.
final last365HeatmapProvider = last365DaysHeatmapProvider;
