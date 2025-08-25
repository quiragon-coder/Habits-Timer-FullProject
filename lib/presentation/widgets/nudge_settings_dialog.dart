import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/services/notifications_service.dart';
import '../../application/providers/unified_providers.dart';

class NudgeSettingsDialog extends ConsumerWidget {
  const NudgeSettingsDialog({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    int weekday = 1; // TODO: read from settings (1=Mon..7=Sun)
    int hourWeekly = 20;
    int hourMonthly = 20;
    return AlertDialog(
      title: const Text('Rappels'),
      content: const Text('Programmer rappels hebdo / mensuels'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        ElevatedButton(
          onPressed: () async {
            final activities = await db.select(db.activities).get();
            final list = activities.map((a) => {'id': a.id, 'name': a.name}).toList().cast<Map<String, dynamic>>();
            await NotificationsService.scheduleWeeklyForAll(list, weekday: weekday, hour: hourWeekly);
            await NotificationsService.scheduleMonthlyForAll(list, hour: hourMonthly);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Programmer'),
        ),
      ],
    );
  }
}
