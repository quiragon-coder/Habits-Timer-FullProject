class NotificationsService {
  static const int _monthlyBaseId = 120000;
  static const int _congratsOffset = 5000;

  static Future<void> showCongratsMonthly(int activityId, {String? activityName}) async {
    await init();
    final details = NotificationDetails(
      android: const AndroidNotificationDetails(
        'habits_congrats', 'Congrats',
        channelDescription: 'Celebration alerts',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
      ),
      iOS: const DarwinNotificationDetails(sound: 'congrats.wav'),
    );
    final title = 'Objectif mensuel atteint 🎉';
    final body = activityName == null ? 'Bravo, objectif atteint ce mois-ci !' : 'Bravo, objectif atteint pour $activityName !';
    await NotificationsService._plugin.show(_monthlyBaseId + activityId + _congratsOffset, title, body, details, payload: 'congrats:$activityId');
  }
}