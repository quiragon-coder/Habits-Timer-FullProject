import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/providers/nudge_settings_provider.dart';
import '../../application/services/notifications_service.dart';
import '../../application/providers/unified_providers.dart';

class NudgeSettingsDialog extends ConsumerWidget {
  const NudgeSettingsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(nudgeSettingsProvider);
    final activitiesAsync = ref.watch(activitiesStreamProvider);
    return AlertDialog(
      title: const Text('Réglages des rappels'),
      content: settingsAsync.when(
        loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
        error: (e, _) => Text('Erreur de chargement: $e'),
        data: (s) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Activer les rappels'),
                  value: s.enabled,
                  onChanged: (v) => ref.read(nudgeSettingsProvider.notifier).setEnabled(v),
                ),
                const Divider(height: 16),
                SwitchListTile(
                  title: const Text('Rappel quotidien'),
                  value: s.dailyEnabled,
                  onChanged: s.enabled ? (v) => ref.read(nudgeSettingsProvider.notifier).setDailyEnabled(v) : null,
                ),
                SwitchListTile(
                  title: const Text('Rappel hebdomadaire (système)'),
                  value: s.weeklyEnabled,
                  onChanged: s.enabled ? (v) => ref.read(nudgeSettingsProvider.notifier).setWeeklyEnabled(v) : null,
                ),
                SwitchListTile(
                  title: const Text('Rappel mensuel (système)'),
                  value: s.monthlyEnabled,
                  onChanged: s.enabled ? (v) => ref.read(nudgeSettingsProvider.notifier).setMonthlyEnabled(v) : null,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Expanded(child: Text('Heure des rappels')),
                    DropdownButton<int>(
                      value: s.eveningHour,
                      onChanged: s.enabled ? (v) { if (v != null) ref.read(nudgeSettingsProvider.notifier).setEveningHour(v); } : null,
                      items: [
                        for (int h = 16; h <= 22; h++)
                          DropdownMenuItem(value: h, child: Text('$h:00')),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Planifie des notifications système pour toutes tes activités.'),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      icon: const Icon(Icons.notifications_active),
                      label: const Text('Activer les notifications'),
                      onPressed: () async {
                        final ok = await NotificationsService.requestPermissions();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(ok ? 'Notifications activées' : 'Permission refusée'),
                          ));
                        }
                      },
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.schedule),
                      label: const Text('Planifier QUOTIDIEN'),
                      onPressed: !(s.enabled && s.dailyEnabled) ? null : () async {
                        final list = activitiesAsync.value ?? [];
                        final serial = list.map((a) => {'id': a.id, 'name': a.name});
                        await NotificationsService.scheduleWeeklyForAll(const [], hour: s.eveningHour); // no-op, avoid accidental weekly scheduling here
                        for (final a in serial) {
                          await NotificationsService.scheduleDailyForActivity(
                            activityId: a['id'] as int,
                            activityName: a['name'] as String,
                            hour: s.eveningHour,
                          );
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Rappels quotidiens planifiés'),
                          ));
                        }
                      },
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_view_week),
                      label: const Text('Planifier HEBDO (dimanche)'),
                      onPressed: !(s.enabled && s.weeklyEnabled) ? null : () async {
                        final list = activitiesAsync.value ?? [];
                        final serial = list.map((a) => {'id': a.id, 'name': a.name});
                        await NotificationsService.scheduleWeeklyForAll(serial, weekday: 7, hour: s.eveningHour);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Rappels hebdo planifiés (dimanche)'),
                          ));
                        }
                      },
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('Planifier MENSUEL (dernier jour)'),
                      onPressed: !(s.enabled && s.monthlyEnabled) ? null : () async {
                        final list = activitiesAsync.value ?? [];
                        final serial = list.map((a) => {'id': a.id, 'name': a.name});
                        await NotificationsService.scheduleMonthlyForAll(serial, hour: s.eveningHour);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Rappels mensuels planifiés (dernier jour)'),
                          ));
                        }
                      },
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.cancel),
                      label: const Text('Tout annuler'),
                      onPressed: () async {
                        await NotificationsService.cancelAll();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Toutes les notifications annulées'),
                          ));
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Astuce: le mensuel se reprogramme chaque fois que tu ouvres l’app (car la date de fin de mois varie).'),
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
      ],
    );
  }
}
