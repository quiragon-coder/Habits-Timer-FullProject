# Notifications locales — Installation

## 1) Dépendances (`pubspec.yaml`)

```yaml
dependencies:
  flutter_local_notifications: ^17.1.2
  timezone: ^0.9.2
```

Puis:
```bash
flutter pub get
```

## 2) Android (Android 13+)

- Ajoute la permission dans `android/app/src/main/AndroidManifest.xml` :
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

- (Optionnel) Exact alarms si nécessaire (non requis ici).

## 3) iOS

- Dans `ios/Runner/Info.plist`, ajoute (si non présent) :
```xml
<key>UIBackgroundModes</key>
<array>
  <string>remote-notification</string>
</array>
<key>NSUserNotificationUsageDescription</key>
<string>Nous utilisons les notifications pour vous rappeler vos objectifs.</string>
```

- Au premier lancement, le code demande la permission via `NotificationsService.requestPermissions()`.

## 4) Initialisation

- Le service s’initialise à la demande. Tu peux appeler :
```dart
await NotificationsService.requestPermissions();
```

## 5) Planifier les rappels quotidiens

Ouvre **Réglages des rappels** (icône cloche) → bouton **Planifier les rappels quotidiens**.
Cela crée une notification quotidienne à l’heure choisie pour **chaque activité**.

## 6) Annuler la notification du jour lorsqu’un objectif est atteint

La badge “OK” sur une activité annule la notification du jour pour éviter un ping inutile.

```dart
NotificationsService.cancelDailyForActivity(activityId);
```

> Remarque : les rappels hebdomadaires et mensuels actuels sont des **bannières in-app**. On peut aussi planifier des notifications système pour ces fréquences si tu veux.
