import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../infrastructure/db/database.dart';
import '../../infrastructure/db/activity_dao_extras.dart';

import '../../application/providers/providers.dart';
import '../../application/providers/stats_provider.dart';
import '../../application/providers/goals_provider.dart';
import '../../application/providers/heatmap_provider.dart';
import '../../application/services/time_utils.dart';
import '../../application/services/timer_service.dart';
import '../widgets/timer_controls.dart';
import '../widgets/weekly_chart.dart';
import '../widgets/goal_card.dart';
import '../widgets/mini_heatmap_section.dart';

class ActivityDetailPage extends HookConsumerWidget {
  final int activityId;
  const ActivityDetailPage({super.key, required this.activityId});

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
    }
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔁 Titre réactif via DAO helpers (watchAll)
    final activitiesAsync = ref.watch(activitiesStreamProvider);
    final activity = activitiesAsync.maybeWhen(
      data: (list) => list.firstWhere(
        (a) => a.id == activityId,
        orElse: () => Activity(id: activityId, name: 'Activité', emoji: null, color: null, createdAtUtc: 0),
      ),
      orElse: () => Activity(id: activityId, name: 'Activité', emoji: null, color: null, createdAtUtc: 0),
    );

    // Timer state + actions
    final timerState = ref.watch(activeTimerProvider(activityId));
    final timer = ref.read(activeTimerProvider(activityId).notifier);
    final isRunning = timerState?.status == TimerStatus.running;

    // Ticker UI pendant que ça tourne
    useEffect(() {
      if (!isRunning) return null;
      final t = Timer.periodic(const Duration(seconds: 1), (_) {});
      return t.cancel;
    }, [isRunning]);

    final elapsed = timerState?.elapsed ?? Duration.zero;

    // Data providers
    final totals = ref.watch(totalsProvider(activityId));
    final last7 = ref.watch(last7DaysTotalsProvider(activityId));
    final history = ref.watch(recentHistoryProvider(activityId));
    final goalProgress = ref.watch(goalProgressProvider(activityId));
    // (heatmap provider est consommé par MiniHeatmapSection)

    final title = (activity.emoji?.isNotEmpty == true)
        ? '${activity.emoji} ${activity.name}'
        : activity.name;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // TIMER CARD
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      _formatDuration(elapsed),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(letterSpacing: 1.5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TimerControls(
                    isRunning: isRunning,
                    onPlay: () => timer.play(),
                    onPause: () => timer.pause(),
                    onStop: () => timer.stop(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          Text('Totaux', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          totals.when(
            data: (m) => Text(
              "Aujourd'hui: ${_formatDuration(m['today']!)}  •  Semaine: ${_formatDuration(m['week']!)}",
            ),
            loading: () => const Text('Calcul...'),
            error: (e, _) => Text('Erreur totaux: $e'),
          ),

          const SizedBox(height: 24),
          Text('Semaine (heures par jour)', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          last7.when(
            data: (list) {
              final hrs = list.map((e) => e.duration.inMinutes / 60.0).toList();
              return WeeklyBarChart(hours: hrs);
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Erreur graphique: $e'),
          ),

          const SizedBox(height: 24),
          // Mini heatmap (8 dernières semaines) avec double‑tap => overview
          MiniHeatmapSection(activityId: activityId),

          const SizedBox(height: 24),
          Text('Historique récent', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          history.when(
            data: (list) {
              // group by local day
              final Map<DateTime, List<dynamic>> groups = {};
              for (final s in list) {
                final startLocal = DateTime.fromMillisecondsSinceEpoch(s.startUtc * 1000, isUtc: true).toLocal();
                final key = DateTime(startLocal.year, startLocal.month, startLocal.day);
                groups.putIfAbsent(key, () => []).add(s);
              }
              final days = groups.keys.toList()..sort((a, b) => b.compareTo(a));
              return Column(
                children: [
                  for (final day in days) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(_friendlyDayLabel(day), style: Theme.of(context).textTheme.labelLarge),
                      ),
                    ),
                    ...groups[day]!.map((s) {
                      final startUtc = DateTime.fromMillisecondsSinceEpoch(s.startUtc * 1000, isUtc: true);
                      final endUtc = s.endUtc == null
                          ? null
                          : DateTime.fromMillisecondsSinceEpoch(s.endUtc! * 1000, isUtc: true);
                      final duration = effectiveOverlapDuration(
                        startUtc,
                        endUtc ?? DateTime.now().toUtc(),
                        s.pauses,
                        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
                        DateTime.now().toUtc().add(const Duration(days: 3650)),
                      );
                      final startLocal = startUtc.toLocal();
                      final endLocal = endUtc?.toLocal();
                      final line =
                          "${formatHm(startLocal)} → ${endLocal == null ? '...' : formatHm(endLocal)}  (${_formatDuration(duration)})";
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.history),
                        title: Text(line),
                      );
                    }),
                    const SizedBox(height: 8),
                  ]
                ],
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Erreur historique: $e'),
          ),

          const SizedBox(height: 24),
          goalProgress.when(
            data: (p) => GoalCard(progress: p),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Erreur objectifs: $e'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _friendlyDayLabel(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (day == today) return "Aujourd'hui";
    if (day == yesterday) return 'Hier';
    return "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
  }
}
