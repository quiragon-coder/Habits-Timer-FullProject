import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/providers/unified_providers.dart';
import '../../application/providers/periods_provider.dart' as periods;
import '../../infrastructure/db/database.dart';
import '../pages/heatmap_overview_page.dart' show dailyTotalsProvider;
import '../../application/services/formatting.dart';
import '../../application/services/notifications_service.dart';
import '../../application/providers/monthly_goals_provider.dart';

/// Optionnel: fournissez une callback pour ouvrir la page "Détail du jour".
typedef OpenDayCallback = void Function(DateTime date);

final activityByIdProvider = StreamProvider.family<Activity?, int>((ref, id) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.activities)..where((a) => a.id.equals(id))).watch().map((rows) => rows.isEmpty ? null : rows.first);
});


class GoalProgressCard extends ConsumerWidget {
  final int activityId;
  final OpenDayCallback? onOpenDay;
  const GoalProgressCard({super.key, required this.activityId, this.onOpenDay});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(goalDaoProvider.selectSingle(activityId));
    final now = DateTime.now();
    final activityAsync = ref.watch(activityByIdProvider(activityId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: goalAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Erreur objectifs: $e'),
          data: (goal) {
            final activityName = activityAsync.value?.name;
            final int? _colorInt = activityAsync.value?.color;
            final Color accentColor = _colorInt != null ? Color(_colorInt) : Theme.of(context).colorScheme.primary;
            final monthlyGoalMinutes = ref.watch(monthlyGoalProvider(activityId)) ?? 0;
            if (goal == null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Objectifs', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Aucun objectif pour cette activité.'),
                ],
              );
            }

            // Providers for totals
            final todayStart = DateTime(now.year, now.month, now.day);
            final tomorrow = todayStart.add(const Duration(days: 1));
            final weekNowAsync = ref.watch(periods.currentWeekStatsProvider(activityId));
            final monthNowAsync = ref.watch(periods.currentMonthStatsProvider(activityId));
            final weekStart = _startOfWeekMonday(now);
            final weekEnd = weekStart.add(const Duration(days: 7));
            final weekDailyAsync = ref.watch(dailyTotalsProvider((
              activityId: activityId,
              startLocal: weekStart,
              endLocal: weekEnd,
            )));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Objectifs', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                _LegendLine(goal: goal),
                const SizedBox(height: 8),
                _SuccessBanner(activityId: activityId, goal: goal),
                const SizedBox(height: 12),

                // Today
                _DailyBlock(activityId: activityId, goalMinutes: goal.minutesPerDay, start: todayStart, end: tomorrow),

                // Week
                const SizedBox(height: 12),
                weekNowAsync.when(
                  data: (w) => _ProgressRow(
                    label: 'Semaine',
                    currentMinutes: w.duration.inMinutes,
                    goalMinutes: goal.minutesPerWeek ?? 0,
                  ),
                  loading: () => const _ShimmerRow(label: 'Semaine'),
                  error: (e, _) => Text('Erreur semaine: $e'),
                ),

