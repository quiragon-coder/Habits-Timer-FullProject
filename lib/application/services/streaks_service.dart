import 'package:collection/collection.dart';

/// Compute streaks (current and best) from a list of day->minutes entries.
/// A day counts if minutes >= minMinutes (default 1).
class StreaksResult {
  final int currentStreakDays;
  final int bestStreakDays;
  const StreaksResult(this.currentStreakDays, this.bestStreakDays);
}

class Streaks {
  static StreaksResult fromDailyMinutes(Map<DateTime, int> minutesByDay, {int minMinutes = 1}) {
    if (minutesByDay.isEmpty) return const StreaksResult(0, 0);

    // Normalize keys to date-only (UTC).
    final normalized = <DateTime, int>{};
    for (final e in minutesByDay.entries) {
      final d = DateTime.utc(e.key.year, e.key.month, e.key.day);
      normalized[d] = (normalized[d] ?? 0) + e.value;
    }

    // Sort ascending
    final days = normalized.keys.toList()..sort();
    if (days.isEmpty) return const StreaksResult(0, 0);

    int best = 0;
    int curr = 0;

    DateTime? prev;
    for (final d in days) {
      final hasWork = (normalized[d] ?? 0) >= minMinutes;
      if (!hasWork) {
        // reset; keep best
        best = best > curr ? best : curr;
        curr = 0;
        prev = d;
        continue;
      }
      if (prev == null) {
        curr = 1;
      } else {
        final expected = DateTime.utc(prev.year, prev.month, prev.day + 1);
        if (d == expected) {
          curr += 1;
        } else {
          // gap
          best = best > curr ? best : curr;
          curr = 1;
        }
      }
      prev = d;
    }
    best = best > curr ? best : curr;

    // Compute "current streak": go backwards from today and count contiguous days with activity.
    final today = DateTime.now().toUtc();
    final todayDay = DateTime.utc(today.year, today.month, today.day);
    int current = 0;
    for (int i = 0; i < 4000; i++) {
      final d = DateTime.utc(todayDay.year, todayDay.month, todayDay.day - i);
      final has = (normalized[d] ?? 0) >= minMinutes;
      if (has) {
        current += 1;
      } else {
        break;
      }
    }
    return StreaksResult(current, best);
  }
}
