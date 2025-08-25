import 'dart:convert';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notifications_service.dart';

const String kWMUniqueName = 'habits_rescheduler_periodic';
const String kWMTaskRescheduleAll = 'reschedule_all';

@pragma('vm:entry-point')
void habitsCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Re-planif en tête sans UI
      final prefs = await SharedPreferences.getInstance();

      final enabled = prefs.getBool('nudge_enabled') ?? true;
      if (!enabled) return Future.value(true);

      final dailyEnabled = prefs.getBool('nudge_daily_enabled') ?? true;
      final weeklyEnabled = prefs.getBool('nudge_weekly_enabled') ?? true;
      final monthlyEnabled = prefs.getBool('nudge_monthly_enabled') ?? true;
      final eveningHour = prefs.getInt('nudge_evening_hour') ?? 18;

      // Liste d'activités mise en cache par l'app (voir StartupRescheduler)
      final raw = prefs.getString('activities_cache');
      if (raw == null || raw.isEmpty) return Future.value(true);
      final List list = jsonDecode(raw) as List;
      final serial = list.cast<Map<String, dynamic>>();

      await NotificationsService.init();

      if (dailyEnabled) {
        for (final a in serial) {
          await NotificationsService.scheduleDailyForActivity(
            activityId: a['id'] as int, activityName: a['name'] as String, hour: eveningHour,
          );
        }
      }
      if (weeklyEnabled) {
        await NotificationsService.scheduleWeeklyForAll(serial, weekday: 7, hour: eveningHour);
      }
      if (monthlyEnabled) {
        await NotificationsService.scheduleMonthlyForAll(serial, hour: eveningHour);
      }

      return Future.value(true);
    } catch (_) {
      return Future.value(false);
    }
  });
}

Future<void> initBackgroundRescheduler() async {
  // Initialise WorkManager and register a daily periodic task.
  await Workmanager().initialize(habitsCallbackDispatcher, isInDebugMode: false);

  // Use 24h frequency. WorkManager doesn't guarantee exact time, but it will persist across reboot.
  await Workmanager().registerPeriodicTask(
    kWMUniqueName,
    kWMTaskRescheduleAll,
    frequency: const Duration(hours: 24),
    initialDelay: const Duration(hours: 6), // première exécution dans ~6h (ajuste si tu veux)
    existingWorkPolicy: ExistingWorkPolicy.keep,
    constraints: Constraints(
      networkType: NetworkType.not_required,
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresDeviceIdle: false,
      requiresStorageNotLow: false,
    ),
    backoffPolicy: BackoffPolicy.exponential,
    backoffPolicyDelay: const Duration(minutes: 10),
  );
}
