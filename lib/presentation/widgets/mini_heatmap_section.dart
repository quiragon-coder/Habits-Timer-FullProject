// Mini heatmap section (loading polished, fixed height, no floating tiny indicator).
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart' as drift;

import '../../application/providers/unified_providers.dart';
import '../../infrastructure/db/database.dart';
import '../pages/heatmap_overview_page.dart';

class DayValue {
  final DateTime day;
  final Duration duration;
  const DayValue(this.day, this.duration);
}

final _dailyTotalsProvider = FutureProvider.family<List<DayValue>, int>((ref, activityId) async {
  final db = ref.read(databaseProvider);
  final now = DateTime.now();
  final start = now.subtract(const Duration(days: 26 * 7));

  final sessions = await (db.select(db.sessions)
        ..where((s) => s.activityId.equals(activityId) & s.startUtc.isBiggerOrEqualValue(start.millisecondsSinceEpoch ~/ 1000))
        ..orderBy([(t) => drift.OrderingTerm.asc(t.startUtc)]))
      .get();

  final map = <DateTime, Duration>{};
  for (final s in sessions) {
    final startUtc = DateTime.fromMillisecondsSinceEpoch(s.startUtc * 1000, isUtc: true);
    final endUtc = s.endUtc == null
        ? DateTime.now().toUtc()
        : DateTime.fromMillisecondsSinceEpoch(s.endUtc! * 1000, isUtc: true);
    DateTime cursor = startUtc.toLocal();
    final endLocal = endUtc.toLocal();
    while (cursor.isBefore(endLocal)) {
      final dayKey = DateTime(cursor.year, cursor.month, cursor.day);
      final nextDay = DateTime(dayKey.year, dayKey.month, dayKey.day + 1);
      final segmentEnd = endLocal.isBefore(nextDay) ? endLocal : nextDay;
      final seg = segmentEnd.difference(cursor);
      map[dayKey] = (map[dayKey] ?? Duration.zero) + seg;
      cursor = segmentEnd;
    }
  }
  final days = <DayValue>[];
  for (int i = 0; i < 26 * 7; i++) {
    final d = DateTime(now.year, now.month, now.day).subtract(Duration(days: 26 * 7 - 1 - i));
    days.add(DayValue(d, map[DateTime(d.year, d.month, d.day)] ?? Duration.zero));
  }
  return days;
});

class MiniHeatmapSection extends ConsumerWidget {
  final int activityId;
  const MiniHeatmapSection({super.key, required this.activityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_dailyTotalsProvider(activityId));
    return async.when(
      data: (list) {
        final weekly = <int, List<DayValue>>{};
        for (int i = 0; i < list.length; i++) {
          final w = i ~/ 7;
          (weekly[w] ??= []).add(list[i]);
        }
        final values = list.map((e) => e.duration.inMinutes.toDouble()).toList()..sort();
        double q(double p) => values.isEmpty ? 0 : values[(p * (values.length - 1)).round()];
        final q25 = q(0.25), q50 = q(0.5), q75 = q(0.75), qMax = values.isEmpty ? 0 : values.last;

        Color cellColor(double v, Color base) {
          if (v <= 0) return base.withOpacity(.08);
          if (qMax <= 0) return base.withOpacity(.12);
          if (v <= q25) return base.withOpacity(.25);
          if (v <= q50) return base.withOpacity(.45);
          if (v <= q75) return base.withOpacity(.65);
          return base.withOpacity(.9);
        }
        final base = Theme.of(context).colorScheme.primary;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 7 * 16, // fixed compact height, prevents overflow
              child: Row(
                children: [
                  for (int w = 0; w < weekly.length; w++)
                    Expanded(
                      child: Column(
                        children: [
                          for (int r = 0; r < 7; r++)
                            Expanded(
                              child: Builder(builder: (_) {
                                final idx = w * 7 + r;
                                if (idx >= list.length) return const SizedBox.shrink();
                                final dv = list[idx];
                                return GestureDetector(
                                  onTap: () {
                                    final text = "${dv.day.year}-${dv.day.month.toString().padLeft(2,'0')}-${dv.day.day.toString().padLeft(2,'0')}"
                                                 " • ${(dv.duration.inMinutes/60).toStringAsFixed(2)} h";
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(text), duration: const Duration(seconds: 1)),
                                    );
                                  },
                                  onDoubleTap: () {
                                    Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => HeatmapOverviewPage(activityId: activityId),
                                    ));
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.all(1.5),
                                    decoration: BoxDecoration(
                                      color: cellColor(dv.duration.inMinutes.toDouble(), base),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                );
                              }),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Moins', style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(width: 8),
                for (final v in [0.0, .25, .5, .75, 1.0])
                  Container(
                    width: 18, height: 10, margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: cellColor(qMax * v, base),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                const SizedBox(width: 8),
                Text('Plus', style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
          ],
        );
      },
      // prevent tiny floating indicator in the middle
      loading: () => const SizedBox(),
      error: (e, _) => Text('Erreur heatmap: $e'),
    );
  }
}