                // Days per week (interactive)
                if (goal.daysPerWeek != null && goal.daysPerWeek! > 0) ...[
                  const SizedBox(height: 8),
                  weekDailyAsync.when(
                    data: (totals) {
                      final map = _asMapDateToMinutes(totals);
                      final active = <int>{};
                      map.forEach((date, minutes) {
                        if (minutes > 0) active.add(date.weekday);
                      });
                      final count = active.length;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Jours actifs / sem'),
                              const SizedBox(width: 8),
                              Text('$count / ${goal.daysPerWeek}', style: Theme.of(context).textTheme.labelLarge),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            children: [
                              for (var i = 1; i <= 7; i++)
                                _DayChip(
                                  letter: _weekdayLetter(i),
                                  active: active.contains(i),
                                  onTap: () {
                                    final date = weekStart.add(Duration(days: i - 1));
                                    final minutes = map[date] ?? 0;
                                    if (onOpenDay != null) {
                                      onOpenDay!(date);
                                    } else {
                                      // Fallback: petit aperçu du jour
                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: Text(_weekdayFull(i)),
                                          content: Text('Total: ${formatHours(minutes / 60.0)}'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                ),
                            ],
                          ),
                        ],
                      );
                    },
                    loading: () => const SizedBox(height: 24, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                    error: (e, _) => Text('Erreur jours actifs: $e'),
                  ),
                ],

                // Month
                const SizedBox(height: 12),
                if (goal.minutesPerMonth != null && goal.minutesPerMonth! > 0)
                  monthNowAsync.when(
                    data: (m) => _ProgressRow(
                      label: 'Mois',
                      currentMinutes: m.duration.inMinutes,
                      goalMinutes: goal.minutesPerMonth!,
                    ),
                    loading: () => const _ShimmerRow(label: 'Mois'),
                    error: (e, _) => Text('Erreur mois: $e'),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  DateTime _startOfWeekMonday(DateTime d) {
    final wd = d.weekday; // 1=Mon..7=Sun
    return DateTime(d.year, d.month, d.day).subtract(Duration(days: wd - 1));
  }

  static String _weekdayLetter(int i) => const ['L','M','M','J','V','S','D'][i - 1];
  static String _weekdayFull(int i) => const ['Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi','Dimanche'][i - 1];
}

class _LegendLine extends StatelessWidget {
  final Goal goal;
  const _LegendLine({required this.goal});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (goal.minutesPerDay != null && goal.minutesPerDay! > 0) {
      parts.add('${(goal.minutesPerDay! / 60).toStringAsFixed(1)} h/j');
    }
    if (goal.daysPerWeek != null && goal.daysPerWeek! > 0) {
      parts.add('${goal.daysPerWeek} j/sem');
    }
    if (goal.minutesPerWeek != null && goal.minutesPerWeek! > 0) {
      parts.add('${(goal.minutesPerWeek! / 60).toStringAsFixed(1)} h/sem');
    }
    if (goal.minutesPerMonth != null && goal.minutesPerMonth! > 0) {
      parts.add('${(goal.minutesPerMonth! / 60).toStringAsFixed(1)} h/mois');
    }
    if (parts.isEmpty) return const SizedBox.shrink();
    return Text('🎯 ${parts.join(' • ')}', style: Theme.of(context).textTheme.bodyMedium);
  }
}

class _SuccessBanner extends ConsumerWidget {
  final int activityId;
  final Goal goal;
  const _SuccessBanner({required this.activityId, required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrow = todayStart.add(const Duration(days: 1));
    final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    final hasDaily = (goal.minutesPerDay ?? 0) > 0;
    final hasWeekly = (goal.minutesPerWeek ?? 0) > 0;
    final hasDays = (goal.daysPerWeek ?? 0) > 0;
    final hasMonthly = (goal.minutesPerMonth ?? 0) > 0;
    final hasAny = hasDaily || hasWeekly || hasDays || hasMonthly;
    if (!hasAny) return const SizedBox.shrink();

    final todayAsync = ref.watch(dailyTotalsProvider((activityId: activityId, startLocal: todayStart, endLocal: tomorrow)));
    final weekAsync = ref.watch(periods.currentWeekStatsProvider(activityId));
    final monthAsync = ref.watch(periods.currentMonthStatsProvider(activityId));
    final weekDailyAsync = ref.watch(dailyTotalsProvider((activityId: activityId, startLocal: weekStart, endLocal: weekEnd)));

    return todayAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (todayTotals) {
        final todayMinutes = _sumMinutes(todayTotals);
        return weekAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (w) {
            final weekMinutes = w.duration.inMinutes;
            return monthAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (m) {
                final monthMinutes = m.duration.inMinutes;
                return weekDailyAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (wd) {
                    var activeDays = 0;
                    final map = _asMapDateToMinutes(wd);
                    map.forEach((_, minutes) {
                      if (minutes > 0) activeDays++;
                    });

                    final okDaily = !hasDaily || todayMinutes >= (goal.minutesPerDay ?? 0);
                    final okWeekly = !hasWeekly || weekMinutes >= (goal.minutesPerWeek ?? 0);
                    final okDays = !hasDays || activeDays >= (goal.daysPerWeek ?? 0);
                    final okMonthly = !hasMonthly || monthMinutes >= (goal.minutesPerMonth ?? 0);
                    final allOk = okDaily && okWeekly && okDays && okMonthly;
                    if (!allOk) return const SizedBox.shrink();

                    final cs = Theme.of(context).colorScheme;
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.verified_rounded, color: cs.onPrimaryContainer),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Objectifs atteints 🎉',
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: cs.onPrimaryContainer),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _DayChip extends StatelessWidget {
  final String letter;
  final bool active;
  final VoidCallback onTap;
  const _DayChip({required this.letter, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = active ? cs.primaryContainer : cs.surfaceVariant;
    final fg = active ? cs.onPrimaryContainer : cs.onSurfaceVariant;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(letter, style: TextStyle(color: fg)),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final int currentMinutes;
  final int goalMinutes;
  const _ProgressRow({required this.label, required this.currentMinutes, required this.goalMinutes});

  @override
  Widget build(BuildContext context) {
    final hours = (currentMinutes / 60).toStringAsFixed(1);
    final goalH = (goalMinutes / 60).toStringAsFixed(1);
    final pct = goalMinutes > 0 ? (currentMinutes / goalMinutes).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label),
            const SizedBox(width: 8),
            Text('$hours / $goalH h', style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(value: pct),
        ),
      ],
    );
  }
}

class _ShimmerRow extends StatelessWidget {
  final String label;
  const _ShimmerRow({required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        const LinearProgressIndicator(),
      ],
    );
  }
}

class _DailyBlock extends ConsumerWidget {
  final int activityId;
  final int? goalMinutes;
  final DateTime start;
  final DateTime end;
  const _DailyBlock({required this.activityId, required this.goalMinutes, required this.start, required this.end});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (goalMinutes == null || goalMinutes == 0) return const SizedBox.shrink();
    final daily = ref.watch(dailyTotalsProvider((activityId: activityId, startLocal: start, endLocal: end)));
    return daily.when(
      data: (totals) {
        final minutes = _sumMinutes(totals);
        return _ProgressRow(label: 'Aujourd\'hui', currentMinutes: minutes, goalMinutes: goalMinutes!);
      },
      loading: () => const _ShimmerRow(label: 'Aujourd\'hui'),
      error: (e, _) => Text('Erreur jour: $e'),
    );
  }
}

// Helpers to handle dynamic types returned by dailyTotalsProvider
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

Map<DateTime, int> _asMapDateToMinutes(dynamic totals) {
  final map = <DateTime, int>{};
  if (totals is Map<DateTime, Duration>) {
    totals.forEach((k, v) => map[k] = v.inMinutes);
  } else if (totals is Map) {
    totals.forEach((k, v) {
      if (k is DateTime) {
        if (v is Duration) map[k] = v.inMinutes;
        else if (v is int) map[k] = v;
        else if (v is Map && v['minutes'] is int) map[k] = v['minutes'] as int;
      }
    });
  } else if (totals is List) {
    for (final item in totals) {
      final dyn = item as dynamic;
      final d = dyn.date ?? dyn['date'];
      final m = dyn.minutes ?? dyn['minutes'];
      if (d is DateTime && m is int) map[d] = m;
    }
  }
  return map;
}

/// Petit helper sur GoalDao pour récupérer 1 goal (ou null)
extension on GoalDao {
  AsyncValue<Goal?> selectSingle(int activityId) {
    return watchByActivityId(activityId).map((list) => list.isEmpty ? null : list.first);
  }
}
