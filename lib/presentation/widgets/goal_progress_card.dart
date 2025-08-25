import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/providers/unified_providers.dart';
import '../../application/providers/goals_select_provider.dart';
import '../../application/providers/periods_provider.dart';
import '../../application/providers/settings_provider.dart';
import '../../application/services/haptics_service.dart';
import '../../infrastructure/db/database.dart';
import '../pages/heatmap_overview_page.dart' show dailyTotalsProvider;

class GoalProgressCard extends ConsumerWidget {
  final int activityId;
  const GoalProgressCard({super.key, required this.activityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(goalSingleProvider(activityId));
    final weekNow = ref.watch(currentWeekStatsProvider(activityId));
    final settings = ref.watch(settingsProvider);

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    final todayTotals = ref.watch(dailyTotalsProvider((
      activityId: activityId,
      startLocal: todayStart,
      endLocal: todayEnd,
    )));

    final minutesToday = todayTotals.maybeWhen(
      data: (listOrMap) => _extractMinutesFromTotals(listOrMap),
      orElse: () => 0,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: goalAsync.when(
          data: (goal) {
            final int goalMinutesPerDay = (goal?.minutesPerDay ?? 0);
            final int goalMinutesPerWeek = (goal?.minutesPerWeek ?? 0);

            final haptics = HapticsService(enabled: settings.hapticsEnabled);
            if (goalMinutesPerDay > 0 && minutesToday >= goalMinutesPerDay) {
              // feu vert : objectif du jour atteint
              haptics.play();
            }

            final weekMinutes = weekNow.maybeWhen(
              data: (s) => s.duration.inMinutes,
              orElse: () => 0,
            );

            if (goalMinutesPerWeek > 0 && weekMinutes >= goalMinutesPerWeek) {
              haptics.play();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flag_outlined),
                    const SizedBox(width: 8),
                    Text('Objectifs', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 12),
                if (goalMinutesPerDay > 0) ...[
                  _ProgressLine(
                    label: 'Aujourd\'hui',
                    valueMinutes: minutesToday,
                    goalMinutes: goalMinutesPerDay,
                  ),
                  const SizedBox(height: 8),
                ],
                if (goalMinutesPerWeek > 0) ...[
                  _ProgressLine(
                    label: 'Cette semaine',
                    valueMinutes: weekMinutes,
                    goalMinutes: goalMinutesPerWeek,
                  ),
                  const SizedBox(height: 8),
                ],
                if (goal == null)
                  Text('Aucun objectif défini pour cette activité.', style: Theme.of(context).textTheme.bodySmall),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Erreur objectifs: $e'),
        ),
      ),
    );
  }
}

int _extractMinutesFromTotals(dynamic totals) {
  if (totals is Map) {
    int sum = 0;
    for (final v in totals.values) {
      if (v is Duration) sum += v.inMinutes;
      else if (v is int) sum += v;
    }
    return sum;
  }
  if (totals is List) {
    int sum = 0;
    for (final t in totals) {
      try {
        final dyn = t as dynamic;
        if (dyn.minutes is int) sum += dyn.minutes as int;
        else if (dyn.duration is Duration) sum += (dyn.duration as Duration).inMinutes;
        else if (dyn['minutes'] is int) sum += dyn['minutes'] as int;
        else if (dyn['duration'] is Duration) sum += (dyn['duration'] as Duration).inMinutes;
      } catch (_) {}
    }
    return sum;
  }
  return 0;
}

class _ProgressLine extends StatelessWidget {
  final String label;
  final int valueMinutes;
  final int goalMinutes;

  const _ProgressLine({required this.label, required this.valueMinutes, required this.goalMinutes});

  @override
  Widget build(BuildContext context) {
    final percent = goalMinutes <= 0 ? 0.0 : (valueMinutes / goalMinutes).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label),
            const Spacer(),
            Text('${(valueMinutes / 60).toStringAsFixed(1)}h / ${(goalMinutes / 60).toStringAsFixed(1)}h'),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(value: percent, minHeight: 8),
        ),
      ],
    );
  }
}
