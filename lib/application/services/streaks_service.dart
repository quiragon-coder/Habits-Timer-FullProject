class Streaks {
  final int currentStreakDays;
  final int bestStreakDays;
  const Streaks({required this.currentStreakDays, required this.bestStreakDays});

  static Streaks fromDailyMinutes(Map<DateTime, int> minutesByDayUtc) {
    if (minutesByDayUtc.isEmpty) return const Streaks(currentStreakDays: 0, bestStreakDays: 0);

    final days = minutesByDayUtc.keys.toList()..sort();
    int current = 0;
    int best = 0;

    DateTime? prev;
    for (final d in days) {
      final minutes = minutesByDayUtc[d] ?? 0;
      final hasWork = minutes > 0;

      if (prev == null) {
        current = hasWork ? 1 : 0;
        best = current;
        prev = d;
        continue;
      }

      final isNextDay = d.difference(prev).inDays == 1;
      if (isNextDay) {
        current = hasWork ? (current + 1) : 0;
      } else {
        // gap -> reset streak (counts this day if worked)
        current = hasWork ? 1 : 0;
      }
      if (current > best) best = current;
      prev = d;
    }

    return Streaks(currentStreakDays: current, bestStreakDays: best);
  }
}
