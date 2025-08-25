import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../application/providers/unified_providers.dart';
import '../widgets/activity_tile.dart';
import './activity_detail_page.dart';
import './stats_trends_page.dart';
import '../pages/heatmap_overview_page.dart' show dailyTotalsProvider;
import '../../infrastructure/db/database.dart';
import 'package:drift/drift.dart' show Value;

import '../../application/services/notifications_service.dart';
import '../../application/providers/nudge_settings_provider.dart';
import '../widgets/nudge_settings_dialog.dart';
import '../widgets/startup_rescheduler.dart';

class ActivitiesHomePage extends ConsumerWidget {
  const ActivitiesHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activitiesStreamProvider);
    final settings = ref.watch(nudgeSettingsProvider).value ?? const NudgeSettings(
      enabled: true, dailyEnabled: true, weeklyEnabled: true, monthlyEnabled: true, eveningHour: 18, deficitMinutes: 30);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities'),
        actions: [
          IconButton(
            tooltip: 'Réglages rappels',
            onPressed: () => showDialog(context: context, builder: (_) => const NudgeSettingsDialog()),
            icon: const Icon(Icons.notifications_active_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final name = await _askName(context);
          if (name == null || name.trim().isEmpty) return;
          try {
            final db = ref.read(databaseProvider);
            final id = await db.into(db.activities).insert(ActivitiesCompanion.insert(
              name: name.trim(),
              emoji: const Value('⏱️'),
              color: const Value(0xFF607D8B),
              createdAtUtc: Value(DateTime.now().toUtc()),
            ));
            if (context.mounted) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ActivityDetailPage(activityId: id),
              ));
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Création impossible: $e")),
              );
            }
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Trigger auto-reschedule (zero-height widget)
          const StartupRescheduler(),
          Expanded(
            child: activities.when(
              data: (list) => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (_, i) {
                  if (i == 0 && settings.enabled && settings.dailyEnabled) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _NotificationsBannerForDaily(listLength: list.length, hour: settings.eveningHour),
                        const SizedBox(height: 12),
                        _ActivityRow(activity: list[i], settings: settings),
                      ],
                    );
                  }
                  return _ActivityRow(activity: list[i], settings: settings);
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: (activities.value?.isNotEmpty ?? false) ? activities.value!.length : 0,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends ConsumerWidget {
  final Activity activity;
  final NudgeSettings settings;
  const _ActivityRow({required this.activity, required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ActivityDetailPage(activityId: activity.id),
              )),
              child: ActivityTile(activity: activity),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: PopupMenuButton<String>(
                tooltip: 'Plus',
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'trends', child: Text('Tendances')),
                ],
                onSelected: (value) {
                  if (value == 'trends') {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => StatsTrendsPage(
                        activityId: activity.id,
                        activityName: activity.name,
                      ),
                    ));
                  }
                },
              ),
            ),
            Positioned(
              left: 8,
              top: 8,
              child: _DailySuccessBadge(activityId: activity.id, activityName: activity.name),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _WeeklyNudge(activityId: activity.id, activityName: activity.name),
        const SizedBox(height: 6),
        _MonthlyNudge(activityId: activity.id, activityName: activity.name),
      ],
    );
  }
}

class _NotificationsBannerForDaily extends StatelessWidget {
  final int listLength;
  final int hour;
  const _NotificationsBannerForDaily({required this.listLength, required this.hour});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_active, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(child: Text('Planifie les rappels quotidiens à ${hour}h pour tes activités.')),
          TextButton(
            onPressed: () async {
              final ok = await NotificationsService.requestPermissions();
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permission notifications refusée')));
                return;
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permissions OK — ouvre Réglages pour planifier.')));
              }
            },
            child: const Text('Activer'),
          ),
        ],
      ),
    );
  }
}

class _DailySuccessBadge extends ConsumerWidget {
  final int activityId;
  final String activityName;
  const _DailySuccessBadge({required this.activityId, required this.activityName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = start.add(const Duration(days: 1));

    final totalsAsync = ref.watch(dailyTotalsProvider((activityId: activityId, startLocal: start, endLocal: end)));

    return totalsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (totals) {
        final minutes = _sumMinutes(totals);
        final dao = ref.watch(goalDaoProvider);
        return StreamBuilder<List<Goal>>(
          stream: dao.watchByActivityId(activityId),
          builder: (context, snap) {
            if (!snap.hasData || snap.data!.isEmpty) return const SizedBox.shrink();
            final g = snap.data!.first;
            final daily = g.minutesPerDay ?? 0;
            if (daily > 0 && minutes >= daily) {
              NotificationsService.cancelDailyForActivity(activityId);
              final cs = Theme.of(context).colorScheme;
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  final hours = (minutes / 60).toStringAsFixed(1);
                  final goalH = (daily / 60).toStringAsFixed(1);
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Bravo pour "$activityName" !'),
                      content: Text('Aujourd’hui: $hours h / $goalH h'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
                      ],
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer, borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded, size: 14, color: cs.onPrimaryContainer),
                      const SizedBox(width: 4),
                      Text('OK', style: TextStyle(color: cs.onPrimaryContainer)),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}

class _WeeklyNudge extends ConsumerWidget {
  final int activityId;
  final String activityName;
  const _WeeklyNudge({required this.activityId, required this.activityName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }
}

class _MonthlyNudge extends ConsumerWidget {
  final int activityId;
  final String activityName;
  const _MonthlyNudge({required this.activityId, required this.activityName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }
}

// Helpers
int _sumMinutes(dynamic totals) {
  int minutes = 0;
  if (totals is Map) {
    for (final v in totals.values) {
      if (v is Duration) minutes += v.inMinutes;
      else if (v is int) minutes += v;
      else if (v is Map && v['minutes'] is int) minutes += v['minutes'] as int;
    }
  } else if (totals is List) {
    for (final t in totals) {
      final dyn = t as dynamic;
      if (dyn is int) minutes += dyn;
      else if (dyn is Duration) minutes += dyn.inMinutes;
      else if (dyn.minutes is int) minutes += dyn.minutes as int;
      else if (dyn.duration is Duration) minutes += (dyn.duration as Duration).inMinutes;
      else if (dyn['minutes'] is int) minutes += dyn['minutes'] as int;
    }
  } else if (totals is Duration) {
    minutes += totals.inMinutes;
  } else if (totals is int) {
    minutes += totals;
  }
  return minutes;
}

Future<String?> _askName(BuildContext context) async {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Nouvelle activité'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Nom'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Créer')),
      ],
    ),
  );
}
