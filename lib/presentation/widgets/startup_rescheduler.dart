import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/services/notifications_service.dart';
import '../../application/providers/unified_providers.dart';

class StartupRescheduler extends ConsumerWidget {
  const StartupRescheduler({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    return FutureBuilder(
      future: () async {
        final activities = await db.select(db.activities).get();
        final list = activities.map((a) => {'id': a.id, 'name': a.name}).toList().cast<Map<String, dynamic>>();
        await NotificationsService.scheduleWeeklyForAll(list, weekday: 1, hour: 20); // Lundi 20h par défaut
        await NotificationsService.scheduleMonthlyForAll(list, hour: 20);
      }(),
      builder: (_, __) => const SizedBox.shrink(),
    );
  }
}
