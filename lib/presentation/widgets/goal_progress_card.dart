import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/providers/unified_providers.dart';
import '../../infrastructure/db/database.dart';
import '../pages/heatmap_overview_page.dart' show dailyTotalsProvider;

class GoalProgressCard extends ConsumerWidget {
  final int activityId;
  const GoalProgressCard({super.key, required this.activityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(goalDaoProvider.selectSingle(activityId));
    final now = DateTime.now();

    // Fenêtre jour & semaine (local)
    final dayStart = DateTime(now.year, now.month, now.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final weekStart =
    dayStart.subtract(Duration(days: dayStart.weekday % 7)); // lundi=1…dim=7 -> iso
    final weekEnd = weekStart.add(const Duration(days: 7));

    final dayTotals = ref.watch(dailyTotalsProvider((
    activityId: activityId,
    startLocal: dayStart,
    endLocal: dayEnd,
    )));
    final weekTotals = ref.watch(dailyTotalsProvider((
    activityId: activityId,
    startLocal: weekStart,
    endLocal: weekEnd,
    )));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: goalAsync.when(
          data: (goal) {
            if (goal == null) {
              return const Text("Aucun objectif défini.");
            }

            final minutesPerDay = goal.minutesPerDay ?? 0;
            final minutesPerWeek = goal.minutesPerWeek ?? 0;
            final daysPerWeek = goal.daysPerWeek ?? 0;

            final daySpent = dayTotals.value?[dayStart]?.inMinutes ?? 0;
            final weekSpentMinutes = weekTotals.value?.values
                .fold<int>(0, (a, d) => a + d.inMinutes) ??
                0;

            // Jours actifs dans la semaine (>= 10 min)
            final activeDays = (weekTotals.value ?? {})
                .entries
                .where((e) => e.value.inMinutes >= 10)
                .length;

            Widget row(String title, String value, bool achieved) {
              final color = achieved
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyMedium),
                  Text(value,
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: color)),
                ],
              );
            }

            final dayOk = minutesPerDay > 0 && daySpent >= minutesPerDay;
            final weekMinutesOk =
                minutesPerWeek > 0 && weekSpentMinutes >= minutesPerWeek;
            final weekDaysOk =
                daysPerWeek > 0 && activeDays >= daysPerWeek;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Objectifs',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (minutesPerDay > 0)
                  row('Jour',
                      '${(daySpent / 60).toStringAsFixed(1)} / ${(minutesPerDay / 60).toStringAsFixed(1)} h',
                      dayOk),
                if (minutesPerWeek > 0)
                  row('Semaine (heures)',
                      '${(weekSpentMinutes / 60).toStringAsFixed(1)} / ${(minutesPerWeek / 60).toStringAsFixed(1)} h',
                      weekMinutesOk),
                if (daysPerWeek > 0)
                  row('Semaine (jours actifs)',
                      '$activeDays / $daysPerWeek', weekDaysOk),
              ],
            );
          },
          loading: () => const SizedBox(
            height: 56,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('Erreur objectifs: $e'),
        ),
      ),
    );
  }
}

/// Petit helper sur GoalDao pour récupérer 1 goal (ou null)
extension on GoalDao {
  /// Stream -> value unique (ou null) pour une activité
  AsyncValue<Goal?> selectSingle(int activityId) {
    return watchByActivityId(activityId).map((list) => list.isEmpty ? null : list.first);
  }
}
