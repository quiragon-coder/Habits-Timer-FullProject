import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/providers/streaks_provider.dart';

class StreakBadge extends ConsumerWidget {
  final int activityId;
  const StreakBadge({super.key, required this.activityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(currentStreakProvider(activityId));
    final best = ref.watch(bestStreakProvider(activityId));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'Streak actuel',
          child: Chip(
            avatar: const Icon(Icons.local_fire_department, size: 18),
            label: Text('${current.value ?? 0} j'),
          ),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: 'Meilleur streak',
          child: Chip(
            avatar: const Icon(Icons.emoji_events, size: 18),
            label: Text('Best ${best.value ?? 0} j'),
          ),
        ),
      ],
    );
  }
}
