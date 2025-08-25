import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/providers/monthly_goals_provider.dart';

String _fmtMinutes(int m) {
  final h = m ~/ 60;
  final min = m % 60;
  if (h > 0) return '${h}h ${min}m';
  return '${min}m';
}

class GoalProgressCard extends ConsumerWidget {
  final int activityId;
  const GoalProgressCard({super.key, required this.activityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(activityProgressProvider(activityId));
    return progressAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, st) => Text('Erreur: $e'),
      data: (p) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProgressRow(label: 'Jour', current: p.dayCurrent, goal: p.dayGoal),
            _ProgressRow(label: 'Semaine', current: p.weekCurrent, goal: p.weekGoal),
            _ProgressRow(label: 'Mois', current: p.monthCurrent, goal: p.monthGoal),
          ],
        );
      },
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final int current;
  final int goal;
  const _ProgressRow({required this.label, required this.current, required this.goal});

  @override
  Widget build(BuildContext context) {
    final pct = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              Text('${_fmtMinutes(current)} / ${_fmtMinutes(goal)}'),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: pct),
          ),
        ],
      ),
    );
  }
}
