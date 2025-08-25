import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../application/providers/unified_providers.dart';
import '../../application/providers/nudge_settings_provider.dart';
import '../../application/services/notifications_service.dart';

/// Déclenche une replanification *une fois par jour* au premier écran ouvert
/// et met en cache la liste d'activités pour l'exécution WorkManager en arrière-plan.
class StartupRescheduler extends ConsumerStatefulWidget {
  const StartupRescheduler({super.key});

  @override
  ConsumerState<StartupRescheduler> createState() => _StartupReschedulerState();
}

class _StartupReschedulerState extends ConsumerState<StartupRescheduler> {
  static bool _doneThisSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeReschedule());
  }

  Future<void> _maybeReschedule() async {
    if (_doneThisSession) return;
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _todayKey();
    final already = prefs.getBool(todayKey) ?? false;
    final needs = prefs.getBool('flutter.needs_reschedule') ?? false;

    try {
      final db = ref.read(databaseProvider);
      final activities = await db.select(db.activities).get();
      final serial = activities.map((a) => {'id': a.id, 'name': a.name}).toList();
      await prefs.setString('activities_cache', jsonEncode(serial));
    } catch (_) {}

    if (!already || needs) {
      try {
        final settings = ref.read(nudgeSettingsProvider).value;
        if (settings != null && settings.enabled) {
          final db = ref.read(databaseProvider);
          final activities = await db.select(db.activities).get();
          final serial = activities.map((a) => {'id': a.id, 'name': a.name});

          // Daily
          if (settings.dailyEnabled) {
            for (final a in serial) {
              await NotificationsService.scheduleDailyForActivity(
                activityId: a['id'] as int,
                activityName: a['name'] as String,
                hour: settings.eveningHour,
              );
            }
          }
          // Weekly (dimanche)
          if (settings.weeklyEnabled) {
            await NotificationsService.scheduleWeeklyForAll(serial, weekday: 7, hour: settings.eveningHour);
          }
          // Monthly (dernier jour)
          if (settings.monthlyEnabled) {
            await NotificationsService.scheduleMonthlyForAll(serial, hour: settings.eveningHour);
          }
        }
      } catch (_) {
        // Silencieux
      }
      await prefs.setBool(todayKey, true);
      await prefs.setBool('flutter.needs_reschedule', false);
      _doneThisSession = true;
    }
  }

  String _todayKey() {
    final now = DateTime.now();
    final y = now.year.toString();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return 'flutter.rescheduled_${y}${m}${d}';
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
