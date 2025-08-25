import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/providers/year_heatmap_provider.dart';
import '../../application/services/time_utils.dart';
import 'day_detail_page.dart';

class HeatmapOverviewPage extends ConsumerWidget {
  final int activityId;
  const HeatmapOverviewPage({super.key, required this.activityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final end = DateTime(today.year, today.month, today.day);
    final start = DateTime(end.year, end.month - 11, 1);

    final async = ref.watch(dailyTotalsWithPausesProvider((activityId: activityId, startLocal: start, endLocal: end)));
    return Scaffold(
      appBar: AppBar(title: const Text('Heatmap – 12 mois')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: async.when(
          data: (map) {
            final days = <DateTime>[];
            var d = DateTime(start.year, start.month, start.day);
            while (!d.isAfter(end)) { days.add(d); d = d.add(const Duration(days: 1)); }

            final values = days.map((d) => (map[d] ?? Duration.zero).inMinutes.toDouble()).toList()..sort();
            double quantile(double p) => values.isEmpty ? 0 : values[(p * (values.length - 1)).round()];
            final q25 = quantile(.25), q50 = quantile(.5), q75 = quantile(.75), qMax = values.isEmpty ? 0 : values.last;

            Color cell(double v, Color base) {
              if (v <= 0) return base.withOpacity(.08);
              if (qMax <= 0) return base.withOpacity(.12);
              if (v <= q25) return base.withOpacity(.25);
              if (v <= q50) return base.withOpacity(.45);
              if (v <= q75) return base.withOpacity(.65);
              return base.withOpacity(.9);
            }

            final base = Theme.of(context).colorScheme.primary;
            final columns = (days.length / 7).ceil();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int c = 0; c < columns; c++)
                          Column(
                            children: [
                              for (int r = 0; r < 7; r++)
                                Builder(builder: (_) {
                                  final idx = c * 7 + r;
                                  if (idx >= days.length) return const SizedBox(width: 14, height: 14);
                                  final day = days[idx];
                                  final val = (map[day] ?? Duration.zero).inMinutes.toDouble();
                                  return GestureDetector(
                                    onDoubleTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => DayDetailPage(
                                            activityId: activityId,
                                            day: day, // ✅ param correct (pas dayLocal)
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 14, height: 14,
                                      margin: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: cell(val, base),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  );
                                }),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('Moins', style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(width: 8),
                    for (final v in [0.0, .25, .5, .75, 1.0])
                      Container(width: 18, height: 10, margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(color: cell(qMax * v, base), borderRadius: BorderRadius.circular(3)),
                      ),
                    const SizedBox(width: 8),
                    Text('Plus', style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Erreur heatmap: $e'),
        ),
      ),
    );
  }
}
