import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/providers/stats_provider.dart';
import '../../application/providers/heatmap_provider.dart';
import '../../application/providers/periods_provider.dart';
import '../widgets/weekly_chart.dart';
import '../widgets/period_comparison_chart.dart';
import '../widgets/streak_badge.dart';
import '../widgets/export_sheet.dart';
import '../widgets/delta_chip.dart';

class StatsPage extends ConsumerWidget {
  final int activityId;
  final String activityName;
  const StatsPage({super.key, required this.activityId, required this.activityName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final last7 = ref.watch(last7DaysTotalsProvider(activityId));
    final heat365 = ref.watch(last365DaysHeatmapProvider(activityId));
    final wNow = ref.watch(currentWeekStatsProvider(activityId));
    final wPrev = ref.watch(previousWeekStatsProvider(activityId));
    final mNow = ref.watch(currentMonthStatsProvider(activityId));
    final mPrev = ref.watch(previousMonthStatsProvider(activityId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Stats — $activityName'),
        actions: [
          IconButton(
            tooltip: 'Exporter',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                showDragHandle: true,
                builder: (_) => ExportSheet(activityId: activityId, activityName: activityName),
              );
            },
            icon: const Icon(Icons.ios_share),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Align(alignment: Alignment.centerLeft, child: StreakBadge(activityId: activityId)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (wNow.hasValue && wPrev.hasValue)
                DeltaChip(
                  label: 'Semaine',
                  currentHours: wNow.value!.duration.inMinutes / 60.0,
                  previousHours: wPrev.value!.duration.inMinutes / 60.0,
                ),
              if (mNow.hasValue && mPrev.hasValue)
                DeltaChip(
                  label: 'Mois',
                  currentHours: mNow.value!.duration.inMinutes / 60.0,
                  previousHours: mPrev.value!.duration.inMinutes / 60.0,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: last7.when(
                data: (days) {
                  final hours = [for (final d in days) d.duration.inMinutes / 60.0];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Semaine (heures)', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      WeeklyBarChart(hours: hours),
                    ],
                  );
                },
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
                error: (e, st) => Text('Erreur: $e'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: heat365.when(
                data: (days) {
                  final byMonth = <String, double>{};
                  for (final d in days) {
                    final key = '${d.day.year}-${d.day.month.toString().padLeft(2, '0')}';
                    byMonth[key] = (byMonth[key] ?? 0) + (d.minutes / 60.0);
                  }
                  final keys = byMonth.keys.toList()..sort();
                  final values = [for (final k in keys) byMonth[k] ?? 0.0];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mois (heures)', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      PeriodComparisonChart(values: values, label: 'Mois'),
                    ],
                  );
                },
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
                error: (e, st) => Text('Erreur: $e'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
