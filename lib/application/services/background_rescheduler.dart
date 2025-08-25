import 'package:workmanager/workmanager.dart';

class BackgroundRescheduler {
  static const String weeklyTask = 'habits_timer_weekly_reschedule';
  static const String monthlyTask = 'habits_timer_monthly_reschedule';

  static Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  }

  static Future<void> registerWeeklyReschedule() async {
    await Workmanager().registerPeriodicTask(
      weeklyTask,
      weeklyTask,
      frequency: const Duration(days: 7),
      existingPeriodicWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: Constraints(networkType: NetworkType.notRequired),
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 10),
    );
  }

  static Future<void> registerMonthlyReschedule() async {
    await Workmanager().registerPeriodicTask(
      monthlyTask,
      monthlyTask,
      frequency: const Duration(days: 28), // safe minimum across devices
      existingPeriodicWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: Constraints(networkType: NetworkType.notRequired),
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 10),
    );
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // TODO: trigger re-scheduling if needed.
    return Future.value(true);
  });
}
