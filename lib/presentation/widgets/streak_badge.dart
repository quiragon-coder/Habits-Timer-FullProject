import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/providers/streaks_provider.dart';

class StreakBadge extends ConsumerWidget {
  final int activityId;
  const StreakBadge({super.key, required this.activityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streaksAsync = ref.watch(streaksProvider(activityId));
    return streaksAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
      data: (s) {
        return Tooltip(
          message: 'Streak actuel: ${s.current}\nMeilleur: ${s.best}\nJours actifs (365j): ${s.activeDaysInYear}',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(.15),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.orange.withOpacity(.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                const SizedBox(width: 6),
                Text('${s.current} 🔥', style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      },
    );
  }
}
