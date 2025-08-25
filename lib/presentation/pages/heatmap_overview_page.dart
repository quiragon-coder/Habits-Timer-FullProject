import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart' as drift;

import '../../infrastructure/db/database.dart';
import '../../application/providers/unified_providers.dart';
import '../../application/services/time_utils.dart';
import 'day_detail_page.dart';

/// Heatmap des 12 derniers mois.
/// - Si [activityId] est null → heatmap **globale** (toutes activités).
/// - Sinon → heatmap d’une **activité** précise.
class HeatmapOverviewPage extends ConsumerWidget {
  final int? activityId;
  const HeatmapOverviewPage({super.key, this.activityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final end = DateTime(today.year, today.month, today.day);
    final start = DateTime(end.year, end.month - 11, 1);

    final async = ref.watch(dailyTotalsProvider((
    activityId: activityId,
    startLocal: start,
    endLocal: end,
    )));

    final title = activityId == null
        ? 'Heatmap – globale'
        : 'Heatmap – activité $activityId';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: async.when(
          data: (map) {
            // Liste continue de jours entre start..end
            final days = <DateTime>[];
            var d = DateTime(start.year, start.month, start.day);
            while (!d.isAfter(end)) {
              days.add(d);
              d = d.add(const Duration(days: 1));
            }

            // Quantiles en minutes (pour la coloration)
            final values = days
                .map((day) => (map[day] ?? Duration.zero).inMinutes.toDouble())
                .toList()
              ..sort();
            double quantile(double p) =>
                values.isEmpty ? 0 : values[(p * (values.length - 1)).round()];
            final q25 = quantile(.25),
                q50 = quantile(.5),
                q75 = quantile(.75),
                qMax = values.isEmpty ? 0 : values.last;

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
                                  if (idx >= days.length) {
                                    return const SizedBox(width: 14, height: 14);
                                  }
                                  final day = days[idx];
                                  final dur = map[day] ?? Duration.zero;
                                  final valMin = dur.inMinutes.toDouble();

                                  return GestureDetector(
                                    onTap: () {
                                      final label =
                                          "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
                                      final hrs =
                                      (dur.inMinutes / 60).toStringAsFixed(2);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("$label • $hrs h"),
                                          duration:
                                          const Duration(milliseconds: 900),
                                        ),
                                      );
                                    },
                                    onDoubleTap: () {
                                      if (activityId == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Sélectionne une activité pour voir le détail du jour.',
                                            ),
                                            duration: Duration(milliseconds: 900),
                                          ),
                                        );
                                        return;
                                      }
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => DayDetailPage(
                                            activityId: activityId!,
                                            day: day, // ✅ paramètre correct
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      margin: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: cell(valMin, base),
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
                    Text('Moins',
                        style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(width: 8),
                    for (final v in [0.0, .25, .5, .75, 1.0])
                      Container(
                        width: 18,
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: cell(qMax * v, base),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Text('Plus',
                        style: Theme.of(context).textTheme.labelMedium),
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

/// Provider : totaux journaliers (pauses soustraites) entre [startLocal..endLocal].
/// - Si [activityId] est null → agrège **toutes** les activités.
/// - Sinon → filtre par l’activité donnée.
final dailyTotalsProvider = FutureProvider.family<
    Map<DateTime, Duration>,
    ({int? activityId, DateTime startLocal, DateTime endLocal})>((ref, args) async {
  final db = ref.read(databaseProvider);

  // Fenêtre en UTC (requêtes)
  final startUtc = DateTime(args.startLocal.year, args.startLocal.month, args.startLocal.day).toUtc();
  final endUtc = DateTime(args.endLocal.year, args.endLocal.month, args.endLocal.day, 23, 59, 59)
      .toUtc()
      .add(const Duration(seconds: 1)); // exclusif

  final startSec = startUtc.millisecondsSinceEpoch ~/ 1000;
  final endSec = endUtc.millisecondsSinceEpoch ~/ 1000;

  final query = db.select(db.sessions)
    ..where((s) =>
    s.startUtc.isSmallerThanValue(endSec) &
    (s.endUtc.isNull() | s.endUtc!.isBiggerOrEqualValue(startSec)));

  if (args.activityId != null) {
    query.where((s) => s.activityId.equals(args.activityId!));
  }

  query.orderBy([(t) => drift.OrderingTerm.asc(t.startUtc)]);
  final sessions = await query.get();
  if (sessions.isEmpty) return <DateTime, Duration>{};

  // Pauses par session
  final ids = sessions.map((s) => s.id).toList();
  final pausesRows =
  await (db.select(db.pauses)..where((p) => p.sessionId.isIn(ids))).get();
  final pausesBySession = <int, List<Pause>>{};
  for (final p in pausesRows) {
    (pausesBySession[p.sessionId] ??= []).add(p);
  }

  // Accumulateur par jour local
  final totals = <DateTime, Duration>{};

  for (final s in sessions) {
    final sStartUtc =
    DateTime.fromMillisecondsSinceEpoch(s.startUtc * 1000, isUtc: true);
    final sEndUtc = (s.endUtc == null)
        ? DateTime.now().toUtc()
        : DateTime.fromMillisecondsSinceEpoch(s.endUtc! * 1000, isUtc: true);

    // Clip sur la fenêtre globale
    final clipStart = sStartUtc.isBefore(startUtc) ? startUtc : sStartUtc;
    final clipEnd = sEndUtc.isAfter(endUtc) ? endUtc : sEndUtc;
    if (!clipEnd.isAfter(clipStart)) continue;

    // Découpe par jour local
    DateTime cursorLocal = clipStart.toLocal();
    final endLocal = clipEnd.toLocal();

    while (cursorLocal.isBefore(endLocal)) {
      final dayKey = DateTime(cursorLocal.year, cursorLocal.month, cursorLocal.day);
      final dayStartLocal = DateTime(dayKey.year, dayKey.month, dayKey.day);
      final dayEndLocal = dayStartLocal.add(const Duration(days: 1));

      // Fenêtre du jour en UTC
      final dayStartUtc = dayStartLocal.toUtc();
      final dayEndUtc = dayEndLocal.toUtc();

      final eff = effectiveOverlapDuration(
        clipStart,
        clipEnd,
        pausesBySession[s.id] ?? const [],
        dayStartUtc,
        dayEndUtc,
      );

      if (eff.inSeconds > 0) {
        totals[dayKey] = (totals[dayKey] ?? Duration.zero) + eff;
      }

      cursorLocal = dayEndLocal;
    }
  }

  return totals;
});
