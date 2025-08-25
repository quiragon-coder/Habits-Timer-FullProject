import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class NotificationsService {
  static final NotificationsService _instance = NotificationsService._internal();
  factory NotificationsService() => _instance;
  NotificationsService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _inited = false;

  Future<void> init() async {
    if (_inited) return;

    tzdata.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: android, iOS: darwin);
    await _plugin.initialize(settings);
    _inited = true;
  }

  Future<bool> requestPermissions() async {
    final ios = await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    final mac = await _plugin
        .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return (ios ?? true) && (mac ?? true);
  }

  Future<void> cancelAll() => _plugin.cancelAll();
  Future<void> cancelDailyForActivity(int activityId) async => _plugin.cancel(_idDaily(activityId));

  int _idDaily(int activityId) => 1000 + activityId;
  int _idWeekly(int activityId, int weekday) => 2000 + activityId * 10 + (weekday % 7);
  int _idMonthly(int activityId) => 3000 + activityId;

  const AndroidNotificationDetails _androidDetails = AndroidNotificationDetails(
    'habits_timer_reminders',
    'Reminders',
    channelDescription: 'Scheduled nudges for habits/goals',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );
  const DarwinNotificationDetails _iosDetails = DarwinNotificationDetails();

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          'habits_timer_reminders',
          'Reminders',
          channelDescription: 'Scheduled nudges for habits/goals',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      );

  Future<void> scheduleDailyForActivity({
    required int activityId,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await init();
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));

    await _plugin.zonedSchedule(
      _idDaily(activityId),
      title,
      body,
      scheduled,
      _details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: activityId.toString(),
    );
  }

  Future<void> scheduleWeeklyForAll({
    required int activityId,
    required String title,
    required String body,
    required List<int> weekdays, // 1=Mon..7=Sun
    required int hour,
    required int minute,
  }) async {
    await init();
    final now = tz.TZDateTime.now(tz.local);
    for (final w in weekdays) {
      final weekday = w.clamp(1, 7);
      var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      await _plugin.zonedSchedule(
        _idWeekly(activityId, weekday),
        title,
        body,
        scheduled,
        _details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: activityId.toString(),
      );
    }
  }

  Future<void> scheduleMonthlyForAll({
    required int activityId,
    required String title,
    required String body,
    required int dayOfMonth,
    required int hour,
    required int minute,
  }) async {
    await init();
    final now = tz.TZDateTime.now(tz.local);
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    final dom = dayOfMonth.clamp(1, lastDay);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, dom, hour, minute);
    if (scheduled.isBefore(now)) {
      final nextMonth = DateTime(now.year, now.month + 1, 1);
      final lastNext = DateTime(nextMonth.year, nextMonth.month + 1, 0).day;
      final dom2 = dayOfMonth.clamp(1, lastNext);
      scheduled = tz.TZDateTime(tz.local, nextMonth.year, nextMonth.month, dom2, hour, minute);
    }
    await _plugin.zonedSchedule(
      _idMonthly(activityId),
      title,
      body,
      scheduled,
      _details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      payload: activityId.toString(),
    );
  }
}
